//
//  EntryPoint.swift
//  SwiftGodotTestExtension
//
//  GDExtension entry point for test extension
//

import SwiftGodot

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
    DemoProbe.self
])
