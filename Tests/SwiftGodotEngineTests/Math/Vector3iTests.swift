// Based on godot/tests/core/math/test_vector3i.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector3iTests: GodotTestCase {
    
    func testConstructorMethods () {
        let vectorEmpty: Vector3i = Vector3i ()
        let vectorZero: Vector3i = Vector3i (x: 0, y: 0, z: 0)
        XCTAssertEqual (vectorEmpty, vectorZero, "Vector3i Constructor with no inputs should return a zero Vector3i.")
    }

    func testAxisMethods () {
        var vector: Vector3i = Vector3i (x: 1, y: 2, z: 3)
        XCTAssertEqual (vector.maxAxisIndex (), Vector3i.Axis.z.rawValue, "Vector3i maxAxisIndex should work as expected.")
        XCTAssertEqual (vector.minAxisIndex (), Vector3i.Axis.x.rawValue, "Vector3i minAxisIndex should work as expected.")
        XCTAssertEqual (vector [vector.maxAxisIndex ()], 3, "Vector3i array operator should work as expected.")
        XCTAssertEqual (vector [vector.minAxisIndex ()], 1, "Vector3i array operator should work as expected.")
        
        vector [Vector3i.Axis.y.rawValue] = 5
        XCTAssertEqual (vector [Vector3i.Axis.y.rawValue], 5, "Vector3i array operator setter should work as expected.")
    }

    func testClampMethod () {
        let vector: Vector3i = Vector3i (x: 10, y: 10, z: 10)
        XCTAssertEqual (Vector3i (x: -5, y: 5, z: 15).clamp (min: Vector3i (), max: vector), Vector3i (x: 0, y: 5, z: 10), "Vector3i clamp should work as expected.")
        XCTAssertEqual (vector.clamp (min: Vector3i (x: 0, y: 10, z: 15), max: Vector3i (x: 5, y: 10, z: 20)), Vector3i (x: 5, y: 10, z: 15), "Vector3i clamp should work as expected.")
    }

    func testLengthMethods () {
        let vector1: Vector3i = Vector3i (x: 10, y: 10, z: 10)
        let vector2: Vector3i = Vector3i (x: 20, y: 30, z: 40)
        XCTAssertEqual (vector1.lengthSquared (), 300, "Vector3i lengthSquared should work as expected and return exact result.")
        assertApproxEqual (vector1.length (), 10 * Double.sqrt3, "Vector3i length should work as expected.")
        XCTAssertEqual (vector2.lengthSquared (), 2900, "Vector3i lengthSquared should work as expected and return exact result.")
        assertApproxEqual (vector2.length (), 53.8516480713450403125, "Vector3i length should work as expected.")
    }

    func testOperators () {
        let vector1: Vector3i = Vector3i (x: 4, y: 5, z: 9)
        let vector2: Vector3i = Vector3i (x: 1, y: 2, z: 3)
        
        XCTAssertEqual ((vector1 + vector2), Vector3i (x: 5, y: 7, z: 12), "Vector3i addition with integers should give exact results.")
        XCTAssertEqual ((vector1 - vector2), Vector3i (x: 3, y: 3, z: 6), "Vector3i subtraction with integers should give exact results.")
        XCTAssertEqual ((vector1 * vector2), Vector3i (x: 4, y: 10, z: 27), "Vector3i multiplication with integers should give exact results.")
        XCTAssertEqual ((vector1 / vector2), Vector3i (x: 4, y: 2, z: 3), "Vector3i division with integers should give exact results.")
        
        XCTAssertEqual ((vector1 * 2), Vector3i (x: 8, y: 10, z: 18), "Vector3i multiplication with integers should give exact results.")
        XCTAssertEqual ((vector1 / 2), Vector3i (x: 2, y: 2, z: 4), "Vector3i division with integers should give exact results.")
        
        XCTAssertEqual (Vector3 (from: vector1), Vector3 (x: 4, y: 5, z: 9), "Vector3i cast to Vector3 should work as expected.")
        XCTAssertEqual (Vector3 (from: vector2), Vector3 (x: 1, y: 2, z: 3), "Vector3i cast to Vector3 should work as expected.")
        XCTAssertEqual (Vector3i (from: Vector3 (x: 1.1, y: 2.9, z: 3.9)), Vector3i (x: 1, y: 2, z: 3), "Vector3i constructed from Vector3 should work as expected.")
    }

    func testOtherMethods () {
        let vector: Vector3i = Vector3i (x: 1, y: 3, z: -7)
        
        // Vector3i().min() and Vector3i.max() are not exposed
        //XCTAssertEqual (vector.min (Vector3i (x: 3, y: 2, z: 5)), Vector3i (x: 1, y: 2, z: -7), "Vector3i min should return expected value.")
        //XCTAssertEqual (vector.max (Vector3i (x: 5, y: 2, z: 4)), Vector3i (x: 5, y: 3, z: 4), "Vector3i max should return expected value.")
        
        XCTAssertEqual (vector.snapped (step: Vector3i (x: 4, y: 2, z: 5)), Vector3i (x: 0, y: 4, z: -5), "Vector3i snapped should work as expected.")
    }

    func testAbsAndSignMethods () {
        let vector1: Vector3i = Vector3i (x: 1, y: 3, z: 5)
        let vector2: Vector3i = Vector3i (x: 1, y: -3, z: -5)
        XCTAssertEqual (vector1.abs (), vector1, "Vector3i abs should work as expected.")
        XCTAssertEqual (vector2.abs (), vector1, "Vector3i abs should work as expected.")
        
        XCTAssertEqual (vector1.sign (), Vector3i (x: 1, y: 1, z: 1), "Vector3i sign should work as expected.")
        XCTAssertEqual (vector2.sign (), Vector3i (x: 1, y: -1, z: -1), "Vector3i sign should work as expected.")
    }
    
}
