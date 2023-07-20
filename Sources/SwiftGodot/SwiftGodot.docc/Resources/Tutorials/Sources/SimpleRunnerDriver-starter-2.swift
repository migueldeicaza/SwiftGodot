// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftGodot

@_cdecl("swift_entry_point")
public func swift_entry_point(interfacePtr: OpaquePointer?,
                              libraryPtr: OpaquePointer?,
                              extensionPtr: OpaquePointer?) -> UInt8 {
    guard let interfacePtr, let libraryPtr, let extensionPtr else {
        print("Not all pointers are available.")
        return 0
    }
    initializeSwiftModule(interfacePtr, libraryPtr, extensionPtr, initHook: { _ in }, deInitHook: { _ in })
    return 1
}
