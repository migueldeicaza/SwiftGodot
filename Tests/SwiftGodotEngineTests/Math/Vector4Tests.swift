// Based on godot/tests/core/math/test_vector4.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector4Tests: GodotTestCase {
    
    func testConstructorMethods () {
        let vectorEmpty: Vector4 = Vector4 ()
        let vectorZero: Vector4 = Vector4 (x: 0.0, y: 0.0, z: 0.0, w: 0.0)
        XCTAssertEqual (vectorEmpty, vectorZero, "Vector4 Constructor with no inputs should return a zero Vector4.")
    }

    func testAxisMethods () {
        var vector: Vector4 = Vector4 (x: 1.2, y: 3.4, z: 5.6, w: -0.9)
        XCTAssertEqual (vector.maxAxisIndex (), Vector4.Axis.z.rawValue, "Vector4 maxAxisIndex should work as expected.")
        XCTAssertEqual (vector.minAxisIndex (), Vector4.Axis.w.rawValue, "Vector4 minAxisIndex should work as expected.")
        assertApproxEqual (vector [vector.maxAxisIndex ()], 5.6, "Vector4 array operator should work as expected.")
        assertApproxEqual (vector [vector.minAxisIndex ()], -0.9, "Vector4 array operator should work as expected.")
        
        vector [Vector4.Axis.y.rawValue] = 3.7
        assertApproxEqual (vector [Vector4.Axis.y.rawValue], 3.7, "Vector4 array operator setter should work as expected.")
    }

    func testInterpolationMethods () {
        let vector1: Vector4 = Vector4 (x: 1, y: 2, z: 3, w: 4)
        let vector2: Vector4 = Vector4 (x: 4, y: 5, z: 6, w: 7)
        XCTAssertEqual (vector1.lerp (to: vector2, weight: 0.5), Vector4 (x: 2.5, y: 3.5, z: 4.5, w: 5.5), "Vector4 lerp should work as expected.")
        assertApproxEqual (vector1.lerp (to: vector2, weight: 1.0 / 3.0), Vector4 (x: 2, y: 3, z: 4, w: 5), "Vector4 lerp should work as expected.")
        XCTAssertEqual (vector1.cubicInterpolate (b: vector2, preA: Vector4 (), postB: Vector4 (x: 7, y: 7, z: 7, w: 7), weight: 0.5), Vector4 (x: 2.375, y: 3.5, z: 4.625, w: 5.75), "Vector4 cubicInterpolate should work as expected.")
        assertApproxEqual (vector1.cubicInterpolate (b: vector2, preA: Vector4 (), postB: Vector4 (x: 7, y: 7, z: 7, w: 7), weight: 1.0 / 3.0), Vector4 (x: 1.851851940155029297, y: 2.962963104248046875, z: 4.074074268341064453, w: 5.185185185185), "Vector4 cubicInterpolate should work as expected.")
    }

    func testLengthMethods () {
        let vector1: Vector4 = Vector4 (x: 10, y: 10, z: 10, w: 10)
        let vector2: Vector4 = Vector4 (x: 20, y: 30, z: 40, w: 50)
        XCTAssertEqual (vector1.lengthSquared (), 400, "Vector4 lengthSquared should work as expected and return exact result.")
        assertApproxEqual (vector1.length (), 20, "Vector4 length should work as expected.")
        XCTAssertEqual (vector2.lengthSquared (), 5400, "Vector4 lengthSquared should work as expected and return exact result.")
        assertApproxEqual (vector2.length (), 73.484692283495, "Vector4 length should work as expected.")
        assertApproxEqual (vector1.distanceTo (vector2), 54.772255750517, "Vector4 distanceTo should work as expected.")
        assertApproxEqual (vector1.distanceSquaredTo (vector2), 3000, "Vector4 distanceSquaredTo should work as expected.")
    }

    func testLimitingMethods () {
        let vector: Vector4 = Vector4 (x: 10, y: 10, z: 10, w: 10)
        XCTAssertEqual (Vector4 (x: -5, y: 5, z: 15, w: -15).clamp (min: Vector4 (), max: vector), Vector4 (x: 0, y: 5, z: 10, w: 0), "Vector4 clamp should work as expected.")
        XCTAssertEqual (vector.clamp (min: Vector4 (x: 0, y: 10, z: 15, w: 18), max: Vector4 (x: 5, y: 10, z: 20, w: 25)), Vector4 (x: 5, y: 10, z: 15, w: 18), "Vector4 clamp should work as expected.")
    }

    func testNormalizationMethods () {
        XCTAssertEqual (Vector4 (x: 1, y: 0, z: 0, w: 0).isNormalized (), true, "Vector4 isNormalized should return true for a normalized vector.")
        XCTAssertEqual (Vector4 (x: 1, y: 1, z: 1, w: 1).isNormalized (), false, "Vector4 isNormalized should return false for a non-normalized vector.")
        XCTAssertEqual (Vector4 (x: 1, y: 0, z: 0, w: 0).normalized (), Vector4 (x: 1, y: 0, z: 0, w: 0), "Vector4 normalized should return the same vector for a normalized vector.")
        assertApproxEqual (Vector4 (x: 1, y: 1, z: 0, w: 0).normalized (), Vector4 (x: Float.sqrt12, y: Float.sqrt12, z: 0, w: 0), "Vector4 normalized should work as expected.")
        assertApproxEqual (Vector4 (x: 1, y: 1, z: 1, w: 1).normalized (), Vector4 (x: 0.5, y: 0.5, z: 0.5, w: 0.5), "Vector4 normalized should work as expected.")
    }

    func testOperators () {
        let decimal1: Vector4 = Vector4 (x: 2.3, y: 4.9, z: 7.8, w: 3.2)
        let decimal2: Vector4 = Vector4 (x: 1.2, y: 3.4, z: 5.6, w: 1.7)
        let power1: Vector4 = Vector4 (x: 0.75, y: 1.5, z: 0.625, w: 0.125)
        let power2: Vector4 = Vector4 (x: 0.5, y: 0.125, z: 0.25, w: 0.75)
        let int1: Vector4 = Vector4 (x: 4, y: 5, z: 9, w: 2)
        let int2: Vector4 = Vector4 (x: 1, y: 2, z: 3, w: 1)
        
        XCTAssertEqual (-decimal1, Vector4 (x: -2.3, y: -4.9, z: -7.8, w: -3.2), "Vector4 change of sign should work as expected.")
        assertApproxEqual ((decimal1 + decimal2), Vector4 (x: 3.5, y: 8.3, z: 13.4, w: 4.9), "Vector4 addition should behave as expected.")
        XCTAssertEqual ((power1 + power2), Vector4 (x: 1.25, y: 1.625, z: 0.875, w: 0.875), "Vector4 addition with powers of two should give exact results.")
        XCTAssertEqual ((int1 + int2), Vector4 (x: 5, y: 7, z: 12, w: 3), "Vector4 addition with integers should give exact results.")
        
        assertApproxEqual ((decimal1 - decimal2), Vector4 (x: 1.1, y: 1.5, z: 2.2, w: 1.5), "Vector4 subtraction should behave as expected.")
        XCTAssertEqual ((power1 - power2), Vector4 (x: 0.25, y: 1.375, z: 0.375, w: -0.625), "Vector4 subtraction with powers of two should give exact results.")
        XCTAssertEqual ((int1 - int2), Vector4 (x: 3, y: 3, z: 6, w: 1), "Vector4 subtraction with integers should give exact results.")
        
        assertApproxEqual ((decimal1 * decimal2), Vector4 (x: 2.76, y: 16.66, z: 43.68, w: 5.44), "Vector4 multiplication should behave as expected.")
        XCTAssertEqual ((power1 * power2), Vector4 (x: 0.375, y: 0.1875, z: 0.15625, w: 0.09375), "Vector4 multiplication with powers of two should give exact results.")
        XCTAssertEqual ((int1 * int2), Vector4 (x: 4, y: 10, z: 27, w: 2), "Vector4 multiplication with integers should give exact results.")
        
        assertApproxEqual ((decimal1 / decimal2), Vector4 (x: 1.91666666666666666, y: 1.44117647058823529, z: 1.39285714285714286, w: 1.88235294118), "Vector4 division should behave as expected.")
        XCTAssertEqual ((power1 / power2), Vector4 (x: 1.5, y: 12.0, z: 2.5, w: 1.0 / 6.0), "Vector4 division with powers of two should give exact results.")
        XCTAssertEqual ((int1 / int2), Vector4 (x: 4, y: 2.5, z: 3, w: 2), "Vector4 division with integers should give exact results.")
        
        assertApproxEqual ((decimal1 * 2), Vector4 (x: 4.6, y: 9.8, z: 15.6, w: 6.4), "Vector4 multiplication should behave as expected.")
        XCTAssertEqual ((power1 * 2), Vector4 (x: 1.5, y: 3, z: 1.25, w: 0.25), "Vector4 multiplication with powers of two should give exact results.")
        XCTAssertEqual ((int1 * 2), Vector4 (x: 8, y: 10, z: 18, w: 4), "Vector4 multiplication with integers should give exact results.")
        
        assertApproxEqual ((decimal1 / 2), Vector4 (x: 1.15, y: 2.45, z: 3.9, w: 1.6), "Vector4 division should behave as expected.")
        XCTAssertEqual ((power1 / 2), Vector4 (x: 0.375, y: 0.75, z: 0.3125, w: 0.0625), "Vector4 division with powers of two should give exact results.")
        XCTAssertEqual ((int1 / 2), Vector4 (x: 2, y: 2.5, z: 4.5, w: 1), "Vector4 division with integers should give exact results.")
        
        XCTAssertEqual (Variant (decimal1).description, "(2.3, 4.9, 7.8, 3.2)", "Vector4 cast to String should work as expected.")
        XCTAssertEqual (Variant (decimal2).description, "(1.2, 3.4, 5.6, 1.7)", "Vector4 cast to String should work as expected.")
        XCTAssertEqual (Variant (Vector4 (x: 9.7, y: 9.8, z: 9.9, w: -1.8)).description, "(9.7, 9.8, 9.9, -1.8)", "Vector4 cast to String should work as expected.")
        XCTAssertEqual (Variant (Vector4 (x: Float.e, y: Float.sqrt2, z: Float.sqrt3, w: Float.sqrt3)).description, "(2.718282, 1.414214, 1.732051, 1.732051)", "Vector4 cast to String should print the correct amount of digits for realT = float.")
    }

    func testOtherMethods () {
        let vector: Vector4 = Vector4 (x: 1.2, y: 3.4, z: 5.6, w: 1.6)
        assertApproxEqual (vector.directionTo (Vector4 ()), -vector.normalized (), "Vector4 directionTo should work as expected.")
        assertApproxEqual (Vector4 (x: 1, y: 1, z: 1, w: 1).directionTo (Vector4 (x: 2, y: 2, z: 2, w: 2)), Vector4 (x: 0.5, y: 0.5, z: 0.5, w: 0.5), "Vector4 directionTo should work as expected.")
        assertApproxEqual (vector.inverse (), Vector4 (x: 1 / 1.2, y: 1 / 3.4, z: 1 / 5.6, w: 1 / 1.6), "Vector4 inverse should work as expected.")
        assertApproxEqual (vector.posmod (mod: 2), Vector4 (x: 1.2, y: 1.4, z: 1.6, w: 1.6), "Vector4 posmod should work as expected.")
        assertApproxEqual ((-vector).posmod (mod: 2), Vector4 (x: 0.8, y: 0.6, z: 0.4, w: 0.4), "Vector4 posmod should work as expected.")
        assertApproxEqual (vector.posmodv (modv: Vector4 (x: 1, y: 2, z: 3, w: 4)), Vector4 (x: 0.2, y: 1.4, z: 2.6, w: 1.6), "Vector4 posmodv should work as expected.")
        assertApproxEqual ((-vector).posmodv (modv: Vector4 (x: 2, y: 3, z: 4, w: 5)), Vector4 (x: 0.8, y: 2.6, z: 2.4, w: 3.4), "Vector4 posmodv should work as expected.")
        XCTAssertEqual (vector.snapped (step: Vector4 (x: 1, y: 1, z: 1, w: 1)), Vector4 (x: 1, y: 3, z: 6, w: 2), "Vector4 snapped to integers should be the same as rounding.")
        XCTAssertEqual (vector.snapped (step: Vector4 (x: 0.25, y: 0.25, z: 0.25, w: 0.25)), Vector4 (x: 1.25, y: 3.5, z: 5.5, w: 1.5), "Vector4 snapped to 0.25 should give exact results.")
        
        // Vector4().min() and Vector4.max() are not exposed
        //assertApproxEqual (Vector4 (x: 1.2, y: 2.5, z: 2.0, w: 1.6), vector.min (Vector4 (x: 3.0, y: 2.5, z: 2.0, w: 3.4)), "Vector4 min should return expected value.")
        //assertApproxEqual (Vector4 (x: 5.3, y: 3.4, z: 5.6, w: 4.2), vector.max (Vector4 (x: 5.3, y: 2.0, z: 3.0, w: 4.2)), "Vector4 max should return expected value.")
    }

    func testRoundingMethods () {
        let vector1: Vector4 = Vector4 (x: 1.2, y: 3.4, z: 5.6, w: 1.6)
        let vector2: Vector4 = Vector4 (x: 1.2, y: -3.4, z: -5.6, w: -1.6)
        XCTAssertEqual (vector1.abs (), vector1, "Vector4 abs should work as expected.")
        XCTAssertEqual (vector2.abs (), vector1, "Vector4 abs should work as expected.")
        XCTAssertEqual (vector1.ceil (), Vector4 (x: 2, y: 4, z: 6, w: 2), "Vector4 ceil should work as expected.")
        XCTAssertEqual (vector2.ceil (), Vector4 (x: 2, y: -3, z: -5, w: -1), "Vector4 ceil should work as expected.")
        
        XCTAssertEqual (vector1.floor (), Vector4 (x: 1, y: 3, z: 5, w: 1), "Vector4 floor should work as expected.")
        XCTAssertEqual (vector2.floor (), Vector4 (x: 1, y: -4, z: -6, w: -2), "Vector4 floor should work as expected.")
        
        XCTAssertEqual (vector1.round (), Vector4 (x: 1, y: 3, z: 6, w: 2), "Vector4 round should work as expected.")
        XCTAssertEqual (vector2.round (), Vector4 (x: 1, y: -3, z: -6, w: -2), "Vector4 round should work as expected.")
        
        XCTAssertEqual (vector1.sign (), Vector4 (x: 1, y: 1, z: 1, w: 1), "Vector4 sign should work as expected.")
        XCTAssertEqual (vector2.sign (), Vector4 (x: 1, y: -1, z: -1, w: -1), "Vector4 sign should work as expected.")
    }

    func testLinearAlgebraMethods () {
        let vectorX: Vector4 = Vector4 (x: 1, y: 0, z: 0, w: 0)
        let vectorY: Vector4 = Vector4 (x: 0, y: 1, z: 0, w: 0)
        let vector1: Vector4 = Vector4 (x: 1.7, y: 2.3, z: 1, w: 9.1)
        let vector2: Vector4 = Vector4 (x: -8.2, y: -16, z: 3, w: 2.4)
        
        XCTAssertEqual (vectorX.dot (with: vectorY), 0.0, "Vector4 dot product of perpendicular vectors should be zero.")
        XCTAssertEqual (vectorX.dot (with: vectorX), 1.0, "Vector4 dot product of identical unit vectors should be one.")
        XCTAssertEqual ((vectorX * 10).dot (with: vectorX * 10), 100.0, "Vector4 dot product of same direction vectors should behave as expected.")
        assertApproxEqual ((vector1 * 2).dot (with: vector2 * 4), -25.9 * 8, "Vector4 dot product should work as expected.")
    }
    
    func testFiniteNumberChecks () {
        let infinite: [Float] = [.nan, .infinity, -.infinity]
        
        XCTAssertTrue (Vector4 (x: 0, y: 1, z: 2, w: 3).isFinite (), "Vector4(x: 0, y: 1, z: 2, w: 3) should be finite")
        
        for x in infinite {
            XCTAssertFalse (Vector4 (x: x, y: 1, z: 2, w: 3).isFinite (), "Vector4 with one component infinite should not be finite.")
            XCTAssertFalse (Vector4 (x: 0, y: x, z: 2, w: 3).isFinite (), "Vector4 with one component infinite should not be finite.")
            XCTAssertFalse (Vector4 (x: 0, y: 1, z: x, w: 3).isFinite (), "Vector4 with one component infinite should not be finite.")
            XCTAssertFalse (Vector4 (x: 0, y: 1, z: 2, w: x).isFinite (), "Vector4 with one component infinite should not be finite.")
        }
        
        for x in infinite {
            for y in infinite {
                XCTAssertFalse (Vector4 (x: x, y: y, z: 2, w: 3).isFinite (), "Vector4 with two components infinite should not be finite.")
                XCTAssertFalse (Vector4 (x: x, y: 1, z: y, w: 3).isFinite (), "Vector4 with two components infinite should not be finite.")
                XCTAssertFalse (Vector4 (x: x, y: 1, z: 2, w: y).isFinite (), "Vector4 with two components infinite should not be finite.")
                XCTAssertFalse (Vector4 (x: 0, y: x, z: y, w: 3).isFinite (), "Vector4 with two components infinite should not be finite.")
                XCTAssertFalse (Vector4 (x: 0, y: x, z: 2, w: y).isFinite (), "Vector4 with two components infinite should not be finite.")
                XCTAssertFalse (Vector4 (x: 0, y: 1, z: x, w: y).isFinite (), "Vector4 with two components infinite should not be finite.")
            }
        }
        
        for x in infinite {
            for y in infinite {
                for z in infinite {
                    XCTAssertFalse (Vector4 (x: 0, y: x, z: y, w: z).isFinite (), "Vector4 with three components infinite should not be finite.")
                    XCTAssertFalse (Vector4 (x: x, y: 1, z: y, w: z).isFinite (), "Vector4 with three components infinite should not be finite.")
                    XCTAssertFalse (Vector4 (x: x, y: y, z: 2, w: z).isFinite (), "Vector4 with three components infinite should not be finite.")
                    XCTAssertFalse (Vector4 (x: x, y: y, z: z, w: 3).isFinite (), "Vector4 with three components infinite should not be finite.")
                }
            }
        }
        
        for x in infinite {
            for y in infinite {
                for z in infinite {
                    for w in infinite {
                        XCTAssertFalse (Vector4 (x: x, y: y, z: z, w: w).isFinite (), "Vector4 with four components infinite should not be finite.")
                    }
                }
            }
        }
    }
    
}
