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
        } else {
            fatalError("It was not possible to construct a \(name)")
        }
    }
}
