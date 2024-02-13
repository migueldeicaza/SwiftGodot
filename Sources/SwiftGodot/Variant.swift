//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/24/23.
//

@_implementationOnly import GDExtension

/// If your application is crashing due to the Variant leak fixes, please
/// enable this flag, and provide me with a test case, so I can find that
/// pesky scenario.
public var experimentalDisableVariantUnref = false

/// Variant objects box various Godot Objects, you create them with one of the
/// constructors, and you can retrieve the contents using the various extension
/// constructors that are declared on the various types that are wrapped.
///
/// You can retrieve the type of a variant from the ``gtype`` property.
///
/// A Variant takes up only 20 bytes and can store almost any engine datatype
/// inside of it. Variants are rarely used to hold information for long periods of
/// time. Instead, they are used mainly for communication, editing, serialization and
/// moving data around.
///
/// A Variant:
/// - Can store almost any Godot engine datatype.
/// - Can perform operations between many variants. GDScript uses Variant as its atomic/native datatype.
/// - Can be hashed, so it can be compared to other variants.
/// - Can be used to convert safely between datatypes.
/// - Can be used to abstract calling methods and their arguments. Godot exports all its functions through variants.
/// - Can be used to defer calls or move data between threads.
/// - Can be serialized as binary and stored to disk, or transferred via network.
/// - Can be serialized to text and use it for printing values and editable settings.
/// - Can work as an exported property, so the editor can edit it universally.
/// - Can be used for dictionaries, arrays, parsers, etc.
///
/// > Note: Containers (``GArray`` and ``GDictionary``): Both are implemented using variants.
/// A ``GDictionary`` can match any datatype used as key to any other datatype.  An ``GArray``
/// just holds an array of Variants.  A ``Variant`` can also hold a ``GDictionary`` and an ``GArray``
/// inside.
///
/// Modifications to a container will modify all references to it.

public class Variant: Hashable, Equatable, CustomDebugStringConvertible {
    static var fromTypeMap: [GDExtensionVariantFromTypeConstructorFunc] = {
        var map: [GDExtensionVariantFromTypeConstructorFunc] = []
        
        for vtype in 0..<Variant.GType.max.rawValue {
            let v = GDExtensionVariantType.RawValue (vtype == 0 ? 1 : vtype)
            map.append (gi.get_variant_from_type_constructor (GDExtensionVariantType (v))!)
        }
        return map
    }()
    
    static var toTypeMap: [GDExtensionTypeFromVariantConstructorFunc] = {
        var map: [GDExtensionTypeFromVariantConstructorFunc] = []
        
        for vtype in 0..<Variant.GType.max.rawValue {
            let v = GDExtensionVariantType.RawValue (vtype == 0 ? 1 : vtype)
            map.append (gi.get_variant_to_type_constructor (GDExtensionVariantType (v))!)
        }
        return map
    }()
    
    typealias ContentType = (Int, Int, Int)
    var content: ContentType = (0, 0, 0)
    static var zero: ContentType = (0, 0, 0)
    
    /// Initializes from the raw contents of another Variant, this will make a copy of the variant contents
    init (fromContent: ContentType) {
        var copy = fromContent
        gi.variant_new_copy (&content, &copy)
    }

    /// Initializes from the raw contents of another Variant, this will make a copy of the variant contents
    init (fromContentPtr: inout ContentType) {
        gi.variant_new_copy (&content, &fromContentPtr)
    }

    deinit {
        if experimentalDisableVariantUnref { return }
        gi.variant_destroy (&content)
    }
    
    /// Creates an empty Variant, that represents the Godot type `nil`
    public init () {
        withUnsafeMutablePointer(to: &content) { ptr in
            gi.variant_new_nil (ptr)
        }
    }

    /// Compares two variants, does this by delegating the comparison to Godot
    public static func == (lhs: Variant, rhs: Variant) -> Bool {
        var valid = GDExtensionBool (0)
        let ret = Variant (false)
        
        gi.variant_evaluate (GDEXTENSION_VARIANT_OP_EQUAL, &lhs.content, &rhs.content, &ret.content, &valid)
        return Bool (ret) ?? false
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(gi.variant_hash (&content))
    }
    
    /// Creates a new Variant based on a copy of the reference variant passed in
    public init (_ other: Variant) {
        var copy = other.content
        withUnsafeMutablePointer(to: &content) { selfPtr in
            withUnsafeMutablePointer(to: &copy) { ptr in
                gi.variant_new_copy (selfPtr, ptr)
            }
        }
    }
    
    convenience public init(_ value: some VariantStorable) {
        self.init(representable: value.toVariantRepresentable())
    }
    
