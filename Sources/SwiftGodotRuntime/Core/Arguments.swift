import Foundation

/// A type representing expected errors that can happen during parsing `Arguments` in the call-site
public enum ArgumentAccessError: Error, CustomStringConvertible {
    case indexOutOfBounds(index: Int, count: Int)
    case variantConversionError(VariantConversionError)
    case godotCallingConventionError
    case couldNotSurfaceObject

    public var description: String {
        switch self {
        case .indexOutOfBounds(let index, let count):
            return "Arguments accessed at index \(index), while total count is \(count)"
        case .variantConversionError(let error):
            return error.description
        case .godotCallingConventionError:
            return "The expected Godot calling convention was not met for RawArguments"
        case .couldNotSurfaceObject:
            return "Godot's object handle could not be surfaced to Swift"
        }
    }
}

/// A lightweight non-copyable storage for arguments marshalled to implementations where a sequence of `Variant`s is expected.
/// If you need a copy of `Variant`s inside, you can construct an array using `Array.init(_ args: borrowing Arguments)`
/// Elements can be accessed using subscript operator.
public struct Arguments: ~Copyable {
    @usableFromInline
    enum Contents {
        @usableFromInline
        struct UnsafeGodotArguments {
            @usableFromInline
            let pargs: UnsafePointer<UnsafeRawPointer?>

            @usableFromInline
            let count: Int

            var first: Variant?? {
                try? copy(at: 0)
            }

            /// Lazily reconstruct ``Variant?`` from `index`, throws an error if index is out of bounds
            @inline(__always)
            @inlinable
            func copy(at index: Int) throws(ArgumentAccessError) -> Variant? {
                if index >= 0 && index < count {
                    guard let ptr = pargs[index] else {
                        return nil
                    }

                    return Variant(
                        copying: ptr
                            .assumingMemoryBound(to: VariantContent.self)
                            .pointee
                    )
                } else {
                    throw .indexOutOfBounds(index: index, count: count)
                }
            }
        }
        /// User constructed and passed an array, reuse it
        /// It's also cheap to use in a case with no arguments, Swift array impl will just hold a null pointer inside.
        case array([Variant?])

        /// Godot passed internally managed buffer, retrieve values lazily
        case unsafeGodotArguments(UnsafeGodotArguments)
    }

    @usableFromInline
    let contents: Contents

    @inline(__always)
    @usableFromInline
    init(contents: Contents) {
        self.contents = contents
    }

    /// Arguments count
    public var count: Int {
        switch contents {
        case .array(let array):
            return array.count
        case .unsafeGodotArguments(let contents):
            return contents.count
        }
    }

    /// The first argument.
    /// This type is double optional like in `[Int?].first`
    /// `.some(.none)` means, that there is first argument and it's `nil`
    /// `.none` means that there is no arguments at all
    public var first: Variant?? {
        switch contents {
        case .unsafeGodotArguments(let contents):
            return try? contents.copy(at: 0)
        case .array(let array):
            return array.first
        }
    }

    @inline(__always)
    public init(from array: [Variant?]) {
        contents = .array(array)
    }

    @inline(__always)
    @usableFromInline
    init(pargs: UnsafePointer<UnsafeRawPointer?>?, argc: Int64) {
        if let pargs, argc > 0 {
            contents = .unsafeGodotArguments(.init(pargs: pargs, count: Int(argc)))
        } else {
            contents = .array([])
        }
    }

    /// Subscript operator to allow expressions like `arguments[2]`.
    /// This implementation will crash in case out-of-bounds access, just like `Swift.Array`.
    public subscript(_ index: Int) -> Variant? {
        get {
            switch contents {
            case .array(let array):
                return array[index]
            case .unsafeGodotArguments(let args):
                do {
                    return try args.copy(at: index)
                } catch {
                    fatalError(error.description)
                }
            }
        }
    }

    /// Returns ``Variant`` or `nil` argument at  `index`.
    ///
    /// Throws an error if `index` is out of bounds.
    public func argument(ofType: Variant?.Type = Variant?.self, at index: Int) throws(ArgumentAccessError) -> Variant? {
        switch contents {
        case .array(let array):
            if index >= 0 && index < array.count {
                return array[index]
            } else {
                throw .indexOutOfBounds(index: index, count: array.count)
            }
        case .unsafeGodotArguments(let unsafeGodotArgs):
            return try unsafeGodotArgs.copy(at: index)
        }
    }

