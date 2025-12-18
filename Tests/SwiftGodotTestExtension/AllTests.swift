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
public func registerAllTestSuites() {
    let runner = TestRunner.shared

    // SwiftGodotTests suites
    runner.addSuite(SignalTests.self)
    runner.addSuite(WrappedTests.self)
    runner.addSuite(DuplicateClassRegistrationTests.self)
    runner.addSuite(PerformanceTests.self)
    runner.addSuite(VariantTests.self)
    runner.addSuite(MarshalTests.self)
    runner.addSuite(MemoryLeakTests.self)
    runner.addSuite(LifecycleTests.self)
    runner.addSuite(SnappingTests.self)
    runner.addSuite(LinearInterpolationTests.self)
    runner.addSuite(TypedArrayTests.self)
    runner.addSuite(TypedDictionaryTests.self)
    runner.addSuite(MacroCallableIntegrationTests.self)
    runner.addSuite(MacroIntegrationTests.self)
    runner.addSuite(ValidatePropertyTests.self)
    runner.addSuite(IntersectRayResultTests.self)
    runner.addSuite(PhysicsDirectSpaceState2DIntersectRayResultTests.self)
    runner.addSuite(PhysicsDirectSpaceState3DIntersectRayResultTests.self)

    // BuiltIn tests (from SwiftGodotTests)
    runner.addSuite(SwiftGodotTests.ColorTests.self)
    runner.addSuite(SwiftGodotTests.PackedArrayTests.self)
    runner.addSuite(SwiftGodotTests.PlaneTests.self)
    runner.addSuite(SwiftGodotTests.QuaternionTests.self)
    runner.addSuite(SwiftGodotTests.Vector2Tests.self)
    runner.addSuite(SwiftGodotTests.Vector2iTests.self)
    runner.addSuite(SwiftGodotTests.Vector3Tests.self)
    runner.addSuite(SwiftGodotTests.Vector3iTests.self)
    runner.addSuite(SwiftGodotTests.Vector4Tests.self)
    runner.addSuite(SwiftGodotTests.Vector4iTests.self)

    // Math tests (from SwiftGodotEngineTests)
    runner.addSuite(SwiftGodotEngineTests.AABBTests.self)
    runner.addSuite(SwiftGodotEngineTests.BasisTests.self)
    runner.addSuite(SwiftGodotEngineTests.ColorTests.self)
    runner.addSuite(SwiftGodotEngineTests.Geometry2DTests.self)
    runner.addSuite(SwiftGodotEngineTests.Geometry3DTests.self)
    runner.addSuite(SwiftGodotEngineTests.PlaneTests.self)
    runner.addSuite(SwiftGodotEngineTests.QuaternionTests.self)
    runner.addSuite(SwiftGodotEngineTests.Rect2Tests.self)
    runner.addSuite(SwiftGodotEngineTests.Rect2iTests.self)
    runner.addSuite(SwiftGodotEngineTests.Transform2DTests.self)
    runner.addSuite(SwiftGodotEngineTests.Transform3DTests.self)
    runner.addSuite(SwiftGodotEngineTests.Vector2Tests.self)
    runner.addSuite(SwiftGodotEngineTests.Vector2iTests.self)
    runner.addSuite(SwiftGodotEngineTests.Vector3Tests.self)
    runner.addSuite(SwiftGodotEngineTests.Vector3iTests.self)
    runner.addSuite(SwiftGodotEngineTests.Vector4Tests.self)
    runner.addSuite(SwiftGodotEngineTests.Vector4iTests.self)
    runner.addSuite(SwiftGodotEngineTests.AStarTests.self)
}
