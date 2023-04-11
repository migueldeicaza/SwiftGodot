//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/24/23.
//

import Foundation
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
/// > Note: Containers (``GArray`` and ``Dictionary``): Both are implemented using variants.
/// A ``Dictionary`` can match any datatype used as key to any other datatype. An ``GArray`
/// just holds an array of Variants.  A ``Variant`` can also hold a ``Dictionary`` and an ``Array``
/// inside.
///
/// Modifications to a container will modify all references to it.

public class Variant: Hashable, Equatable {
    static var fromTypeMap: [GDExtensionVariantFromTypeConstructorFunc] = {
        var map: [GDExtensionVariantFromTypeConstructorFunc] = []
        
        for vtype in 0..<Variant.GType.max.rawValue {
            let v = UInt32 (vtype == 0 ? 1 : vtype)
            map.append (gi.get_variant_from_type_constructor (GDExtensionVariantType (v))!)
        }
        return map
    }()
    
    static var toTypeMap: [GDExtensionTypeFromVariantConstructorFunc] = {
        var map: [GDExtensionTypeFromVariantConstructorFunc] = []
        
        for vtype in 0..<Variant.GType.max.rawValue {
            let v = UInt32 (vtype == 0 ? 1 : vtype)
            map.append (gi.get_variant_to_type_constructor (GDExtensionVariantType (v))!)
        }
        return map
    }()
    
    typealias ContentType = (Int, Int, Int)
    var content: ContentType = (0, 0, 0)
    
    /// Initializes from the raw contents of another Variant
    init (fromContent: ContentType) {
        content = fromContent
    }
    
    deinit {
        gi.variant_destroy (&content)
    }
    
    /// Creates a nil variant
    public init (_ value: Nil) {
        var nh: UnsafeMutableRawPointer?
        
        gi.variant_new_nil (UnsafeMutablePointer (&content))
    }
    
    public init () {
        var nh: UnsafeMutableRawPointer?
        
        gi.variant_new_nil (UnsafeMutablePointer (&content))
    }

    public static func == (lhs: Variant, rhs: Variant) -> Bool {
        var valid = GDExtensionBool (0)
        var ret = Variant (false)
        
        gi.variant_evaluate (GDEXTENSION_VARIANT_OP_EQUAL, &lhs.content, &rhs.content, &ret, &valid)
        return Bool (ret) ?? false
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(gi.variant_hash (&content))
    }
    
    public init (other: Variant) {
        var copy = other
        gi.variant_new_copy (&content, &copy.content)
    }
    
    public init (_ value: Bool) {
        var v = GDExtensionBool (value ? 1 : 0)
        Variant.fromTypeMap [GType.bool.rawValue] (&content, &v)
   }
    
    public init (_ value: Int) {
        var v = GDExtensionInt(value)
        Variant.fromTypeMap [GType.int.rawValue] (&content, &v)
    }
    
    public init (_ value: String) {
        var vh: UnsafeMutableRawPointer?
        var v = GDExtensionStringPtr (mutating: value.cString(using: .utf8))
        Variant.fromTypeMap [GType.int.rawValue] (&content, &v)
    }
    
    public init (_ value: Float) {
        var v = value
        Variant.fromTypeMap [GType.float.rawValue] (&content, &v)
    }
    
    public init (_ value: GString) {
        var v = GDExtensionStringPtr (&value.content)
        Variant.fromTypeMap [GType.string.rawValue] (&content, v)
    }
    
    public init (_ value: Vector2) {
        var v = value
        Variant.fromTypeMap [GType.vector2.rawValue] (&content, &v)
    }
    
    public init (_ value: Vector2i) {
        var v = value
        Variant.fromTypeMap [GType.vector2i.rawValue] (&content, &v)
    }
    
    public init (_ value: Rect2) {
        var v = value
        Variant.fromTypeMap [GType.rect2.rawValue] (&content, &v)
    }
    
    public init (_ value: Rect2i) {
        var v = value
        Variant.fromTypeMap [GType.rect2i.rawValue] (&content, &v)
    }
    
    public init (_ value: Vector3) {
        var v = value
        Variant.fromTypeMap [GType.vector3.rawValue] (&content, &v)
    }
    
    public init (_ value: Vector3i) {
        var v = value
        Variant.fromTypeMap [GType.vector3i.rawValue] (&content, &v)
    }
    
    public init (_ value: Transform2D) {
        var v = value
        Variant.fromTypeMap [GType.transform2d.rawValue] (&content, &v)
    }
    
    public init (_ value: Vector4) {
        var v = value
        Variant.fromTypeMap [GType.vector4.rawValue] (&content, &v)
    }
    
    public init (_ value: Vector4i) {
        var v = value
        Variant.fromTypeMap [GType.vector4i.rawValue] (&content, &v)
    }
    
