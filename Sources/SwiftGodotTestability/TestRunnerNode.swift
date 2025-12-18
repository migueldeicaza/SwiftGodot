//
//  TestRunnerNode.swift
//  SwiftGodotTestability
//
//  A Godot node that runs all registered tests when added to the scene tree
//

import SwiftGodot

/// A Node that runs all registered tests when added to the scene tree.
/// This is the entry point for test execution inside Godot.
///
/// Usage:
/// 1. Register test suites with `TestRunner.shared.addSuite(...)`
/// 2. Create a TestRunnerNode and add it to the scene tree
/// 3. The node will run all tests in `_ready()` and quit Godot with appropriate exit code
@Godot
public class TestRunnerNode: Node {
    /// Path where JSON results will be written
    @Export public var resultsPath: String = "/tmp/swiftgodot_test_results.json"

    public override func _ready() {
        GD.print("=".repeated(60))
        GD.print("SwiftGodot Test Runner")
        GD.print("=".repeated(60))

        // Configure results path
        TestRunner.shared.resultsPath = resultsPath

        // Run all registered tests
        let results = TestRunner.shared.runAllTests()

        // Write results to JSON
        TestRunner.shared.writeResults(results)

        // Print summary
        GD.print("-".repeated(60))
        GD.print("Summary: \(results.summary.passed) passed, \(results.summary.failed) failed, \(results.summary.skipped) skipped")
        GD.print("Total time: \(results.durationMs)ms")
        GD.print("=".repeated(60))

        // Exit Godot with appropriate code
        let exitCode = results.summary.failed > 0 ? 1 : 0
        getTree()?.quit(exitCode: Int32(exitCode))
    }
}

// Helper extension for string repetition
private extension String {
    func repeated(_ times: Int) -> String {
        return String(repeating: self, count: times)
    }
}
