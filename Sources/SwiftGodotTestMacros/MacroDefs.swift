//
//  MacroDefs.swift
//

/// Adds SwiftGodotTestSuiteProtocol conformance and generates allTests property.
///
/// This macro:
/// - Adds conformance to SwiftGodotTestSuiteProtocol
/// - Generates `allTests` computed property containing every method whose name
///   begins with `test` (taking no arguments and returning nothing)
///
/// Usage:
/// ```swift
/// @SwiftGodotTestSuite
/// class MyTests {
///     func testFoo() { }
///
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
