//
//  AllTests.swift
//  SwiftGodotTestExtension
//
//  Registers all test suites with the TestRunner
//

import SwiftGodotTestability

// Import test modules
@_exported import SwiftGodotTests
@_exported import SwiftGodotEngineTests

/// Register all test suites with the TestRunner.
/// This is called during extension initialization.
///
/// NOTE: Only tests that have been migrated to the new format (with public class,
/// allTests property, and public required init()) are registered here.
/// Additional tests need to be migrated before they can be added.
public func registerAllTestSuites() {
    let runner = TestRunner.shared

    // Migrated SwiftGodotTests suites
    runner.addSuite(SignalTests.self)
    runner.addSuite(WrappedTests.self)
    runner.addSuite(DuplicateClassRegistrationTests.self)
    runner.addSuite(PerformanceTests.self)

    // TODO: Migrate remaining test suites:
    // - VariantTests
    // - MarshalTests
    // - MemoryLeakTests
    // - LifecycleTests
    // - SnappingTests
    // - LinearInterpolationTests
    // - TypedArrayTests
    // - TypedDictionaryTests
    // - MacroCallableIntegrationTests
    // - MacroIntegrationTests
    // - ValidatePropertyTests
    // - IntersectRayResultTests
    // - PhysicsDirectSpaceState2DIntersectRayResultTests
    // - PhysicsDirectSpaceState3DIntersectRayResultTests
    // - BuiltIn/* tests
    // - SwiftGodotEngineTests/Math/* tests
}
