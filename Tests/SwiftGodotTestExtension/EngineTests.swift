//
//  EngineTests.swift
//  SwiftGodotTestExtension
//

import SwiftGodot
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime

@SwiftGodotTestSuite
final class EngineTests {
    public func testSingletonBindingIsRenewedAfterReload() {
        for _ in 0..<3 {
            let previous = OS.shared
            guard let handle = previous.handle else {
                fail("OS must have a valid binding before reload")
                return
            }

            // GDExtension::clear_instance_bindings uses this call during reload.
            // The native singleton stays alive; only its Swift binding is freed.
            gi.object_free_instance_binding(
                UnsafeMutableRawPointer(mutating: handle),
                extensionInterface.getLibrary()
            )
            assertNil(previous.handle, "Reload must invalidate the previous wrapper")

            let current = OS.shared
            guard current.handle != nil else {
                fail("Singleton access must create a new binding after reload")
                return
            }
            assertTrue(current.handle == handle, "Reload must retain the native singleton")
            assertFalse(current === previous, "Singleton access must replace the invalid wrapper")
            assertTrue(OS.hasEnvironment(variable: "PATH"), "OS methods must work after reload")
            assertTrue(OS.hasFeature(tagName: "editor"), "The runtime registration check must work after reload")
        }
    }

    public func testGetMainLoopCanBeCastToSceneTree() {
        guard let sceneTree = Engine.getMainLoop() as? SceneTree else {
            fail("Expected Engine.getMainLoop() to return a SceneTree")
            return
        }

        assertNotNil(sceneTree.root, "SceneTree should expose the root window")
    }
}
