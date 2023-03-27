//
//  File 2.swift
//  
//
//  Created by Miguel de Icaza on 3/25/23.
//

import Foundation
import GDExtension

class GDExample: Node {
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
        
        let className = StringName ("Node2D")
        
        // Now do set_position
        var y: UnsafeMutableRawPointer?     
        let value = GString ("set_position")
        args = [UnsafeRawPointer(&y), UnsafeRawPointer(&value.handle)]
        let handleSetPosition = ctor2 (UnsafeMutableRawPointer (&y), &args)
        
        //var method_name = StringName ("set_position")
        
        //gi.classdb_get_method_bind (class_name.handle, method_name.handle,
    }
}
