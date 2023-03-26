//
//  File 2.swift
//  
//
//  Created by Miguel de Icaza on 3/25/23.
//

import Foundation
import GDExtension

class GDExample {
    var time_passed: Float

    init () {
        time_passed = 0
    }
    
    func _process (delta: Float) {
        time_passed += delta
        
        var newPos = Vector2(x: 10 + (10 * sin(time_passed * 2.0)),
                             y: 10.0 + (10.0 * cos(time_passed * 1.5)))
        
        //var class_name = Node2D.get_class_static ()
//        StringName::StringName(const String &from) {
//                internal::_call_builtin_constructor(_method_bindings.constructor_2, &opaque, &from);
//        }
        
        let ctor2 = gi.variant_get_ptr_constructor (GDEXTENSION_VARIANT_TYPE_STRING_NAME, 2)!
        var x: UnsafeMutableRawPointer?
        let className = GString ("Node2D")
        var args: [UnsafeRawPointer?] = [
            UnsafeRawPointer (&x),
            UnsafeRawPointer (&className.handle)
        ]
        let stringNameHandle = ctor2 (UnsafeMutableRawPointer(&x), &args)
        var class_name = StringName ()
        
        // Now do set_position
        var y: UnsafeMutableRawPointer?     
        let value = GString ("set_position")
        args = [UnsafeRawPointer(&y), UnsafeRawPointer(&value.handle)]
        let handleSetPosition = ctor2 (UnsafeMutableRawPointer (&y), &args)
        
        //var method_name = StringName ("set_position")
        
        //gi.classdb_get_method_bind (class_name.handle, method_name.handle,
    }
}
