//
//  GodotTestCase.swift
//
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import XCTest
import SwiftGodot

@MainActor
open class GodotTestCase: XCTestCase {
    
    private static var testSuites: [XCTestSuite] = []
    
    override open class var defaultTestSuite: XCTestSuite {
        let testSuite = super.defaultTestSuite
        testSuites.append (testSuite)
        return testSuite
    }
    
    override open func run () {
        if GodotRuntime.isRunning {
            super.run ()
        } else {
            guard !GodotRuntime.isInitialized else { return }
            GodotRuntime.run {
                if !Self.testSuites.isEmpty {
                    // Executing all test suites from the context
                    for testSuite in Self.testSuites {
                        testSuite.perform (XCTestSuiteRun (test: testSuite))
                    }
                } else {
                    Self.godotSetUp ()
                    // Executing single test method
                    super.run ()
                    Self.godotTearDown ()
                }
                
                GodotRuntime.stop ()
            }
        }
    }
    
    open class func godotSetUp () {}
    
    override open class func setUp () {
        if GodotRuntime.isRunning {
            godotSetUp ()
        }
    }
    
    open class func godotTearDown () {}
    
    override open class func tearDown () {
        if GodotRuntime.isRunning {
            godotTearDown ()
        }
    }
    
}

public extension GodotTestCase {
    
    /// Asserts approximate equality of two floating point values based on `Math::is_equal_approx` implementation in Godot
    func assertApproxEqual<T: FloatingPoint & ExpressibleByFloatLiteral> (_ a: T, _ b: T, epsilon: T = 0.00001, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        // Check for exact equality first, required to handle "infinity" values.
        guard a != b else { return }
        
        // Then check for approximate equality.
        let tolerance: T = max (epsilon * abs (a), epsilon)
        XCTAssertEqual (a, b, accuracy: tolerance, message, file: file, line: line)
    }
    
    /// Asserts approximate equality of two vectors by comparing approximately each component
    func assertApproxEqual (_ a: Vector2, _ b: Vector2, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        assertApproxEqual (a.x, b.x, "Fail due to X. " + message, file: file, line: line)
        assertApproxEqual (a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
    }
    
    /// Asserts approximate equality of two vectors by comparing approximately each component
    func assertApproxEqual (_ a: Vector3, _ b: Vector3, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        assertApproxEqual (a.x, b.x, "Fail due to X. " + message, file: file, line: line)
        assertApproxEqual (a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
        assertApproxEqual (a.z, b.z, "Fail due to Z. " + message, file: file, line: line)
    }
    
    /// Asserts approximate equality of two vectors by comparing approximately each component
    func assertApproxEqual (_ a: Vector4, _ b: Vector4, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        assertApproxEqual (a.x, b.x, "Fail due to X. " + message, file: file, line: line)
        assertApproxEqual (a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
        assertApproxEqual (a.z, b.z, "Fail due to Z. " + message, file: file, line: line)
        assertApproxEqual (a.w, b.w, "Fail due to W. " + message, file: file, line: line)
    }
    
    /// Asserts approximate equality of two quaternions by comparing approximately each component
    func assertApproxEqual (_ a: Quaternion, _ b: Quaternion, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        assertApproxEqual (a.x, b.x, "Fail due to X. " + message, file: file, line: line)
        assertApproxEqual (a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
        assertApproxEqual (a.z, b.z, "Fail due to Z. " + message, file: file, line: line)
        assertApproxEqual (a.w, b.w, "Fail due to W. " + message, file: file, line: line)
    }
    
}
