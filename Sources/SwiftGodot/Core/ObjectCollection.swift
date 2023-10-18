//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 4/11/23.
//

@_implementationOnly import GDExtension

/// Protocol implemented by the built-in classes in Godot to allow to be wrapped in a ``Variant``
public protocol GodotObject {
    init (nativeHandle: UnsafeRawPointer)
}

/// This represents a typed array of one of the built-in types from Godot
public class ObjectCollection<T:Object>: Collection {
    var array: GArray
    
    init (content: Int64) {
        array = GArray (content: content)
    }
    
    init () {
        array = GArray ()
        let name = StringName()
        let variant = Variant()

        gi.array_set_typed (&array.content, GDExtensionVariantType (GDExtensionVariantType.RawValue(Variant.GType.object.rawValue)), &name.content, &variant.content)
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
            var handle = UnsafeMutableRawPointer(bitPattern: 0)
            v.toType(.object, dest: &handle)
            return lookupObject(nativeHandle: handle!)
        }
        set {
            array [index] = Variant (newValue)
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
