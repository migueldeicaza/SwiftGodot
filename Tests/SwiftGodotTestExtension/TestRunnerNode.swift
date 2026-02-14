//
//  TestRunnerNode.swift
//  SwiftGodotTestExtension
//
//  A Godot node that runs all registered tests when added to the scene tree
//

import Foundation
import SwiftGodot

/// A Node that runs all registered tests when added to the scene tree.
/// This is the entry point for test execution inside Godot.
@Godot
public class TestRunnerNode: Node {
    /// Path where JSON results will be written
    private let resultsPath = "res://test_results.json"

    /// Test filter from environment variable (format: "SuiteName" or "SuiteName.testName")
    private var testFilter: TestFilter? {
        guard let filter = ProcessInfo.processInfo.environment["SWIFTGODOT_TEST_FILTER"],
              !filter.isEmpty else {
            return nil
        }
        return TestFilter(filter)
    }

    /// All test suites to run
    private let suites: [any SwiftGodotTestSuiteProtocol] = [
        // Core tests
        SignalTests(),
        WrappedTests(),
        DuplicateClassRegistrationTests(),
        PerformanceTests(),
        VariantTests(),
        MarshalTests(),
        MemoryLeakTests(),
        LifecycleTests(),
        SnappingTests(),
        LinearInterpolationTests(),
        TypedArrayTests(),
        TypedDictionaryTests(),
        MacroCallableIntegrationTests(),
        MacroIntegrationTests(),
        ValidatePropertyTests(),
        RegistrationOrderTests(),
        IntersectRayResultTests(),
        PhysicsDirectSpaceState2DIntersectRayResultTests(),
        PhysicsDirectSpaceState3DIntersectRayResultTests(),
        CodableTests(),

        // BuiltIn type tests
        ColorTests(),
        PackedArrayTests(),
        PlaneTests(),
        QuaternionTests(),
        Vector2Tests(),
        Vector2iTests(),
        Vector3Tests(),
        Vector3iTests(),
        Vector4Tests(),
        Vector4iTests(),

        // Engine math tests
        AABBTests(),
        BasisTests(),
        EngineColorTests(),
        Geometry2DTests(),
        Geometry3DTests(),
        EnginePlaneTests(),
        EngineQuaternionTests(),
        Rect2Tests(),
        Rect2iTests(),
        Transform2DTests(),
        Transform3DTests(),
        EngineVector2Tests(),
        EngineVector2iTests(),
        EngineVector3Tests(),
        EngineVector3iTests(),
        EngineVector4Tests(),
        EngineVector4iTests(),
        AStarTests(),
    ]

    public override func _ready() {
        print("[TestRunnerNode] _ready() called")
        GD.print("=".repeated(60))
        GD.print("SwiftGodot Test Runner")
        GD.print("=".repeated(60))

        let results = runAllTests()
        writeResults(results)

        GD.print("-".repeated(60))
        GD.print("Summary: \(results.summary.passed) passed, \(results.summary.failed) failed, \(results.summary.skipped) skipped")
        GD.print("Total time: \(formatDuration(results.duration))")
        GD.print("=".repeated(60))

        let exitCode = results.summary.failed > 0 ? 1 : 0
        getTree()?.quit(exitCode: Int32(exitCode))
    }

    // MARK: - Test Execution

    private func runAllTests() -> TestResults {
        var suiteResults: [TestSuiteResult] = []
        let startTime = getCurrentTime()

        let filter = testFilter
        let filteredSuites: [any SwiftGodotTestSuiteProtocol]
        if let filter {
            filteredSuites = suites.filter { filter.matchesSuite(type(of: $0).name) }
            GD.print("Running filtered tests: \(filter.suiteName)\(filter.testName.map { ".\($0)" } ?? "")...")
        } else {
            filteredSuites = suites
            GD.print("Running \(suites.count) test suites...")
        }

        for suite in filteredSuites {
            let suiteResult = runSuite(suite, filter: filter)
            suiteResults.append(suiteResult)
        }

        let duration = getCurrentTime() - startTime

        let results = TestResults(suites: suiteResults, duration: duration)
        GD.print("Tests completed: \(results.summary.passed) passed, \(results.summary.failed) failed, \(results.summary.skipped) skipped")

        return results
    }

    private func runSuite(_ suite: any SwiftGodotTestSuiteProtocol, filter: TestFilter? = nil) -> TestSuiteResult {
        let suiteType = type(of: suite)
        let suiteName = suiteType.name
        GD.printRich("[color=blue][b]\(suiteName)[/b][/color]")

        // Register Godot subclasses needed by this suite
        for subclass in suiteType.registeredTypes {
            register(type: subclass)
        }

        // Run test methods (filtered if specified)
        let allTests = suite.allTests
        let tests = filter.map { f in allTests.filter { f.matchesTest($0.name) } } ?? allTests
        var testResults: [TestCaseResult] = []

        for test in tests {
            GD.printRich("[color=blue]\(test.name)[/color]")
            let result = runTest(suite: suite, test: test)
            testResults.append(result)

            if let failure = result.failure {
                GD.printRich("[color=red][b]FAILED:[/b] \(failure.message)[/color]")
                GD.printRich("[color=red]  at \(failure.file):\(failure.line)[/color]")
            }
        }

        // Unregister Godot subclasses
        for subclass in suiteType.registeredTypes.reversed() {
            releasePendingObjects()
            unregister(type: subclass)
        }

        GD.print("")
        return TestSuiteResult(name: suiteName, tests: testResults)
    }

    private func runTest(suite: any SwiftGodotTestSuiteProtocol, test: SwiftGodotTestInvocation) -> TestCaseResult {
        let context = TestContext(testName: test.name)
        TestContext.current = context

        let startTime = getCurrentTime()

        test.run()

        TestContext.current = nil
        let duration = getCurrentTime() - startTime

        let status: TestStatus = context.hasFailed ? .failed : .passed

        return TestCaseResult(
            name: test.name,
            status: status,
            duration: duration,
            failure: context.failures.first
        )
    }

    // MARK: - Results Output

    private func writeResults(_ results: TestResults) {
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

    private func getCurrentTime() -> Double {
        return Date().timeIntervalSince1970
    }

    private func formatDuration(_ seconds: Double) -> String {
        if seconds >= 1.0 {
            return String(format: "%.2fs", seconds)
        } else {
            return String(format: "%.2fms", seconds * 1000)
        }
    }
}

private extension String {
    func repeated(_ times: Int) -> String {
        return String(repeating: self, count: times)
    }
}

/// Filter for running specific tests
struct TestFilter {
    let suiteName: String
    let testName: String?

    init(_ filter: String) {
        let parts = filter.split(separator: ".", maxSplits: 1)
        suiteName = String(parts[0])
        testName = parts.count > 1 ? String(parts[1]) : nil
    }

    func matchesSuite(_ name: String) -> Bool {
        name == suiteName
    }

    func matchesTest(_ name: String) -> Bool {
        testName == nil || testName == name
    }
}