    /// Returns ``Variant``  argument at  `index`.
    ///
    /// Throws an error if `index` is out of bounds or argument is `nil`.
    @inline(__always)
    public func argument(ofType: Variant.Type = Variant.self, at index: Int) throws(ArgumentAccessError) -> Variant {
        guard let variant = try argument(ofType: Variant?.self, at: index) else {
            throw .variantConversionError(
                .unexpectedNilContent(parsing: Variant.self)
            )
        }
        return variant
    }

    /// Returns `T` value wrapped argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant?` contains a type from which `T` cannot be unwrapped
    /// - `index` is out of bounds.
    @inline(__always)
    public func argument<T>(ofType type: T.Type = T.self, at index: Int) throws(ArgumentAccessError) -> T where T: VariantConvertible {
        let variant = try argument(ofType: Variant?.self, at: index)
        do {
            return try T.fromVariantOrThrow(variant)
        } catch {
            throw .variantConversionError(error)
        }
    }

    /// Returns `T?` value wrapped in argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant?` contains a type from which `T?` cannot be unwrapped
    /// - `index` is out of bounds.
    @inline(__always)
    @_disfavoredOverload
    public func argument<T>(ofType type: T?.Type = T?.self, at index: Int) throws(ArgumentAccessError) -> T? where T: VariantConvertible {
        let variant = try argument(ofType: Variant?.self, at: index)
        do {
            switch variant {
            case .some(let variant):
                return try T.fromVariantOrThrow(variant)
            case .none:
                return nil
            }
        } catch {
            throw .variantConversionError(error)
        }
    }

    /// Returns a `enum` or `OptionSet` value wrapped in `Variant` argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant` is `nil`
    /// - `Variant` wraps a type other than `T.RawValue`
    /// - `index` is out of bounds.
    /// - `T` can't be constructed from `rawValue` unwrapped from `Variant`
    @inline(__always)
    public func argument<T>(ofType type: T.Type = T.self, at index: Int) throws(ArgumentAccessError) -> T where T: RawRepresentable, T.RawValue: VariantConvertible {
        guard let variant = try argument(ofType: Variant?.self, at: index) else {
            throw .variantConversionError(.unexpectedNilContent(parsing: type))
        }
        do {
            return try T.fromVariantOrThrow(variant)
        } catch {
            throw .variantConversionError(error)
        }
    }
}

/// This helper class is used to access the arguments that Godot passes to functions
/// that you have exposed with @Callable - and provides direct access to the values in
/// there - it is part of Godot's fast path so the number of arguments and the types are
/// expected to be correct, and they will not be checked.
///
/// You should generally not use this in your code
public struct RawArguments: Sendable {
    public var args: UnsafePointer<UnsafeRawPointer?>
    public init (args: UnsafePointer<UnsafeRawPointer?>) {
        self.args = args
    }

    // Generic overload for any enum with Int raw values
    public func fetchArgument<T>(at: Int) throws(ArgumentAccessError) -> T where T: RawRepresentable, T.RawValue == Int {
        let raw = args[at]!.assumingMemoryBound(to: Int.self).pointee

        guard let value = T(rawValue: raw) else {
            preconditionFailure("Invalid raw value \(raw) for \(T.self)")
        }
        return value
    }

    // Generic overload for any enum with Int64 raw values
    public func fetchArgument<T>(at: Int) throws(ArgumentAccessError) -> T where T: RawRepresentable, T.RawValue == Int64 {
        let raw = args[at]!.assumingMemoryBound(to: Int.self).pointee

        guard let value = T(rawValue: Int64(raw)) else {
            preconditionFailure("Invalid raw value \(raw) for \(T.self)")
        }
        return value
    }

    public func fetchArgument<T: _GodotBridgeableBuiltin>(at index: Int) throws(ArgumentAccessError) -> T {
        try T._fromRawArgument(args[index]!)
    }

    public func fetchArgument<T: Wrapped>(at: Int) throws(ArgumentAccessError) -> T? {
        guard let value = args[at] else {
            return nil
        }
        let ptr = value.assumingMemoryBound(to: UnsafeMutableRawPointer.self).pointee
        return lookupLiveObject(handleAddress: ptr) as? T
    }

    // Like the above, but if it does not find, it fails
    public func fetchArgument<T: Wrapped>(at: Int) throws(ArgumentAccessError) -> T {
        guard let value = args[at] else {
            // There was no object pointer passed
            throw .godotCallingConventionError
        }
        let ptr = value.assumingMemoryBound(to: UnsafeMutableRawPointer.self).pointee
        if let lookup = lookupLiveObject(handleAddress: ptr) {
            if let value = lookup as? T {
                return value
            } else {
                throw ArgumentAccessError.variantConversionError(VariantConversionError.unexpectedContent(requestedType: T.self, actualContent: lookup.godotClassName.description))
            }
        } else {
            throw ArgumentAccessError.couldNotSurfaceObject
        }
    }

