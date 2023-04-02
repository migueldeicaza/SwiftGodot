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
    
    public required init () {
        fatalError("This constructor should not be called")
    }
    /// The constructor chain that uses StringName is internal, and is triggered
    /// when a class is initialized with the empty constructor - this means that
    /// subclasses will have a diffrent name than the subclass
    internal init (name: StringName) {
        let v = gi.classdb_construct_object (UnsafeRawPointer (&name.content))
                                
        if let r = UnsafeRawPointer (v) {
            handle = r
            let retain = Unmanaged.passRetained(self)
            
            // TODO: what happens if the user subclasses but the name conflicts with the Godot type?
            // say "class Sprite2D: Godot.Sprite2D"
            let thisTypeName = StringName (String (describing: Swift.type(of: self)))
            let frameworkType = thisTypeName == name
            
            print ("SWIFT: Wrapped(StringName) at \(handle), this is a class of type: \(Swift.type(of: self)) and it is: \(frameworkType ? "Builtin" : "User defined")")
            
            // This I believe should only be set for user subclasses, and not anything else.
            if frameworkType {
                print ("SWIFT: Skipping object registration, this is a framework type")
            } else {
                print ("SWIFT: Registering instance with Godot")
                gi.object_set_instance (UnsafeMutableRawPointer (mutating: handle),
                                        UnsafeRawPointer (&thisTypeName.content), retain.toOpaque())
            }
            var callbacks = frameworkType ? Wrapped.frameworkTypeBindingCallback : Wrapped.userTypeBindingCallback
            gi.object_set_instance_binding(UnsafeMutableRawPointer (mutating: handle), token, retain.toOpaque(), &callbacks);
        } else {
            fatalError("It was not possible to construct a \(name)")
        }
    }
}

// TODO: make it so that you can register using a generic, so that we can
// ensure it is a subclass of Wrapper
public func register (type name: StringName, parent: StringName, type: AnyObject) {
    guard let wt = type as? Wrapped.Type else {
        print ("The provided type should be a subclass of SwiftGodot.Wrapped type")
        return
    }
    var info = GDExtensionClassCreationInfo ()
    info.create_instance_func = createFunc(_:)
    info.free_instance_func = freeFunc(_:_:)
    info.get_virtual_func = getVirtual
    info.notification_func = notificationFunc
    
    let retained = Unmanaged<AnyObject>.passRetained(type)
    info.class_userdata = retained.toOpaque()
    
    gi.classdb_register_extension_class (library, UnsafeRawPointer (&name.content), UnsafeRawPointer(&parent.content), &info)
}

/// Registers a user-defined subclass of any of the SwiftGodot classes,
/// those that derive from SwiftGodot.Wrapped/SwiftGodot.Object
public func register (type: AnyObject) {
    // Strips the namespace and returns a StringName
    func stripNamespace (_ fqname: String) -> StringName {
        if let r = fqname.lastIndex(of: ".") {
            return StringName (String (fqname [fqname.index(r, offsetBy: 1)...]))
        }
        return StringName (fqname)
    }
    
    guard let wt = type as? Wrapped.Type else {
        print ("The provided type should be a subclass of SwiftGodot.Wrapped type")
        return
    }
    guard let superType = Mirror (reflecting: type).superclassMirror?.subjectType else {
        print ("You can not register the root class")
        return
    }
    let superStr = String (describing: superType)
    let typeStr = String (describing: Mirror (reflecting: type).subjectType)
        
    register (type: stripNamespace (typeStr), parent: stripNamespace (superStr), type: type)
}

var liveObjects: [UnsafeRawPointer:Wrapped] = [:]

func createFunc (_ userData: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    print ("SWIFT: Creating object userData:\(userData)")
    guard let userData else {
        print ("Got a nil userData")
        return nil
    }
    let typeAny = Unmanaged<AnyObject>.fromOpaque(userData).takeUnretainedValue()
    guard let type  = typeAny as? Wrapped.Type else {
        print ("SWIFT: The wrapped value did not contain a type: \(typeAny)")
        return nil
    }
    let o = type.init ()
    liveObjects [o.handle] = o
    print ("SWIFT: REGISTERING \(o.handle)")
    return UnsafeMutableRawPointer (mutating: o.handle)
}

func freeFunc (_ userData: UnsafeMutableRawPointer?, _ objectHandle: UnsafeMutableRawPointer?) {
    print ("SWIFT: Destroying object, userData: \(userData) objectHandle: \(objectHandle)")
    if let key = objectHandle {
        let original = Unmanaged<Wrapped>.fromOpaque(key).takeRetainedValue()
        let removed = liveObjects.removeValue(forKey: original.handle)
        if removed == nil {
            print ("attempt to release object we were not aware of: \(original) \(key)")
        }
    }
}

func getVirtual (_ userData: UnsafeMutableRawPointer?, _ name: GDExtensionConstStringNamePtr?) ->  GDExtensionClassCallVirtual? {
    print ("SWIFT: Get virtual called userData=\(userData)")
    let n = StringName (fromPtr: name)
    print ("SWIFT: getVirtual on \(n.description)")
    if n.description == "_process" {
        return processProxy
    }
    return nil
}

func processProxy (instance: UnsafeMutableRawPointer?, args: UnsafePointer<UnsafeRawPointer?>?, r: UnsafeMutableRawPointer?) {
    Node.proxy_process(instance: instance, args: args, retPtr: r)
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

