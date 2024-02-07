//
//  GodotRuntime.swift
//
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import libgodot
import Foundation
@_implementationOnly import GDExtension
@testable import SwiftGodot

public final class GodotRuntime {
    enum State {
    case begin
    case running
    case stopping
    case end
    }

    static var state: State = .begin
    static var isRunning: Bool { state == .running }
    
    static var scene: SceneTree?
    
    public static func run (completion: @escaping () -> Void) {
        guard state == .begin else { return }
        state = .running
        runGodot (loadScene: { scene in
            RunLoop.install()
            self.scene = scene
            completion ()
        })
    }
    
    public static func stop () {
        state = .stopping
        scene?.quit ()
    }
    
    public static func getScene () throws -> SceneTree {
        if let scene {
            return scene
        }
        throw RuntimeError.noSceneLoaded
    }
    
    enum RuntimeError: Error {
        case noSceneLoaded
    }
    
}

private var godotLibrary: OpaquePointer!
private var loadSceneCb: ((SceneTree) -> Void)?
private func embeddedExtensionInit (userData _: UnsafeMutableRawPointer?, l _: GDExtensionInitializationLevel) {}
private func embeddedExtensionDeinit (userData _: UnsafeMutableRawPointer?, l _: GDExtensionInitializationLevel) {}

private extension GodotRuntime {
    
    static func runGodot (loadScene: @escaping (SceneTree) -> ()) {
        loadSceneCb = loadScene
        
        libgodot_gdextension_bind (
            { godotGetProcAddr, libraryPtr, extensionInit in
                guard let godotGetProcAddr else {
                    return 0
                }
                let bit = unsafeBitCast (godotGetProcAddr, to: OpaquePointer.self)
                setExtensionInterface (to: bit, library: OpaquePointer (libraryPtr!))
                godotLibrary = OpaquePointer (libraryPtr)!
                extensionInit?.pointee = GDExtensionInitialization (
                    minimum_initialization_level: GDEXTENSION_INITIALIZATION_CORE,
                    userdata: nil,
                    initialize: embeddedExtensionInit,
                    deinitialize: embeddedExtensionDeinit
                )
                return 1

            },
            { ptr in
                if let loadSceneCb, let ptr {
                    loadSceneCb (SceneTree.createFrom (nativeHandle: ptr))
                }
            }
        )

        let args = ["SwiftGodotKit", "--headless", "--verbose"]
        withUnsafePtr (strings: args) { ptr in
            godot_main (Int32 (args.count), ptr)
        }
    }

    // Courtesy of GPT-4
    static func withUnsafePtr (strings: [String], callback: (UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Void) {
        let cStrings: [UnsafeMutablePointer<Int8>?] = strings.map { string in
            // Convert Swift string to a C string (null-terminated)
            strdup (string)
        }

        // Allocate memory for the array of C string pointers
        let cStringArray = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate (capacity: cStrings.count + 1)
        cStringArray.initialize (from: cStrings, count: cStrings.count)

        // Add a null pointer at the end of the array to indicate its end
        cStringArray[cStrings.count] = nil

        callback (cStringArray)

        for i in 0 ..< strings.count {
            free (cStringArray[i])
        }
        cStringArray.deallocate ()
    }

    
}