    public func fetchArgument(at: Int) throws(ArgumentAccessError) -> Variant {
        let i = args[at]!.assumingMemoryBound(to: VariantContent.self).pointee
        guard let v = Variant(copying: i) else {
            throw ArgumentAccessError.variantConversionError(
                .unexpectedNilContent(parsing: Variant.self)
            )
        }
        return v
    }

    public func fetchArgument(at: Int) throws(ArgumentAccessError)  -> Variant? {
        let i = args[at]!.assumingMemoryBound(to: VariantContent.self).pointee
        return Variant(copying: i)
    }
}

/// This is a helper tool used by the generated bridge functions, do not use directly
//
// For the variants here that end up getting deallocated by SwiftGodot on their
// deinit methods, we make a copy, and then prevent the deinit from deallocating
// by clearing the value
public struct RawReturnWriter {
    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Int) {
        target!.assumingMemoryBound(to: Int.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Int64) {
        target!.assumingMemoryBound(to: Int.self).pointee = Int(value)
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Int32) {
        target!.assumingMemoryBound(to: Int.self).pointee = Int(value)
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Int16) {
        target!.assumingMemoryBound(to: Int.self).pointee = Int(value)
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Int8) {
        target!.assumingMemoryBound(to: Int.self).pointee = Int(value)
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Double) {
        target!.assumingMemoryBound(to: Double.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Float) {
        target!.assumingMemoryBound(to: Double.self).pointee = Double(value)
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Vector2) {
        target!.assumingMemoryBound(to: Vector2.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Vector2i) {
        target!.assumingMemoryBound(to: Vector2i.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Vector3) {
        target!.assumingMemoryBound(to: Vector3.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Vector3i) {
        target!.assumingMemoryBound(to: Vector3i.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Vector4) {
        target!.assumingMemoryBound(to: Vector4.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Vector4i) {
        target!.assumingMemoryBound(to: Vector4i.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Plane) {
        target!.assumingMemoryBound(to: Plane.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Quaternion) {
        target!.assumingMemoryBound(to: Quaternion.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Rect2) {
        target!.assumingMemoryBound(to: Rect2.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Rect2i) {
        target!.assumingMemoryBound(to: Rect2i.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Transform2D) {
        target!.assumingMemoryBound(to: Transform2D.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: AABB) {
        target!.assumingMemoryBound(to: AABB.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Basis) {
        target!.assumingMemoryBound(to: Basis.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Transform3D) {
        target!.assumingMemoryBound(to: Transform3D.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Projection) {
        target!.assumingMemoryBound(to: Projection.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Color) {
        target!.assumingMemoryBound(to: Color.self).pointee = value
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: StringName) {
        var copy = StringName(from: value)
        target!.assumingMemoryBound(to: StringName.ContentType.self).pointee = copy.content
        copy.content = 0
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: String) {
        var content = GString.zero
        gi.string_new_with_utf8_chars(&content, value)
        target!.assumingMemoryBound(to: StringName.ContentType.self).pointee = content
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: NodePath) {
        var copy = NodePath(from: value)
        target!.assumingMemoryBound(to: NodePath.ContentType.self).pointee = copy.content
        copy.content = 0
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: RID) {
        target!.assumingMemoryBound(to: RID.ContentType.self).pointee = value.content
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Callable) {
        var copy = Callable(from: value)
        target!.assumingMemoryBound(to: Callable.ContentType.self).pointee = copy.content
        copy.content = Callable.zero
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Signal) {
        var copy = Signal(from: value)
        target!.assumingMemoryBound(to: Signal.ContentType.self).pointee = copy.content
        copy.content = Callable.zero
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Variant) {
        target!.assumingMemoryBound(to: VariantContent.self).pointee = value.makeContent()
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Variant?) {
        target!.assumingMemoryBound(to: VariantContent.self).pointee = value.makeContent()
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: VariantDictionary) {
        var copy = VariantDictionary(from: value)
        target!.assumingMemoryBound(to: VariantDictionary.ContentType.self).pointee = copy.content
        copy.content = VariantDictionary.zero
    }

    public static func writeResult<Key, Value>(
        _ target: UnsafeMutableRawPointer?,
        _ value: TypedDictionary<Key, Value>
    ) where Key: _GodotContainerTypingParameter, Value: _GodotContainerTypingParameter {
        writeResult(target, value.dictionary)
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: VariantArray) {
        var copy = VariantArray(from: value)
        target!.assumingMemoryBound(to: VariantArray.ContentType.self).pointee = copy.content
        copy.content = VariantArray.zero
    }

    public static func writeResult<Element>(
        _ target: UnsafeMutableRawPointer?,
        _ value: TypedArray<Element>
    ) where Element: _GodotContainerTypingParameter {
        writeResult(target, value.array)
    }

    public static func writeResult<T>(_ target: UnsafeMutableRawPointer?, _ value: T) where T: GodotBuiltinConvertible {
        writeResult(target, value.toGodotBuiltin())
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: PackedByteArray) {
        var copy = PackedByteArray(from: value)
        target!.assumingMemoryBound(to: PackedByteArray.ContentType.self).pointee = copy.content
        copy.content = PackedByteArray.zero
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: PackedInt32Array) {
        var copy = PackedInt32Array(from: value)
        target!.assumingMemoryBound(to: PackedInt32Array.ContentType.self).pointee = copy.content
        copy.content = PackedInt32Array.zero
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: PackedInt64Array) {
        var copy = PackedInt64Array(from: value)
        target!.assumingMemoryBound(to: PackedInt64Array.ContentType.self).pointee = copy.content
        copy.content = PackedInt64Array.zero
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: PackedFloat32Array) {
        var copy = PackedFloat32Array(from: value)
        target!.assumingMemoryBound(to: PackedFloat32Array.ContentType.self).pointee = copy.content
        copy.content = PackedFloat32Array.zero
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: PackedFloat64Array) {
        var copy = PackedFloat64Array(from: value)
        target!.assumingMemoryBound(to: PackedFloat64Array.ContentType.self).pointee = copy.content
        copy.content = PackedFloat64Array.zero
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: PackedStringArray) {
        var copy = PackedStringArray(from: value)
        target!.assumingMemoryBound(to: PackedStringArray.ContentType.self).pointee = copy.content
        copy.content = PackedStringArray.zero
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: PackedVector2Array) {
        var copy = PackedVector2Array(from: value)
        target!.assumingMemoryBound(to: PackedVector2Array.ContentType.self).pointee = copy.content
        copy.content = PackedVector2Array.zero
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: PackedVector3Array) {
        var copy = PackedVector3Array(from: value)
        target!.assumingMemoryBound(to: PackedVector3Array.ContentType.self).pointee = copy.content
        copy.content = PackedVector3Array.zero
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: PackedColorArray) {
        var copy = PackedColorArray(from: value)
        target!.assumingMemoryBound(to: PackedColorArray.ContentType.self).pointee = copy.content
        copy.content = PackedColorArray.zero
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: PackedVector4Array) {
        var copy = PackedVector4Array(from: value)
        target!.assumingMemoryBound(to: PackedVector4Array.ContentType.self).pointee = copy.content
        copy.content = PackedVector4Array.zero
    }

    public static func writeResult<T>(_ target: UnsafeMutableRawPointer?, _ value: T?) where T: _GodotBridgeableBuiltin {
        if let value {
            target!.assumingMemoryBound(to: VariantContent.self).pointee = value.toVariant().makeContent()
        } else {
            target!.assumingMemoryBound(to: VariantContent.self).pointee = .zero
        }
    }

    public static func writeResult<T>(_ target: UnsafeMutableRawPointer?, _ value: T?) where T: VariantConvertible {
        if let value {
            writeResult(target, value)
        } else {
            target!.assumingMemoryBound(to: VariantContent.self).pointee = .zero
        }
    }

    @_disfavoredOverload
    public static func writeResult<T>(_ target: UnsafeMutableRawPointer?, _ value: T) where T: VariantConvertible {
        target!.assumingMemoryBound(to: VariantContent.self).pointee = value.toVariant().makeContent()
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Void) {
        // No return
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ object: Wrapped?) {
        if let object, let handle = object.handle {
            if let rc = object as? RefCounted {
                rc.reference()
            }
            target!.assumingMemoryBound(to: UnsafeMutableRawPointer.self).pointee = handle
        } else {
            target!.assumingMemoryBound(to: UnsafeMutableRawPointer?.self).pointee = nil
        }
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: Bool) {
        target!.assumingMemoryBound(to: Int.self).pointee = value ? 1 : 0
    }

    public static func writeResult<T>(_ target: UnsafeMutableRawPointer?, _ value: T) where T: RawRepresentable, T.RawValue == Int {
        target!.assumingMemoryBound(to: Int.self).pointee = value.rawValue
    }

    public static func writeResult<T>(_ target: UnsafeMutableRawPointer?, _ value: T) where T: RawRepresentable, T.RawValue == Int64 {
        target!.assumingMemoryBound(to: Int.self).pointee = Int(value.rawValue)
    }

}

/// Execute `body` and return the result of executing it taking temporary storage keeping Godot managed `Variant`s stored in `pargs`.
@inline(__always)
@inlinable
func withArguments<T: ~Copyable>(pargs: UnsafePointer<UnsafeRawPointer?>?, argc: Int64, _ body: (borrowing Arguments) -> T) -> T {
    let arguments = Arguments(pargs: pargs, argc: argc)
    let result = body(arguments)
    return result
}

@inline(__always)
@inlinable
func withArguments<T: ~Copyable>(from array: [Variant?], _ body: (borrowing Arguments) -> T) -> T {
    body(Arguments(from: array))
}

public extension Array where Element == Variant? {
    init(_ args: borrowing Arguments) {
        switch args.contents {
        case .array(let array):
            self = array
        case .unsafeGodotArguments(let args):
            self = (0..<args.count).map { index in
                // OOB should never happen in this scenario
                try! args.copy(at: index)
            }
        }
    }
}

public extension VariantConvertible {
    /// Extract from `Arguments` increasing `index` after complete. Useful for `repeat each` iteration.
    static func fromArguments(_ arguments: borrowing Arguments, incrementingIndex index: inout Int) throws(ArgumentAccessError) -> Self {
        defer { index += 1 }
        return try arguments.argument(at: index)
    }
}

/// Internal API. Protocol covering types that have nullable semantics on Godot Side: Object-derived types and Variant.
/// For example when Godot says `Array[ObjectOrObjectSubclass]`, it actually means Array of `ObjectOrObjectSubclass?`
///
/// It's used for conditional extension of `Optional`.
///
/// It's implemented by
/// - `Object` (and its subclasses)
/// - `Variant`, because we differentiate between `Variant` with something inside and  Godot `Variant` containing `null` (which is simply Swift `nil`)
public protocol _GodotNullableBridgeable: _GodotBridgeable {
}

/// Internal API.
/// Allows `Variant?` and `ObjectOrObjectSubclass?` to be a generic parameter
/// - for `TypedArray` as `Element`
/// - for `TypedDictionary` as `Key` and `Value`
extension Optional: _GodotContainerTypingParameter where Wrapped: _GodotNullableBridgeable {
    /// Internal API. Required for implementation of `TypedArray`.
    public typealias _NonOptionalType = Wrapped

    /// Internal API.
    public static var _className: StringName {
        if Wrapped.self == Variant.self {
            ""
        } else {
            "\(Wrapped.self)"
        }
    }
}

// Allows static dispatch for processing `Variant?` `Object?` types during parsing callback ``Arguments`` or using them as arguments for invoking Godot functions.
extension Optional: _GodotBridgeable, VariantConvertible where Wrapped: _GodotNullableBridgeable {
    public typealias TypedArrayElement = Self

    @inline(__always)
    @inlinable
    public static func _argumentPropInfo(name: String) -> PropInfo {
        Wrapped._argumentPropInfo(name: name)
    }

    @inline(__always)
    @inlinable
    public static var _returnValuePropInfo: PropInfo {
        Wrapped._returnValuePropInfo
    }

    @inline(__always)
    @inlinable
    public static func _propInfo(name: String, hint: PropertyHint?, hintStr: String?, usage: PropertyUsageFlags?) -> PropInfo {
        Wrapped._propInfo(name: name, hint: hint, hintStr: hintStr, usage: usage)
    }

    @inline(__always)
    @inlinable
    public static var _variantType: Variant.GType {
        Wrapped._variantType
    }

    @inline(__always)
    @inlinable
    public static var _builtinOrClassName: String {
        Wrapped._builtinOrClassName
    }

    /// Variant?.some -> Variant?.some (never throws, see Variant.fromVariantOrThrow)
    /// Variant?.some -> Object?.some or throw
    @inline(__always)
    @inlinable
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        try Wrapped.fromVariantOrThrow(variant)
    }

    /// Variant?.none -> Object?.none
    /// Variant?.none -> Variant?.none
    @inline(__always)
    @inlinable
    public static func fromNilOrThrow() -> Self { nil }
}
