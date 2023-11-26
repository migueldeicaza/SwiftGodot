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
