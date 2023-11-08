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
        testSuites.append(testSuite)
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
                    // Executing single test method
                    super.run ()
                }
                
                GodotRuntime.stop ()
            }
        }
    }
    
}
