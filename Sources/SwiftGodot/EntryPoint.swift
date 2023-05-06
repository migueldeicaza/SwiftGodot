//
//  EntryPoint.swift: This is where Godot calls initially into the plugin
//  
//  Created by Miguel de Icaza on 3/24/23.
//
//

import Foundation
@_implementationOnly import GDExtension

/// The pointer to the Godot Extension Interface
var gi: GDExtensionInterface = GDExtensionInterface()
/// The library pointer we received at startup
var library: GDExtensionClassLibraryPtr!
var token: GDExtensionClassLibraryPtr! {
    return library
}

var extensionInitCallback: ((GDExtension.InitializationLevel)->())?
var extensionDeInitCallback: ((GDExtension.InitializationLevel)->())?

///
/// This method is used to configure the extension interface for SwiftGodot to
/// operate.   It is only used when you use SwiftGodot embedded into an
/// application - as opposed to using SwiftGodot purely as an extension
///
public func setExtensionInterface (to: OpaquePointer?, library lib: OpaquePointer?) {

    guard let pgi = UnsafeMutablePointer<GDExtensionInterface> (to) else {
        print ("Expected a pointer to a GDExtensionInitialization")
        return
    }
    gi = pgi.pointee
    library = GDExtensionClassLibraryPtr (lib)
}

// Extension initialization callback
func extension_initialize (userData: UnsafeMutableRawPointer?, l: GDExtensionInitializationLevel) {
    print ("SWIFT: extension_initialize")
    let level = GDExtension.InitializationLevel(rawValue: Int (exactly: l.rawValue)!)!
    
    if let cb = extensionInitCallback {
        cb (level)
    }
}

// Extension deinitialization callback
func extension_deinitialize (userData: UnsafeMutableRawPointer?, l: GDExtensionInitializationLevel) {
    print ("SWIFT: extension_deinitialize")
    
    let level = GDExtension.InitializationLevel(rawValue: Int (exactly: l.rawValue)!)!
    if let cb = extensionDeInitCallback {
        cb (level)
    }
}

///
/// For use in extensions created for a Godot project
///
/// Call this function from your declared Swift entry point passing the three
/// pointers that you receive from Godot and passing a method that will
/// be invoked during the various stages of the initialization.
///
/// This routine takes OpaquePointers to help you simplify the declaration of
/// your Swift entry point, which can look like this:
///
/// ```
/// @cdecl ("swift_entry_point")
/// public func swift_entry_point (i: OpaquePointer?, l: OpaquePointer?, e: OpaquePointer?) -> UInt8 {
///     guard let iface, let lib, let ext else {
///         return 0
///     }
///     initializeSwiftModule (iface, lib, ext, initHook: myInit, deInitHook: myDeinit)
///     return 1
/// }
///
/// func myInit (level: GDExtension.InitializationLevel) {
///    if level == .scene {
///       registerType (MySpinningCube.self)
///    }
/// }
///
/// func myDeInit (level: GDExtension.InitializationLevel) {
///     if level == .scene {
///         print ("Deinitialized")
///     }
/// }
/// ```
/// - Parameters:
///  - interfacePtr: the first parameter you got on your entry point, it points to the API to communicate with Godot (this is of type GDExtensionInterface>
///  - libraryPtr: the second parameter you entry point gets, it is of type GDExtensionClassLibraryPtr
///  - extensionPtr: the third parameter you get, it is of type GDExtensionInitialization and it is filled with our callbacks
///  - initHook: this method is invoked repeatedly during the various stages of the extension
///  initialization
///  - deInitHook: this method is invoked repeatedly when various stages of the extension are wrapped up
public func initializeSwiftModule (
    _ interfacePtr: OpaquePointer,
    _ libraryPtr: OpaquePointer,
    _ extensionPtr: OpaquePointer,
    initHook: @escaping (GDExtension.InitializationLevel)->(),
    deInitHook: @escaping (GDExtension.InitializationLevel)->())
{
    gi = UnsafePointer<GDExtensionInterface> (interfacePtr).pointee
    library = GDExtensionClassLibraryPtr(libraryPtr)
    
    let initialization = UnsafeMutablePointer<GDExtensionInitialization> (extensionPtr)
    initialization.pointee.deinitialize = extension_deinitialize
    initialization.pointee.initialize = extension_initialize
    initialization.pointee.minimum_initialization_level = GDEXTENSION_INITIALIZATION_CORE
    extensionInitCallback = initHook
    extensionDeInitCallback = deInitHook
}
