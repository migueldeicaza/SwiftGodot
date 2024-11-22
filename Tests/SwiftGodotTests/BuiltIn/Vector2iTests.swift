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

    static let testInt64s: [Int64] = [
        .min,
        Int64(Int32.min) - 1,
        Int64(Int32.min),
        -2,
        -1,
        0,
        1,
        2,
        Int64(Int32.max),
        Int64(Int32.max) + 1,
        .max
    ]

    static let testDoubles: [Double] = testInt64s.map { Double($0) } + [
        -.infinity,
        -1e100,
        -0.0,
        1e100,
         .infinity,
         .nan
    ]

    static let testVectors: [Vector2i] = testInt32s.flatMap { y in
        testInt32s.map { x in
            Vector2i(x: x, y: y)
        }
    }

    func testInitFromVector2i() throws {
        for v in Self.testVectors {
            try checkCover { Vector2i(from: v) }
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

    func testNullaryCovers() throws {
        // Methods of the form Vector2i.method().

        func checkMethod(
            _ method: (Vector2i) -> () -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            for v in Self.testVectors {
                try checkCover(filePath: filePath, line: line) { method(v)() }
            }
        }

        try checkMethod(Vector2i.aspect)
        try checkMethod(Vector2i.maxAxisIndex)
        try checkMethod(Vector2i.minAxisIndex)
        try checkMethod(Vector2i.length)
        try checkMethod(Vector2i.lengthSquared)
        try checkMethod(Vector2i.sign)
        try checkMethod(Vector2i.abs)
    }

    func testUnaryCovers_Vector2i() throws {
        // Methods of the form Vector2i.method(Vector2i).

        func checkMethod(
            _ method: (Vector2i) -> (Vector2i) -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            for v in Self.testVectors {
                for u in Self.testVectors {
                    try checkCover(filePath: filePath, line: line) { method(v)(u) }
                }
            }
        }

        try checkMethod(Vector2i.distanceTo)
        try checkMethod(Vector2i.distanceSquaredTo)
        try checkMethod(Vector2i.min(with:))
        try checkMethod(Vector2i.max(with:))
    }

    func testClamp() throws {
        for v in Self.testVectors {
            for u in Self.testVectors {
                for w in Self.testVectors {
                    try checkCover { v.clamp(min: u, max: w) }
                }
            }
        }
    }

    func testClampi() throws {
        for v in Self.testVectors {
            for i in Self.testInt64s {
                for j in Self.testInt64s {
                    try checkCover { v.clampi(min: i, max: j) }
                }
            }
        }
    }

    func testSnappedi() throws {
        for v in Self.testVectors {
            for i in Self.testInt64s {
                try checkCover { v.snappedi(step: i) }
            }
        }
    }

    func testMini() throws {
        for v in Self.testVectors {
            for i in Self.testInt64s {
                try checkCover { v.mini(with: i) }
            }
        }
    }

    func testMaxi() throws {
        for v in Self.testVectors {
            for i in Self.testInt64s {
                try checkCover { v.maxi(with: i) }
            }
        }
    }

    func testSubscriptGet() throws {
        for v in Self.testVectors {
            for i in Vector2i.Axis.allCases {
                try checkCover {
                    var v = v
                    return v[i.rawValue]
                }
            }
        }
    }

    func testSubscriptSet() throws {
        for v in Self.testVectors {
            for i in Vector2i.Axis.allCases {
                for j in Self.testInt64s {
                    try checkCover {
                        var v = v
                        v[i.rawValue] = j
                        return v
                    }
                }
            }
        }
    }

    func testBinaryOperators_Vector2i_Vector2i() throws {
        // Operators of the form Vector2i * Vector2i.

        func checkOperator(
            _ op: (Vector2i, Vector2i) -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            for v in Self.testVectors {
                for u in Self.testVectors {
                    try checkCover(filePath: filePath, line: line) { op(v, u) }
                }
            }
        }

        try checkOperator(==)
        try checkOperator(!=)
        try checkOperator(<)
        try checkOperator(<=)
        try checkOperator(>)
        try checkOperator(>=)
        try checkOperator(+)
        try checkOperator(-)
        try checkOperator(*)
        try checkOperator(/)

        // try checkOperator(%)
        //
        // The `Vector2i % Vector2i` operator is implemented incorrectly by Godot, for any gdextension that uses the ptrcall API. It performs `Vector2i / Vector2i` instead of what it's supposed to do.
        //
        // See https://github.com/godotengine/godot/issues/99518 for details.
        //
        // Note that it isn't enough for the bug to be fixed in the Godot project. The libgodot project also needs to be fixed, because that's what SwiftGodot actually uses.
        // https://github.com/migueldeicaza/libgodot
    }

    func testBinaryOperators_Vector2i_Int64() throws {
        // Operators of the form Vector2i * Int64.

        func checkOperator(
            _ op: (Vector2i, Int64) -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            for v in Self.testVectors {
                for i in Self.testInt64s {
                    try checkCover(filePath: filePath, line: line) { op(v, i) }
                }
            }
        }

        try checkOperator(*)
        try checkOperator(/)
        try checkOperator(%)
    }

    func testTimesInt64() throws {
        for v in Self.testVectors {
            for d in Self.testDoubles {
                try checkCover { v * d }
            }
        }
    }

    func testDividedByInt64() throws {
        for v in Self.testVectors {
            for d in Self.testDoubles {
                try checkCover { v / d }
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
