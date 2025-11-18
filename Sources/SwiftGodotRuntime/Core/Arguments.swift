import Foundation

/// A type representing expected errors that can happen during parsing `Arguments` in the call-site
public enum ArgumentAccessError: Error, CustomStringConvertible {
    case indexOutOfBounds(index: Int, count: Int)
    case variantConversionError(VariantConversionError)
    
    public var description: String {
        switch self {
        case .indexOutOfBounds(let index, let count):
            return "Arguments accessed at index \(index), while total count is \(count)"
        case .variantConversionError(let error):
            return error.description        
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
            
            /// Lazily reconstruct ``Variant?`` from `index`, throws an error if index is out ouf bounds
            @inline(__always)
            @inlinable
            func copy(_ variantType: Variant.Type = Variant.self, at index: Int) throws(ArgumentAccessError) -> Variant? {
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
            
            /// Lazily reconstruct ``FastVariant?`` at `index`, throws an error if index is out ouf bounds
            @inline(__always)
            @inlinable
            func copy(_ variantType: FastVariant.Type = FastVariant.self, at index: Int) throws(ArgumentAccessError) -> FastVariant? {
                if index >= 0 && index < count {
                    guard let ptr = pargs[index] else {
                        return nil
                    }
                    
                    return FastVariant(
                        copying: ptr
                            .assumingMemoryBound(to: VariantContent.self)
                            .pointee
                    )
                } else {
                    throw .indexOutOfBounds(index: index, count: count)
                }
            }
            
            /// Borrow ``FastVariant`` at `index` to perform some action on it and return some result.
            /// This function avoids making redundant copy of underlying `VariantContent`.
            @inline(__always)
            @inlinable
            func withBorrowedFastVariant<T>(
                at index: Int,
                use: (borrowing FastVariant?) -> Result<T, ArgumentAccessError>
            ) throws(ArgumentAccessError) -> T {
                if index >= 0 && index < count {
                    let result: Result<T, ArgumentAccessError>
                    
                    if let ptr = pargs[index] {
                        let fastVariant = FastVariant(
                            unsafelyBorrowing: ptr
                                .assumingMemoryBound(to: VariantContent.self)
                                .pointee
                        )
                                                
                        result = use(fastVariant)
                        
                        fastVariant?.unsafelyForget()
                    } else {
                        result = use(nil)
                    }
                    
                    switch result {
                    case .success(let success):
                        return success
                    case .failure(let error):
                        throw error
                    }
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
    @usableFromInline
    init(from array: [Variant?]) {
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
    /// This function is similar to `subscript[_ index: Int]`, but throws an error instead of crashing,
    /// It can be handy in the contexts where crash during OOB is inconvenient (parsing arguments of a call from Godot side, for example).    
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
    
    /// Borrow ``FastVariant`` at `index` to perform some action on it and return result.
    /// This function is the fastest one if you just need to extract something from the arguments without taking ownership over `Variant` copies.
    @inline(__always)
    @inlinable
    public func withBorrowedFastVariant<T>(
        at index: Int,
        use: (borrowing FastVariant?) -> Result<T, ArgumentAccessError>
    ) throws(ArgumentAccessError) -> T {
        switch contents {
        case .array(let array):
            if index >= 0 && index < array.count {
                let variant = array[index]
                // That's a weird case, but it's fine!
                // We'll just borrow content of `Variant` into `FastVariant`
                let result: Result<T, ArgumentAccessError>
                
                if let variant {
                    var fastVariant = FastVariant(unsafelyBorrowing: variant.content)
                    result = use(fastVariant)
                    
                    /// Prevent `FastVariant` from destroying content owned by Godot Variant
                    fastVariant?.content = .zero
                } else {
                    result = use(nil)
                }
                
                switch result {
                case .success(let success):
                    return success
                case .failure(let failure):
                    throw failure
                }
            } else {
                throw .indexOutOfBounds(index: index, count: array.count)
            }
        case .unsafeGodotArguments(let unsafeGodotArguments):
            return try unsafeGodotArguments.withBorrowedFastVariant(at: index, use: use)
        }
    }
    
    /// Returns ``Variant``  argument at  `index`.
    ///
    /// Throws an error if `index` is out of bounds or argument is `nil`
    /// This function is similar to `subscript[_ index: Int]`, but throws an error instead of crashing,
    /// It can be handy in the contexts where crash during OOB is inconvenient (parsing arguments of a call from Godot side, for example).
    @inline(__always)
    @inlinable
    public func argument(ofType: Variant.Type = Variant.self, at index: Int) throws(ArgumentAccessError) -> Variant {
        let variantOrNil: Variant?
        switch contents {
        case .array(let array):
            if index >= 0 && index < array.count {
                variantOrNil = array[index]
            } else {
                throw .indexOutOfBounds(index: index, count: array.count)
            }
        case .unsafeGodotArguments(let unsafeGodotArgs):
            variantOrNil = try unsafeGodotArgs.copy(Variant.self, at: index)
        }
        
        guard let variant = variantOrNil else {
            throw .variantConversionError(
                .unexpectedNilContent(parsing: Variant.self)
            )
        }
        
        return variant
    }
    
    /// Returns ``FastVariant``  argument at  `index`.
    ///
    /// Throws an error if `index` is out of bounds or argument is `nil`
    /// This function is similar to `subscript[_ index: Int]`, but throws an error instead of crashing,
    /// It can be handy in the contexts where crash during OOB is inconvenient (parsing arguments of a call from Godot side, for example).
    @inline(__always)
    @inlinable
    public func argument(ofType: FastVariant.Type = FastVariant.self, at index: Int) throws(ArgumentAccessError) -> FastVariant {
        let variantOrNil: FastVariant?
        switch contents {
        case .array(let array):
            if index >= 0 && index < array.count {
                variantOrNil = array[index]?.toFastVariant()
            } else {
                throw .indexOutOfBounds(index: index, count: array.count)
            }
        case .unsafeGodotArguments(let unsafeGodotArgs):
            variantOrNil = try unsafeGodotArgs.copy(FastVariant.self, at: index)
        }
        
        guard let variant = variantOrNil else {
            throw .variantConversionError(
                // We report Variant here to not bother with ~Copyable in the `ArgumentAccessError`. It's purely for logging.
                .unexpectedNilContent(parsing: Variant.self)
            )
        }
        
        return variant
    }
    
    /// Returns ``FastVariant`` or `nil` argument at  `index`.
    ///
    /// Throws an error if `index` is out of bounds.
    /// This function is similar to `subscript[_ index: Int]`, but throws an error instead of crashing,
    /// It can be handy in the contexts where crash during OOB is inconvenient (parsing arguments of a call from Godot side, for example).
    @inline(__always)
    @inlinable
    public func argument(ofType: FastVariant?.Type = FastVariant?.self, at index: Int) throws(ArgumentAccessError) -> FastVariant? {
        switch contents {
        case .array(let array):
            if index >= 0 && index < array.count {
                return array[index]?.toFastVariant()
            } else {
                throw .indexOutOfBounds(index: index, count: array.count)
            }
        case .unsafeGodotArguments(let unsafeGodotArgs):
            return try unsafeGodotArgs.copy(FastVariant.self, at: index)
        }
    }
        
    /// Returns `T` value wrapped argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant?` contains a type from which `T` cannot be unwrapped
    /// - `index` is out of bounds.
    @inline(__always)
    @inlinable
    public func argument<T>(ofType type: T.Type = T.self, at index: Int) throws(ArgumentAccessError) -> T where T: VariantConvertible {
        try withBorrowedFastVariant(at: index) { variantOrNil in
            extract(T.self, from: variantOrNil)
        }
    }
    
    @inline(__always)
    @inlinable
    func extract<T>(_ type: T.Type = T.self, from variantOrNil: borrowing FastVariant?) -> Result<T, ArgumentAccessError> where T: VariantConvertible {
        do {
            return .success(try T.fromFastVariantOrThrow(variantOrNil))
        } catch {
            return .failure(.variantConversionError(error))
        }
    }
    
    /// Returns `T?` value wrapped in argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant?` contains a type from which `T?` cannot be unwrapped
    /// - `index` is out of bounds.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func argument<T>(ofType type: T?.Type = T?.self, at index: Int) throws(ArgumentAccessError) -> T? where T: VariantConvertible {
        try withBorrowedFastVariant(at: index) { variantOrNil in
            extract(T?.self, from: variantOrNil)
        }
    }
    
    @inline(__always)
    @inlinable
    func extract<T>(_ type: T?.Type = T?.self, from variantOrNil: borrowing FastVariant?) -> Result<T?, ArgumentAccessError> where T: VariantConvertible {
        do {
            switch variantOrNil {
            case .some(let variant):
                return .success(try T.fromFastVariantOrThrow(variant))
            case .none:
                return .success(nil)
            }
        } catch {
            return .failure(.variantConversionError(error))
        }
    }
    
    /// Returns a `enum` or `OptionSet` value wrapped in `Variant` argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant` is `nil`
    /// - `Variant` wraps a type other than `T.RawValue`
    /// - `index` is out of bounds.
    /// - `T` can't be constucted from `rawValue` unwrapped from `Variant`
    @inline(__always)
    @inlinable
    public func argument<T>(ofType type: T.Type = T.self, at index: Int) throws(ArgumentAccessError) -> T where T: RawRepresentable, T.RawValue: VariantConvertible {
        let variantOrNil = try argument(ofType: FastVariant?.self, at: index)
        
        switch variantOrNil {
        case .some(let variant):
            do {
                return try T.fromFastVariantOrThrow(variant)
            } catch {
                throw .variantConversionError(error)
            }
        case .none:
            throw .variantConversionError(.unexpectedContent(parsing: type, from: variantOrNil))
        }
    }
}

/// This helper class is sued to access the arguments that Godot passes to functions
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

    public func fetchArgument(at: Int) -> Int {
        args[at]!.assumingMemoryBound(to: Int.self).pointee
    }

    // Generic overload for any enum with Int raw values
    public func fetchArgument<T>(at: Int) -> T where T: RawRepresentable, T.RawValue == Int {
        // Replace this with however you obtain the raw value
        let raw = args[at]!.assumingMemoryBound(to: Int.self).pointee

        guard let value = T(rawValue: raw) else {
            preconditionFailure("Invalid raw value \(raw) for \(T.self)")
        }
        return value
    }

    public func fetchArgument(at: Int) -> Int64 {
        Int64(args[at]!.assumingMemoryBound(to: Int.self).pointee)
    }

    public func fetchArgument(at: Int) -> Int32 {
        Int32(args[at]!.assumingMemoryBound(to: Int.self).pointee)
    }

    public func fetchArgument(at: Int) -> Int16 {
        Int16(args[at]!.assumingMemoryBound(to: Int.self).pointee)
    }

    public func fetchArgument(at: Int) -> Int8 {
        Int8(args[at]!.assumingMemoryBound(to: Int.self).pointee)
    }

    public func fetchArgument(at: Int) -> String {
        args[at]!.assumingMemoryBound(to: Int.self).pointee
        return GString.toString(pContent: args[at]!)
    }

    public func fetchArgument(at: Int) -> Double {
        args[at]!.assumingMemoryBound(to: Double.self).pointee
    }

    public func fetchArgument(at: Int) -> Float {
        Float(args[at]!.assumingMemoryBound(to: Double.self).pointee)
    }

    public func fetchArgument(at: Int) -> Vector2 {
        args[at]!.assumingMemoryBound(to: Vector2.self).pointee
    }

    public func fetchArgument(at: Int) -> Vector2i {
        args[at]!.assumingMemoryBound(to: Vector2i.self).pointee
    }

    public func fetchArgument(at: Int) -> Vector3 {
        args[at]!.assumingMemoryBound(to: Vector3.self).pointee
    }

    public func fetchArgument(at: Int) -> Vector3i {
        args[at]!.assumingMemoryBound(to: Vector3i.self).pointee
    }

    public func fetchArgument(at: Int) -> Vector4 {
        args[at]!.assumingMemoryBound(to: Vector4.self).pointee
    }

    public func fetchArgument(at: Int) -> Vector4i {
        args[at]!.assumingMemoryBound(to: Vector4i.self).pointee
    }

    public func fetchArgument(at: Int) -> Plane {
        args[at]!.assumingMemoryBound(to: Plane.self).pointee
    }

    public func fetchArgument(at: Int) -> Quaternion {
        args[at]!.assumingMemoryBound(to: Quaternion.self).pointee
    }

    public func fetchArgument(at: Int) -> Rect2 {
        args[at]!.assumingMemoryBound(to: Rect2.self).pointee
    }

    public func fetchArgument(at: Int) -> Rect2i {
        args[at]!.assumingMemoryBound(to: Rect2i.self).pointee
    }

    public func fetchArgument(at: Int) -> Transform2D {
        args[at]!.assumingMemoryBound(to: Transform2D.self).pointee
    }

    public func fetchArgument(at: Int) -> AABB {
        args[at]!.assumingMemoryBound(to: AABB.self).pointee
    }

    public func fetchArgument(at: Int) -> Basis {
        args[at]!.assumingMemoryBound(to: Basis.self).pointee
    }

    public func fetchArgument(at: Int) -> Transform3D {
        args[at]!.assumingMemoryBound(to: Transform3D.self).pointee
    }

    public func fetchArgument(at: Int) -> Projection {
        args[at]!.assumingMemoryBound(to: Projection.self).pointee
    }

    public func fetchArgument(at: Int) -> Color {
        args[at]!.assumingMemoryBound(to: Color.self).pointee
    }

    public func fetchArgument(at: Int) -> Bool {
        let i = args[at]!.assumingMemoryBound(to: Int.self).pointee
        return i != 0
    }

    public func fetchArgument<T: Wrapped>(at: Int) -> T? {
        guard let value = args[at] else {
            GD.print("There was no value at \(at)")
            return nil
        }
        print("I have \(value)")
        let ptr = value.assumingMemoryBound(to: UnsafeMutableRawPointer.self).pointee
        return lookupLiveObject(handleAddress: ptr) as? T
    }

    // Like the above, but if it does not find, it fails
    public func fetchArgument<T: Wrapped>(at: Int) -> T {
        guard let value = args[at] else {
            fatalError("There was no object pointer passed")
        }
        let ptr = value.assumingMemoryBound(to: UnsafeMutableRawPointer.self).pointee
        if let value = lookupLiveObject(handleAddress: ptr) as? T {
            return value
        }
        fatalError("Did not find an object of type \(T.self), you can try using Wrapped? instead")
    }

    public func fetchArgument(at: Int) -> StringName {
        let i = args[at]!.assumingMemoryBound(to: StringName.ContentType.self).pointee
        return StringName(content: i)
    }

    public func fetchArgument(at: Int) -> NodePath {
        let i = args[at]!.assumingMemoryBound(to: NodePath.ContentType.self).pointee
        return NodePath(content: i)
    }

    public func fetchArgument(at: Int) -> RID {
        let i = args[at]!.assumingMemoryBound(to: RID.ContentType.self).pointee
        return RID(content: i)
    }

    public func fetchArgument(at: Int) -> Callable {
        let i = args[at]!.assumingMemoryBound(to: Callable.ContentType.self).pointee
        return Callable(content: i)
    }

    public func fetchArgument(at: Int) -> Signal {
        let i = args[at]!.assumingMemoryBound(to: Signal.ContentType.self).pointee
        return Signal(content: i)
    }

    public func fetchArgument(at: Int) -> VariantDictionary {
        let i = args[at]!.assumingMemoryBound(to: VariantDictionary.ContentType.self).pointee
        return VariantDictionary(content: i)
    }

    public func fetchArgument(at: Int) -> VariantArray {
        let i = args[at]!.assumingMemoryBound(to: VariantArray.ContentType.self).pointee
        return VariantArray(content: i)
    }

    public func fetchArgument(at: Int) -> PackedByteArray {
        let i = args[at]!.assumingMemoryBound(to: PackedByteArray.ContentType.self).pointee
        return PackedByteArray(content: i)
    }

    public func fetchArgument(at: Int) -> PackedInt32Array {
        let i = args[at]!.assumingMemoryBound(to: PackedInt32Array.ContentType.self).pointee
        return PackedInt32Array(content: i)
    }

    public func fetchArgument(at: Int) -> PackedInt64Array {
        let i = args[at]!.assumingMemoryBound(to: PackedInt64Array.ContentType.self).pointee
        return PackedInt64Array(content: i)
    }

    public func fetchArgument(at: Int) -> PackedFloat32Array {
        let i = args[at]!.assumingMemoryBound(to: PackedFloat32Array.ContentType.self).pointee
        return PackedFloat32Array(content: i)
    }

    public func fetchArgument(at: Int) -> PackedFloat64Array {
        let i = args[at]!.assumingMemoryBound(to: PackedFloat64Array.ContentType.self).pointee
        return PackedFloat64Array(content: i)
    }

    public func fetchArgument(at: Int) -> PackedStringArray {
        let i = args[at]!.assumingMemoryBound(to: PackedStringArray.ContentType.self).pointee
        return PackedStringArray(content: i)
    }

    public func fetchArgument(at: Int) -> PackedVector2Array {
        let i = args[at]!.assumingMemoryBound(to: PackedVector2Array.ContentType.self).pointee
        return PackedVector2Array(content: i)
    }

    public func fetchArgument(at: Int) -> PackedColorArray {
        let i = args[at]!.assumingMemoryBound(to: PackedColorArray.ContentType.self).pointee
        return PackedColorArray(content: i)
    }
    
    public func fetchArgument(at: Int) -> PackedVector4Array {
        let i = args[at]!.assumingMemoryBound(to: PackedVector4Array.ContentType.self).pointee
        return PackedVector4Array(content: i)
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

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: VariantDictionary) {
        var copy = VariantDictionary(from: value)
        target!.assumingMemoryBound(to: VariantDictionary.ContentType.self).pointee = copy.content
        copy.content = VariantDictionary.zero
    }

    public static func writeResult(_ target: UnsafeMutableRawPointer?, _ value: VariantArray) {
        var copy = VariantArray(from: value)
        target!.assumingMemoryBound(to: VariantArray.ContentType.self).pointee = copy.content
        copy.content = VariantArray.zero
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
                // OOB should never happen in this scenaro
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
/// This is a workaround for Swift inability to have multiple conditional extensions for one type (`Optional` in our case).
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
///
/// ### Note
/// `Variant` and `ObjectOrObjectSubclass` themselves are _not_ `_GodotContainerTypingParameter`.
/// Godot doesn't guarantee that they are not null in the places where`_GodotContainerTypingParameter` is used, and neither do we.
extension Optional: _GodotContainerTypingParameter where Wrapped: _GodotNullableBridgeable {
    /// Internal API. Required for implementation of `TypedArray`.
    /// For `Optional` it's `Wrapped` type.
    public typealias _NonOptionalType = Wrapped
    
    /// Internal API.
    /// `class_name` for given `Optional` type as Godot requires it
    /// - for `ObjectOrObjectSubclass?` it's the literal name of the `ObjectOrObjectSubclass`
    /// - for `Variant?` it's an empty string
    public static var _className: StringName {
        if Wrapped.self == Variant.self {
            ""
        } else {
            // TODO: Make Godot macro generate this in a static context for every class, same for code generator
            "\(Wrapped.self)"
        }
    }
}


// Allows static dispatch for processing `Variant?` `Object?` types during  parsing callback ``Arguments`` or using them as arguments for invoking Godot functions.
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
        // TODO: investigate a case where Variant can contain an object, but fails to unwrap it not because it's wrong type, but because it was nullified. We need to distinguish such case and return nil instead of throwing. It's an opposite of case where the incompatible object is contained inside Variant - then we indeed need to throw.
        try Wrapped.fromVariantOrThrow(variant)
    }
    
    @inline(__always)
    @inlinable
    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Optional<Wrapped> {
        try Wrapped.fromFastVariantOrThrow(variant)
    }
        
    /// Variant?.none -> Object?.none
    /// Variant?.none -> Variant?.none
    @inline(__always)
    @inlinable
    public static func fromNilOrThrow() -> Self { nil }
}
