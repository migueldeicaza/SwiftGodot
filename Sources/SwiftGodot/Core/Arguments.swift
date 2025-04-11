/// A type representing expected errors that can happen during parsing `Arguments` in the call-site
public enum ArgumentAccessError: Error, CustomStringConvertible {
    case indexOutOfBounds(index: Int, count: Int)
    case mismatchingArrayElementType
    case mismatchingType(expected: String, actual: String)
    case invalidRawValue(value: String, typeName: String)
    
    public var description: String {
        switch self {
        case .indexOutOfBounds(let index, let count):
            return "Can't retrieve argument at index \(index), arguments count is \(count)"
        case .mismatchingType(let expected, let actual):
            return "Mismatching type, got `\(actual)` instead of `\(expected)`"
        case .mismatchingArrayElementType:
            return "Array got an element of unexpected type"
        case .invalidRawValue(let value, let typeName):
            return "`\(typeName)` doesn't have a value represented by `\(value)"
        }
    }
}

public struct ArgumentConversionError: Error {
}

/// A lightweight non-copyable storage for arguments marshalled to implementations where a sequence of `Variant`s is expected.
/// If you need a copy of `Variant`s inside, you can construct an array using `Array.init(_ args: borrowing Arguments)`
/// Elements can be accessed using subscript operator.
public struct Arguments: ~Copyable {
    enum Contents {
        struct UnsafeGodotArgs {
            let pargs: UnsafePointer<UnsafeRawPointer?>
            let count: Int
            
            var first: Variant?? {
                try? argument(at: 0)
            }
            
            /// Lazily reconstruct variant at `index`, throws an error if index is out ouf bounds
            func argument(at index: Int) throws -> Variant? {
                if index >= 0 && index < count {
                    guard let ptr = pargs[index] else {
                        return nil
                    }
                    
                    return Variant(copying: ptr.assumingMemoryBound(to: Variant.ContentType.self).pointee)
                } else {
                    throw ArgumentAccessError.indexOutOfBounds(index: index, count: count)
                }
            }
        }
        /// User constructed and passed an array, reuse it
        /// It's also cheap to use in a case with no arguments, Swift array impl will just hold a null pointer inside.
        case array([Variant?])
        
        /// Godot passed internally managed buffer, retrieve values lazily
        case unsafeGodotArgs(UnsafeGodotArgs)
    }
    
    let contents: Contents
    
    /// Arguments count
    public var count: Int {
        switch contents {
        case .array(let array):
            return array.count
        case .unsafeGodotArgs(let contents):
            return contents.count
        }
    }
    
    /// The first argument.
    /// This type is double optional like in `[Int?].first`
    /// `.some(.none)` means, that there is first argument and it's `nil`
    /// `.none` means that there is no arguments at all
    public var first: Variant?? {
        switch contents {
        case .unsafeGodotArgs(let contents):
            return try? contents.argument(at: 0)
        case .array(let array):
            return array.first
        }
    }
    
    init(from array: [Variant?]) {
        contents = .array(array)
    }
    
    init(pargs: UnsafePointer<UnsafeRawPointer?>?, argc: Int64) {
        if let pargs, argc > 0 {
            contents = .unsafeGodotArgs(.init(pargs: pargs, count: Int(argc)))
        } else {
            contents = .array([])
        }
    }
    
    init() {
        contents = .array([])
    }
    
    /// Subscript operator to allow expressions like `arguments[2]`.
    /// This implementation will crash in case out-of-bounds access, just like `Swift.Array`.
    public subscript(_ index: Int) -> Variant? {
        get {
            switch contents {
            case .array(let array):
                return array[index]
            case .unsafeGodotArgs(let args):
                do {
                    return try args.argument(at: index)
                } catch let error as ArgumentAccessError {
                    fatalError(error.description)
                } catch {
                    fatalError("\(error)")
                }
            }
        }
    }
    
