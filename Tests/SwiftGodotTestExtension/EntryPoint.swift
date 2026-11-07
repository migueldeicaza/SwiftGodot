//
//  EntryPoint.swift
//  SwiftGodotTestExtension
//
//  GDExtension entry point for test extension
//

import SwiftGodot
import Foundation

private func testAutoloads() -> [Autoload] {
    let entries: [Autoload] = [
        .init(name: "SwiftTestState", type: AutoloadTestState.self),
        .init(name: "SwiftTestObserver", type: AutoloadTestObserver.self)
    ]
    switch ProcessInfo.processInfo.environment["SWIFTGODOT_AUTOLOAD_TEST_MODE"] {
    case "empty": return []
    case "reverse": return entries.reversed()
    default: return entries
    }
}

#initSwiftExtension(cdecl: "swift_entry_point", types: [
    // TestRunnerNode must be registered for tests to run
    TestRunnerNode.self,
    // Registration order test classes - intentionally listed in non-topological order
    // to verify that prepareForRegistration() sorts them correctly
    SceneLevelClass.self,
    AnotherSceneLevelClass.self,
    CoreLevelClass.self,
    ServersLevelClass.self,
    ThirdSceneLevelClass.self,
    DemoProbe.self,
    // Verify that listing an autoload here does not register its type twice.
    AutoloadTestState.self
], autoloads: testAutoloads())
