//
//  MainLoopCastWarningTests.swift
//  SwiftGodotCompileDiagnosticsTests
//

import SwiftGodot
import XCTest

private func documentedMainLoopCastCompilesWithoutWarning() {
    if let sceneTree = Engine.getMainLoop() as? SceneTree {
        _ = sceneTree
    }
}

final class MainLoopCastWarningTests: XCTestCase {
    func testDocumentedMainLoopCastFixtureIsCompiled() {
        XCTAssertTrue(true)
    }
}