    /// Returns `Variant` or `nil` argument at  `index`.
    ///
    /// Throws an error if `index` is out of bounds.
    /// This function is similar to `subscript[_ index: Int]`, but throws an error instead of crashing,
    /// It can be handy in the contexts where crash during OOB is inconvenient (parsing arguments of a call from Godot side, for example).
    public func argument(ofType: Variant?.Type = Variant?.self, at index: Int) throws -> Variant? {
        switch contents {
        case .array(let array):
            if index >= 0 && index < array.count {
                return array[index]
            } else {
                throw ArgumentAccessError.indexOutOfBounds(index: index, count: array.count)
            }
        case .unsafeGodotArgs(let unsafeGodotArgs):
            return try unsafeGodotArgs.argument(at: index)
        }
    }
    
    /// Returns `Variant`  argument at  `index`.
    ///
    /// Throws an error if `index` is out of bounds or argument is `nil`
    /// This function is similar to `subscript[_ index: Int]`, but throws an error instead of crashing,
    /// It can be handy in the contexts where crash during OOB is inconvenient (parsing arguments of a call from Godot side, for example).
    public func argument(ofType: Variant.Type = Variant.self, at index: Int) throws -> Variant {
        let variantOrNil: Variant?
        switch contents {
        case .array(let array):
            if index >= 0 && index < array.count {
                variantOrNil = array[index]
            } else {
                throw ArgumentAccessError.indexOutOfBounds(index: index, count: array.count)
            }
        case .unsafeGodotArgs(let unsafeGodotArgs):
            variantOrNil = try unsafeGodotArgs.argument(at: index)
        }
        
        guard let variant = variantOrNil else {
            throw ArgumentAccessError.mismatchingType(expected: "non-nil Variant", actual: "nil")
        }
        
        return variant
    }
    
    /// Returns `[T]` value wrapped in `Variant` argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant` is `nil`
    /// - `Variant` wraps a type other than `Array`
    /// - Any element of underlying Godot Array couldn't be converted to `T`
    /// - `index` is out of bounds.
    ///
    public func argument<T>(ofType type: [T].Type = [T].self, at index: Int) throws -> [T] where T: _ArgumentConvertible {
        let arg = try argument(ofType: Variant?.self, at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: "nil")
        }
        
