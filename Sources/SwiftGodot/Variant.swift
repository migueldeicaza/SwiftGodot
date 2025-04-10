//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/24/23.
//

@_implementationOnly import GDExtension

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

public final class Variant: Hashable, Equatable, CustomDebugStringConvertible {
    static let fromTypeMap: [GDExtensionVariantFromTypeConstructorFunc] = {
        var map: [GDExtensionVariantFromTypeConstructorFunc] = []
        
        // stub for GDEXTENSION_VARIANT_TYPE_NIL
        map.append({ _, _ in })
        
        for vtype in GDEXTENSION_VARIANT_TYPE_NIL.rawValue + 1 ..< GDEXTENSION_VARIANT_TYPE_VARIANT_MAX.rawValue {
            map.append(gi.get_variant_from_type_constructor(GDExtensionVariantType(rawValue: vtype))!)
        }
        return map
    }()
    
    static let toTypeMap: [GDExtensionTypeFromVariantConstructorFunc] = {
        var map: [GDExtensionTypeFromVariantConstructorFunc] = []
        
        // stub for GDEXTENSION_VARIANT_TYPE_NIL
        map.append({ _, _ in })
        
        for vtype in GDEXTENSION_VARIANT_TYPE_NIL.rawValue + 1 ..< GDEXTENSION_VARIANT_TYPE_VARIANT_MAX.rawValue {
            map.append(gi.get_variant_to_type_constructor(GDExtensionVariantType(rawValue: vtype))!)
        }
        
        return map
    }()
    
    typealias ContentType = (Int, Int, Int)
    var content: ContentType = Variant.zero
    static var zero: ContentType = (0, 0, 0)
    
    /// Initializes from the raw contents of another Variant, this will make a copy of the variant contents
    init?(copying otherContent: ContentType) {
        if otherContent == Variant.zero { return nil }
        
        withUnsafePointer(to: otherContent) { src in
            gi.variant_new_copy(&content, src)
        }

        extensionInterface.variantInited(variant: self, content: &content)
    }
    
    /// Initializes using `ContentType` and assuming that this `Variant` is sole owner of this content now.
    init?(takingOver otherContent: ContentType) {
        if otherContent == Variant.zero { return nil }
        
        self.content = otherContent

        extensionInterface.variantInited(variant: self, content: &content)
    }

