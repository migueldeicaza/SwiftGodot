// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftGodot

func setupExtension(at level: GDExtension.InitializationLevel) {
    if level == .scene {
        register(type: PlayerController.self)
        register(type: MainLevel.self)
    }
}

@_cdecl("swift_entry_point")
public func swift_entry_point(interfacePtr: OpaquePointer?,
                              libraryPtr: OpaquePointer?,
                              extensionPtr: OpaquePointer?) -> UInt8 {
    guard let interfacePtr, let libraryPtr, let extensionPtr else {
        print("Not all pointers are available.")
        return 0
    }
    initializeSwiftModule(interfacePtr, libraryPtr, extensionPtr, initHook: setupExtension, deInitHook: { _ in })
    return 1
}
