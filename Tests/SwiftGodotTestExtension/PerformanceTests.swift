//
//  PerformanceTests.swift
//
//
//  Created by Patrick Beard on 12/3/23.
//


import SwiftGodot

extension Vector2 {
    static let zero = Vector2(x: 0, y: 0)
}

// Note: Performance testing using XCTCPUMetric and measure() is not available
// in the new test framework. This test has been converted to a basic functional test.
public final class PerformanceTests: GodotTestCase {
    public override class var allTests: [GodotTest] {
        [
            GodotTest(name: "testInputGetVector", method: testInputGetVector),
        ]
    }

    public required init() {}

    public func testInputGetVector() {
        let ui_left = StringName("ui_left")
        let ui_right = StringName("ui_right")
        let ui_up = StringName("ui_up")
        let ui_down = StringName("ui_down")

        let velocity = Input.getVector(
            negativeX: ui_left, positiveX: ui_right,
            negativeY: ui_up, positiveY: ui_down
        )
        XCTAssertEqual(velocity, .zero)
    }
}
