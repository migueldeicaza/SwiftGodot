//
//  Vector4iTests.swift
//  
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector4iTests: GodotTestCase {

    static let testInt32s: [Int32] = [
        .min,
        -2,
        -1,
        0,
        1,
        2,
        .max,
    ]

    /// Fewer values to reduce combinatorial explosion.
    static let testFewerInt32s: [Int32] = [
        -2,
        0,
        2,
    ]

    /// Adding or subtracting any two of these won't overflow.
    static let testSmallerInt32s: [Int32] = [
        -(Int32.max / 2),
         -2,
         -1,
         0,
         1,
         2,
         Int32.max / 2,
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

    static let testVectors: [Vector4i] = testInt32s.flatMap { w in
        testInt32s.flatMap { z in
            testInt32s.flatMap { y in
                testInt32s.map { x in
                    Vector4i(x: x, y: y, z: z, w: w)
                }
            }
        }
    }

    /// Fewer vectors than `testVectors` for tests where the combinatorial explosion from `testVectors` would be too slow.
    static let testFewerVectors: [Vector4i] = testFewerInt32s.flatMap { w in
        testFewerInt32s.flatMap { z in
            testInt32s.flatMap { y in
                testFewerInt32s.map { x in
                    Vector4i(x: x, y: y, z: z, w: w)
                }
            }
        }
    }

    /// Vectors where adding or subtracting any two of them won't overflow.
    static let testSmallerVectors: [Vector4i] = testSmallerInt32s.flatMap { w in
        testSmallerInt32s.flatMap { z in
            testSmallerInt32s.flatMap { y in
                testSmallerInt32s.map { x in
                    Vector4i(x: x, y: y, z: z, w: w)
                }
            }
        }
    }

    /// Fewer vectors and they won't overflow.
    static let testFewerSmallerVectors: [Vector4i] = testFewerInt32s.flatMap { w in
        testFewerInt32s.flatMap { z in
            testSmallerInt32s.flatMap { y in
                testFewerInt32s.map { x in
                    Vector4i(x: x, y: y, z: z, w: w)
                }
            }
        }
    }

    func testInitFromVector4i() throws {
        for v in Self.testVectors {
            try checkCover { Vector4i(from: v) }
        }
    }

    func testInitFromVector4() throws {
        for y in Self.testInt32s {
            try checkCover { Vector4i(from: Vector4(x: 0, y: Float(y), z: 2, w: 1)) }
        }

        for y: Float in [-.infinity, -1e25, -0.0, 1e25, .infinity, .nan] {
            try checkCover { Vector4i(from: Vector4(x: 0, y: y, z: 2, w: 1))}
        }
    }

    func testNullaryCovers() throws {
        // Methods of the form Vector4i.method().

        func checkMethod(
            _ method: (Vector4i) -> () -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            for v in Self.testVectors {
                try checkCover(filePath: filePath, line: line) { method(v)() }
            }
        }

        try checkMethod(Vector4i.maxAxisIndex)
        try checkMethod(Vector4i.minAxisIndex)
        try checkMethod(Vector4i.length)
        try checkMethod(Vector4i.lengthSquared)
        try checkMethod(Vector4i.sign)
        try checkMethod(Vector4i.abs)
    }

    func testUnaryCovers_Vector4i() throws {
        // Methods of the form Vector4i.method(Vector4i).

        func checkMethod(
            _ method: (Vector4i) -> (Vector4i) -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            for v in Self.testVectors {
                for w in Self.testFewerVectors {
                    try checkCover(filePath: filePath, line: line) { method(v)(w) }
                }
            }
        }

        func checkMethodAvoidingOverflow(
            _ method: (Vector4i) -> (Vector4i) -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            for v in Self.testSmallerVectors {
                for u in Self.testFewerSmallerVectors {
                    try checkCover(filePath: filePath, line: line) { method(v)(u) }
                }
            }
        }

        try checkMethodAvoidingOverflow(Vector4i.distanceTo)
        try checkMethodAvoidingOverflow(Vector4i.distanceSquaredTo)
        try checkMethod(Vector4i.min(with:))
        try checkMethod(Vector4i.max(with:))
    }

    func testClamp() throws {
        for v in Self.testFewerVectors {
            for u in Self.testFewerVectors {
                for w in Self.testFewerVectors {
                    try checkCover { v.clamp(min: u, max: w) }
                }
            }
        }
    }

    func testClampi() throws {
        for v in Self.testFewerVectors {
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
            for i in Vector4i.Axis.allCases {
                try checkCover {
                    var v = v
                    return v[i.rawValue]
                }
            }
        }
    }

    func testSubscriptSet() throws {
        for v in Self.testVectors {
            for i in Vector4i.Axis.allCases {
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

    func testBinaryOperators_Vector4i_Vector4i() throws {
        // Operators of the form Vector4i * Vector4i.

        func checkOperator(
            _ op: (Vector4i, Vector4i) -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            for v in Self.testVectors {
                for u in Self.testFewerVectors {
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
        try checkOperator(%)
    }

    func testBinaryOperators_Vector4i_Int64() throws {
        // Operators of the form Vector4i * Int64.

        func checkOperator(
            _ op: (Vector4i, Int64) -> some Equatable,
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
        var value: Vector4i
        
        value = -Vector4i (x: -1, y: 2, z: -3, w: 4)
        XCTAssertEqual (value.x, 1)
        XCTAssertEqual (value.y, -2)
        XCTAssertEqual (value.z, 3)
        XCTAssertEqual (value.w, -4)
        
        value = -Vector4i (x: 5, y: -6, z: 7, w: -8)
        XCTAssertEqual (value.x, -5)
        XCTAssertEqual (value.y, 6)
        XCTAssertEqual (value.z, -7)
        XCTAssertEqual (value.w, 8)
        
        value = -Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max)
        XCTAssertEqual (value.x, Int32.min + 1)
        XCTAssertEqual (value.y, Int32.min + 1)
        XCTAssertEqual (value.z, Int32.min + 1)
        XCTAssertEqual (value.w, Int32.min + 1)
        
        value = -Vector4i (x: Int32.min + 1, y: Int32.min + 1, z: Int32.min + 1, w: Int32.min + 1)
        XCTAssertEqual (value.x, Int32.max)
        XCTAssertEqual (value.y, Int32.max)
        XCTAssertEqual (value.z, Int32.max)
        XCTAssertEqual (value.w, Int32.max)
        
        value = -Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min)
        XCTAssertEqual (value.x, Int32.min)
        XCTAssertEqual (value.y, Int32.min)
        XCTAssertEqual (value.z, Int32.min)
        XCTAssertEqual (value.w, Int32.min)
    }
    
    func testOperatorPlus () {
        var value: Vector4i
        
        value = Vector4i (x: 1, y: 2, z: 3, w: 4) + Vector4i (x: 5, y: 6, z: 7, w: 8)
        XCTAssertEqual (value.x, 6)
        XCTAssertEqual (value.y, 8)
        XCTAssertEqual (value.z, 10)
        XCTAssertEqual (value.w, 12)
        
        value = Vector4i (x: -9, y: 10, z: -11, w: 12) + Vector4i (x: 13, y: -14, z: 15, w: -16)
        XCTAssertEqual (value.x, 4)
        XCTAssertEqual (value.y, -4)
        XCTAssertEqual (value.z, 4)
        XCTAssertEqual (value.w, -4)
        
        value = Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max) + Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max)
        XCTAssertEqual (value.x, -2)
        XCTAssertEqual (value.y, -2)
        XCTAssertEqual (value.z, -2)
        XCTAssertEqual (value.w, -2)
        
        value = Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min) + Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min)
        XCTAssertEqual (value.x, 0)
        XCTAssertEqual (value.y, 0)
        XCTAssertEqual (value.z, 0)
        XCTAssertEqual (value.w, 0)
        
        value = Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max) + Vector4i (x: 1, y: 2, z: 3, w: 4)
        XCTAssertEqual (value.x, Int32.min)
        XCTAssertEqual (value.y, Int32.min + 1)
        XCTAssertEqual (value.z, Int32.min + 2)
        XCTAssertEqual (value.w, Int32.min + 3)
        
        value = Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min) + Vector4i (x: -5, y: -6, z: -7, w: -8)
        XCTAssertEqual (value.x, Int32.max - 4)
        XCTAssertEqual (value.y, Int32.max - 5)
        XCTAssertEqual (value.z, Int32.max - 6)
        XCTAssertEqual (value.w, Int32.max - 7)
    }
    
    func testOperatorMinus () {
        var value: Vector4i
        
        value = Vector4i (x: 1, y: 2, z: 3, w: 4) - Vector4i (x: 5, y: 6, z: 7, w: 8)
        XCTAssertEqual (value.x, -4)
        XCTAssertEqual (value.y, -4)
        XCTAssertEqual (value.z, -4)
        XCTAssertEqual (value.z, -4)
        
        value = Vector4i (x: -9, y: 10, z: -11, w: 12) - Vector4i (x: 13, y: -14, z: 15, w: -16)
        XCTAssertEqual (value.x, -22)
        XCTAssertEqual (value.y, 24)
        XCTAssertEqual (value.z, -26)
        XCTAssertEqual (value.w, 28)
        
        value = Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max) - Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min)
        XCTAssertEqual (value.x, -1)
        XCTAssertEqual (value.y, -1)
        XCTAssertEqual (value.z, -1)
        XCTAssertEqual (value.w, -1)
        
        value = Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min) - Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max)
        XCTAssertEqual (value.x, 1)
        XCTAssertEqual (value.y, 1)
        XCTAssertEqual (value.z, 1)
        XCTAssertEqual (value.w, 1)
        
        value = Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max) - Vector4i (x: -2, y: -3, z: -4, w: -5)
        XCTAssertEqual (value.x, Int32.min + 1)
        XCTAssertEqual (value.y, Int32.min + 2)
        XCTAssertEqual (value.z, Int32.min + 3)
        XCTAssertEqual (value.w, Int32.min + 4)
        
        value = Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min) - Vector4i (x: 6, y: 7, z: 8, w: 9)
        XCTAssertEqual (value.x, Int32.max - 5)
        XCTAssertEqual (value.y, Int32.max - 6)
        XCTAssertEqual (value.z, Int32.max - 7)
        XCTAssertEqual (value.w, Int32.max - 8)
    }
    
}
