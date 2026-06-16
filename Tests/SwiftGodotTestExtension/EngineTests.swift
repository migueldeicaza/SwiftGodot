//
//  EngineTests.swift
//  SwiftGodotTestExtension
//

@testable import SwiftGodot

@SwiftGodotTestSuite
final class EngineTests {
    public func testGetMainLoopCanBeCastToSceneTree() {
        guard let sceneTree = Engine.getMainLoop() as? SceneTree else {
            fail("Expected Engine.getMainLoop() to return a SceneTree")
            return
        }

        assertNotNil(sceneTree.root, "SceneTree should expose the root window")
    }
}
