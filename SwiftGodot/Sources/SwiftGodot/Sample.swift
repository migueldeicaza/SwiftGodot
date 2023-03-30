//
//  File 2.swift
//  
//
//  Created by Miguel de Icaza on 3/25/23.
//

import Foundation
import GDExtension

func registerExample () {
//    var info = GDExtensionClassCreationInfo ()
//    info.create_instance_func = createFunc(_:)
//    info.free_instance_func = freeFunc(_:_:)
//    info.get_virtual_func = getVirtual
//    info.notification_func = notificationFunc
//
//    info.class_userdata = UnsafeMutableRawPointer(bitPattern: 0xdeadbeef)
    
    let name = StringName ("GDExample")
    let parent = StringName ("Sprite2D")
    register(type: name, parent: parent, type: GDExample.self)

    // I guess this is to surface functions to Godot, but not clear why should
    // having the function would be useful
    if false {
        let methodName = StringName ("_update")
        
        var argMeta = UnsafeMutableBufferPointer<GDExtensionClassMethodArgumentMetadata>.allocate(capacity: 1)
        argMeta [0] = GDEXTENSION_METHOD_ARGUMENT_METADATA_NONE
        
        var argInfo = UnsafeMutableBufferPointer<GDExtensionPropertyInfo>.allocate(capacity: 1)
        var updateName = StringName ("_update")
        var none = GString ("Swift: no hint provided")
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
}

func notificationFunc (ptr: UnsafeMutableRawPointer?, code: Int32) {
    print ("SWIFT: Notification \(code)")
}

func callFunc (_ method_userdata: UnsafeMutableRawPointer?,
               _ instance: UnsafeMutableRawPointer?,
               _ args: UnsafePointer<UnsafeRawPointer?>?,
               _ argc: Int64,
               _ ret: UnsafeMutableRawPointer?,
               _ error: UnsafeMutablePointer<GDExtensionCallError>?) {
    print ("SWIFT: Function called, instance: \(instance)")
}
func ptrCallFunc (_ method_userdata: UnsafeMutableRawPointer?,
                  _ instance: UnsafeMutableRawPointer?,
                  _ args: UnsafePointer<UnsafeRawPointer?>?,
                  _ ret: UnsafeMutableRawPointer?) {
    print ("SWIFT: ptrFunction called, instance: \(instance)")
}
/* Class Methods */

var sequence = 0
class GDExample: Sprite2D {
    var time_passed: Double
    var id: Int
    
    required init () {
        id = sequence
        sequence += 1
        print ("GDEXAMPLE: Initializing ID=\(id)")
        time_passed = 0
        super.init ()
        print ("GDExample initialized")
    }
    
    deinit {
        print ("GDEXAMPLE: Releasing \(id)")
    }
    
    override func _process (delta: Double) {
        print ("GDExample._process called ID=\(id)")
        time_passed += delta
        
        var newPos = Vector2(x: Float (10 + (10 * sin(time_passed * 2.0))),
                             y: Float (10.0 + (10.0 * cos(time_passed * 1.5))))
        
        self.position = newPos
    }
}
