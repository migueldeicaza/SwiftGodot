//
//  EntryPoint.swift
//  SwiftGodotTestExtension
//
//  GDExtension entry point for test extension
//

import SwiftGodot


/// Initialize the test extension when Godot loads it
func initializeTestExtension(level: ExtensionInitializationLevel) {
    if level == .scene {
        register(type: TestRunnerNode.self)
    }
}

/// Deinitialize the test extension
func deinitializeTestExtension(level: ExtensionInitializationLevel) {
    if level == .scene {
        unregister(type: TestRunnerNode.self)
    }
}

/// GDExtension entry point called by Godot
@_cdecl("swift_entry_point")
public func swift_entry_point(
    godotGetProcAddr: OpaquePointer?,
    libraryPtr: OpaquePointer?,
    extensionPtr: OpaquePointer?
) -> UInt8 {
    print("[SwiftGodotTestExtension] Entry point called")
    guard let godotGetProcAddr, let libraryPtr, let extensionPtr else {
        print("[SwiftGodotTestExtension] Missing parameters")
        return 0
    }

    print("[SwiftGodotTestExtension] Initializing Swift module...")
    initializeSwiftModule(
        godotGetProcAddr,
        libraryPtr,
        extensionPtr,
        initHook: initializeTestExtension,
        deInitHook: deinitializeTestExtension
    )

    print("[SwiftGodotTestExtension] Entry point complete")
    return 1
}
