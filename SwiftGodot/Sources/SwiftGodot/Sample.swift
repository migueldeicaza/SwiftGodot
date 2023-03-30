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
    info.notification_func = notificationFunc
    
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

var liveObjects: [UnsafeRawPointer:Wrapped] = [:]

func createFunc (_ userData: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    print ("SWIFT: Creating object userData:\(userData)")
    let o = GDExample ()
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
    guard let instance else {
        return
    }
    let original = Unmanaged<GDExample>.fromOpaque(instance).takeUnretainedValue()
    let first = args![0]!
    original._process(delta: first.assumingMemoryBound(to: Double.self).pointee)
    
}

var sequence = 0
class GDExample: Sprite2D {
    var time_passed: Double
    var id: Int
    
    override init () {
        id = sequence
        sequence += 1
        print ("GDEXAMPLE: Initializing ID=\(id)")
        time_passed = 0
        super.init (name: StringName("Sprite2D"))
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
