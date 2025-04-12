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
    enum Contents {
        struct UnsafeGodotArgs {
            let pargs: UnsafePointer<UnsafeRawPointer?>
            let count: Int
            
            var first: Variant?? {
                try? argument(at: 0)
            }
            
            /// Lazily reconstruct variant at `index`, throws an error if index is out ouf bounds
            func argument(at index: Int) throws(ArgumentAccessError) -> Variant? {
                if index >= 0 && index < count {
                    guard let ptr = pargs[index] else {
                        return nil
                    }
                    
                    return Variant(copying: ptr.assumingMemoryBound(to: Variant.ContentType.self).pointee)
                } else {
                    throw .indexOutOfBounds(index: index, count: count)
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
                } catch {
                    fatalError(error.description)
                }
            }
        }
    }
    
    /// Returns `Variant` or `nil` argument at  `index`.
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
        case .unsafeGodotArgs(let unsafeGodotArgs):
            return try unsafeGodotArgs.argument(at: index)
        }
    }
    
    /// Returns `Variant`  argument at  `index`.
    ///
    /// Throws an error if `index` is out of bounds or argument is `nil`
    /// This function is similar to `subscript[_ index: Int]`, but throws an error instead of crashing,
    /// It can be handy in the contexts where crash during OOB is inconvenient (parsing arguments of a call from Godot side, for example).
    public func argument(ofType: Variant.Type = Variant.self, at index: Int) throws(ArgumentAccessError) -> Variant {
        let variantOrNil: Variant?
        switch contents {
        case .array(let array):
            if index >= 0 && index < array.count {
                variantOrNil = array[index]
            } else {
                throw .indexOutOfBounds(index: index, count: array.count)
            }
        case .unsafeGodotArgs(let unsafeGodotArgs):
            variantOrNil = try unsafeGodotArgs.argument(at: index)
        }
        
        guard let variant = variantOrNil else {
            throw .variantConversionError(
                .unexpectedContent(parsing: Variant.self, from: nil)
            )
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
    public func argument<T>(ofType type: [T].Type = [T].self, at index: Int) throws(ArgumentAccessError) -> [T] where T: VariantConvertible {
        let variantOrNil = try argument(ofType: Variant?.self, at: index)
        do {
            let array = try GArray.fromVariantOrThrow(variantOrNil)
            var result: [T] = []
            result.reserveCapacity(array.count)
            for element in array {
                result.append(
                    try T.fromVariantOrThrow(element)
                )
            }
            return result
        } catch {
            throw .variantConversionError(error)
        }
    }
        
    /// Returns `T` value wrapped in `Variant?` argument at `index`.
    ///
    /// Throws an error if:
    /// - `Variant?` contains a type from which `T` cannot be unwrapped
    /// - `index` is out of bounds.
    public func argument<T: VariantConvertible>(ofType type: T.Type = T.self, at index: Int) throws(ArgumentAccessError) -> T {
        let variant = try argument(ofType: Variant?.self, at: index)
        
        do {
            if let variant {
                return try T.fromVariantOrThrow(variant)
            } else {
                return try T.fromVariantOrThrow(nil)
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
    /// - `T` can't be constucted from `rawValue` unwrapped from `Variant`
    public func argument<T>(ofType type: T.Type = T.self, at index: Int) throws(ArgumentAccessError) -> T where T: RawRepresentable, T.RawValue: VariantConvertible {
        let variantOrNil = try argument(ofType: Variant?.self, at: index)
        
        guard let variant = variantOrNil else {
            throw .variantConversionError(.unexpectedContent(parsing: type, from: variantOrNil))
        }
        
        do {
            return try T.fromVariantOrThrow(variant)
        } catch {
            throw .variantConversionError(error)
        }
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

public extension VariantConvertible {
    /// Extract from `Arguments` increasing `index` after complete. Useful for `repeat each` iteration.
    static func fromArguments(_ arguments: borrowing Arguments, incrementingIndex index: inout Int) throws(ArgumentAccessError) -> Self {
        defer { index += 1 }
        return try arguments.argument(at: index)
    }
}

/// Internal API. Protocol covering types that have nullable semantics on Godot Side: Object-derived types and Variant.
/// It's used for conditional extension of Optional.
/// This is a workaround for Swift inability to have multiple conditional extensions for one type (Optional in our case).
public protocol _GodotOptionalBridgeable: _GodotBridgeable {
}


extension Object: _GodotOptionalBridgeable {
}

extension Variant: _GodotOptionalBridgeable {
    public static var _gtype: GType {
        .nil
    }
    
    public static var _typeNameHintStr: String {
        "Variant"
    }
    
}

// Allows static dispatch for processing `Variant?` `Object?` types during  parsing callback ``Arguments`` or using them as arguments for invoking Godot functions.
extension Optional: _GodotBridgeable, VariantConvertible where Wrapped: _GodotOptionalBridgeable {
    public static var _gtype: Variant.GType {
        Wrapped._gtype
    }
    
    public static var _typeNameHintStr: String {
        Wrapped._typeNameHintStr
    }
    
    /// Variant?.some -> Variant?.some (never throws, see Variant.fromVariantOrThrow)
    /// Variant?.some -> Object?.some or throw
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        // TODO: investigate a case where Variant can contain an object, but fails to unwrap it not because it's wrong type, but because it was nullified. We need to distinguish such case and return nil instead of throwing. It's an opposite of case where the incompatible object is contained inside Variant - then we indeed need to throw.
        try Wrapped.fromVariantOrThrow(variant)
    }
        
    /// Variant?.none -> Object?.none
    /// Variant?.none -> Variant?.none
    public static func fromNilVariantOrThrow() -> Self { nil }
}
