//
//  EngineTests.swift
//  SwiftGodotTestExtension
//

@testable import SwiftGodot

@SwiftGodotTestSuite
final class EngineTests {
    @SwiftGodotTest
    public func testGetMainLoopCanBeCastToSceneTree() {
        guard let sceneTree = Engine.getMainLoop() as? SceneTree else {
            XCTFail("Expected Engine.getMainLoop() to return a SceneTree")
            return
        }

        XCTAssertNotNil(sceneTree.root, "SceneTree should expose the root window")
    }
}
