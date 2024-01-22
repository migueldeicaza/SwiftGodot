// Based on godot/tests/core/math/test_vector2.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector2Tests: GodotTestCase {
    
    func testConstructorMethods () {
        let vectorEmpty: Vector2 = Vector2 ()
        let vectorZero: Vector2 = Vector2 (x: 0.0, y: 0.0)
        XCTAssertEqual (vectorEmpty, vectorZero, "Vector2 Constructor with no inputs should return a zero Vector2.")
    }

    func testAngleMethods () {
        let vectorX: Vector2 = Vector2 (x: 1, y: 0)
        let vectorY: Vector2 = Vector2 (x: 0, y: 1)
        assertApproxEqual (vectorX.angleTo (vectorY), Double.tau / 4, "Vector2 angleTo should work as expected.")
        assertApproxEqual (vectorY.angleTo (vectorX), -Double.tau / 4, "Vector2 angleTo should work as expected.")
        assertApproxEqual (vectorX.angleToPoint (to: vectorY), Double.tau * 3 / 8, "Vector2 angleToPoint should work as expected.")
        assertApproxEqual (vectorY.angleToPoint (to: vectorX), -Double.tau / 8, "Vector2 angleToPoint should work as expected.")
    }

    func testAxisMethods () {
        var vector: Vector2 = Vector2 (x: 1.2, y: 3.4)
        XCTAssertEqual (vector.maxAxisIndex (), Vector2.Axis.y.rawValue, "Vector2 maxAxisIndex should work as expected.")
        XCTAssertEqual (vector.minAxisIndex (), Vector2.Axis.x.rawValue, "Vector2 minAxisIndex should work as expected.")
        assertApproxEqual (vector [vector.minAxisIndex ()], 1.2, "Vector2 array operator should work as expected.")
        vector [Vector2.Axis.y.rawValue] = 3.7
        assertApproxEqual (vector [Vector2.Axis.y.rawValue], 3.7, "Vector2 array operator setter should work as expected.")
    }
    
    func testInterpolationMethods () {
        let vector1: Vector2 = Vector2 (x: 1, y: 2)
        let vector2: Vector2 = Vector2 (x: 4, y: 5)
        XCTAssertEqual (vector1.lerp (to: vector2, weight: 0.5), Vector2 (x: 2.5, y: 3.5), "Vector2 lerp should work as expected.")
        assertApproxEqual (vector1.lerp (to: vector2, weight: 1.0 / 3.0), Vector2 (x: 2, y: 3), "Vector2 lerp should work as expected.")
        assertApproxEqual (vector1.normalized ().slerp (to: vector2.normalized (), weight: 0.5), Vector2 (x: 0.538953602313995361, y: 0.84233558177947998), "Vector2 slerp should work as expected.")
        assertApproxEqual (vector1.normalized ().slerp (to: vector2.normalized (), weight: 1.0 / 3.0), Vector2 (x: 0.508990883827209473, y: 0.860771894454956055), "Vector2 slerp should work as expected.")
        assertApproxEqual (Vector2 (x: 5, y: 0).slerp (to: Vector2 (x: 0, y: 5), weight: 0.5), Vector2 (x: 5, y: 5) * Double.sqrt12, "Vector2 slerp with non-normalized values should work as expected.")
        assertApproxEqual (Vector2 (x: 1, y: 1).slerp (to: Vector2 (x: 2, y: 2), weight: 0.5), Vector2 (x: 1.5, y: 1.5), "Vector2 slerp with colinear inputs should behave as expected.")
        XCTAssertEqual (Vector2 ().slerp (to: Vector2 (), weight: 0.5), Vector2 (), "Vector2 slerp with both inputs as zero vectors should return a zero vector.")
        XCTAssertEqual (Vector2 ().slerp (to: Vector2 (x: 1, y: 1), weight: 0.5), Vector2 (x: 0.5, y: 0.5), "Vector2 slerp with one input as zero should behave like a regular lerp.")
        XCTAssertEqual (Vector2 (x: 1, y: 1).slerp (to: Vector2 (), weight: 0.5), Vector2 (x: 0.5, y: 0.5), "Vector2 slerp with one input as zero should behave like a regular lerp.")
        assertApproxEqual (Vector2 (x: 4, y: 6).slerp (to: Vector2 (x: 8, y: 10), weight: 0.5), Vector2 (x: 5.9076470794008017626, y: 8.07918879020090480697), "Vector2 slerp should work as expected.")
        assertApproxEqual (vector1.slerp (to: vector2, weight: 0.5).length (), 4.31959610746631919, "Vector2 slerp with different length input should return a vector with an interpolated length.")
        assertApproxEqual (vector1.angleTo (vector1.slerp (to: vector2, weight: 0.5)) * 2, vector1.angleTo (vector2), "Vector2 slerp with different length input should return a vector with an interpolated angle.")
        XCTAssertEqual (vector1.cubicInterpolate (b: vector2, preA: Vector2 (), postB: Vector2 (x: 7, y: 7), weight: 0.5), Vector2 (x: 2.375, y: 3.5), "Vector2 cubicInterpolate should work as expected.")
        assertApproxEqual (vector1.cubicInterpolate (b: vector2, preA: Vector2 (), postB: Vector2 (x: 7, y: 7), weight: 1.0 / 3.0), Vector2 (x: 1.851851940155029297, y: 2.962963104248046875), "Vector2 cubicInterpolate should work as expected.")
        XCTAssertEqual (Vector2 (x: 1, y: 0).moveToward (to: Vector2 (x: 10, y: 0), delta: 3), Vector2 (x: 4, y: 0), "Vector2 moveToward should work as expected.")
    }

    func testLengthMethods () {
        let vector1: Vector2 = Vector2 (x: 10, y: 10)
        let vector2: Vector2 = Vector2 (x: 20, y: 30)
        XCTAssertEqual (vector1.lengthSquared (), 200, "Vector2 lengthSquared should work as expected and return exact result.")
        assertApproxEqual (vector1.length (), 10 * Double.sqrt2, "Vector2 length should work as expected.")
        XCTAssertEqual (vector2.lengthSquared (), 1300, "Vector2 lengthSquared should work as expected and return exact result.")
        assertApproxEqual (vector2.length (), 36.05551275463989293119, "Vector2 length should work as expected.")
        XCTAssertEqual (vector1.distanceSquaredTo (vector2), 500, "Vector2 distanceSquaredTo should work as expected and return exact result.")
        assertApproxEqual (vector1.distanceTo (vector2), 22.36067977499789696409, "Vector2 distanceTo should work as expected.")
    }

    func testLimitingMethods () {
        let vector: Vector2 = Vector2 (x: 10, y: 10)
        assertApproxEqual (vector.limitLength (), Vector2 (x: Float.sqrt12, y: Float.sqrt12), "Vector2 limitLength should work as expected.")
        assertApproxEqual (vector.limitLength (5), Vector2 (x: Float.sqrt12, y: Float.sqrt12) * 5, "Vector2 limitLength should work as expected.")
        
        XCTAssertEqual (Vector2 (x: -5, y: 15).clamp (min: Vector2 (), max: vector), Vector2 (x: 0, y: 10), "Vector2 clamp should work as expected.")
        XCTAssertEqual (vector.clamp (min: Vector2 (x: 0, y: 15), max: Vector2 (x: 5, y: 20)), Vector2 (x: 5, y: 15), "Vector2 clamp should work as expected.")
    }
    
    func testNormalizationMethods () {
        XCTAssertEqual (Vector2 (x: 1, y: 0).isNormalized (), true, "Vector2 isNormalized should return true for a normalized vector.")
        XCTAssertEqual (Vector2 (x: 1, y: 1).isNormalized (), false, "Vector2 isNormalized should return false for a non-normalized vector.")
        XCTAssertEqual (Vector2 (x: 1, y: 0).normalized (), Vector2 (x: 1, y: 0), "Vector2 normalized should return the same vector for a normalized vector.")
        assertApproxEqual (Vector2 (x: 1, y: 1).normalized (), Vector2 (x: Float.sqrt12, y: Float.sqrt12), "Vector2 normalized should work as expected.")
        assertApproxEqual (Vector2 (x: 3.2, y: -5.4).normalized (), Vector2 (x: 0.509802390301732898898, y: -0.860291533634174266891), "Vector2 normalized should work as expected.")
        
        // Vector2().normalize() is not exposed
        //var vector: Vector2 = Vector2 (x: 3.2, y: -5.4)
        //vector.normalize ()
        //XCTAssertEqual (vector, Vector2 (x: 3.2, y: -5.4).normalized (), "Vector2 normalize should convert same way as Vector2 normalized.")
        //assertApproxEqual (vector, Vector2 (x: 0.509802390301732898898, y: -0.860291533634174266891), "Vector2 normalize should work as expected.")
    }
    
    func testOperators () {
        let decimal1: Vector2 = Vector2 (x: 2.3, y: 4.9)
        let decimal2: Vector2 = Vector2 (x: 1.2, y: 3.4)
        let power1: Vector2 = Vector2 (x: 0.75, y: 1.5)
        let power2: Vector2 = Vector2 (x: 0.5, y: 0.125)
        let int1: Vector2 = Vector2 (x: 4, y: 5)
        let int2: Vector2 = Vector2 (x: 1, y: 2)
        
        assertApproxEqual ((decimal1 + decimal2), Vector2 (x: 3.5, y: 8.3), "Vector2 addition should behave as expected.")
        XCTAssertEqual ((power1 + power2), Vector2 (x: 1.25, y: 1.625), "Vector2 addition with powers of two should give exact results.")
        XCTAssertEqual ((int1 + int2), Vector2 (x: 5, y: 7), "Vector2 addition with integers should give exact results.")
        
        assertApproxEqual ((decimal1 - decimal2), Vector2 (x: 1.1, y: 1.5), "Vector2 subtraction should behave as expected.")
        XCTAssertEqual ((power1 - power2), Vector2 (x: 0.25, y: 1.375), "Vector2 subtraction with powers of two should give exact results.")
        XCTAssertEqual ((int1 - int2), Vector2 (x: 3, y: 3), "Vector2 subtraction with integers should give exact results.")
        
        assertApproxEqual ((decimal1 * decimal2), Vector2 (x: 2.76, y: 16.66), "Vector2 multiplication should behave as expected.")
        XCTAssertEqual ((power1 * power2), Vector2 (x: 0.375, y: 0.1875), "Vector2 multiplication with powers of two should give exact results.")
        XCTAssertEqual ((int1 * int2), Vector2 (x: 4, y: 10), "Vector2 multiplication with integers should give exact results.")
        
        assertApproxEqual ((decimal1 / decimal2), Vector2 (x: 1.91666666666666666, y: 1.44117647058823529), "Vector2 division should behave as expected.")
        XCTAssertEqual ((power1 / power2), Vector2 (x: 1.5, y: 12.0), "Vector2 division with powers of two should give exact results.")
        XCTAssertEqual ((int1 / int2), Vector2 (x: 4, y: 2.5), "Vector2 division with integers should give exact results.")
        
        assertApproxEqual ((decimal1 * 2), Vector2 (x: 4.6, y: 9.8), "Vector2 multiplication should behave as expected.")
        XCTAssertEqual ((power1 * 2), Vector2 (x: 1.5, y: 3), "Vector2 multiplication with powers of two should give exact results.")
        XCTAssertEqual ((int1 * 2), Vector2 (x: 8, y: 10), "Vector2 multiplication with integers should give exact results.")
        
        assertApproxEqual ((decimal1 / 2), Vector2 (x: 1.15, y: 2.45), "Vector2 division should behave as expected.")
        XCTAssertEqual ((power1 / 2), Vector2 (x: 0.375, y: 0.75), "Vector2 division with powers of two should give exact results.")
        XCTAssertEqual ((int1 / 2), Vector2 (x: 2, y: 2.5), "Vector2 division with integers should give exact results.")
        
        XCTAssertEqual (Vector2i (from: decimal1), Vector2i (x: 2, y: 4), "Vector2 cast to Vector2i should work as expected.")
        XCTAssertEqual (Vector2i (from: decimal2), Vector2i (x: 1, y: 3), "Vector2 cast to Vector2i should work as expected.")
        XCTAssertEqual (Vector2 (from: Vector2i (x: 1, y: 2)), Vector2 (x: 1, y: 2), "Vector2 constructed from Vector2i should work as expected.")
        
        XCTAssertEqual (Variant (decimal1).description, "(2.3, 4.9)", "Vector2 cast to String should work as expected.")
        XCTAssertEqual (Variant (decimal2).description, "(1.2, 3.4)", "Vector2 cast to String should work as expected.")
        XCTAssertEqual (Variant (Vector2 (x: 9.8, y: 9.9)).description, "(9.8, 9.9)", "Vector2 cast to String should work as expected.")
        XCTAssertEqual (Variant (Vector2 (x: Float.pi, y: Float.tau)).description, "(3.141593, 6.283185)", "Vector2 cast to String should print the correct amount of digits for realT = float.")
    }

    func testOtherMethods () {
        let vector: Vector2 = Vector2 (x: 1.2, y: 3.4)
        assertApproxEqual (vector.aspect (), 1.2 / 3.4, "Vector2 aspect should work as expected.")
        
        assertApproxEqual (vector.directionTo (Vector2 ()), -vector.normalized (), "Vector2 directionTo should work as expected.")
        assertApproxEqual (Vector2 (x: 1, y: 1).directionTo (Vector2 (x: 2, y: 2)), Vector2 (x: Float.sqrt12, y: Float.sqrt12), "Vector2 directionTo should work as expected.")
        
        assertApproxEqual (vector.posmod (mod: 2), Vector2 (x: 1.2, y: 1.4), "Vector2 posmod should work as expected.")
        assertApproxEqual ((-vector).posmod (mod: 2), Vector2 (x: 0.8, y: 0.6), "Vector2 posmod should work as expected.")
        assertApproxEqual (vector.posmodv (modv: Vector2 (x: 1, y: 2)), Vector2 (x: 0.2, y: 1.4), "Vector2 posmodv should work as expected.")
        assertApproxEqual ((-vector).posmodv (modv: Vector2 (x: 2, y: 3)), Vector2 (x: 0.8, y: 2.6), "Vector2 posmodv should work as expected.")
        
        assertApproxEqual (vector.rotated (angle: Double.tau), Vector2 (x: 1.2, y: 3.4), "Vector2 rotated should work as expected.")
        assertApproxEqual (vector.rotated (angle: Double.tau / 4), Vector2 (x: -3.4, y: 1.2), "Vector2 rotated should work as expected.")
        assertApproxEqual (vector.rotated (angle: Double.tau / 3), Vector2 (x: -3.544486372867091398996, y: -0.660769515458673623883), "Vector2 rotated should work as expected.")
        assertApproxEqual (vector.rotated (angle: Double.tau / 2), vector.rotated (angle: Double.tau / -2), "Vector2 rotated should work as expected.")
        
        XCTAssertEqual (vector.snapped (step: Vector2 (x: 1, y: 1)), Vector2 (x: 1, y: 3), "Vector2 snapped to integers should be the same as rounding.")
        assertApproxEqual (Vector2 (x: 3.4, y: 5.6).snapped (step: Vector2 (x: 1, y: 1)), Vector2 (x: 3, y: 6), "Vector2 snapped to integers should be the same as rounding.")
        assertApproxEqual (vector.snapped (step: Vector2 (x: 0.25, y: 0.25)), Vector2 (x: 1.25, y: 3.5), "Vector2 snapped to 0.25 should give exact results.")
        
        // Vector2().min() and Vector2().max() are not exposed
        //assertApproxEqual (Vector2 (x: 1.2, y: 2.5), vector.min (Vector2 (x: 3.0, y: 2.5)), "Vector2 min should return expected value.")
        //assertApproxEqual (Vector2 (x: 5.3, y: 3.4), vector.max (Vector2 (x: 5.3, y: 2.0)), "Vector2 max should return expected value.")
    }

    func testPlaneMethods () {
        let vector: Vector2 = Vector2 (x: 1.2, y: 3.4)
        let vectorY: Vector2 = Vector2 (x: 0, y: 1)
        let vectorNormal: Vector2 = Vector2 (x: 0.95879811270838721622267, y: 0.2840883296913739899919)
        let vectorNonNormal: Vector2 = Vector2 (x: 5.4, y: 1.6)
        XCTAssertEqual (vector.bounce (n: vectorY), Vector2 (x: 1.2, y: -3.4), "Vector2 bounce on a plane with normal of the Y axis should.")
        assertApproxEqual (vector.bounce (n: vectorNormal), Vector2 (x: -2.85851197982345523329, y: 2.197477931904161412358), "Vector2 bounce with normal should return expected value.")
        XCTAssertEqual (vector.reflect (n: vectorY), Vector2 (x: -1.2, y: 3.4), "Vector2 reflect on a plane with normal of the Y axis should.")
        assertApproxEqual (vector.reflect (n: vectorNormal), Vector2 (x: 2.85851197982345523329, y: -2.197477931904161412358), "Vector2 reflect with normal should return expected value.")
        XCTAssertEqual (vector.project (b: vectorY), Vector2 (x: 0, y: 3.4), "Vector2 projected on the Y axis should only give the Y component.")
        assertApproxEqual (vector.project (b: vectorNormal), Vector2 (x: 2.0292559899117276166, y: 0.60126103404791929382), "Vector2 projected on a normal should return expected value.")
        XCTAssertEqual (vector.slide (n: vectorY), Vector2 (x: 1.2, y: 0), "Vector2 slide on a plane with normal of the Y axis should set the Y to zero.")
        assertApproxEqual (vector.slide (n: vectorNormal), Vector2 (x: -0.8292559899117276166456, y: 2.798738965952080706179), "Vector2 slide with normal should return expected value.")
        // There's probably a better way to test these ones?
        assertApproxEqual (vector.bounce (n: vectorNonNormal), Vector2 (), "Vector2 bounce should return empty Vector2 with non-normalized input.")
        assertApproxEqual (vector.reflect (n: vectorNonNormal), Vector2 (), "Vector2 reflect should return empty Vector2 with non-normalized input.")
        assertApproxEqual (vector.slide (n: vectorNonNormal), Vector2 (), "Vector2 slide should return empty Vector2 with non-normalized input.")
    }

    func testRoundingMethods () {
        let vector1: Vector2 = Vector2 (x: 1.2, y: 5.6)
        let vector2: Vector2 = Vector2 (x: 1.2, y: -5.6)
        XCTAssertEqual (vector1.abs (), vector1, "Vector2 abs should work as expected.")
        XCTAssertEqual (vector2.abs (), vector1, "Vector2 abs should work as expected.")
        
        XCTAssertEqual (vector1.ceil (), Vector2 (x: 2, y: 6), "Vector2 ceil should work as expected.")
        XCTAssertEqual (vector2.ceil (), Vector2 (x: 2, y: -5), "Vector2 ceil should work as expected.")
        
        XCTAssertEqual (vector1.floor (), Vector2 (x: 1, y: 5), "Vector2 floor should work as expected.")
        XCTAssertEqual (vector2.floor (), Vector2 (x: 1, y: -6), "Vector2 floor should work as expected.")
        
        XCTAssertEqual (vector1.round (), Vector2 (x: 1, y: 6), "Vector2 round should work as expected.")
        XCTAssertEqual (vector2.round (), Vector2 (x: 1, y: -6), "Vector2 round should work as expected.")
        
        XCTAssertEqual (vector1.sign (), Vector2 (x: 1, y: 1), "Vector2 sign should work as expected.")
        XCTAssertEqual (vector2.sign (), Vector2 (x: 1, y: -1), "Vector2 sign should work as expected.")
    }

    func testLinearAlgebraMethods () {
        let vectorX: Vector2 = Vector2 (x: 1, y: 0)
        let vectorY: Vector2 = Vector2 (x: 0, y: 1)
        let a: Vector2 = Vector2 (x: 3.5, y: 8.5)
        let b: Vector2 = Vector2 (x: 5.2, y: 4.6)
        XCTAssertEqual (vectorX.cross (with: vectorY), 1, "Vector2 cross product of X and Y should give 1.")
        XCTAssertEqual (vectorY.cross (with: vectorX), -1, "Vector2 cross product of Y and X should give negative 1.")
        assertApproxEqual (a.cross (with: b), -28.1, "Vector2 cross should return expected value.")
        assertApproxEqual (Vector2 (x: -a.x, y: a.y).cross (with: Vector2 (x: b.x, y: -b.y)), -28.1, "Vector2 cross should return expected value.")
        
        XCTAssertEqual (vectorX.dot (with: vectorY), 0.0, "Vector2 dot product of perpendicular vectors should be zero.")
        XCTAssertEqual (vectorX.dot (with: vectorX), 1.0, "Vector2 dot product of identical unit vectors should be one.")
        XCTAssertEqual ((vectorX * 10).dot (with: vectorX * 10), 100.0, "Vector2 dot product of same direction vectors should behave as expected.")
        assertApproxEqual (a.dot (with: b), 57.3, "Vector2 dot should return expected value.")
        assertApproxEqual (Vector2 (x: -a.x, y: a.y).dot (with: Vector2 (x: b.x, y: -b.y)), -57.3, "Vector2 dot should return expected value.")
    }
    
    func testFiniteNumberChecks () {
        let infinite: [Float] = [.nan, .infinity, -.infinity]
        
        XCTAssertTrue (Vector2 (x: 0, y: 1).isFinite (), "Vector2(x: 0, y: 1) should be finite")
        
        for x in infinite {
            XCTAssertFalse (Vector2 (x: x, y: 1).isFinite (), "Vector2 with one component infinite should not be finite.")
            XCTAssertFalse (Vector2 (x: 0, y: x).isFinite (), "Vector2 with one component infinite should not be finite.")
        }
        
        for x in infinite {
            for y in infinite {
                XCTAssertFalse (Vector2 (x: x, y: y).isFinite (), "Vector2 with two components infinite should not be finite.")
            }
        }
    }
    
}
