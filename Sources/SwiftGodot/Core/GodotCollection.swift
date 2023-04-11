//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/28/23.
//

import Foundation
@_implementationOnly import GDExtension

/// Protocol implemented by the built-in classes in Godot to allow to be wrapped in a ``Variant``
public protocol GodotVariant {
    func toVariant () -> Variant
}

/// This represents a typed array of one of the built-in types from Godot
public class GodotCollection<T:GodotVariant>: GArray, Collection {
    override init (content: Int64) {
        super.init (content: content)
    }
    
    public override init () {
        super.init ()
        var name = StringName()
        var variant = Variant()

        //gi.array_set_typed (&content, GDExtensionVariantType (UInt32(T.variantType.rawValue)), &name.content, &variant.content)
    }
    
    // If I make this optional, I am told I need to implement an internal _read method
    public subscript (index: Index) -> Iterator.Element {
        get {
            let v = super [index]
            switch v.gtype {
            case .object:
                var handle = UnsafeMutableRawPointer(bitPattern: 0)
                v.toType(.object, dest: &handle)
                if let o = lookupLiveObject(handleAddress: handle!) as? T {
                    return o
                }
            case .nil:
                return Nil () as! T
            case .bool:
                return Bool (v) as! T
            case .int:
                return Int (v) as! T
            case .float:
                return Float(v) as! T
            case .string:
                return GString(v) as! T
            case .vector2:
                return Vector2(v) as! T
            case .vector2i:
                return Vector2i(v) as! T
            case .rect2:
                return Rect2(v) as! T
            case .rect2i:
                return Rect2i(v) as! T
            case .vector3:
                return Vector3(v) as! T
            case .vector3i:
                return Vector3i(v) as! T
            case .transform2d:
                return Transform2D(v) as! T
            case .vector4:
                return Vector4(v) as! T
            case .vector4i:
                return Vector4i(v) as! T
            case .plane:
                return Plane(v) as! T
            case .quaternion:
                return Quaternion(v) as! T
            case .aabb:
                return AABB(v) as! T
            case .basis:
                return Basis(v) as! T
            case .transform3d:
                return Transform3D(v) as! T
            case .projection:
                return Projection(v) as! T
            case .color:
                return Color(v) as! T
            case .stringName:
                return StringName(v) as! T
            case .nodePath:
                return NodePath(v) as! T
            case .rid:
                return RID(v) as! T
            case .callable:
                return Callable(v) as! T
            case .signal:
                return Signal(v) as! T
            case .dictionary:
                return Dictionary(v) as! T
            case .array:
                return GArray(v) as! T
            case .packedByteArray:
                return PackedByteArray (v) as! T
            case .packedInt32Array:
                return PackedInt32Array (v) as! T
            case .packedInt64Array:
                return PackedInt64Array (v) as! T
            case .packedFloat32Array:
                return PackedFloat32Array (v) as! T
            case .packedFloat64Array:
                return PackedFloat64Array (v) as! T
            case .packedStringArray:
                return PackedStringArray (v) as! T
            case .packedVector2Array:
                return PackedVector2Array (v) as! T
            case .packedVector3Array:
                return PackedVector3Array (v) as! T
            case .packedColorArray:
                return PackedColorArray (v) as! T
            default:
                fatalError()
            }
            fatalError ("This collection contained objects of a different type")
        }
        set {
            super [index] = newValue.toVariant()
        }
    }
    
    // Required nested types, that tell Swift what our collection contains
    public typealias Index = Int
    public typealias Element = T
    
    // The upper and lower bounds of the collection, used in iterations
    public var startIndex: Index { 0 }
    public var endIndex: Index { Int (size()) }
    
    // Method that returns the next index when iterating
    public func index(after i: Index) -> Index {
        return i+1
    }
}
