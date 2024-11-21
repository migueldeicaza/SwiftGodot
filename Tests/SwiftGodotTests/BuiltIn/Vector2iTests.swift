//
//  Vector2iTests.swift
//
//
//  Created by Mikhail Tishin on 21.10.2023.
//

import XCTest
import SwiftGodotTestability
import RegexBuilder
@testable import SwiftGodot

final class Vector2iTests: GodotTestCase {

    static let testInt32s: [Int32] = [
        .min,
        -2,
        -1,
        0,
        1,
        2,
        .max,
    ]

    static let testVectors: [Vector2i] = testInt32s.flatMap { y in
        testInt32s.map { x in
            Vector2i(x: x, y: y)
        }
    }

    func testInitFromVector2i() throws {
        for y in Self.testInt32s {
            try checkCover { Vector2i(from: Vector2i(x: 0, y: y)) }
        }
    }

    func testInitFromVector2() throws {
        for y in Self.testInt32s {
            try checkCover { Vector2i(from: Vector2(x: 0, y: Float(y))) }
        }

        for y: Float in [-.infinity, -1e25, -0.0, 1e25, .infinity, .nan] {
            try checkCover { Vector2i(from: Vector2(x: 0, y: y)) }
        }
    }

    func testAspect() throws {
        for v in Self.testVectors {
            try checkCover { v.aspect() }
        }
    }

    func testMaxAxisIndex() throws {
        for v in Self.testVectors {
            try checkCover { v.maxAxisIndex() }
        }
    }

    func testMinAxisIndex() throws {
        for v in Self.testVectors {
            try checkCover { v.minAxisIndex() }
        }
    }

    func testDistanceTo() throws {
        for v in Self.testVectors {
            for u in Self.testVectors {
                try checkCover { v.distanceTo(u) }
            }
        }
    }

    func testDistanceSquaredTo() throws {
        for v in Self.testVectors {
            for u in Self.testVectors {
                try checkCover { v.distanceSquaredTo(u) }
            }
        }
    }

    func testPlus() throws {
        for v in Self.testVectors {
            for u in Self.testVectors {
                try checkCover { v + u }
            }
        }
    }

    func testOperatorUnaryMinus () {
        var value: Vector2i
        
        value = -Vector2i (x: -1, y: 2)
        XCTAssertEqual (value.x, 1)
        XCTAssertEqual (value.y, -2)
        
        value = -Vector2i (x: 3, y: -4)
        XCTAssertEqual (value.x, -3)
        XCTAssertEqual (value.y, 4)
        
        value = -Vector2i (x: Int32.max, y: Int32.max)
        XCTAssertEqual (value.x, Int32.min + 1)
        XCTAssertEqual (value.y, Int32.min + 1)
        
        value = -Vector2i (x: Int32.min + 1, y: Int32.min + 1)
        XCTAssertEqual (value.x, Int32.max)
        XCTAssertEqual (value.y, Int32.max)
        
        value = -Vector2i (x: Int32.min, y: Int32.min)
        XCTAssertEqual (value.x, Int32.min)
        XCTAssertEqual (value.y, Int32.min)
    }
    
    func testOperatorPlus () {
        var value: Vector2i
        
        value = Vector2i (x: 1, y: 2) + Vector2i (x: 3, y: 4)
        XCTAssertEqual (value.x, 4)
        XCTAssertEqual (value.y, 6)
        
        value = Vector2i (x: -5, y: 6) + Vector2i (x: 7, y: -8)
        XCTAssertEqual (value.x, 2)
        XCTAssertEqual (value.y, -2)
        
        value = Vector2i (x: Int32.max, y: Int32.min) + Vector2i (x: Int32.min, y: Int32.max)
        XCTAssertEqual (value.x, -1)
        XCTAssertEqual (value.y, -1)
        
        value = Vector2i (x: Int32.max, y: Int32.min) + Vector2i (x: Int32.max, y: Int32.min)
        XCTAssertEqual (value.x, -2)
        XCTAssertEqual (value.y, 0)
        
        value = Vector2i (x: Int32.max, y: 1) + Vector2i (x: 1, y: 2)
        XCTAssertEqual (value.x, Int32.min)
        XCTAssertEqual (value.y, 3)
        
        value = Vector2i (x: 1, y: Int32.min) + Vector2i (x: 2, y: -1)
        XCTAssertEqual (value.x, 3)
        XCTAssertEqual (value.y, Int32.max)
    }
    
    func testOperatorMinus () {
        var value: Vector2i
        
        value = Vector2i (x: 1, y: 2) - Vector2i (x: 3, y: 4)
        XCTAssertEqual (value.x, -2)
        XCTAssertEqual (value.y, -2)
        
        value = Vector2i (x: -5, y: 6) - Vector2i (x: 7, y: -8)
        XCTAssertEqual (value.x, -12)
        XCTAssertEqual (value.y, 14)
        
        value = Vector2i (x: Int32.min, y: Int32.max) - Vector2i (x: Int32.min, y: Int32.max)
        XCTAssertEqual (value.x, 0)
        XCTAssertEqual (value.y, 0)
        
        value = Vector2i (x: Int32.min, y: Int32.max) - Vector2i (x: Int32.max, y: Int32.min)
        XCTAssertEqual (value.x, 1)
        XCTAssertEqual (value.y, -1)
        
        value = Vector2i (x: Int32.min, y: Int32.max) - Vector2i (x: 2, y: -3)
        XCTAssertEqual (value.x, Int32.max - 1)
        XCTAssertEqual (value.y, Int32.min + 2)
        
        value = Vector2i (x: Int32.max - 1, y: Int32.min + 2) - Vector2i (x: -3, y: 4)
        XCTAssertEqual (value.x, Int32.min + 1)
        XCTAssertEqual (value.y, Int32.max - 1)
    }
    
}
