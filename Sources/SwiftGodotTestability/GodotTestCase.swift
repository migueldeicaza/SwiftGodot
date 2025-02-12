//
//  GodotTestCase.swift
//
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import XCTest

@testable import SwiftGodot


/// Base class for all test cases that run in the Godot runtime.
open class GodotTestCase: EmbeddedTestCase<GodotTestHost> {
    open override class func setUp() {
        super.setUp()
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
            for subclass in godotSubclasses.reversed() {
                unregister(type: subclass)
            }
        }
        super.tearDown()
    }

    /// List of types that need to be registered in the Godot runtime.
    /// Subclasses should override this to return the types they need.
    open class var godotSubclasses: [Wrapped.Type] {
        return []
    }

}


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
