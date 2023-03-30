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
    print ("SWIFT: extension_initialize")
    guard l == GDEXTENSION_INITIALIZATION_SCENE else {
        return
    }
    
    var gs = GString("Hello GString")
    var gd = gs.description
    print ("1Got: \(gd)")
    let a = StringName ("2Hello")
    let ad = a.description
    print ("1GotSN \(ad)")
    let x = StringName ("Node")
    let xd = x.description
    print ("StirngName for Node: \(xd)")
    print ("Handle is: \(x.handle)")
    print ("The size of the string is: \(a.length())")
    let y = StringName ("Node")
    print ("The two are \(y.handle) and \(x.handle)")
    let b = a.description
    print ("Ad I got \(b)")
    registerExample()
}

// Scene de-init
public func extension_deinitialize (userData: UnsafeMutableRawPointer?, l: GDExtensionInitializationLevel) {
    print ("SWIFT: extension_deinitialize")
    
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
        print ("SWIFT: ENTRY POINT")
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