        guard let array = GArray(variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: String(describing: variant.gtype))
        }
        
        var result: [T] = []
        result.reserveCapacity(array.count)
        for element in array {
            result.append(
                try T.fromArgumentVariant(element)
            )
        }
        return result
    }
    
    /// Returns `Variant` or `nil` argument at  `index`.
    ///
    /// Throws an error if `index` is out of bounds.
    /// This function is similar to `subscript[_ index: Int]`, but throws an error instead of crashing,
    /// It can be handy in the contexts where crash during OOB is inconvenient (parsing arguments of a call from Godot side, for example).
    @available(*, deprecated, message: "Old compatibility API, use argument(ofType:at:)")
    @_disfavoredOverload
    public func optionalVariantArgument(at index: Int) throws -> Variant? {
        switch contents {
        case .array(let array):
            if index >= 0 && index < array.count {
                return array[index]
            } else {
                throw ArgumentAccessError.indexOutOfBounds(index: index, count: array.count)
            }
        case .unsafeGodotArgs(let unsafeGodotArgs):
            return try unsafeGodotArgs.argument(at: index)
        }
    }
    
    @available(*, deprecated, message: "Old compatibility API, use argument(ofType:at:)")
    @_disfavoredOverload
    public func variantArgument(at index: Int) throws -> Variant {
        let variant: Variant?
        switch contents {
        case .array(let array):
            if index >= 0 && index < array.count {
                variant = array[index]
            } else {
                throw ArgumentAccessError.indexOutOfBounds(index: index, count: array.count)
            }
        case .unsafeGodotArgs(let unsafeGodotArgs):
            variant = try unsafeGodotArgs.argument(at: index)
        }
        
        guard let result = variant else {
            throw ArgumentAccessError.mismatchingType(expected: "Variant", actual: "Variant?")
        }
        
        return result
    }
    
    /// Returns `T?` value wrapped in `Variant` argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant` is not `nil` but wraps a type other than `T`
    /// - `index` is out of bounds.
    @available(*, deprecated, message: "Old compatibility API, use argument(ofType:at:)")
    @_disfavoredOverload
    public func optionalArgument<T: VariantStorable>(ofType type: T.Type = T.self, at index: Int) throws -> T? {
        let arg = try optionalVariantArgument(at: index)
        
        if let variant = arg {
            guard let result = T.unwrap(from: variant) else {
                throw ArgumentAccessError.mismatchingType(expected: "\(T.self)", actual: String(describing: variant.gtype))
            }
            
            return result
        } else {
            return nil
        }
    }
    
    @available(*, deprecated, renamed: "optionalArgument(ofType:at:)", message: "Fixing typo")
    @_disfavoredOverload
    public func optionlArgument<T: VariantStorable>(ofType type: T.Type = T.self, at index: Int) throws -> T? {
        try optionalArgument(ofType: type, at: index)
    }
    
    /// Returns `T?` value wrapped in `Variant` argument at `index`.  This method is a preferred overload for `T: Object`.
    ///
    /// Throws an error if:
    /// - `Variant` is not `nil` but wraps a type other than `T`
    /// - `index` is out of bounds.
    @available(*, deprecated, message: "Old compatibility API")
    @_disfavoredOverload
    public func optionalArgument<T: Object>(ofType type: T.Type = T.self, at index: Int) throws -> T? {
        let arg = try optionalVariantArgument(at: index)
        
        if let variant = arg {
            guard let result = T.unwrap(from: variant) else {
                throw ArgumentAccessError.mismatchingType(expected: "\(T.self)", actual: String(describing: variant.gtype))
            }
            
            return result
        } else {
            return nil
        }
    }
    
    @available(*, deprecated, renamed: "optionalArgument(ofType:at:)", message: "Fixing typo")
    public func optionlArgument<T: Object>(ofType type: T.Type = T.self, at index: Int) throws -> T? {
        try optionalArgument(ofType: type, at: index)
    }
    
    /// Returns `T` value wrapped in `Variant?` argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant?` contains a type from which `T` cannot be unwrapped
    /// - `index` is out of bounds.
    public func argument<T: _ArgumentConvertible>(ofType type: T.Type = T.self, at index: Int) throws -> T {
        return try T.fromArgumentVariant(
            try argument(at: index)
        )
    }
        
    /// Returns `T` value wrapped in `Variant` argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant` is `nil`
    /// - `Variant` contains a type other than `T`
    /// - `index` is out of bounds.
    @available(*, deprecated, message: "Old compatibility API, use argument(ofType:at:)")
    @_disfavoredOverload
    public func argument<T: VariantStorable>(ofType type: T.Type = T.self, at index: Int) throws -> T {
        let arg = try optionalVariantArgument(at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "\(T.self)", actual: "nil")
        }
                
        guard let result = T.unwrap(from: variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "\(T.self)", actual: String(describing: variant.gtype))
        }
        
        return result
    }
    
    /// Returns `T` value wrapped in `Variant` argument at `index`. This method is a preferred overload for `T: Object`.
    ///
    /// Throws an error if:
    /// - `Variant` is `nil`
    /// - `Variant` contains a type other than `T`
    /// - `index` is out of bounds.
    @available(*, deprecated, message: "Old compatibility API, use argument(ofType:at:)")
    @_disfavoredOverload
    public func argument<T: Object>(ofType type: T.Type = T.self, at index: Int) throws -> T {
        let arg = try optionalVariantArgument(at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "\(T.self)", actual: "nil")
        }
                
        guard let result = T.unwrap(from: variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "\(T.self)", actual: String(describing: variant.gtype))
        }
        
        return result
    }
    
    /// Returns a `enum` or `OptionSet` `T` value wrapped in `Variant` argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant` is `nil`
    /// - `Variant` wraps a type other than `Int`
    /// - `index` is out of bounds.
    /// - `T` can't be constucted from `rawValue` equal to wrapped `Int`
    public func rawRepresentableArgument<T: RawRepresentable>(ofType type: T.Type = T.self, at index: Int) throws -> T where T.RawValue: BinaryInteger {
        let arg = try argument(ofType: Variant?.self, at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "int", actual: "nil")
        }
        
        guard let rawValue = Int(variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "int", actual: String(describing: variant.gtype))
        }
        
        guard let result = T(rawValue: T.RawValue(rawValue)) else {
            throw ArgumentAccessError.invalidRawValue(value: "\(rawValue)", typeName: "\(T.self)")
        }
        
        return result
    }
    
    /// Returns `[T]` value wrapped in `Variant` argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant` is `nil`
    /// - `Variant` wraps a type other than `Int`
    /// - `index` is out of bounds.
    /// - `T` can't be constucted from `rawValue` equal to wrapped `Int`
    @_disfavoredOverload
    @available(*, deprecated, message: "Old compatibility API, use argument(ofType:at:)")
    public func arrayArgument<T: VariantStorable>(ofType type: T.Type = T.self, at index: Int) throws -> [T] {
        let arg = try argument(ofType: Variant?.self, at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: "nil")
        }
        
        guard let array = GArray(variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: String(describing: variant.gtype))
        }
        
        var result: [T] = []
        result.reserveCapacity(array.count)
        for element in array {
            guard let element else {
                throw ArgumentAccessError.mismatchingArrayElementType
            }
            
            guard let element = T.unwrap(from: element) else {
                throw ArgumentAccessError.mismatchingArrayElementType
            }
        
            result.append(element)
        }
        return result
    }
    
    /// Returns `[T]` value wrapped in `Variant` argument at `index`.  This method is a preferred overload for `T: Object`.
    ///
    /// Throws an error if:
    /// - `Variant` is `nil`
    /// - `Variant` wraps a type other than `Int`
    /// - `index` is out of bounds.
    /// - `T` can't be constucted from `rawValue` equal to wrapped `Int`
    @_disfavoredOverload
    @available(*, deprecated, message: "Old compatibility API, use argument(ofType:at:)")
    public func arrayArgument<T: Object>(ofType type: T.Type = T.self, at index: Int) throws -> [T] {
        let arg = try argument(ofType: Variant?.self, at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: "nil")
        }
        
        guard let array = GArray(variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: String(describing: variant.gtype))
        }
        
        var result: [T] = []
        result.reserveCapacity(array.count)
        for element in array {
            guard let element else {
                throw ArgumentAccessError.mismatchingArrayElementType
            }
            
            guard let element = T.unwrap(from: element) else {
                throw ArgumentAccessError.mismatchingArrayElementType
            }
        
            result.append(element)
        }
        return result
    }
    
    /// Returns `VariantCollection<T>` (aka `TypedArray` of builtin Godot class) value wrapped in `Variant` argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant` is `nil`
    /// - `Variant` wraps a type other than `GArray`
    /// - `index` is out of bounds.
    /// - `T` can't be constucted from `rawValue` equal to wrapped `Int`
    /// - Passed argument is `GArray`, but contains a type other than `T` or is `nil`
    public func variantCollectionArgument<T: VariantStorable>(ofType type: T.Type = T.self, at index: Int) throws -> VariantCollection<T> {
        let arg = try argument(ofType: Variant?.self, at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: "nil")
        }
        
        guard let array = GArray(variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: String(describing: variant.gtype))
        }
        
        guard let result = VariantCollection<T>(array) else {
            throw ArgumentAccessError.mismatchingArrayElementType
        }
        
        return result
    }
    
    /// Returns `ObjectCollection<T>` (aka `TypedArray` of `Object`-inherited classes) value wrapped in `Variant` argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant` is `nil`
    /// - `Variant` wraps a type other than `GArray`
    /// - `index` is out of bounds.
    /// - `T` can't be constucted from `rawValue` equal to wrapped `Int`
    /// - Passed argument is `GArray`, but contains a type other than `T`
    ///
    /// Note:
    /// Unlike `VariantCollection`, Godot allows `nil` elements in this case.
    public func objectCollectionArgument<T: Object>(ofType type: T.Type = T.self, at index: Int) throws -> ObjectCollection<T> {
        let arg = try argument(ofType: Variant?.self, at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: "nil")
        }
        
        guard let array = GArray(variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: String(describing: variant.gtype))
        }
        
        guard let result = ObjectCollection<T>(array) else {
            throw ArgumentAccessError.mismatchingArrayElementType
        }
        
        return result
    }
}

