//
//  main.swift
//
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import XCTest
import SwiftGodot

@MainActor
final class MainTest: XCTestCase {
    
    private func runTests () {
        run (test: VariantTests ())
        run (test: Vector2iTests ())
        run (test: Vector3iTests ())
        run (test: Vector4iTests ())
    }
    
    private func run (test: XCTest) {
        XCTestSuite.default.perform (XCTestRun (test: test))
    }
    
    override func run () {
        GodotRuntime.run {
            self.runTests ()
            GodotRuntime.stop ()
        }
    }
    
    func test () {
    }
    
}

@MainActor
class GodotTestCase: XCTestCase {
    
    override func run () {
        guard GodotRuntime.isRunning else { return }
        super.run ()
    }
    
}
