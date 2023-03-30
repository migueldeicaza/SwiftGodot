//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/28/23.
//

import Foundation
import GDExtension

open class Wrapped {
    var handle: UnsafeRawPointer

    public init (nativeHandle: UnsafeRawPointer) {
        handle = nativeHandle
    }
    
    public init (name: StringName) {
        if let r = UnsafeRawPointer (gi.classdb_construct_object (UnsafeRawPointer (&name.handle))) {
            handle = r
            let retain = Unmanaged.passRetained(self)
            
            // Only call this for user-bindings
            print("Will I crash?")
            print ("SWIFT: Wrapped(StringName), this is a class of type: \(Swift.type(of: self))")
            let n = StringName ("GDExample")
            print ("SWIFT: handle \(handle) is \(retain.toOpaque())")
            gi.object_set_instance (UnsafeMutableRawPointer (mutating: handle),
                                    UnsafeRawPointer (&n.handle), retain.toOpaque())
            
            // This should be 
            var callbacks = GDExtensionInstanceBindingCallbacks ()
            callbacks.create_callback = instanceBindingCreate
            callbacks.free_callback = instanceBindingFree
            callbacks.reference_callback = instanceBindingReference
            gi.object_set_instance_binding(UnsafeMutableRawPointer (mutating: handle), token, retain.toOpaque(), &callbacks);
        } else {
            fatalError("It was not possible to construct a \(name)")
        }
    }
}

func instanceBindingCreate (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    print ("SWIFT: instanceBindingCreate")
    return nil
}
func instanceBindingFree (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?) {
    print ("SWIFT: instanceBindingFree")

}
func instanceBindingReference(_ x: UnsafeMutableRawPointer?, _ y: UnsafeMutableRawPointer?, _ z: UInt8) -> UInt8{
    print ("SWIFT: instanceBindingReference")
    return 1
}

