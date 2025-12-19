//
//  TestContext.swift
//  SwiftGodotTestability
//
//  Context for recording test failures during test execution
//

import Foundation

/// Context for recording test failures during test execution.
/// Each test method gets its own context that collects any assertion failures.
final class TestContext {
    /// The current test context. Set by the test runner before executing each test.
    public static var current: TestContext?

    /// The name of the test being executed
    public let testName: String

    /// Failures recorded during test execution
    public private(set) var failures: [TestFailure] = []

    public init(testName: String) {
        self.testName = testName
    }

    /// Record a test failure
    public func recordFailure(message: String, file: String, line: Int) {
        failures.append(TestFailure(message: message, file: file, line: line))
    }

    /// Whether the test has any failures
    public var hasFailed: Bool {
        !failures.isEmpty
    }
}
