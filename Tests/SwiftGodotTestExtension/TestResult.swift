//
//  TestResult.swift
//  SwiftGodotTestability
//
//  JSON-encodable test result models
//

import Foundation

/// Status of a single test case
public enum TestStatus: String, Codable {
    case passed
    case failed
    case skipped
}

/// Details about a test failure
public struct TestFailure: Codable {
    public let message: String
    public let file: String
    public let line: Int

    public init(message: String, file: String, line: Int) {
        self.message = message
        self.file = file
        self.line = line
    }
}

/// Result of a single test case execution
public struct TestCaseResult: Codable {
    public let name: String
    public let status: TestStatus
    public let durationMs: Int
    public let failure: TestFailure?

    public init(name: String, status: TestStatus, durationMs: Int, failure: TestFailure? = nil) {
        self.name = name
        self.status = status
        self.durationMs = durationMs
        self.failure = failure
    }
}

/// Result of a test suite execution
public struct TestSuiteResult: Codable {
    public let name: String
    public let tests: [TestCaseResult]

    public init(name: String, tests: [TestCaseResult]) {
        self.name = name
        self.tests = tests
    }

    public var passed: Int {
        tests.filter { $0.status == .passed }.count
    }

    public var failed: Int {
        tests.filter { $0.status == .failed }.count
    }

    public var skipped: Int {
        tests.filter { $0.status == .skipped }.count
    }
}

/// Summary statistics for test results
public struct TestSummary: Codable {
    public let total: Int
    public let passed: Int
    public let failed: Int
    public let skipped: Int

    public init(total: Int, passed: Int, failed: Int, skipped: Int) {
        self.total = total
        self.passed = passed
        self.failed = failed
        self.skipped = skipped
    }
}

/// Complete test results for a test run
public struct TestResults: Codable {
    public let version: String
    public let timestamp: Date
    public let durationMs: Int
    public let summary: TestSummary
    public let suites: [TestSuiteResult]

    public init(suites: [TestSuiteResult], durationMs: Int) {
        self.version = "1.0"
        self.timestamp = Date()
        self.durationMs = durationMs
        self.suites = suites

        let total = suites.reduce(0) { $0 + $1.tests.count }
        let passed = suites.reduce(0) { $0 + $1.passed }
        let failed = suites.reduce(0) { $0 + $1.failed }
        let skipped = suites.reduce(0) { $0 + $1.skipped }
        self.summary = TestSummary(total: total, passed: passed, failed: failed, skipped: skipped)
    }

    /// Encode results to JSON string
    public func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}
