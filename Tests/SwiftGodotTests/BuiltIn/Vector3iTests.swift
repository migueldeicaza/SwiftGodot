//
//  Vector3iTests.swift
//
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector3iTests: GodotTestCase {

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

    static let testVectors: [Vector3i] = testInt32s.flatMap { z in
        testInt32s.flatMap { y in
            testInt32s.map { x in
                Vector3i(x: x, y: y, z: z)
            }
        }
    }

    /// Fewer vectors than `testVectors` for tests where the combinatorial explosion from `testVectors` would be too slow.
    static let testFewerVectors: [Vector3i] = testFewerInt32s.flatMap { z in
        testInt32s.flatMap { y in
            testFewerInt32s.map { x in
                Vector3i(x: x, y: y, z: z)
            }
        }
    }

    /// Vectors where adding or subtracting any two of them won't overflow.
    static let testSmallerVectors: [Vector3i] = testSmallerInt32s.flatMap { z in
        testSmallerInt32s.flatMap { y in
            testSmallerInt32s.map { x in
                Vector3i(x: x, y: y, z: z)
            }
        }
    }

    func testInitFromVector3i() throws {
        for v in Self.testVectors {
            try checkCover { Vector3i(from: v) }
        }
    }

    func testInitFromVector3() throws {
        for y in Self.testInt32s {
            try checkCover { Vector3i(from: Vector3(x: 0, y: Float(y), z: 1)) }
        }

        for y: Float in [-.infinity, -1e25, -0.0, 1e25, .infinity, .nan] {
            try checkCover { Vector3i(from: Vector3(x: 0, y: y, z: 1)) }
        }
    }

    func testNullaryCovers() throws {
        // Methods of the form Vector3i.method().

        func checkMethod(
            _ method: (Vector3i) -> () -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            for v in Self.testVectors {
                try checkCover(filePath: filePath, line: line) { method(v)() }
            }
        }

        try checkMethod(Vector3i.maxAxisIndex)
        try checkMethod(Vector3i.minAxisIndex)
        try checkMethod(Vector3i.length)
        try checkMethod(Vector3i.lengthSquared)
        try checkMethod(Vector3i.sign)
        try checkMethod(Vector3i.abs)
    }

    func testUnaryCovers_Vector3i() throws {
        // Methods of the form Vector3i.method(Vector3i).

        func checkMethod(
            _ method: (Vector3i) -> (Vector3i) -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            for v in Self.testVectors {
                for u in Self.testVectors {
                    try checkCover(filePath: filePath, line: line) { method(v)(u) }
                }
            }
        }

        func checkMethodAvoidingOverflow(
            _ method: (Vector3i) -> (Vector3i) -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            for v in Self.testSmallerVectors {
                for u in Self.testSmallerVectors {
                    try checkCover(filePath: filePath, line: line) { method(v)(u) }
                }
            }
        }

        /// ## Why I restrict the test inputs for `distanceTo` and `distanceSquaredTo`
        ///
        /// Consider this program:
        ///
        /// ```swift
        /// let a = Vector3i(x: .min, y: .min, z: .min)
        /// let b = Vector3i(x: 1, y: .min, z: .min)
        /// let answer = a.distanceTo(b)
        /// ```
        ///
        /// Remarkably, this produces different output depending on whether libgodot was compiled with optimization or not.
        ///
        /// The Godot implementation looks like this:
        ///
        /// ```c++
        /// double Vector3i::distance_to(const Vector3i &p_to) const {
        ///     return (p_to - *this).length();
        /// }
        ///
        /// int64_t Vector3i::length_squared() const {
        ///     return x * (int64_t)x + y * (int64_t)y + z * (int64_t)z;
        /// }
        ///
        /// double Vector3i::length() const {
        ///     return Math::sqrt((double)length_squared());
        /// }
        /// ```
        ///
        /// Note in particular the cast `(int64_t)` in `length_squared`. So the treatment of the X coordinate in a non-optimized build is (using Swift notation):
        ///
        /// ```swift
        ///    square(signExtend(Int32(1) &- Int32.min))
        /// ==
        ///    square(signExtend(0x0000_0001 &- 0x8000_0000))
        /// == // overflow!
        ///    square(signExtend(0x8000_0001))
        /// ==
        ///    square(0xffff_ffff_8000_0001)
        /// ==
        ///    0x3fff_ffff_0000_0001
        /// ```
        ///
        /// But `1 &- Int32.min` is signed integer overflow, and in C++, signed integer overflow is undefined behavior. The optimizer is allowed to assume that undefined behavior doesn't happen. Clang chooses to assume that `b.x - a.x` does not overflow (where, remember, `b.x` and `a.x` are `Int32`). If `b.x - a.x` doesn't overflow, then `Int64(b.x) - Int64(a.x)` is mathematically equal to `b.x - a.x`. So clang's optimizer treats the X coordinate like this:
        ///
        /// ```swift
        ///    square(signExtend(Int32(1)) &- signExtend(Int32.min))
        /// =
        ///    square(0x0000_0000_0000_0001 &- 0xffff_ffff_8000_0000
        /// = // no overflow!
        ///    square(0x0000_0000_8000_0001)
        /// =
        ///    0x4000_0001_0000_0001
        /// ```
        ///
        /// The difference between the two computations is big enough that the `distanceTo` answer is 2147483647.0 in a debug build and 2147483649.0 in a release build.
        ///
        /// I can't know here whether I've been linked to a debug libgodot or a release libgodot. So I simply avoid testing `distanceTo` and `distanceSquaredTo` with inputs that could cause signed integer overflow.


        try checkMethodAvoidingOverflow(Vector3i.distanceTo)
        try checkMethodAvoidingOverflow(Vector3i.distanceSquaredTo)
        try checkMethod(Vector3i.min(with:))
        try checkMethod(Vector3i.max(with:))
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
            for i in Vector3i.Axis.allCases {
                try checkCover {
                    var v = v
                    return v[i.rawValue]
                }
            }
        }
    }

    func testSubscriptSet() throws {
        for v in Self.testVectors {
            for i in Vector3i.Axis.allCases {
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

    func testBinaryOperators_Vector3i_Vector3i() throws {
        // Operators of the form Vector3i * Vector3i.

        func checkOperator(
            _ op: (Vector3i, Vector3i) -> some Equatable,
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
        try checkOperator(%)
    }

    func testBinaryOperators_Vector3i_Int64() throws {
        // Operators of the form Vector3i * Int64.

        func checkOperator(
            _ op: (Vector3i, Int64) -> some Equatable,
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
        var value: Vector3i
        
        value = -Vector3i (x: -1, y: 2, z: -3)
        XCTAssertEqual (value.x, 1)
        XCTAssertEqual (value.y, -2)
        XCTAssertEqual (value.z, 3)
        
        value = -Vector3i (x: 4, y: -5, z: 6)
        XCTAssertEqual (value.x, -4)
        XCTAssertEqual (value.y, 5)
        XCTAssertEqual (value.z, -6)
        
        value = -Vector3i (x: Int32.max, y: Int32.max, z: Int32.max)
        XCTAssertEqual (value.x, Int32.min + 1)
        XCTAssertEqual (value.y, Int32.min + 1)
        XCTAssertEqual (value.z, Int32.min + 1)
        
        value = -Vector3i (x: Int32.min + 1, y: Int32.min + 1, z: Int32.min + 1)
        XCTAssertEqual (value.x, Int32.max)
        XCTAssertEqual (value.y, Int32.max)
        XCTAssertEqual (value.z, Int32.max)
        
        value = -Vector3i (x: Int32.min, y: Int32.min, z: Int32.min)
        XCTAssertEqual (value.x, Int32.min)
        XCTAssertEqual (value.y, Int32.min)
        XCTAssertEqual (value.z, Int32.min)
    }
    
    func testOperatorPlus () {
        var value: Vector3i
        
        value = Vector3i (x: 1, y: 2, z: 3) + Vector3i (x: 4, y: 5, z: 6)
        XCTAssertEqual (value.x, 5)
        XCTAssertEqual (value.y, 7)
        XCTAssertEqual (value.z, 9)
        
        value = Vector3i (x: -7, y: 8, z: -9) + Vector3i (x: 10, y: -11, z: 12)
        XCTAssertEqual (value.x, 3)
        XCTAssertEqual (value.y, -3)
        XCTAssertEqual (value.z, 3)
        
        value = Vector3i (x: Int32.max, y: Int32.max, z: Int32.max) + Vector3i (x: Int32.max, y: Int32.max, z: Int32.max)
        XCTAssertEqual (value.x, -2)
        XCTAssertEqual (value.y, -2)
        XCTAssertEqual (value.z, -2)
        
        value = Vector3i (x: Int32.min, y: Int32.min, z: Int32.min) + Vector3i (x: Int32.min, y: Int32.min, z: Int32.min)
        XCTAssertEqual (value.x, 0)
        XCTAssertEqual (value.y, 0)
        XCTAssertEqual (value.z, 0)
        
        value = Vector3i (x: Int32.max, y: Int32.max, z: Int32.max) + Vector3i (x: 1, y: 2, z: 3)
        XCTAssertEqual (value.x, Int32.min)
        XCTAssertEqual (value.y, Int32.min + 1)
        XCTAssertEqual (value.z, Int32.min + 2)
        
        value = Vector3i (x: Int32.min, y: Int32.min, z: Int32.min) + Vector3i (x: -3, y: -2, z: -1)
        XCTAssertEqual (value.x, Int32.max - 2)
        XCTAssertEqual (value.y, Int32.max - 1)
        XCTAssertEqual (value.z, Int32.max)
    }
    
    func testOperatorMinus () {
        var value: Vector3i
        
        value = Vector3i (x: 1, y: 2, z: 3) - Vector3i (x: 4, y: 5, z: 6)
        XCTAssertEqual (value.x, -3)
        XCTAssertEqual (value.y, -3)
        XCTAssertEqual (value.z, -3)
                
        value = Vector3i (x: -7, y: 8, z: -9) - Vector3i (x: 10, y: -11, z: 12)
        XCTAssertEqual (value.x, -17)
        XCTAssertEqual (value.y, 19)
        XCTAssertEqual (value.z, -21)
        
        value = Vector3i (x: Int32.max, y: Int32.max, z: Int32.max) - Vector3i (x: Int32.min, y: Int32.min, z: Int32.min)
        XCTAssertEqual (value.x, -1)
        XCTAssertEqual (value.y, -1)
        XCTAssertEqual (value.z, -1)
        
        value = Vector3i (x: Int32.min, y: Int32.min, z: Int32.min) - Vector3i (x: Int32.max, y: Int32.max, z: Int32.max)
        XCTAssertEqual (value.x, 1)
        XCTAssertEqual (value.y, 1)
        XCTAssertEqual (value.z, 1)
        
        value = Vector3i (x: Int32.max, y: Int32.max, z: Int32.max) - Vector3i (x: -2, y: -3, z: -4)
        XCTAssertEqual (value.x, Int32.min + 1)
        XCTAssertEqual (value.y, Int32.min + 2)
        XCTAssertEqual (value.z, Int32.min + 3)
        
        value = Vector3i (x: Int32.min, y: Int32.min, z: Int32.min) - Vector3i (x: 5, y: 6, z: 7)
        XCTAssertEqual (value.x, Int32.max - 4)
        XCTAssertEqual (value.y, Int32.max - 5)
        XCTAssertEqual (value.z, Int32.max - 6)
    }
    
}