/// Execute `body` and return the result of executing it taking temporary storage keeping Godot managed `Variant`s stored in `pargs`.
func withArguments<T>(pargs: UnsafePointer<UnsafeRawPointer?>?, argc: Int64, _ body: (borrowing Arguments) -> T) -> T {
    let arguments = Arguments(pargs: pargs, argc: argc)
    let result = body(arguments)
    return result
}

func withArguments<T>(from array: [Variant?], _ body: (borrowing Arguments) -> T) -> T {
    body(Arguments(from: array))
}

public extension Array where Element == Variant? {
    init(_ args: borrowing Arguments) {
        switch args.contents {
        case .array(let array):
            self = array
        case .unsafeGodotArgs(let args):
            self = (0..<args.count).map { index in
                // OOB should never happen in this scenaro
                try! args.argument(at: index)
            }
        }
    }
}

/// Internal API. Needed for interaction with``Arguments`` in a generalised way. Allows to differentiate between `Variant`, `Variant?`, Builtin types, `Object` and `Object?` during static dispatch when used in the context of managing arguments marshaling to and from Godot.
///
/// Unlike ``VariantConvertible`` this type is used to treat weird quirks of interop of Godot and Swift Type system:
/// 1. Godot has `Variant` type, which has nullable semantics, but represented as `Variant` and `Variant?` on Swift side incorporating nullability into Swift type system
/// 2. Godot has `BuiltinClass` types, in the scope of interop they can never be passed as `nil`. If function takes `Array` - it's always an array.
/// 3. Godot has `Object`-derived  types types. They can be either `nil` or not when used as argument.
public protocol _ArgumentConvertible {
    /// Attempts to unwrap `Self` from `Variant?` throws a error if it failed
    static func fromArgumentVariant(_ variantOrNil: Variant?) throws(ArgumentConversionError) -> Self
    