    public init (_ value: Plane) {
        var v = value
        Variant.fromTypeMap [GType.plane.rawValue] (&content, &v)
    }
    
    public init (_ value: Quaternion) {
        var v = value
        Variant.fromTypeMap [GType.quaternion.rawValue] (&content, &v)
    }
    
    public init (_ value: AABB) {
        var v = value
        Variant.fromTypeMap [GType.aabb.rawValue] (&content, &v)
    }
    
    public init (_ value: Basis) {
        var v = value
        Variant.fromTypeMap [GType.basis.rawValue] (&content, &v)
    }
    
    public init (_ value: Transform3D) {
        var v = value
        Variant.fromTypeMap [GType.transform3d.rawValue] (&content, &v)
    }
    
    public init (_ value: Projection) {
        var v = value
        Variant.fromTypeMap [GType.projection.rawValue] (&content, &v)
    }
    
    public init (_ value: Color) {
        var v = value
        Variant.fromTypeMap [GType.color.rawValue] (&content, &v)
    }
    
    public init (_ value: StringName) {
        Variant.fromTypeMap [GType.stringName.rawValue] (&content, &value.content)
    }
    
    public init (_ value: NodePath) {
        Variant.fromTypeMap [GType.nodePath.rawValue] (&content, &value.content)
    }
    
    public init (_ value: RID) {
        Variant.fromTypeMap [GType.rid.rawValue] (&content, &value.content)
    }
    
    public init (_ value: Object) {
        Variant.fromTypeMap [GType.object.rawValue] (&content, UnsafeMutableRawPointer (mutating: value.handle))
    }
    
    public init (_ value: Callable) {
        Variant.fromTypeMap [GType.callable.rawValue] (&content, &value.content)
    }
    
    public init (_ value: Signal) {
        Variant.fromTypeMap [GType.signal.rawValue] (&content, &value.content)
    }
    
    public init (_ value: Dictionary) {
        Variant.fromTypeMap [GType.dictionary.rawValue] (&content, &value.content)
    }
    
    public init (_ value: GArray) {
        Variant.fromTypeMap [GType.array.rawValue] (&content, &value.content)
    }
    
    public init (_ value: PackedByteArray) {
        Variant.fromTypeMap [GType.packedByteArray.rawValue] (&content, &value.content)
    }
    
    public init (_ value: PackedInt32Array) {
        Variant.fromTypeMap [GType.packedInt32Array.rawValue] (&content, &value.content)
    }
    
    public init (_ value: PackedInt64Array) {
        Variant.fromTypeMap [GType.packedInt64Array.rawValue] (&content, &value.content)
    }
    
    public init (_ value: PackedFloat32Array) {
        Variant.fromTypeMap [GType.packedFloat32Array.rawValue] (&content, &value.content)
    }
    
    public init (_ value: PackedFloat64Array) {
        Variant.fromTypeMap [GType.packedFloat64Array.rawValue] (&content, &value.content)
    }
    
    public init (_ value: PackedStringArray) {
        Variant.fromTypeMap [GType.packedStringArray.rawValue] (&content, &value.content)
    }
    
    public init (_ value: PackedVector2Array) {
        Variant.fromTypeMap [GType.packedVector2Array.rawValue] (&content, &value.content)
    }
    
    public init (_ value: PackedVector3Array) {
        Variant.fromTypeMap [GType.packedVector3Array.rawValue] (&content, &value.content)
    }
    
    public init (_ value: PackedColorArray) {
        Variant.fromTypeMap [GType.packedColorArray.rawValue] (&content, &value.content)
    }
    
    public var gtype: GType {
        var copy = content
        return GType (rawValue: Int (gi.variant_get_type (&copy).rawValue)) ?? .nil
    }
    
    func toType (_ type: GType, dest: UnsafeMutableRawPointer) {
        Variant.toTypeMap [type.rawValue] (dest, &content)
    }
}

