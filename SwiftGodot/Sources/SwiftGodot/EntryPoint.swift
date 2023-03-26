//
//  EntryPoint.swift: This is where Godot calls initially into the plugin
//  
//  Created by Miguel de Icaza on 3/24/23.
//
// TODO:
//   - Support different extension levels in swift_entry_point
//

import Foundation
import GDExtension

/// The pointer to the Godot Extension Interface
var gi: GDExtensionInterface = GDExtensionInterface()
var library: GDExtensionClassLibraryPtr!
var token: GDExtensionClassLibraryPtr! {
    return library
}

// Scene init
public func extension_initialize (userData: UnsafeMutableRawPointer?, l: GDExtensionInitializationLevel) {
    print ("extension_deinitialize")
    guard l == GDEXTENSION_INITIALIZATION_SCENE else {
        return
    }
    
}

// Scene de-init
public func extension_deinitialize (userData: UnsafeMutableRawPointer?, l: GDExtensionInitializationLevel) {
    print ("extension_deinitialize")
    
    // This is what the sample does
    guard l == GDEXTENSION_INITIALIZATION_SCENE else {
        return
    }
}


// Set the swift.gdextension's entry_symbol to "swift_entry_point
@_cdecl ("swift_entry_point")
public func swift_entry_point(
    interfacePtr: UnsafePointer<GDExtensionInterface>?,
    ptrLibrary: GDExtensionClassLibraryPtr?,
    initialization: UnsafeMutablePointer<GDExtensionInitialization>?) -> GDExtensionBool {
        print ("I am being called!")
        guard let interfacePtr else {
            return 0
        }
        gi = interfacePtr.pointee
        guard let ptrLibrary else {
            return 0
        }
        library = ptrLibrary
        
        initialization?.pointee.deinitialize = extension_deinitialize
        initialization?.pointee.initialize = extension_initialize
        initialization?.pointee.minimum_initialization_level = GDEXTENSION_INITIALIZATION_CORE
        return 1
}

public class Object {
    var handle: OpaquePointer
    public init (h: OpaquePointer) { handle = h }
}
