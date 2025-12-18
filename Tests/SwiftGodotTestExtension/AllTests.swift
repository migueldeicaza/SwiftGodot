//
//  AllTests.swift
//  SwiftGodotTestExtension
//
//  Provides all test suites for the test runner
//

/// All test suites to run.
func allTestSuites() -> [any GodotTestCaseProtocol.Type] {
    [
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
}

/// Register all test suites with TestRunnerNode.
/// This is called during extension initialization.
public func registerAllTestSuites() {
    TestRunnerNode.suites = allTestSuites()
}