extension Int: GodotVariant {
    /// Creates a new instance from the given variant if it contains an integer
    public init? (_ from: Variant) {
        guard from.gtype == .int else {
            return nil
        }
        var value = 0
        from.toType(.int, dest: &value)
        self.init (value)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Int64: GodotVariant {
    /// Creates a new instance from the given variant if it contains an integer
    public init? (_ from: Variant) {
        guard from.gtype == .int else {
            return nil
        }
        var value = 0
        from.toType(.int, dest: &value)
        self.init (value)
    }
    
    public func toVariant () -> Variant { Variant (Int (self)) }
}

extension Bool: GodotVariant {
    /// Creates a new instance from the given variant if it contains a boolean
    public init? (_ from: Variant) {
        guard from.gtype == .bool else {
            return nil
        }
        var v = GDExtensionBool (0)
        from.toType(.bool, dest: &v)
        self.init (v == 0 ? false : true)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension GString {
    /// Creates a new instance from the given variant if it contains a GString
    public convenience init? (_ from: Variant) {
        guard from.gtype == .string else {
            return nil
        }
        var content: GString.ContentType = 0
        from.toType(.string, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Float: GodotVariant {
    /// Creates a new instance from the given variant if it contains a float
    public init? (_ from: Variant) {
        guard from.gtype == .float else {
            return nil
        }
        var value: Float = 0
        from.toType(.float, dest: &value)
        self.init (value)
    }

    public func toVariant () -> Variant { Variant (self) }
}

extension Rect2 {
    /// Creates a new instance from the given variant if it contains a Rect2
    public init? (_ from: Variant) {
        guard from.gtype == .rect2 else {
            return nil
        }
        var v = Rect2()
        from.toType(.rect2, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Rect2i {
    /// Creates a new instance from the given variant if it contains a Rect2i
    public init? (_ from: Variant) {
        guard from.gtype == .rect2i else {
            return nil
        }
        var v = Rect2i()
        from.toType(.rect2i, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Vector2 {
    /// Creates a new instance from the given variant if it contains a Vector2
    public init? (_ from: Variant) {
        guard from.gtype == .vector2 else {
            return nil
        }
        var v = Vector2()
        from.toType(.vector2, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Vector2i {
    /// Creates a new instance from the given variant if it contains a Vector2i
    public init? (_ from: Variant) {
        guard from.gtype == .vector2i else {
            return nil
        }
        var v = Vector2i()
        from.toType(.vector2i, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Vector3 {
    /// Creates a new instance from the given variant if it contains a Vector3
    public init? (_ from: Variant) {
        guard from.gtype == .vector3 else {
            return nil
        }
        var v = Vector3()
        from.toType(.vector3, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Vector3i {
    /// Creates a new instance from the given variant if it contains a Vector3i
    public init? (_ from: Variant) {
        guard from.gtype == .vector3i else {
            return nil
        }
        var v = Vector3i()
        from.toType(.vector3i, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Vector4 {
    /// Creates a new instance from the given variant if it contains a Vector4
    public init? (_ from: Variant) {
        guard from.gtype == .vector4 else {
            return nil
        }
        var v = Vector4()
        from.toType(.vector4, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Vector4i {
    /// Creates a new instance from the given variant if it contains a Vector4i
    public init? (_ from: Variant) {
        guard from.gtype == .vector4i else {
            return nil
        }
        var v = Vector4i()
        from.toType(.vector4i, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Transform2D {
    /// Creates a new instance from the given variant if it contains a Transform2D
    public init? (_ from: Variant) {
        guard from.gtype == .transform2d else {
            return nil
        }
        var v = Transform2D()
        from.toType(.transform2d, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Transform3D {
    /// Creates a new instance from the given variant if it contains a Transform3D
    public init? (_ from: Variant) {
        guard from.gtype == .transform3d else {
            return nil
        }
        var v = Transform3D()
        from.toType(.transform3d, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Projection {
    /// Creates a new instance from the given variant if it contains a Projection
    public init? (_ from: Variant) {
        guard from.gtype == .projection else {
            return nil
        }
        var v = Projection()
        from.toType(.projection, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Quaternion {
    /// Creates a new instance from the given variant if it contains a Quaternion
    public init? (_ from: Variant) {
        guard from.gtype == .quaternion else {
            return nil
        }
        var v = Quaternion()
        from.toType(.quaternion, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension AABB {
    /// Creates a new instance from the given variant if it contains a AABB
    public init? (_ from: Variant) {
        guard from.gtype == .aabb else {
            return nil
        }
        var v = AABB()
        from.toType(.aabb, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Basis {
    /// Creates a new instance from the given variant if it contains a Basis
    public init? (_ from: Variant) {
        guard from.gtype == .basis else {
            return nil
        }
        var v = Basis()
        from.toType(.basis, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Color {
    /// Creates a new instance from the given variant if it contains a Color
    public init? (_ from: Variant) {
        guard from.gtype == .color else {
            return nil
        }
        var v = Color()
        from.toType(.color, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Plane {
    /// Creates a new instance from the given variant if it contains a Plane
    public init? (_ from: Variant) {
        guard from.gtype == .plane else {
            return nil
        }
        var v = Plane()
        from.toType(.plane, dest: &v)
        self.init (from: v)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Signal {
    /// Creates a new instance from the given variant if it contains a Signal
    public convenience init? (_ from: Variant) {
        guard from.gtype == .signal else {
            return nil
        }
        var content: Signal.ContentType = (0, 0)
        from.toType(.signal, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension GArray {
    /// Creates a new instance from the given variant if it contains a GArray
    public convenience init? (_ from: Variant) {
        guard from.gtype == .array else {
            return nil
        }
        var content: GArray.ContentType = 0
        from.toType(.array, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Dictionary {
    /// Creates a new instance from the given variant if it contains a Dictionary
    public convenience init? (_ from: Variant) {
        guard from.gtype == .dictionary else {
            return nil
        }
        var content: Dictionary.ContentType = 0
        from.toType(.dictionary, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension NodePath {
    /// Creates a new instance from the given variant if it contains a NodePath
    public convenience init? (_ from: Variant) {
        guard from.gtype == .nodePath else {
            return nil
        }
        var content: NodePath.ContentType = 0
        from.toType(.nodePath, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension RID {
    /// Creates a new instance from the given variant if it contains a RID
    public convenience init? (_ from: Variant) {
        guard from.gtype == .rid else {
            return nil
        }
        var content: RID.ContentType = 0
        from.toType(.rid, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension StringName {
    /// Creates a new instance from the given variant if it contains a StringName
    public convenience init? (_ from: Variant) {
        guard from.gtype == .stringName else {
            return nil
        }
        var content: StringName.ContentType = 0
        from.toType(.rid, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension PackedByteArray {
    /// Creates a new instance from the given variant if it contains a PackedByteArray
    public convenience init? (_ from: Variant) {
        guard from.gtype == .packedByteArray else {
            return nil
        }
        var content: PackedByteArray.ContentType = (0, 0)
        from.toType(.packedByteArray, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension PackedColorArray {
    /// Creates a new instance from the given variant if it contains a PackedColorArray
    public convenience init? (_ from: Variant) {
        guard from.gtype == .packedColorArray else {
            return nil
        }
        var content: PackedColorArray.ContentType = (0, 0)
        from.toType(.packedColorArray, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension PackedFloat32Array {
    /// Creates a new instance from the given variant if it contains a PackedFloat32Array
    public convenience init? (_ from: Variant) {
        guard from.gtype == .packedFloat32Array else {
            return nil
        }
        var content: PackedFloat32Array.ContentType = (0, 0)
        from.toType(.packedFloat32Array, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Nil {
    /// Creates a new instance from the given variant if it contains a Callable
    public convenience init? (_ from: Variant) {
        guard from.gtype == .nil else {
            return nil
        }
        var content: Nil.ContentType = 0
        from.toType(.callable, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension Callable {
    /// Creates a new instance from the given variant if it contains a Callable
    public convenience init? (_ from: Variant) {
        guard from.gtype == .callable else {
            return nil
        }
        var content: Callable.ContentType = (0, 0)
        from.toType(.callable, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension PackedFloat64Array {
    /// Creates a new instance from the given variant if it contains a PackedFloat64Array
    public convenience init? (_ from: Variant) {
        guard from.gtype == .packedFloat64Array else {
            return nil
        }
        var content: PackedFloat64Array.ContentType = (0, 0)
        from.toType(.packedFloat64Array, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension PackedInt32Array {
    /// Creates a new instance from the given variant if it contains a PackedInt32Array
    public convenience init? (_ from: Variant) {
        guard from.gtype == .packedInt32Array else {
            return nil
        }
        var content: PackedInt32Array.ContentType = (0, 0)
        from.toType(.packedInt32Array, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension PackedInt64Array {
    /// Creates a new instance from the given variant if it contains a PackedInt64Array
    public convenience init? (_ from: Variant) {
        guard from.gtype == .packedInt64Array else {
            return nil
        }
        var content: PackedInt64Array.ContentType = (0, 0)
        from.toType(.packedInt64Array, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension PackedVector2Array {
    /// Creates a new instance from the given variant if it contains a PackedVector2Array
    public convenience init? (_ from: Variant) {
        guard from.gtype == .packedVector2Array else {
            return nil
        }
        var content: PackedVector2Array.ContentType = (0, 0)
        from.toType(.packedVector2Array, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension PackedVector3Array {
    /// Creates a new instance from the given variant if it contains a PackedVector2Array
    public convenience init? (_ from: Variant) {
        guard from.gtype == .packedVector3Array else {
            return nil
        }
        var content: PackedVector3Array.ContentType = (0, 0)
        from.toType(.packedVector3Array, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}

extension PackedStringArray {
    /// Creates a new instance from the given variant if it contains a PackedVector2Array
    public convenience init? (_ from: Variant) {
        guard from.gtype == .packedStringArray else {
            return nil
        }
        var content: PackedStringArray.ContentType = (0, 0)
        from.toType(.packedStringArray, dest: &content)
        self.init (content: content)
    }
    
    public func toVariant () -> Variant { Variant (self) }
}
