//
//  GodotTestCase.swift
//
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import XCTest

@testable import SwiftGodot

/// Base class for all test cases that run in the Godot runtime.
open class GodotTestCase: XCTestCase {
    open override var testRunClass: AnyClass? {
        // use a dummy run if the engine isn't running to avoid generating output
        !GodotRuntime.isRunning ? DummyTestRun.self : super.testRunClass
    }

    override open func run() {
        // We will be run twice - once in the normal XCTest runtime,
        // and once in the Godot runtime. We only want to actually
        // run the tests in the Godot runtime.
        if GodotRuntime.isRunning {
            super.run()
        }
    }
    
    override open class func setUp() {
        if GodotRuntime.isRunning {
            // register any types that are needed for the tests
            for subclass in godotSubclasses {
                register(type: subclass)
            }
        }
    }

    override open class func tearDown() {
        if GodotRuntime.isRunning {
            // unregister any types that were registered for the tests
            for subclass in godotSubclasses {
                unregister(type: subclass)
            }
        }
    }

    override open func tearDown() async throws {
        if GodotRuntime.isRunning {
            // clean up test objects
            let liveObjects: [Wrapped] = Array(liveFrameworkObjects.values) + Array(liveSubtypedObjects.values)
            for liveObject in liveObjects {
                switch liveObject {
                case let node as Node:
                    node.queueFree()
                case let refCounted as RefCounted:
                    refCounted._exp_unref()
                case let object as Object:
                    _ = object.call(method: "free")
                default:
                    print("Unable to free \(liveObject)")
                }
            }
            liveFrameworkObjects.removeAll()
            liveSubtypedObjects.removeAll()

            // waiting for queueFree to take effect
            let scene = try GodotRuntime.getScene()
            await scene.processFrame.emitted
        }
    }

    /// List of types that need to be registered in the Godot runtime.
    /// Subclasses should override this to return the types they need.
    open class var godotSubclasses: [Wrapped.Type] {
        return []
    }

}

/// Test run which does nothing.
/// We return one of these when a Godot test is run
/// without the test engine running. This avoids having
/// duplicate runs of the test appear in the output.
open class DummyTestRun: XCTestCaseRun {
    override init(test: XCTest) {
        super.init(test: XCTestCase())
    }
    open override func start() {
    }
    open override func stop() {
    }
    open override func record(_ issue: XCTIssue) {
    }
    open override var hasBeenSkipped: Bool { true }
    open override var hasSucceeded: Bool { false }
    open override var skipCount: Int { 0 }
    open override var failureCount: Int { 0 }
    open override var executionCount: Int { 0 }
    open override var testCaseCount: Int { 0 }
    open override var unexpectedExceptionCount: Int { 0 }
    open override var totalFailureCount: Int { 0 }

    open override var totalDuration: TimeInterval { 0 }
    open override var testDuration: TimeInterval { 0 }
}
/// Godot testing support.

public extension GodotTestCase {
    
    /// Asserts approximate equality of two floating point values based on `Math::is_equal_approx` implementation in Godot
    func assertApproxEqual<T: FloatingPoint & ExpressibleByFloatLiteral> (_ a: T?, _ b: T?, epsilon: T = 0.00001, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        // Check for exact equality first, required to handle "infinity" values.
        guard a != b else { return }
        guard let a, let b else {
            XCTAssertEqual (a, b, message, file: file, line: line)
            return
        }
        
        // Then check for approximate equality.
        let tolerance: T = max (epsilon * abs (a), epsilon)
        XCTAssertEqual (a, b, accuracy: tolerance, message, file: file, line: line)
    }
    
