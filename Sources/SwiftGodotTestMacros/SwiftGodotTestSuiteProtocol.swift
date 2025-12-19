//
//  SwiftGodotTestSuiteProtocol.swift
//

import SwiftGodot

/// Protocol that defines the interface for a test suite.
///
/// Classes decorated with @SwiftGodotTestSuite automatically conform to this protocol.
/// The protocol provides default implementations for all optional members.
public protocol SwiftGodotTestSuiteProtocol: AnyObject {
    /// The display name of the test case.
    /// Defaults to the class name.
    static var testCaseName: String { get }

    /// Godot subclasses that need to be registered before running tests.
    /// Override to return types that should be registered with ClassDB.
    static var godotSubclasses: [Object.Type] { get }

    /// Array of all tests in this suite.
    /// Generated automatically by @SwiftGodotTestSuite macro.
    var allTests: [SwiftGodotTestInvocation] { get }

    /// Called once before any tests in the suite run.
    static func setUpClass()

    /// Called once after all tests in the suite have run.
    static func tearDownClass()

    /// Called before each test method runs.
    func setUp()

    /// Called after each test method runs.
    func tearDown()
}

// MARK: - Default Implementations

public extension SwiftGodotTestSuiteProtocol {
    /// Default implementation returns the class name.
    static var testCaseName: String {
        String(describing: self)
    }

    /// Default implementation returns an empty array.
    static var godotSubclasses: [Object.Type] {
        []
    }

    /// Default implementation does nothing.
    static func setUpClass() {}

    /// Default implementation does nothing.
    static func tearDownClass() {}

    /// Default implementation does nothing.
    func setUp() {}

    /// Default implementation does nothing.
    func tearDown() {}
}