    deinit {
        if !extensionInterface.variantShouldDeinit(content: &content) { return }
        gi.variant_destroy (&content)
        extensionInterface.variantDeinited(variant: self, content: &content)
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
    public init(_ other: Variant) {
        withUnsafeMutablePointer(to: &content) { selfPtr in
            withUnsafePointer(to: other.content) { ptr in
                gi.variant_new_copy(selfPtr, ptr)
            }
        }
        extensionInterface.variantInited(variant: self, content: &content)
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
        extensionInterface.variantInited(variant: self, content: &content)
    }
    
    /// This describes the type of the data wrapped by this variant
    public var gtype: GType {
        let rawValue = gi.variant_get_type(&content).rawValue
        
        guard let result = GType(rawValue: Int64(rawValue)) else {
            fatalError("Unknown GType with raw value \(rawValue).")
        }
        
        return result
    }
    
    func toType (_ type: GType, dest: UnsafeMutableRawPointer) {
        withUnsafeMutablePointer(to: &content) { selfPtr in
            Variant.toTypeMap [Int (type.rawValue)] (dest, selfPtr)
        }
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``Variant`` or ``Variant?`` is used as an `@Exported` variable
    @inline(__always)
    @inlinable
    public static func _macroGodotGetVariablePropInfo(
        name: String,
        userHint: PropertyHint?,
        userHintStr: String?,
        userUsage: PropertyUsageFlags?
    ) -> PropInfo {
        _macroGodotGetVariablePropInfoSimple(
            propertyType: .nil, // Godot treats .nil as Godot Variant
            name: name,
            userHint: userHint,
            userHintStr: userHintStr,
            userUsage: userUsage
        )
    }
    
    /// Returns true if the variant is not an object, or the object is missing from the lookup table
    public var isNull: Bool {
        return asObject(Object.self) == nil
    }
    
    ///
    /// Attempts to cast the Variant into a SwiftGodot.Object, if the variant contains a value of type `.object`, then
    // this will return the object.  If the variant contains the nil value, or the content of the variant is not
    /// a `.object, the value `nil` is returned.
    ///
    /// - Parameter type: the desired type eg. `.asObject(Node.self)`
    /// - Returns: nil on error, or the type on success
    ///
    public func asObject<T: Object> (_ type: T.Type = T.self) -> T? {
        guard gtype == .object else {
            return nil
        }

        var value: UnsafeRawPointer? = UnsafeRawPointer(bitPattern: 1)!
        toType(.object, dest: &value)
        guard let value else {
            return nil
        }
        let ret: T? = lookupObject(nativeHandle: value, ownsRef: false)
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

    public enum VariantErrorType: Error {
        case notFound
    }
    

    public static func fromVariant(_ variant: Variant) -> Variant? {
        return variant
    }
    
    public func toVariant() -> Variant {
        return self
    }

    /// Gets the value of a named key from a Variant.
    /// - Parameter key: a Variant representing the key.
    /// - Returns: Result with the value on success
    public func getNamed(key: StringName) -> Result<Variant?, VariantErrorType> {
        var newContent: ContentType = Variant.zero
        var valid: GDExtensionBool = 0

        gi.variant_get_named(&content, &key.content, &newContent, &valid)
        if valid != 0 {
            return .success(Variant(takingOver: newContent))
        } else {
            return .failure(.notFound)
        }
    }

    /// Invokes a variant's method by name.
    /// - Parameters:
    ///  - method: name of the method to invoke
    ///  - arguments: variable list of arguments to pass to the method
    /// - Returns: on success, the variant result, on error, the reason
    public func call(method: StringName, _ arguments: Variant?...) -> Result<Variant?, CallErrorType> {
        var result = Variant.zero
        
        // Shadow self.content, we just need a copy of it locally
        var content = content
        
        var err = GDExtensionCallError()
        
        if arguments.count == 1 {
            var argContent = arguments.first!.content
            withUnsafePointer(to: &argContent) { ptr in
                gi.variant_call(&content, &method.content, ptr, 1, &result, &err)
            }
        } else if arguments.count > 1 {
            // A temporary allocation containing pointers to `Variant.ContentType` of marshaled arguments
            withUnsafeTemporaryAllocation(of: UnsafeRawPointer?.self, capacity: arguments.count) { pArgsBuffer in
                // We use entire buffer so can initialize every element in the end. It's not
                // necessary for UnsafeRawPointer and other POD types (which Variant.ContentType also is)
                // but we'll do it for the sake of correctness
                defer { pArgsBuffer.deinitialize() }
                guard let pArgs = pArgsBuffer.baseAddress else {
                    fatalError("pargsBuffer.baseAddress is nil")
                }
                             
                // A temporary allocation containing `Variant.ContentType` of marshaled arguments
                withUnsafeTemporaryAllocation(of: Variant.ContentType.self, capacity: arguments.count) { contentsBuffer in
                    defer { contentsBuffer.deinitialize() }
                    guard let contentsPtr = contentsBuffer.baseAddress else {
                        fatalError("contentsBuffer.baseAddress is nil")
                    }
                    
                    for i in 0..<arguments.count {
                        // Copy `content`s of the variadic `Variant`s into `contentBuffer`
                        contentsBuffer.initializeElement(at: i, to: arguments[i].content)
                        
                        // Initialize `pArgs` elements to point at respective contents of `contentsBuffer`
                        pArgsBuffer.initializeElement(at: i, to: contentsPtr + i)
                    }
                    
                    gi.variant_call(&content, &method.content, pArgs, Int64(arguments.count), &result, &err)
                }
            }
        } else {
            gi.variant_call(&content, &method.content, nil, 0, &result, &err)
        }
        
        if err.error != GDEXTENSION_CALL_OK {
            return .failure(toCallErrorType(err.error))
        }
        
        return .success(Variant(takingOver: result))
    }

    /// Constructs a new variant of the specified type, with the given array of types
    public static func construct(type: Variant.GType) -> Result<Variant?,CallErrorType> {
        var newContent: ContentType = Variant.zero
        var err = GDExtensionCallError()
        gi.variant_construct(GDExtensionVariantType(rawValue: GDExtensionVariantType.RawValue(type.rawValue)), &newContent, nil, 0, &err)
        if err.error != GDEXTENSION_CALL_OK {
            return .failure(toCallErrorType(err.error))
        }
        return .success(Variant(takingOver: newContent))
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
                        
            return Variant(takingOver: _result)
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

    /// Provides keyed access to the variant using a variant as an index
    public subscript(index: Variant) -> Variant? {
        get {
            var newContent: ContentType = Variant.zero
            var valid: GDExtensionBool = 0

            gi.variant_get(&content, &index.content, &newContent, &valid)
            if valid != 0 {
                return Variant(takingOver: newContent)
            } else {
                return nil
            }
        }
        set {
            var copyValue: Variant.ContentType = newValue.content
            var valid: GDExtensionBool = 0
            gi.variant_set(&content, &index.content, &copyValue, &valid)            
        }
    }
    /// Gets the name of a Variant type.
    public static func typeName(_ type: GType) -> String {
        let res = GString()
        gi.variant_get_type_name (GDExtensionVariantType (GDExtensionVariantType.RawValue(type.rawValue)), &res.content)
        let ret = GString.stringFromGStringPtr(ptr: &res.content)
        return ret ?? ""
    }
}

extension Optional where Wrapped == Variant {
    var content: Variant.ContentType {
        if let wrapped = self {
            return wrapped.content
        } else {
            return Variant.zero
        }
    }
}

extension Optional: VariantStorable where Wrapped: VariantStorable {
    public typealias Representable = Wrapped.Representable
    
    public func toVariantRepresentable() -> Wrapped.Representable {
        if let wrapped = self {
            return wrapped.toVariantRepresentable()
        }
        // It's not needed and is just a wrong abstraction of internal implementation leaking into the public API
        fatalError("It's illegal to construct a `Variant` from `Variant?`, unwrap it or pass it as it is.")
    }
    
    public init?(_ variant: Variant) {
        if let wrapped = Wrapped(variant) {
            self = .some(wrapped)
        } else {
            return nil
        }
    }
}
