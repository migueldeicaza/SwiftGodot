//
//  TestResults.swift
//  SwiftGodotTestRunner
//
//  Test result models for JSON parsing (mirrors SwiftGodotTestability.TestResult)
//

import Foundation

/// Status of a single test case
enum TestStatus: String, Codable {
    case passed
    case failed
    case skipped
}

/// Details about a test failure
struct TestFailure: Codable {
    let message: String
    let file: String
    let line: Int
}

/// Result of a single test case execution
struct TestCaseResult: Codable {
    let name: String
    let status: TestStatus
    let durationMs: Int
    let failure: TestFailure?
}

/// Result of a test suite execution
struct TestSuiteResult: Codable {
    let name: String
    let tests: [TestCaseResult]
}

/// Summary statistics for test results
struct TestSummary: Codable {
    let total: Int
    let passed: Int
    let failed: Int
    let skipped: Int
}

/// Complete test results for a test run
struct TestResults: Codable {
    let version: String
    let timestamp: Date
    let durationMs: Int
    let summary: TestSummary
    let suites: [TestSuiteResult]
}
