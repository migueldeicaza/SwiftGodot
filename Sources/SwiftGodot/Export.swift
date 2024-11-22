//
//  
//
//  Created by Miguel de Icaza on 3/25/23.
//

@_implementationOnly import GDExtension

func additionalRegistations (name: StringName) {
    // I guess this is to surface functions to Godot, but not clear why should
    // having the function would be useful
    
//    if false {
//        let methodName = StringName ("_update")
//        
//        var argMeta = UnsafeMutableBufferPointer<GDExtensionClassMethodArgumentMetadata>.allocate(capacity: 1)
//        argMeta [0] = GDEXTENSION_METHOD_ARGUMENT_METADATA_NONE
//        
//        var argInfo = UnsafeMutableBufferPointer<GDExtensionPropertyInfo>.allocate(capacity: 1)
//        var updateName = StringName ("_update")
//        var none = GString ("Swift: no hint provided")
//        argInfo [0] = GDExtensionPropertyInfo(type: GDEXTENSION_VARIANT_TYPE_FLOAT,
//                                              name: UnsafeMutableRawPointer (&updateName.content),
//                                              class_name: UnsafeMutableRawPointer (&name.content),
//                                              hint: 34,
//                                              hint_string: UnsafeMutableRawPointer (&none.content),
//                                              usage: 6)
//        argMeta.withContiguousStorageIfAvailable { argMetaPtr in
//            argInfo.withContiguousStorageIfAvailable { argInfoPtr in
//                
//                var minfo = GDExtensionClassMethodInfo ()
//                minfo.name = UnsafeMutableRawPointer (&methodName.content)
//                minfo.method_userdata = UnsafeMutableRawPointer (bitPattern: 0x123123123)
//                minfo.call_func = callFunc
//                minfo.ptrcall_func = ptrCallFunc
//                minfo.method_flags = UInt32((GDEXTENSION_METHOD_FLAG_VIRTUAL).rawValue)
//                minfo.has_return_value = 0
//                minfo.argument_count = 1
//                minfo.arguments_metadata = UnsafeMutablePointer (mutating: argMetaPtr.baseAddress)
//                minfo.arguments_info = UnsafeMutablePointer (mutating: argInfoPtr.baseAddress)
//                
//                gi.classdb_register_extension_class_method (extensionInterface.getLibrary(), UnsafePointer(&name.content), &minfo)
//            }
//        }
//    }
}

func callFunc (_ method_userdata: UnsafeMutableRawPointer?,
               _ instance: UnsafeMutableRawPointer?,
               _ args: UnsafePointer<UnsafeRawPointer?>?,
               _ argc: Int64,
               _ ret: UnsafeMutableRawPointer?,
               _ error: UnsafeMutablePointer<GDExtensionCallError>?) {
    print ("SWIFT: Function called, instance: \(String(describing: instance))")
}
func ptrCallFunc (_ method_userdata: UnsafeMutableRawPointer?,
                  _ instance: UnsafeMutableRawPointer?,
                  _ args: UnsafePointer<UnsafeRawPointer?>?,
                  _ ret: UnsafeMutableRawPointer?) {
    print ("SWIFT: ptrFunction called, instance: \(String(describing: instance))")
}
/* Class Methods */