    func toArgumentVariant() -> Variant?
}

public extension _ArgumentConvertible {
    /// Extract from `Arguments` increasing `index` after complete. Useful for `repeat each` iteration.
    static func fromArguments(_ arguments: borrowing Arguments, incrementingIndex index: inout Int) throws -> Self {
        defer { index += 1 }
        return try arguments.argument(at: index)
    }
}

public extension _GodotBridgeableBuiltin {
    /// Attempts to unwrap `Self` from `Variant?` throws a error if it failed. BuiltinType on Godot side are not nullable, so we just throw to gracefully exit this situation
    static func fromArgumentVariant(_ variantOrNil: Variant?) throws(ArgumentConversionError) -> Self {
        guard let variant = variantOrNil else {
            throw ArgumentConversionError()
        }
        
        guard let value = Self.fromVariant(variant) else {
            throw ArgumentConversionError()
        }
        
        return value
    }
    
    func toArgumentVariant() -> Variant? {
        toVariant()
    }
}

extension VariantCollection: _ArgumentConvertible where Element: _ArgumentConvertible {
    /// Attempts to unwrap `Self` from `Variant?` throws a error if it failed. BuiltinType on Godot side are not nullable, so we just throw to gracefully exit this situation
    public static func fromArgumentVariant(_ variantOrNil: Variant?) throws(ArgumentConversionError) -> Self {
        guard let variant = variantOrNil else {
            throw ArgumentConversionError()
        }
        
        guard let array = GArray.fromVariant(variant) else {
            throw ArgumentConversionError()
        }
        
        guard let typedArray = Self(array) else {
            throw ArgumentConversionError()
        }
        
        return typedArray
    }
    
