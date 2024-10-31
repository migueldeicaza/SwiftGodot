//
//  GodotTestCase.swift
//
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import XCTest

@testable import SwiftGodot

class __GodotTestRunner: XCTestCase {
    static var failureCount = 0

    func testAAAARunEverythingInGodot() {
        XCTAssert(Self.failureCount == 0, "Some tests failed when running in Godot")
    }

    override func run() {
        if !GodotRuntime.isInitialized {
            GodotRuntime.run {
                let allTests = XCTestSuite.default
                let suite = XCTestSuite(name: "All Tests In Godot")
                for test in allTests.tests {
                    suite.addTest(test)
                }
                suite.run()
                GodotRuntime.stop()
                Self.failureCount = suite.testRun!.totalFailureCount
            }
            super.run()
        }
    }
}

open class GodotTestCase: XCTestCase {
    override open func run() {
        if GodotRuntime.isRunning {
            super.run()
        }
    }

    open override var name: String {
        var name = super.name
        if GodotRuntime.isRunning {
            name.replace("-[", with: "-[Godot.")
            return "Godot." + super.name
        }
        return name
    }

    override open class func setUp() {
        if GodotRuntime.isRunning {
            godotSetUp()
        }
    }

    override open class func tearDown() {
        if GodotRuntime.isRunning {
            godotTearDown()
        }
    }

    override open func tearDown() async throws {
        if GodotRuntime.isRunning {
            // Cleaning up test objects
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

            // Waiting for queueFree to take effect
            let scene = try GodotRuntime.getScene()
            await scene.processFrame.emitted
        }
    }

    open class var godotSubclasses: [Wrapped.Type] {
        return []
    }

    open class func godotSetUp() {
        for subclass in godotSubclasses {
            register(type: subclass)
        }
    }

    open class func godotTearDown() {
        for subclass in godotSubclasses {
            unregister(type: subclass)
        }
    }
}

extension GodotTestCase {

    /// Asserts approximate equality of two floating point values based on `Math::is_equal_approx` implementation in Godot
    public func assertApproxEqual<T: FloatingPoint & ExpressibleByFloatLiteral>(_ a: T?, _ b: T?, epsilon: T = 0.00001, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        // Check for exact equality first, required to handle "infinity" values.
        guard a != b else { return }
        guard let a, let b else {
            XCTAssertEqual(a, b, message, file: file, line: line)
            return
        }

        // Then check for approximate equality.
        let tolerance: T = max(epsilon * abs(a), epsilon)
        XCTAssertEqual(a, b, accuracy: tolerance, message, file: file, line: line)
    }

    /// Asserts approximate equality of two vectors by comparing approximately each component
    public func assertApproxEqual(_ a: Vector2?, _ b: Vector2?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        guard let a, let b else {
            XCTAssertEqual(a, b, message, file: file, line: line)
            return
        }
        assertApproxEqual(a.x, b.x, "Fail due to X. " + message, file: file, line: line)
        assertApproxEqual(a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
    }

    /// Asserts approximate equality of two vectors by comparing approximately each component
    public func assertApproxEqual(_ a: Vector3?, _ b: Vector3?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        guard let a, let b else {
            XCTAssertEqual(a, b, message, file: file, line: line)
            return
        }
        assertApproxEqual(a.x, b.x, "Fail due to X. " + message, file: file, line: line)
        assertApproxEqual(a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
        assertApproxEqual(a.z, b.z, "Fail due to Z. " + message, file: file, line: line)
    }

    /// Asserts approximate equality of two vectors by comparing approximately each component
    public func assertApproxEqual(_ a: Vector4?, _ b: Vector4?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        guard let a, let b else {
            XCTAssertEqual(a, b, message, file: file, line: line)
            return
        }
        assertApproxEqual(a.x, b.x, "Fail due to X. " + message, file: file, line: line)
        assertApproxEqual(a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
        assertApproxEqual(a.z, b.z, "Fail due to Z. " + message, file: file, line: line)
        assertApproxEqual(a.w, b.w, "Fail due to W. " + message, file: file, line: line)
    }

    /// Asserts approximate equality of two quaternions by comparing approximately each component
    public func assertApproxEqual(_ a: Quaternion?, _ b: Quaternion?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        guard let a, let b else {
            XCTAssertEqual(a, b, message, file: file, line: line)
            return
        }
        assertApproxEqual(a.x, b.x, "Fail due to X. " + message, file: file, line: line)
        assertApproxEqual(a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
        assertApproxEqual(a.z, b.z, "Fail due to Z. " + message, file: file, line: line)
        assertApproxEqual(a.w, b.w, "Fail due to W. " + message, file: file, line: line)
    }

    /// Asserts approximate equality of two colors by comparing approximately each component
    public func assertApproxEqual(_ a: Color?, _ b: Color?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        guard let a, let b else {
            XCTAssertEqual(a, b, message, file: file, line: line)
            return
        }
        assertApproxEqual(a.red, b.red, "Fail due to R. " + message, file: file, line: line)
        assertApproxEqual(a.green, b.green, "Fail due to G. " + message, file: file, line: line)
        assertApproxEqual(a.blue, b.blue, "Fail due to B. " + message, file: file, line: line)
        assertApproxEqual(a.alpha, b.alpha, "Fail due to A. " + message, file: file, line: line)
    }

}
