//
//  GodotTestCase.swift
//
//
//  Created by Padraig O Cinneide on 2023-10-31.
//

import libgodot
@testable import SwiftGodot
import XCTest

var godotLibrary: OpaquePointer!
func embeddedExtensionInit(userData _: UnsafeMutableRawPointer?, l _: GDExtensionInitializationLevel) {}
func embeddedExtensionDeinit(userData _: UnsafeMutableRawPointer?, l _: GDExtensionInitializationLevel) {}
var loadSceneCb: ((SceneTree) -> Void)?

@MainActor
class GodotTestCase: XCTestCase {
    func runInGodot(_ testBlock: @escaping () -> Void) {
        loadSceneCb = { scene in
            testBlock()
            scene.quit()
        }
        libgodot_gdextension_bind(
            { godotGetProcAddr, libraryPtr, extensionInit in
                guard let godotGetProcAddr else {
                    return 0
                }
                let bit = unsafeBitCast(godotGetProcAddr, to: OpaquePointer.self)
                loadGodotInterface(godotGetProcAddr)
                setExtensionInterface(to: bit, library: OpaquePointer(libraryPtr!))
                godotLibrary = OpaquePointer(libraryPtr)!
                extensionInit?.pointee = GDExtensionInitialization(
                    minimum_initialization_level: GDEXTENSION_INITIALIZATION_CORE,
                    userdata: nil,
                    initialize: embeddedExtensionInit,
                    deinitialize: embeddedExtensionDeinit
                )
                return 1

            },
            { startup in
                if let cb = loadSceneCb, let ptr = startup {
                    cb(SceneTree.createFrom(nativeHandle: ptr))
                }
            }
        )

        let args = ["SwiftGodotKit", "--headless"]
        withUnsafePtr(strings: args) { ptr in
            godot_main(Int32(args.count), ptr)
        }
    }
}

// Courtesy of GPT-4
func withUnsafePtr(strings: [String], callback: (UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Void) {
    let cStrings: [UnsafeMutablePointer<Int8>?] = strings.map { string in
        // Convert Swift string to a C string (null-terminated)
        strdup(string)
    }

    // Allocate memory for the array of C string pointers
    let cStringArray = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: cStrings.count + 1)
    cStringArray.initialize(from: cStrings, count: cStrings.count)

    // Add a null pointer at the end of the array to indicate its end
    cStringArray[cStrings.count] = nil

    callback(cStringArray)

    for i in 0 ..< strings.count {
        free(cStringArray[i])
    }
    cStringArray.deallocate()
}
