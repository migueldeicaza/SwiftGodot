//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/28/23.
//

@_implementationOnly import GDExtension

/// Protocol implemented by the built-in classes in Godot to allow to be wrapped in a ``Variant``
public protocol GodotVariant {
    func toVariant () -> Variant
    init? (_ fromVariant: Variant)
}

/// This represents a typed array of one of the built-in types from Godot
public class VariantCollection<T:GodotVariant>: Collection {
    var array: GArray
    
    init (content: Int64) {
        array = GArray (content: content)
    }
    
    public init () {
        array = GArray ()
        
//        let name = StringName()
//        let variant = Variant()
        // Looks like this is not useful for Variants, godot says:
        // ERR_FAIL_COND_MSG(p_class_name != StringName() && p_type != Variant::OBJECT, "Class names can only be set for type OBJECT");

        //gi.array_set_typed (&content, GDExtensionVariantType (GDExtensionVariantType.RawValue(T.variantType.rawValue)), &name.content, &variant.content)
    }
    
    public init? (_ variant: Variant) {
        if let array = GArray (variant) {
            self.array = array
        } else {
            return nil
        }
    }
    
    // If I make this optional, I am told I need to implement an internal _read method
    public subscript (index: Index) -> T {
        get {
            let v = array [index]
            return T.init (v)!
        }
        set {
            array [index] = newValue.toVariant()
        }
    }
    
    // Required nested types, that tell Swift what our collection contains
    public typealias Index = Int
    public typealias Element = T
    
    // The upper and lower bounds of the collection, used in iterations
    public var startIndex: Index { 0 }
    public var endIndex: Index { Int (array.size()) }
    
    // Method that returns the next index when iterating
    public func index(after i: Index) -> Index {
        return i+1
    }
}
