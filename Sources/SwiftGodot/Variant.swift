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
    
    /// Initializes from the raw contents of another Variant
    init (fromContent: ContentType) {
        content = fromContent
    }
    
    deinit {
        //gi.variant_destroy (&content)
    }
    
    public init () {
        withUnsafeMutablePointer(to: &content) { ptr in
            gi.variant_new_nil (ptr)
        }
    }

    public static func == (lhs: Variant, rhs: Variant) -> Bool {
        var valid = GDExtensionBool (0)
        let ret = Variant (false)
        
        gi.variant_evaluate (GDEXTENSION_VARIANT_OP_EQUAL, &lhs.content, &rhs.content, &ret.content, &valid)
        return Bool (ret) ?? false
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(gi.variant_hash (&content))
    }
    
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
    
    convenience public init<T: VariantStorable>(
        _ value: T
    ) where T.Representable: ContentTypeStoring & VariantRepresentable {
        self.init(representable: value.toVariantRepresentable())
    }
    
    private init<T: VariantRepresentable>(representable value: T) where T: ContentTypeStoring {
        let godotType = T.godotType
        
        var mutableValue: T.ContentType
        mutableValue = value.content
        
        withUnsafeMutablePointer(to: &content) { selfPtr in
            withUnsafeMutablePointer(to: &mutableValue) { ptr in
                Variant.fromTypeMap [godotType.rawValue] (selfPtr, ptr)
            }
        }
    }
    
    private init<T: VariantRepresentable>(representable value: T) {
        let godotType = T.godotType
        
        withUnsafeMutablePointer(to: &content) { selfPtr in
            if let object = value as? Object {
                var mutableValue = object.handle
                withUnsafeMutablePointer(to: &mutableValue) { ptr in
                    Variant.fromTypeMap [godotType.rawValue] (selfPtr, ptr)
                }
            } else {
                var mutableValue = value
                withUnsafeMutablePointer(to: &mutableValue) { ptr in
                    Variant.fromTypeMap [godotType.rawValue] (selfPtr, ptr)
                }
            }
        }
    }
    
    public var gtype: GType {
        var copy = content
        return GType (rawValue: Int (gi.variant_get_type (&copy).rawValue)) ?? .nil
    }
    
    func toType (_ type: GType, dest: UnsafeMutableRawPointer) {
        withUnsafeMutablePointer(to: &content) { selfPtr in
            Variant.toTypeMap [type.rawValue] (dest, selfPtr)
        }
    }
    
    ///
    /// Attempts to cast the Variant into a GodotObject, this requires that the Variant value be of type `.object`.
    /// - Returns: nil on error, or the type on success
    ///
    public func asObject<T:GodotObject> () -> T? {
        guard gtype == .object else {
            return nil
        }
        var value: UnsafeRawPointer = UnsafeRawPointer(bitPattern: 1)!
        toType(.object, dest: &value)
        let ret: T? = lookupObject(nativeHandle: value)
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
}
