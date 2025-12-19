//
//  MacroDefs.swift
//

/// Marks a method as a test to be collected by @SwiftGodotTestSuite.
///
/// Use this attribute on test methods within a @SwiftGodotTestSuite class:
/// ```swift
/// @SwiftGodotTestSuite
/// class MyTests {
///     @SwiftGodotTest
///     func testSomething() {
///         // test code
///     }
/// }
/// ```
@attached(peer)
public macro SwiftGodotTest() = #externalMacro(
    module: "SwiftGodotTestMacrosLibrary",
    type: "SwiftGodotTestMacro"
)

/// Adds SwiftGodotTestSuiteProtocol conformance and generates allTests property.
///
/// This macro:
/// - Adds conformance to SwiftGodotTestSuiteProtocol
/// - Generates `allTests` computed property containing all @SwiftGodotTest methods
///
/// Usage:
/// ```swift
/// @SwiftGodotTestSuite
/// class MyTests {
///     @SwiftGodotTest
///     func testFoo() { }
///
///     @SwiftGodotTest
///     func testBar() { }
/// }
/// ```
///
/// Generates:
/// ```swift
/// extension MyTests: SwiftGodotTestSuiteProtocol {}
///
/// // Inside class:
/// var allTests: [SwiftGodotTestInvocation] {
///     [
///         SwiftGodotTestInvocation(name: "testFoo", run: testFoo),
///         SwiftGodotTestInvocation(name: "testBar", run: testBar),
///     ]
/// }
/// ```
@attached(member, names: named(allTests))
@attached(extension, conformances: SwiftGodotTestSuiteProtocol)
public macro SwiftGodotTestSuite() = #externalMacro(
    module: "SwiftGodotTestMacrosLibrary",
    type: "SwiftGodotTestSuiteMacro"
)
