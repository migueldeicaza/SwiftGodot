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
    static var userTypeBindingCallback = GDExtensionInstanceBindingCallbacks(
        create_callback: userTypeBindingCreate,
        free_callback: userTypeBindingFree,
        reference_callback: userTypeBindingReference)
    static var frameworkTypeBindingCallback = GDExtensionInstanceBindingCallbacks(
        create_callback: frameworkTypeBindingCreate,
        free_callback: frameworkTypeBindingFree,
        reference_callback: frameworkTypeBindingReference)
    
    public init (nativeHandle: UnsafeRawPointer) {
        handle = nativeHandle
    }
    
    /// The constructor chain that uses StringName is internal, and is triggered
    /// when a class is initialized with the empty constructor - this means that
    /// subclasses will have a diffrent name than the subclass
    internal init (name: StringName) {
        if let r = UnsafeRawPointer (gi.classdb_construct_object (UnsafeRawPointer (&name.handle))) {
            handle = r
            let retain = Unmanaged.passRetained(self)
            
            // TODO: what happens if the user subclasses but the name conflicts with the Godot type?
            // say "class Sprite2D: Godot.Sprite2D"
            let thisTypeName = StringName (String (describing: Swift.type(of: self)))
            let frameworkType = thisTypeName == name
            
            print ("SWIFT: Wrapped(StringName), this is a class of type: \(Swift.type(of: self)) and it is: \(frameworkType ? "Builtin" : "User defined")")
            
            // This I believe should only be set for user subclasses, and not anything else.
            if frameworkType {
                print ("SWIFT: Skipping object registration, this is a framework type")
            } else {
                print ("SWIFT: Registering instance with Godot")
                gi.object_set_instance (UnsafeMutableRawPointer (mutating: handle),
                                        UnsafeRawPointer (&thisTypeName.handle), retain.toOpaque())
            }
            var callbacks = frameworkType ? Wrapped.frameworkTypeBindingCallback : Wrapped.userTypeBindingCallback
            gi.object_set_instance_binding(UnsafeMutableRawPointer (mutating: handle), token, retain.toOpaque(), &callbacks);
        } else {
            fatalError("It was not possible to construct a \(name)")
        }
    }
}

func userTypeBindingCreate (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    // Godot-cpp does nothing for user types
    //print ("SWIFT: instanceBindingCreate")
    return nil
}

func userTypeBindingFree (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?) {
    // Godot-cpp does nothing for user types
    //print ("SWIFT: instanceBindingFree")
}

func userTypeBindingReference(_ x: UnsafeMutableRawPointer?, _ y: UnsafeMutableRawPointer?, _ z: UInt8) -> UInt8{
    // No clue what this is used for, but godot-cpp returns 1
    return 1
}

func frameworkTypeBindingCreate (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    print ("SWIFT: frameworkBindingCreate")
    
    // TODO, this needs to create an instance of the most derived type at this point
    // from the pointer passed in instance
    fatalError()
    return nil
}

func frameworkTypeBindingFree (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?) {
    print ("SWIFT: frameworkBindingFree")
    // TODO: this needs to release the Swift object
    fatalError()

}

func frameworkTypeBindingReference(_ x: UnsafeMutableRawPointer?, _ y: UnsafeMutableRawPointer?, _ z: UInt8) -> UInt8 {
    // No clue what this is used for, but godot-cpp returns 1
    return 1
}