    public func toArgumentVariant() -> Variant? {
        array.toVariant()
    }
}

extension ObjectCollection: _ArgumentConvertible where Element: _ArgumentConvertible {
    /// Attempts to unwrap `Self` from `Variant?` throws a error if it failed. BuiltinType on Godot side are not nullable, so we just throw to gracefully exit this situation.
    public static func fromArgumentVariant(_ variantOrNil: Variant?) throws(ArgumentConversionError) -> Self {
        guard let variant = variantOrNil else {
            throw ArgumentConversionError()
        }
        
        guard let array = GArray.fromVariant(variant) else {
            throw ArgumentConversionError()
        }
        
        guard let typedArray = Self(array) else {
            throw ArgumentConversionError()
        }
        
        return typedArray
    }
    
    public func toArgumentVariant() -> Variant? {
        array.toVariant()
    }
}

/// Internal API. Protocol covering types that have nullable semantics on Godot Side: Object-derived types and Variant.
/// It's used for conditional extension of Optional.
/// This is a workaround for Swift inability to have multiple conditional extensions for one type (Optional in our case).
public protocol _GodotOptionalBridgeable: VariantConvertible {
}


extension Object: _ArgumentConvertible, _GodotOptionalBridgeable {
    /// Attempts to unwrap `Self` from `Variant?` throws a error if it failed. Objects are technically nullable but this overload will be used in a context where non-optional `Object` was explicitly requested.
    public static func fromArgumentVariant(_ variantOrNil: Variant?) throws(ArgumentConversionError) -> Self {
        guard let variant = variantOrNil else {
            throw ArgumentConversionError()
        }
        
        guard let value = Self.fromVariant(variant) else {
            throw ArgumentConversionError()
        }
        
        return value
    }
    
    public func toArgumentVariant() -> Variant? {
        toVariant()
    }
}

extension Variant: _ArgumentConvertible, _GodotOptionalBridgeable {
    /// Attempts to unwrap `Variant` from `Variant?` throws if `nil`. `Variant` on Godot side do have nullable semantics but this overload is used in the context where non-optional `Variant` was explicitly requested
    public static func fromArgumentVariant(
        _ variantOrNil: Variant?
    ) throws(ArgumentConversionError) -> Variant {
        if let variant = variantOrNil {
            return variant
        } else {
            throw ArgumentConversionError()
        }
    }
    
    public func toArgumentVariant() -> Variant? {
        self
    }
}

// Allows static dispatch for processing `Variant?` `Object?` types during  parsing callback ``Arguments`` or using them as arguments for invoking Godot functions.
extension Optional: _ArgumentConvertible where Wrapped: _GodotOptionalBridgeable {
    /// Unwrap `Object?` or `Variant?` from `variant`. If it's `nil` - return `nil`. If it's not `nil`, and unwrapping failed, throw an error.
    public static func fromArgumentVariant(_ variantOrNil: Variant?) throws(ArgumentConversionError) -> Self {
        if let variant = variantOrNil {
            guard let value = Wrapped.fromVariant(variant) else {
                throw ArgumentConversionError()
            }
            
            return value
        } else {
            return nil // Expected
        }
    }
    
    /// Wrap `Object?` into `Variant?` or pass `Variant?` as is
    public func toArgumentVariant() -> Variant? {
        map { $0.toVariant() }
    }
}
