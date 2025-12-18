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

    /// All test suites to run
    private let suites: [any GodotTestCaseProtocol.Type] = [
        // Core tests
        SignalTests.self,
        WrappedTests.self,
        DuplicateClassRegistrationTests.self,
        PerformanceTests.self,
        VariantTests.self,
        MarshalTests.self,
        MemoryLeakTests.self,
        LifecycleTests.self,
        SnappingTests.self,
        LinearInterpolationTests.self,
        TypedArrayTests.self,
        TypedDictionaryTests.self,
        MacroCallableIntegrationTests.self,
        MacroIntegrationTests.self,
        ValidatePropertyTests.self,
        IntersectRayResultTests.self,
        PhysicsDirectSpaceState2DIntersectRayResultTests.self,
        PhysicsDirectSpaceState3DIntersectRayResultTests.self,

        // BuiltIn type tests
        ColorTests.self,
        PackedArrayTests.self,
        PlaneTests.self,
        QuaternionTests.self,
        Vector2Tests.self,
        Vector2iTests.self,
        Vector3Tests.self,
        Vector3iTests.self,
        Vector4Tests.self,
        Vector4iTests.self,

        // Engine math tests
        AABBTests.self,
        BasisTests.self,
        EngineColorTests.self,
        Geometry2DTests.self,
        Geometry3DTests.self,
        EnginePlaneTests.self,
        EngineQuaternionTests.self,
        Rect2Tests.self,
        Rect2iTests.self,
        Transform2DTests.self,
        Transform3DTests.self,
        EngineVector2Tests.self,
        EngineVector2iTests.self,
        EngineVector3Tests.self,
        EngineVector3iTests.self,
        EngineVector4Tests.self,
        EngineVector4iTests.self,
        AStarTests.self,
    ]

    public override func _ready() {
        GD.print("=".repeated(60))
        GD.print("SwiftGodot Test Runner")
        GD.print("=".repeated(60))

        let results = runAllTests()
        writeResults(results)

        GD.print("-".repeated(60))
        GD.print("Summary: \(results.summary.passed) passed, \(results.summary.failed) failed, \(results.summary.skipped) skipped")
        GD.print("Total time: \(results.durationMs)ms")
        GD.print("=".repeated(60))

        let exitCode = results.summary.failed > 0 ? 1 : 0
        getTree()?.quit(exitCode: Int32(exitCode))
    }

    // MARK: - Test Execution

    private func runAllTests() -> TestResults {
        var suiteResults: [TestSuiteResult] = []
        let startTime = getCurrentTimeMs()

        GD.print("Running \(suites.count) test suites...")

        for suiteType in suites {
            let suiteResult = runSuite(suiteType)
            suiteResults.append(suiteResult)
        }

        let endTime = getCurrentTimeMs()
        let duration = Int(endTime - startTime)

        let results = TestResults(suites: suiteResults, durationMs: duration)
        GD.print("Tests completed: \(results.summary.passed) passed, \(results.summary.failed) failed, \(results.summary.skipped) skipped")

        return results
    }

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

    private func runTest(suiteType: any GodotTestCaseProtocol.Type, test: GodotTest) -> TestCaseResult {
        let instance = suiteType.init()
        let context = TestContext(testName: test.name)
        TestContext.current = context

        let startTime = getCurrentTimeMs()

        instance.setUp()
        test.run(instance)
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

    private func getCurrentTimeMs() -> UInt64 {
        return UInt64(Date().timeIntervalSince1970 * 1000)
    }
}

private extension String {
    func repeated(_ times: Int) -> String {
        return String(repeating: self, count: times)
    }
}
