/// A type representing expected errors that can happen during parsing `Arguments` in the call-site
public enum ArgumentRetrievalError: Error, CustomStringConvertible {
    case notEnoughArguments
    case mismatchingArrayElementType(expected: String, actual: String)
    case mismatchingType(expected: String, actual: String)
    
    public var description: String {
        switch self {
        case .notEnoughArguments:
            return "Not enough arguments were provided"
        case .mismatchingType(let expected, let actual):
            return "Mismatching type, got `\(actual)` instead of `\(expected)`"
        case .mismatchingArrayElementType(expected: let expected, actual: let actual):
            return "Array got an element of unexpected type, got `\(actual)` instead of `\(expected)`"
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
                if count > 0 {
                    return retrieveVariant(at: 0)
                } else {
                    return nil
                }
            }
            
            /// Lazily reconstruct variant at `index`
            func retrieveVariant(at index: Int) -> Variant? {
                precondition(index >= 0 && index < count, "Index \(index) out of bounds")
                
                guard let ptr = pargs[index] else {
                    return nil
                }
                
                return Variant(copying: ptr.assumingMemoryBound(to: Variant.ContentType.self).pointee)
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
    ///
    /// If the `Arguments` is empty, the value of this property is `nil`.
    public var first: Variant?? {
        switch contents {
        case .unsafeGodotArgs(let contents):
            if contents.count > 0 {
                return contents.retrieveVariant(at: 0)
            } else {
                return nil
            }
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
    
    public subscript(_ index: Int) -> Variant? {
        get {
            switch contents {
            case .array(let array):
                return array[index]
            case .unsafeGodotArgs(let args):
                return args.retrieveVariant(at: index)
            }
        }
    }
    
    public func retrieveArray<T: VariantStorable>(ofType type: T.Type = T.self, at index: Int) throws -> [T] {
        guard let arg = first else {
            throw ArgumentRetrievalError.notEnoughArguments
        }
        
        guard let variant = arg else {
            throw ArgumentRetrievalError.mismatchingType(expected: "GArray", actual: "nil")
        }
        
        guard let array = GArray(variant) else {
            throw ArgumentRetrievalError.mismatchingType(expected: "GArray", actual: variant.gtype.debugDescription)
        }
        
        var result: [T] = []
        result.reserveCapacity(array.count)
        for element in array {
            guard let element else {
                throw ArgumentRetrievalError.mismatchingArrayElementType(expected: "\(T.self)", actual: "nil")
            }
            
            guard let element = T.makeOrUnwrap(element) else {
                throw ArgumentRetrievalError.mismatchingArrayElementType(expected: "\(T.self)", actual: element.gtype.debugDescription)
            }
        
            result.append(element)
        }
        return result
    }
    
    public func retrieveVariantCollection<T: VariantStorable>(ofType type: T.Type = T.self, at index: Int) throws -> VariantCollection<T> {
        guard let arg = first else {
            throw ArgumentRetrievalError.notEnoughArguments
        }
        
        guard let variant = arg else {
            throw ArgumentRetrievalError.mismatchingType(expected: "GArray", actual: "nil")
        }
        
        guard let array = GArray(variant) else {
            throw ArgumentRetrievalError.mismatchingType(expected: "GArray", actual: variant.gtype.debugDescription)
        }
        
        let result = VariantCollection<T>()
        for element in array {
            guard let element else {
                throw ArgumentRetrievalError.mismatchingArrayElementType(expected: "\(T.self)", actual: "nil")
            }
            
            guard let element = T.makeOrUnwrap(element) else {
                throw ArgumentRetrievalError.mismatchingArrayElementType(expected: "\(T.self)", actual: element.gtype.debugDescription)
            }
        
            result.append(element)
        }
        return result
    }
    
    public func retrieveObjectCollection<T: Object>(ofType type: T.Type = T.self, at index: Int) throws -> ObjectCollection<T> {
        guard let arg = first else {
            throw ArgumentRetrievalError.notEnoughArguments
        }
        
        guard let variant = arg else {
            throw ArgumentRetrievalError.mismatchingType(expected: "GArray", actual: "nil")
        }
        
        guard let array = GArray(variant) else {
            throw ArgumentRetrievalError.mismatchingType(expected: "GArray", actual: variant.gtype.debugDescription)
        }
        
        let result = ObjectCollection<T>()
        for element in array {
            if let element {
                guard let element = T.makeOrUnwrap(element) else {
                    throw ArgumentRetrievalError.mismatchingArrayElementType(expected: "\(T.self)", actual: element.gtype.debugDescription)
                }
            
                result.append(element)
            } else {
                result.append(nil)
            }            
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
            self = (0..<args.count).map { i in
                args.retrieveVariant(at: i)
            }
        }
    }
}
