//
//  GodotTestCase.swift
//
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import XCTest
import SwiftGodot

protocol Initializable: XCTestCase {
    init()
}

@MainActor
class GodotTestCase: XCTestCase {
    
    private static var testCases: [XCTestCase] = []
    
    override class var defaultTestSuite: XCTestSuite {
        if let initializable = self as? Initializable.Type {
            testCases.append(initializable.init())
        } else {
            if self != GodotTestCase.self {
                fatalError("\(self) is not Initializable. All GodotTestCase subclasses must conform to Initializable protocol")
            }
        }
        return super.defaultTestSuite
    }
    
    override func run () {
        if GodotRuntime.isRunning {
            super.run()
        } else {
            guard !GodotRuntime.isInitialized else { return }
            GodotRuntime.run {
                for test in Self.testCases {
                    XCTestSuite.default.perform (XCTestRun (test: test))
                }
                GodotRuntime.stop ()
            }
        }
    }
    
}