    /// Asserts approximate equality of two vectors by comparing approximately each component
    func assertApproxEqual (_ a: Vector2?, _ b: Vector2?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        guard let a, let b else {
            XCTAssertEqual (a, b, message, file: file, line: line)
            return
        }
        assertApproxEqual (a.x, b.x, "Fail due to X. " + message, file: file, line: line)
        assertApproxEqual (a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
    }
    
    /// Asserts approximate equality of two vectors by comparing approximately each component
    func assertApproxEqual (_ a: Vector3?, _ b: Vector3?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        guard let a, let b else {
            XCTAssertEqual (a, b, message, file: file, line: line)
            return
        }
        assertApproxEqual (a.x, b.x, "Fail due to X. " + message, file: file, line: line)
        assertApproxEqual (a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
        assertApproxEqual (a.z, b.z, "Fail due to Z. " + message, file: file, line: line)
    }
    
    /// Asserts approximate equality of two vectors by comparing approximately each component
    func assertApproxEqual (_ a: Vector4?, _ b: Vector4?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        guard let a, let b else {
            XCTAssertEqual (a, b, message, file: file, line: line)
            return
        }
        assertApproxEqual (a.x, b.x, "Fail due to X. " + message, file: file, line: line)
        assertApproxEqual (a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
        assertApproxEqual (a.z, b.z, "Fail due to Z. " + message, file: file, line: line)
        assertApproxEqual (a.w, b.w, "Fail due to W. " + message, file: file, line: line)
    }
    
    /// Asserts approximate equality of two quaternions by comparing approximately each component
    func assertApproxEqual (_ a: Quaternion?, _ b: Quaternion?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        guard let a, let b else {
            XCTAssertEqual (a, b, message, file: file, line: line)
            return
        }
        assertApproxEqual (a.x, b.x, "Fail due to X. " + message, file: file, line: line)
        assertApproxEqual (a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
        assertApproxEqual (a.z, b.z, "Fail due to Z. " + message, file: file, line: line)
        assertApproxEqual (a.w, b.w, "Fail due to W. " + message, file: file, line: line)
    }
    
    /// Asserts approximate equality of two colors by comparing approximately each component
    func assertApproxEqual (_ a: Color?, _ b: Color?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        guard let a, let b else {
            XCTAssertEqual (a, b, message, file: file, line: line)
            return
        }
        assertApproxEqual (a.red, b.red, "Fail due to R. " + message, file: file, line: line)
        assertApproxEqual (a.green, b.green, "Fail due to G. " + message, file: file, line: line)
        assertApproxEqual (a.blue, b.blue, "Fail due to B. " + message, file: file, line: line)
        assertApproxEqual (a.alpha, b.alpha, "Fail due to A. " + message, file: file, line: line)
    }
    
}

extension GodotTestCase {

    /**
     * Check that a value is computed the same by a Swift cover and the Godot engine method it replaces.
     */
    public func checkCover(
        filePath: StaticString = #filePath,
        line: UInt = #line,
        _ expression: () throws -> some Equatable
    ) throws {
#if TESTABLE_SWIFT_COVERS
        let coverValue = try $useSwiftCovers.withValue(true) {
            try expression()
        }
        let engineValue = try $useSwiftCovers.withValue(false) {
            try expression()
        }

        // NaNs never compare equal, so first check for bytewise equality.
        let bytewiseEqual = withUnsafeBytes(of: coverValue) { coverBytes in
            withUnsafeBytes(of: engineValue) { engineBytes in
                coverBytes.elementsEqual(engineBytes)
            }
        }

        guard !bytewiseEqual else { return }

        // Not bytewise-equal, but could still compare equal.
        XCTAssertEqual(coverValue, engineValue, file: #filePath, line: line)
#else
        throw XCTSkip("This test requires the compilation condition TESTABLE_SWIFT_COVERS.", file: filePath, line: line)
#endif
    }

    public func forAll<Input>(
        filePath: StaticString = #filePath, line: UInt = #line,
        function: StaticString = #function,
        @TinyGenBuilder _ build: () -> TinyGen<Input>,
        checkCover expression: (Input) throws -> some TestEquatable
    ) rethrows {
#if TESTABLE_SWIFT_COVERS
        let gen = build()

        for k: UInt64 in 1 ... 1_000 {
            var rng = SipRNG(key0: k, key1: 1234)
            // Mix in the function name so every test that starts by asking for, say, a Plane doesn't get the same Plane.
            function.withUTF8Buffer { buffer in
                for byte in buffer {
                    for bit in 0 ..< 8 {
                        rng = (byte & (1 << bit) == 0) ? rng.left() : rng.right()
                    }
                }
            }

            let input = gen(rng)

            let coverOutput = try $useSwiftCovers.withValue(true) {
                try expression(input)
            }
            let engineOutput = try $useSwiftCovers.withValue(false) {
                try expression(input)
            }

            guard coverOutput.closeEnough(to: engineOutput) else {
                XCTFail("Test failure: cover output \(coverOutput) is not close enough to engine output \(engineOutput) for input \(input)", file: filePath, line: line)
                return
            }
        }

#else
        throw XCTSkip("This test requires the compilation condition TESTABLE_SWIFT_COVERS.", file: filePath, line: line)
#endif
    }

}