    private init<T: VariantRepresentable>(representable value: T) {
        let godotType = T.godotType
        
        withUnsafeMutablePointer(to: &content) { selfPtr in
            var mutableValue = value.content
            withUnsafeMutablePointer(to: &mutableValue) { ptr in
                Variant.fromTypeMap [Int (godotType.rawValue)] (selfPtr, ptr)
            }
        }
    }
    
    /// This describes the type of the data wrapped by this variant
    public var gtype: GType {
        var copy = content
        return GType (rawValue: Int64 (gi.variant_get_type (&copy).rawValue)) ?? .nil
    }
    
    func toType (_ type: GType, dest: UnsafeMutableRawPointer) {
        withUnsafeMutablePointer(to: &content) { selfPtr in
            Variant.toTypeMap [Int (type.rawValue)] (dest, selfPtr)
        }
    }
    
    /// Returns true if the variant is flagged as being an object (`gtype == .object`) and it has a nil pointer.
    public var isNull: Bool {
        return asObject(Object.self) == nil
    }
    
    ///
    /// Attempts to cast the Variant into a GodotObject, if the variant contains a value of type `.object`, then
    // this will return the object.  If the variant contains the nil value, or the content of the variant is not
    /// a `.object, the value `nil` is returned.
    ///
    /// - Parameter type: the desired type eg. `.asObject(Node.self)`
    /// - Returns: nil on error, or the type on success
    ///
    public func asObject<T:GodotObject> (_ type: T.Type = T.self) -> T? {
        guard gtype == .object else {
            return nil
        }
        var value: UnsafeRawPointer = UnsafeRawPointer(bitPattern: 1)!
        toType(.object, dest: &value)
        if value == UnsafeRawPointer(bitPattern: 0) {
            return nil
        }
        let ret: T? = lookupObject(nativeHandle: value)
        if let rc = ret as? RefCounted {
            // When we pull out a refcounted out of a Variant, take a reference
            rc.reference ()
        }
        return ret
    }
    
    public var description: String {
        var ret = GDExtensionStringPtr (bitPattern: 0xdeaddead)
        gi.variant_stringify (&content, &ret)
        
        let str = stringFromGodotString(&ret)
        GString.destructor (&ret)
        return str ?? ""
    }
    
    public var debugDescription: String {
        "\(gtype) [\(description)]"
    }
    
    /// Invokes a variant's method by name.
    /// - Parameters:
    ///  - method: name of the method to invoke
    ///  - arguments: variable list of arguments to pass to the method
    /// - Returns: on success, the variant result, on error, the reason
    public func call (method: StringName, _ arguments: Variant...) -> Result<Variant,CallErrorType> {
        let copy_method = method
        var _result: Variant.ContentType = Variant.zero
        var _args: [UnsafeRawPointer?] = []
        var copy_content = content
        //return withUnsafePointer (to: &copy_method.content) { p0 in
//            _args.append (p0)
        
        let content = UnsafeMutableBufferPointer<Variant.ContentType>.allocate(capacity: arguments.count)
        defer { content.deallocate () }
        for idx in 0..<arguments.count {
            content [idx] = arguments [idx].content
            _args.append (content.baseAddress! + idx)
        }
        var err = GDExtensionCallError ()
        
        gi.variant_call (&copy_content, &copy_method.content, &_args, Int64(_args.count), &_result, &err)
        if err.error != GDEXTENSION_CALL_OK {
            return .failure(toCallErrorType(err.error))
        }
        return .success(Variant (fromContent: _result))
    }
    
    /// Errors raised by the variant subscript
    ///
    /// There are two possible error conditions, an attempt to use an indexer on a variant that is not
    /// an array, or an attempt to access an element out bounds.
    public enum VariantIndexerError: Error, CustomDebugStringConvertible {
        case ok
        /// The variant is not an array
        case invalidOperation
        /// The index is out of bounds
        case outOfBounds
        
        public var debugDescription: String {
            switch self {
            case .ok:
                return "Success"
            case .invalidOperation:
                return "Attempt to use indexer methods in a variant that does not support it"
            case .outOfBounds:
                return "Index value was out of bounds"
            }
        }
    }
    
    /// Variants that represent arrays can be indexed, this subscript allows you to fetch the individual elements of those arrays
    ///
    public subscript (index: Int) -> Variant? {
        get {
            var copy_content = content
            var _result: Variant.ContentType = Variant.zero
            var valid: GDExtensionBool = 0
            var oob: GDExtensionBool = 0
            
            gi.variant_get_indexed(&copy_content, Int64(index), &_result, &valid, &oob)
            if valid == 0 || oob != 0 {
                return nil
            }
            return Variant(fromContent: _result)
        }
        set {
            guard let newValue else {
                return
            }
            var copy_content = content
            var newV = newValue.content
            var valid: GDExtensionBool = 0
            var oob: GDExtensionBool = 0

            gi.variant_set_indexed (&copy_content, Int64(index), &newV, &valid, &oob)
        }
    }
}
