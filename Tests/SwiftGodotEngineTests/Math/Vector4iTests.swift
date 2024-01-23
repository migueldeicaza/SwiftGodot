// Based on godot/tests/core/math/test_vector4i.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector4iTests: GodotTestCase {
    
    func testConstructorMethods () {
        let vectorEmpty: Vector4i = Vector4i ()
        let vectorZero: Vector4i = Vector4i (x: 0, y: 0, z: 0, w: 0)
        XCTAssertEqual (vectorEmpty, vectorZero, "Vector4i Constructor with no inputs should return a zero Vector4i.")
    }

    func testAxisMethods () {
        var vector: Vector4i = Vector4i (x: 1, y: 2, z: 3, w: 4)
        XCTAssertEqual (vector.maxAxisIndex (), Vector4i.Axis.w.rawValue, "Vector4i maxAxisIndex should work as expected.")
        XCTAssertEqual (vector.minAxisIndex (), Vector4i.Axis.x.rawValue, "Vector4i minAxisIndex should work as expected.")
        XCTAssertEqual (vector [vector.maxAxisIndex ()], 4, "Vector4i array operator should work as expected.")
        XCTAssertEqual (vector [vector.minAxisIndex ()], 1, "Vector4i array operator should work as expected.")
        
        vector [Vector4i.Axis.y.rawValue] = 5
        XCTAssertEqual (vector [Vector4i.Axis.y.rawValue], 5, "Vector4i array operator setter should work as expected.")
    }

    func testClampMethod () {
        let vector: Vector4i = Vector4i (x: 10, y: 10, z: 10, w: 10)
        XCTAssertEqual (Vector4i (x: -5, y: 5, z: 15, w: INT_MAX).clamp (min: Vector4i (), max: vector), Vector4i (x: 0, y: 5, z: 10, w: 10), "Vector4i clamp should work as expected.")
        XCTAssertEqual (vector.clamp (min: Vector4i (x: 0, y: 10, z: 15, w: -10), max: Vector4i (x: 5, y: 10, z: 20, w: -5)), Vector4i (x: 5, y: 10, z: 15, w: -5), "Vector4i clamp should work as expected.")
    }

    func testLengthMethods () {
        let vector1: Vector4i = Vector4i (x: 10, y: 10, z: 10, w: 10)
        let vector2: Vector4i = Vector4i (x: 20, y: 30, z: 40, w: 50)
        XCTAssertEqual (vector1.lengthSquared (), 400, "Vector4i lengthSquared should work as expected and return exact result.")
        assertApproxEqual (vector1.length (), 20, "Vector4i length should work as expected.")
        XCTAssertEqual (vector2.lengthSquared (), 5400, "Vector4i lengthSquared should work as expected and return exact result.")
        assertApproxEqual (vector2.length (), 73.4846922835, "Vector4i length should work as expected.")
    }

    func testOperators () {
        let vector1: Vector4i = Vector4i (x: 4, y: 5, z: 9, w: 2)
        let vector2: Vector4i = Vector4i (x: 1, y: 2, z: 3, w: 4)
        
        XCTAssertEqual (-vector1, Vector4i (x: -4, y: -5, z: -9, w: -2), "Vector4i change of sign should work as expected.")
        XCTAssertEqual ((vector1 + vector2), Vector4i (x: 5, y: 7, z: 12, w: 6), "Vector4i addition with integers should give exact results.")
        XCTAssertEqual ((vector1 - vector2), Vector4i (x: 3, y: 3, z: 6, w: -2), "Vector4i subtraction with integers should give exact results.")
        XCTAssertEqual ((vector1 * vector2), Vector4i (x: 4, y: 10, z: 27, w: 8), "Vector4i multiplication with integers should give exact results.")
        XCTAssertEqual ((vector1 / vector2), Vector4i (x: 4, y: 2, z: 3, w: 0), "Vector4i division with integers should give exact results.")
        
        XCTAssertEqual ((vector1 * 2), Vector4i (x: 8, y: 10, z: 18, w: 4), "Vector4i multiplication with integers should give exact results.")
        XCTAssertEqual ((vector1 / 2), Vector4i (x: 2, y: 2, z: 4, w: 1), "Vector4i division with integers should give exact results.")
        
        XCTAssertEqual (Vector4 (from: vector1), Vector4 (x: 4, y: 5, z: 9, w: 2), "Vector4i cast to Vector4 should work as expected.")
        XCTAssertEqual (Vector4 (from: vector2), Vector4 (x: 1, y: 2, z: 3, w: 4), "Vector4i cast to Vector4 should work as expected.")
        XCTAssertEqual (Vector4i (from: Vector4 (x: 1.1, y: 2.9, z: 3.9, w: 100.5)), Vector4i (x: 1, y: 2, z: 3, w: 100), "Vector4i constructed from Vector4 should work as expected.")
    }

    func testOtherMethods () {
        let vector: Vector4i = Vector4i (x: 1, y: 3, z: -7, w: 13)
        
        // Vector4i().min() and Vector4i.max() are not exposed
        //XCTAssertEqual (vector.min (Vector4i (x: 3, y: 2, z: 5, w: 8)), Vector4i (x: 1, y: 2, z: -7, w: 8), "Vector4i min should return expected value.")
        //XCTAssertEqual (vector.max (Vector4i (x: 5, y: 2, z: 4, w: 8)), Vector4i (x: 5, y: 3, z: 4, w: 13), "Vector4i max should return expected value.")
        
        XCTAssertEqual (vector.snapped (step: Vector4i (x: 4, y: 2, z: 5, w: 8)), Vector4i (x: 0, y: 4, z: -5, w: 16), "Vector4i snapped should work as expected.")
    }

    func testAbsAndSignMethods () {
        let vector1: Vector4i = Vector4i (x: 1, y: 3, z: 5, w: 7)
        let vector2: Vector4i = Vector4i (x: 1, y: -3, z: -5, w: 7)
        XCTAssertEqual (vector1.abs (), vector1, "Vector4i abs should work as expected.")
        XCTAssertEqual (vector2.abs (), vector1, "Vector4i abs should work as expected.")
        
        XCTAssertEqual (vector1.sign (), Vector4i (x: 1, y: 1, z: 1, w: 1), "Vector4i sign should work as expected.")
        XCTAssertEqual (vector2.sign (), Vector4i (x: 1, y: -1, z: -1, w: 1), "Vector4i sign should work as expected.")
    }
    
}
