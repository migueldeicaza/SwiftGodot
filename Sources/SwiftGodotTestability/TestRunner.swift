//
//  TestRunner.swift
//  SwiftGodotTestability
//
//  Test execution engine that discovers and runs tests
//

import Foundation
import SwiftGodot

/// The test runner that executes all registered test suites.
public final class TestRunner {
    /// Shared test runner instance
    public static let shared = TestRunner()

    /// Registered test suite types
    private var suiteTypes: [any GodotTestCaseProtocol.Type] = []

    /// Path where JSON results will be written
    public var resultsPath: String = "/tmp/swiftgodot_test_results.json"

    private init() {}

    /// Register a test suite to be run
    public func addSuite(_ suiteType: any GodotTestCaseProtocol.Type) {
        suiteTypes.append(suiteType)
    }

    /// Register multiple test suites
    public func addSuites(_ types: [any GodotTestCaseProtocol.Type]) {
        suiteTypes.append(contentsOf: types)
    }

    /// Clear all registered suites
    public func clearSuites() {
        suiteTypes.removeAll()
    }

    /// Run all registered test suites and return results
    public func runAllTests() -> TestResults {
        var suiteResults: [TestSuiteResult] = []
        let startTime = getCurrentTimeMs()

        GD.print("Running \(suiteTypes.count) test suites...")

        for suiteType in suiteTypes {
            let suiteResult = runSuite(suiteType)
            suiteResults.append(suiteResult)
        }

        let endTime = getCurrentTimeMs()
        let duration = Int(endTime - startTime)

        let results = TestResults(suites: suiteResults, durationMs: duration)

        GD.print("Tests completed: \(results.summary.passed) passed, \(results.summary.failed) failed, \(results.summary.skipped) skipped")

        return results
    }

    /// Run a single test suite
    private func runSuite(_ suiteType: any GodotTestCaseProtocol.Type) -> TestSuiteResult {
        let suiteName = suiteType.testCaseName
        GD.print("  Suite: \(suiteName)")

        // Register Godot subclasses needed by this suite
        for subclass in suiteType.godotSubclasses {
            register(type: subclass)
        }

        // Suite-level setup
        suiteType.setUpClass()

        // Run all test methods
        let tests = suiteType.allTests
        var testResults: [TestCaseResult] = []

        for test in tests {
            let result = runTest(suiteType: suiteType, test: test)
            testResults.append(result)

            let icon = result.status == .passed ? "+" : "x"
            GD.print("    [\(icon)] \(test.name)")
            if let failure = result.failure {
                GD.print("        \(failure.message)")
                GD.print("        at \(failure.file):\(failure.line)")
            }
        }

        // Suite-level teardown
        suiteType.tearDownClass()

        // Unregister Godot subclasses
        for subclass in suiteType.godotSubclasses.reversed() {
            releasePendingObjects()
            unregister(type: subclass)
        }

        return TestSuiteResult(name: suiteName, tests: testResults)
    }

    /// Run a single test method
    private func runTest(suiteType: any GodotTestCaseProtocol.Type, test: GodotTest) -> TestCaseResult {
        let instance = suiteType.init()
        let context = TestContext(testName: test.name)
        TestContext.current = context

        let startTime = getCurrentTimeMs()

        // Setup
        instance.setUp()

        // Run the test
        test.run(instance)

        // Teardown
        instance.tearDown()

        TestContext.current = nil
        let endTime = getCurrentTimeMs()

        let status: TestStatus = context.hasFailed ? .failed : .passed

        return TestCaseResult(
            name: test.name,
            status: status,
            durationMs: Int(endTime - startTime),
            failure: context.failures.first
        )
    }

    /// Write results to JSON file
    public func writeResults(_ results: TestResults) {
        guard let jsonString = results.toJSON() else {
            GD.printErr("Failed to encode test results to JSON")
            return
        }

        let file = FileAccess.open(path: resultsPath, flags: .write)
        if let file {
            _ = file.storeString(jsonString)
            file.close()
            GD.print("Results written to: \(resultsPath)")
        } else {
            GD.printErr("Failed to open results file: \(resultsPath)")
        }
    }

    /// Get current time in milliseconds
    private func getCurrentTimeMs() -> UInt64 {
        return UInt64(Date().timeIntervalSince1970 * 1000)
    }
}
