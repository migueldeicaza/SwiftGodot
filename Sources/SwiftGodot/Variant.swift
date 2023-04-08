//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/24/23.
//

import Foundation
@_implementationOnly import GDExtension

public struct Variant {
    var handle: UnsafeMutableRawPointer?
    
    public enum VariantType {
        
    }
    static var boolTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_BOOL)!
    }()
    static var intTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_INT)!
    }()
    static var floatTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_FLOAT)!
    }()
    static var stringTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_STRING)!
    }()
    static var vector2TypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_VECTOR2)!
    }()
    static var vector2iTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_VECTOR2I)!
    }()
    static var vector3TypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_VECTOR3)!
    }()
    static var vector3iTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_VECTOR3I)!
    }()
    static var transform2dTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_TRANSFORM2D)!
    }()
    static var vector4TypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_VECTOR4)!
    }()
    static var vector4iTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_VECTOR4I)!
    }()
    static var planeTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_PLANE)!
    }()
    static var quaternionTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_QUATERNION)!
    }()
    static var aabbTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_AABB)!
    }()
    static var basisTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_BASIS)!
    }()
    static var transform3dTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_TRANSFORM3D)!
    }()
    static var projectionTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_PROJECTION)!
    }()
    static var colorTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_COLOR)!
    }()
    static var stringNameTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_STRING_NAME)!
    }()
    static var nodePathTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_NODE_PATH)!
    }()
    static var ridTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_RID)!
    }()
    static var objectTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_OBJECT)!
    }()
    static var callableTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_CALLABLE)!
    }()
    static var signalTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_SIGNAL)!
    }()
    static var dictionaryTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_DICTIONARY)!
    }()
    static var arrayTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_ARRAY)!
    }()
    static var packedByteArrayTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_PACKED_BYTE_ARRAY)!
    }()
    static var packedInt32ArrayTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_PACKED_INT32_ARRAY)!
    }()
    static var packedInt64ArrayTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_PACKED_INT64_ARRAY)!
    }()
    static var packedFloat32ArrayTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_PACKED_FLOAT32_ARRAY)!
    }()
    static var packedFloat64ArrayTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_PACKED_FLOAT64_ARRAY)!
    }()
    static var packedStringArrayTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_PACKED_STRING_ARRAY)!
    }()
    static var packedVector2ArrayTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_PACKED_VECTOR2_ARRAY)!
    }()
    static var packedVector3ArrayTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_PACKED_VECTOR3_ARRAY)!
    }()
    static var packedColorArrayTypeCtor: GDExtensionVariantFromTypeConstructorFunc = {
        gi.get_variant_from_type_constructor (GDEXTENSION_VARIANT_TYPE_PACKED_COLOR_ARRAY)!
    } ()
    
    public init () {
        var nh: UnsafeMutableRawPointer?
        gi.variant_new_nil (&nh)
        handle = nh
    }
    
    public init (other: Variant) {
        var vh: UnsafeMutableRawPointer?
        gi.variant_new_copy (&vh, other.handle)
        handle = vh
    }
    
    public init (_ value: Bool) {
        var vh: UnsafeMutableRawPointer?
        var v = GDExtensionBool (value ? 1 : 0)
        Variant.boolTypeCtor (&vh, &v)
        handle = vh
    }
    
    public init (_ value: Int) {
        var vh: UnsafeMutableRawPointer?
        var v = GDExtensionInt(value)
        Variant.intTypeCtor (&vh, &v)
        handle = vh
    }
    
    public init (_ value: String) {
        var vh: UnsafeMutableRawPointer?
        var v = GDExtensionStringPtr (mutating: value.cString(using: .utf8))
        Variant.stringTypeCtor (&vh, &v)
        handle = vh
    }
}
