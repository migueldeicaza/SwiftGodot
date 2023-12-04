//
//  PerformanceTests.swift
//  
//
//  Created by Patrick Beard on 12/3/23.
//

import XCTest
import SwiftGodotTestability
import SwiftGodot

extension Vector2 {
    static let zero = Vector2(x: 0, y: 0)
}

final class PerformanceTests: GodotTestCase {
    func testPerformanceExample() throws {
        let metric = XCTCPUMetric()
        
        let ui_left = StringName("ui_left")
        let ui_right = StringName("ui_right")
        let ui_up = StringName("ui_up")
        let ui_down = StringName("ui_down")
        
        self.measure(metrics: [metric]) { 
            let velocity = Input.getVector(
                negativeX: ui_left, positiveX: ui_right,
                negativeY: ui_up, positiveY: ui_down
            )
            XCTAssertEqual(velocity, .zero)
        }
    }
}
