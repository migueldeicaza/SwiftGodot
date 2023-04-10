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
    // The issue with a constructor requirement is that Object subclasses
    // really should not be created this way, since we might have a user-defined
    // object that needs to be looked up, not created from a handle.
    // So we likely need to move to class-level factory method, so that
    // we can get that semantic (lookupLiveObject (nativeHandle: ..) ?? T (nativeHandle: )
    //
    // Which btw, for user-level stuff, the latter should always abort.
    
//    init? (_ from: Variant)
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
            if T.self == Object.self {
                var handle = UnsafeMutableRawPointer(bitPattern: 0xdeadbeef)
                v.toType(.object, dest: &handle)
                if let o = lookupLiveObject(handleAddress: handle!) as? T {
                    return o
                }
            }
            // TODO: figure out if I want to use a constructor or a class method
//            if let ret = T.init (v) {
//                return ret
//            }
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
    public var endIndex: Index { self.count }
    
    // Method that returns the next index when iterating
    public func index(after i: Index) -> Index {
        return i+1
    }
}
