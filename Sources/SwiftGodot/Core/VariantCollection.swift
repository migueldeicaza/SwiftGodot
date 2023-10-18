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
    
    /// Creates a new instance from the given variant if it contains a GArray
    public init? (_ variant: Variant) {
        if let array = GArray (variant) {
            self.array = array
        } else {
            return nil
        }
    }
    
    /// Accesses the element at the specified position.
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
    
    /// The position of the first element in a nonempty collection.
    public var startIndex: Index { 0 }
    
    /// The collection’s “past the end” position—that is, the position one greater than the last valid subscript argument.
    public var endIndex: Index { Int (array.size()) }
    
    /// Returns the position immediately after the given index.
    public func index(after i: Index) -> Index {
        return i+1
    }
}
