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
    public func optionlArgument<T: VariantStorable>(ofType type: T.Type = T.self, at index: Int) throws -> T? {
        let arg = try optionalVariantArgument(at: index)
        
        if let variant = arg {
            guard let result = T.unwrap(from: variant) else {
                throw ArgumentAccessError.mismatchingType(expected: "\(T.self)", actual: variant.gtype.debugDescription)
            }
            
            return result
        } else {
            return nil
        }
    }
    
    /// Returns `T?` value wrapped in `Variant` argument at `index`.  This method is a preferred overload for `T: Object`.
    ///
    /// Throws an error if:
    /// - `Variant` is not `nil` but wraps a type other than `T`
    /// - `index` is out of bounds.
    public func optionlArgument<T: Object>(ofType type: T.Type = T.self, at index: Int) throws -> T? {
        let arg = try optionalVariantArgument(at: index)
        
        if let variant = arg {
            guard let result = T.unwrap(from: variant) else {
                throw ArgumentAccessError.mismatchingType(expected: "\(T.self)", actual: variant.gtype.debugDescription)
            }
            
            return result
        } else {
            return nil
        }
    }
        
    /// Returns `T` value wrapped in `Variant` argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant` is `nil`
    /// - `Variant` contains a type other than `T`
    /// - `index` is out of bounds.
    public func argument<T: VariantStorable>(ofType type: T.Type = T.self, at index: Int) throws -> T {
        let arg = try optionalVariantArgument(at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "\(T.self)", actual: "nil")
        }
                
        guard let result = T.unwrap(from: variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "\(T.self)", actual: variant.gtype.debugDescription)
        }
        
        return result
    }
    
    /// Returns `T` value wrapped in `Variant` argument at `index`. This method is a preferred overload for `T: Object`.
    ///
    /// Throws an error if:
    /// - `Variant` is `nil`
    /// - `Variant` contains a type other than `T`
    /// - `index` is out of bounds.
    public func argument<T: Object>(ofType type: T.Type = T.self, at index: Int) throws -> T {
        let arg = try optionalVariantArgument(at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "\(T.self)", actual: "nil")
        }
                
        guard let result = T.unwrap(from: variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "\(T.self)", actual: variant.gtype.debugDescription)
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
        let arg = try optionalVariantArgument(at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "int", actual: "nil")
        }
        
        guard let rawValue = Int(variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "int", actual: variant.gtype.debugDescription)
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
    public func arrayArgument<T: VariantStorable>(ofType type: T.Type = T.self, at index: Int) throws -> [T] {
        let arg = try optionalVariantArgument(at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: "nil")
        }
        
        guard let array = GArray(variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: variant.gtype.debugDescription)
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
    public func arrayArgument<T: Object>(ofType type: T.Type = T.self, at index: Int) throws -> [T] {
        let arg = try optionalVariantArgument(at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: "nil")
        }
        
        guard let array = GArray(variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: variant.gtype.debugDescription)
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
        let arg = try optionalVariantArgument(at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: "nil")
        }
        
        guard let array = GArray(variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: variant.gtype.debugDescription)
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
        let arg = try optionalVariantArgument(at: index)
        
        guard let variant = arg else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: "nil")
        }
        
        guard let array = GArray(variant) else {
            throw ArgumentAccessError.mismatchingType(expected: "GArray", actual: variant.gtype.debugDescription)
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
