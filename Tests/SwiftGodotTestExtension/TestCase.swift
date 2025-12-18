//
//  TestCase.swift
//  SwiftGodotTestability
//
//  Base class for all Godot runtime tests
//

import SwiftGodot

/// Protocol that all test cases must conform to.
/// This allows type-erased handling of test suites.
public protocol GodotTestCaseProtocol: AnyObject {
    /// Display name for this test case (defaults to class name)
    static var testCaseName: String { get }

    /// Types to register with Godot before running tests in this suite.
    /// Override to provide custom Godot classes needed by your tests.
    static var godotSubclasses: [Object.Type] { get }

    /// All test methods in this test case.
    /// Each tuple contains (test name, test method).
    static var allTests: [GodotTest] { get }

    /// Called once before any tests in this suite run.
    /// Override for suite-level setup.
    static func setUpClass()

    /// Called once after all tests in this suite complete.
    /// Override for suite-level teardown.
    static func tearDownClass()

    /// Called before each test method.
    /// Override for per-test setup.
    func setUp()

    /// Called after each test method.
    /// Override for per-test teardown.
    func tearDown()

    /// Required initializer
    init()
}

/// A test method reference
public struct GodotTest {
    public let name: String
    public let run: (any GodotTestCaseProtocol) -> Void

    public init<T: GodotTestCaseProtocol>(name: String, method: @escaping (T) -> () -> Void) {
        self.name = name
        self.run = { instance in
            guard let typedInstance = instance as? T else { return }
            method(typedInstance)()
        }
    }
}

/// Base class for all test cases that run in the Godot runtime.
/// Subclass this to create test suites.
///
/// Example:
/// ```swift
/// final class MyTests: GodotTestCase {
///     override class var godotSubclasses: [Object.Type] {
///         [MyCustomNode.self]
///     }
///
///     override class var allTests: [GodotTest] {
///         [
///             GodotTest(name: "testSomething", method: testSomething),
///         ]
///     }
///
///     func testSomething() {
///         let node = MyCustomNode()
///         assertEqual(node.value, 42)
///         node.free()
///     }
/// }
/// ```
open class GodotTestCase: GodotTestCaseProtocol {
    /// Display name for this test case (defaults to class name)
    open class var testCaseName: String {
        String(describing: self)
    }

    /// Types to register with Godot before running tests in this suite.
    /// Override to provide custom Godot classes needed by your tests.
    open class var godotSubclasses: [Object.Type] {
        []
    }

    /// All test methods in this test case.
    /// Override to return all tests in this suite.
    open class var allTests: [GodotTest] {
        []
    }

    /// Called once before any tests in this suite run.
    /// Override for suite-level setup.
    open class func setUpClass() {}

    /// Called once after all tests in this suite complete.
    /// Override for suite-level teardown.
    open class func tearDownClass() {}

    /// Called before each test method.
    /// Override for per-test setup.
    open func setUp() {}

    /// Called after each test method.
    /// Override for per-test teardown.
    open func tearDown() {}

    /// Required initializer
    public required init() {}
}
