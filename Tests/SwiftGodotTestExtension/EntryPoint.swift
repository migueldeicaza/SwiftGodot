//
//  EntryPoint.swift
//  SwiftGodotTestExtension
//
//  GDExtension entry point for test extension
//

import SwiftGodot
import SwiftGodotTestability

/// Initialize the test extension when Godot loads it
func initializeTestExtension(level: ExtensionInitializationLevel) {
    if level == .scene {
        // Register the TestRunnerNode so it can be instantiated in scenes
        register(type: TestRunnerNode.self)

        // Register all test suites
        registerAllTestSuites()
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
    guard let godotGetProcAddr, let libraryPtr, let extensionPtr else {
        return 0
    }

    initializeSwiftModule(
        godotGetProcAddr,
        libraryPtr,
        extensionPtr,
        initHook: initializeTestExtension,
        deInitHook: deinitializeTestExtension
    )

    return 1
}
