//
//  File 2.swift
//  
//
//  Created by Miguel de Icaza on 3/25/23.
//

import Foundation
import GDExtension

func registerExample () {
    var info = GDExtensionClassCreationInfo ()
    info.create_instance_func = createFunc(_:)
    info.free_instance_func = freeFunc(_:_:)
    info.get_virtual_func = getVirtual
    
    
    var name = StringName("GDExample")
    var nodeName = StringName ("Sprite2D")
    
    gi.classdb_register_extension_class (library, UnsafeRawPointer (&name.handle), UnsafeRawPointer(&nodeName.handle), &info)
    
    let methodName = StringName ("_update")
    
    
    var argMeta = UnsafeMutableBufferPointer<GDExtensionClassMethodArgumentMetadata>.allocate(capacity: 1)
    argMeta [0] = GDEXTENSION_METHOD_ARGUMENT_METADATA_NONE
    
    var argInfo = UnsafeMutableBufferPointer<GDExtensionPropertyInfo>.allocate(capacity: 1)
    var updateName = StringName ("_update")
    var none = GString ("none")
    argInfo [0] = GDExtensionPropertyInfo(type: GDEXTENSION_VARIANT_TYPE_FLOAT,
                                          name: UnsafeMutableRawPointer (&updateName.handle),
                                          class_name: UnsafeMutableRawPointer (&name.handle),
                                          hint: 34,
                                          hint_string: UnsafeMutableRawPointer (&none.handle),
                                          usage: 6)
    argMeta.withContiguousStorageIfAvailable { argMetaPtr in
        argInfo.withContiguousStorageIfAvailable { argInfoPtr in
            
            var minfo = GDExtensionClassMethodInfo ()
            minfo.name = UnsafeMutableRawPointer (&methodName.handle)
            minfo.method_userdata = UnsafeMutableRawPointer (bitPattern: 0x123123123)
            minfo.call_func = callFunc
            minfo.ptrcall_func = ptrCallFunc
            minfo.method_flags = (GDEXTENSION_METHOD_FLAG_VIRTUAL).rawValue
            minfo.has_return_value = 0
            minfo.argument_count = 1
            minfo.arguments_metadata = UnsafeMutablePointer (mutating: argMetaPtr.baseAddress)
            minfo.arguments_info = UnsafeMutablePointer (mutating: argInfoPtr.baseAddress)
            
            gi.classdb_register_extension_class_method (library, UnsafePointer(&name.handle), &minfo)
        }
    }
}

func callFunc (_ method_userdata: UnsafeMutableRawPointer?,
               _ instance: UnsafeMutableRawPointer?,
               _ args: UnsafePointer<UnsafeRawPointer?>?,
               _ argc: Int64,
               _ ret: UnsafeMutableRawPointer?,
               _ error: UnsafeMutablePointer<GDExtensionCallError>?) {
    print ("Function called")
}
func ptrCallFunc (_ method_userdata: UnsafeMutableRawPointer?,
                  _ instance: UnsafeMutableRawPointer?,
                  _ args: UnsafePointer<UnsafeRawPointer?>?,
                  _ ret: UnsafeMutableRawPointer?) {
    print ("ptrFunction called")
}
/* Class Methods */

var liveObjects: [UnsafeRawPointer:Wrapped] = [:]

func createFunc (_ userData: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    print ("Creating object")
    let o = GDExample ()
    liveObjects [o.handle] = o
    return UnsafeMutableRawPointer (mutating: o.handle)
}

func freeFunc (_ userData: UnsafeMutableRawPointer?, _ objectHandle: UnsafeMutableRawPointer?) {
    print ("Destroying object")
    if let key = objectHandle {
        let removed = liveObjects.removeValue(forKey: key)
        if removed == nil {
            print ("attempt to release object we were not aware of: \(objectHandle)")
        }
    }
}

func getVirtual (_ userData: UnsafeMutableRawPointer?, _ name: GDExtensionConstStringNamePtr?) ->  GDExtensionClassCallVirtual? {
    print ("Get virtual called")
    return nil
}
public class Object: Wrapped {
    init () {
        super.init (name: StringName ("Node"))
    }
}

class Node: Object{
    override init () {
        super.init ()
    }
    func _process (delta: Float) {}
}

class GDExample: Node {
    var time_passed: Float

    override init () {
        time_passed = 0
        super.init ()

    }
    
    override func _process (delta: Float) {
        print ("process called")
        time_passed += delta
        
        var newPos = Vector2(x: 10 + (10 * sin(time_passed * 2.0)),
                             y: 10.0 + (10.0 * cos(time_passed * 1.5)))
        
        //var class_name = Node2D.get_class_static ()
//        StringName::StringName(const String &from) {
//                internal::_call_builtin_constructor(_method_bindings.constructor_2, &opaque, &from);
//        }
        
        let className = StringName ("Node2D")
        
        // Now do set_position
//        var y: UnsafeMutableRawPointer?     
//        let value = GString ("set_position")
//        args = [UnsafeRawPointer(&y), UnsafeRawPointer(&value.handle)]
//        let handleSetPosition = ctor2 (UnsafeMutableRawPointer (&y), &args)
        
        //var method_name = StringName ("set_position")
        
        //gi.classdb_get_method_bind (class_name.handle, method_name.handle,
    }
}
