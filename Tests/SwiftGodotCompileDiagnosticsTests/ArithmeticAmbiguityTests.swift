//
//  ArithmeticAmbiguityTests.swift
//

import SwiftGodot
import XCTest

private func arithmeticWithIntegerLiteralsCompiles() {
    _ = Vector2(x: 1, y: 2) * 2
    _ = Vector3(x: 1, y: 2, z: 3) / 2
    _ = Color(r: 1, g: 1, b: 1, a: 1) * 2
    _ = Vector2i(x: 1, y: 2) * 2

    var v = Vector2(x: 1, y: 2)
    v *= 2
}

final class ArithmeticAmbiguityTests: XCTestCase {
    func testArithmeticFixtureIsCompiled() {
        XCTAssertTrue(true)
    }
}
