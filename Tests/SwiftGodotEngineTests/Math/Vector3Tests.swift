// Based on godot/tests/core/math/test_vector3.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector3Tests: GodotTestCase {
    
    func testConstructorMethods () {
        let vectorEmpty: Vector3 = Vector3 ()
        let vectorZero: Vector3 = Vector3 (x: 0.0, y: 0.0, z: 0.0)
        XCTAssertEqual (vectorEmpty, vectorZero, "Vector3 Constructor with no inputs should return a zero Vector3.")
    }
    
    func testAngleMethods () {
        let vectorX: Vector3 = Vector3 (x: 1, y: 0, z: 0)
        let vectorY: Vector3 = Vector3 (x: 0, y: 1, z: 0)
        let vectorYz: Vector3 = Vector3 (x: 0, y: 1, z: 1)
        assertApproxEqual (vectorX.angleTo (vectorY), Double.tau / 4, "Vector3 angleTo should work as expected.")
        assertApproxEqual (vectorX.angleTo (vectorYz), Double.tau / 4, "Vector3 angleTo should work as expected.")
        assertApproxEqual (vectorYz.angleTo (vectorX), Double.tau / 4, "Vector3 angleTo should work as expected.")
        assertApproxEqual (vectorY.angleTo (vectorYz), Double.tau / 8, "Vector3 angleTo should work as expected.")
        
        assertApproxEqual (vectorX.signedAngleTo (vectorY, axis: vectorY), Double.tau / 4, "Vector3 signedAngleTo edge case should be positive.")
        assertApproxEqual (vectorX.signedAngleTo (vectorYz, axis: vectorY), Double.tau / -4, "Vector3 signedAngleTo should work as expected.")
        assertApproxEqual (vectorYz.signedAngleTo (vectorX, axis: vectorY), Double.tau / 4, "Vector3 signedAngleTo should work as expected.")
    }

    func testAxisMethods () {
        var vector: Vector3 = Vector3 (x: 1.2, y: 3.4, z: 5.6)
        XCTAssertEqual (vector.maxAxisIndex (), Vector3.Axis.z.rawValue, "Vector3 maxAxisIndex should work as expected.")
        XCTAssertEqual (vector.minAxisIndex (), Vector3.Axis.x.rawValue, "Vector3 minAxisIndex should work as expected.")
        assertApproxEqual (vector [vector.maxAxisIndex ()], 5.6, "Vector3 array operator should work as expected.")
        assertApproxEqual (vector [vector.minAxisIndex ()], 1.2, "Vector3 array operator should work as expected.")
        
        vector [Vector3.Axis.y.rawValue] = 3.7
        assertApproxEqual (vector [Vector3.Axis.y.rawValue], 3.7, "Vector3 array operator setter should work as expected.")
    }
    
    func testInterpolationMethods () {
        let vector1: Vector3 = Vector3 (x: 1, y: 2, z: 3)
        let vector2: Vector3 = Vector3 (x: 4, y: 5, z: 6)
        XCTAssertEqual (vector1.lerp (to: vector2, weight: 0.5), Vector3 (x: 2.5, y: 3.5, z: 4.5), "Vector3 lerp should work as expected.")
        assertApproxEqual (vector1.lerp (to: vector2, weight: 1.0 / 3.0), Vector3 (x: 2, y: 3, z: 4), "Vector3 lerp should work as expected.")
        assertApproxEqual (vector1.normalized ().slerp (to: vector2.normalized (), weight: 0.5), Vector3 (x: 0.363866806030273438, y: 0.555698215961456299, z: 0.747529566287994385), "Vector3 slerp should work as expected.")
        assertApproxEqual (vector1.normalized ().slerp (to: vector2.normalized (), weight: 1.0 / 3.0), Vector3 (x: 0.332119762897491455, y: 0.549413740634918213, z: 0.766707837581634521), "Vector3 slerp should work as expected.")
        assertApproxEqual (Vector3 (x: 5, y: 0, z: 0).slerp (to: Vector3 (x: 0, y: 3, z: 4), weight: 0.5), Vector3 (x: 3.535533905029296875, y: 2.121320486068725586, z: 2.828427314758300781), "Vector3 slerp with non-normalized values should work as expected.")
        assertApproxEqual (Vector3 (x: 1, y: 1, z: 1).slerp (to: Vector3 (x: 2, y: 2, z: 2), weight: 0.5), Vector3 (x: 1.5, y: 1.5, z: 1.5), "Vector3 slerp with colinear inputs should behave as expected.")
        XCTAssertEqual (Vector3 ().slerp (to: Vector3 (), weight: 0.5), Vector3 (), "Vector3 slerp with both inputs as zero vectors should return a zero vector.")
        XCTAssertEqual (Vector3 ().slerp (to: Vector3 (x: 1, y: 1, z: 1), weight: 0.5), Vector3 (x: 0.5, y: 0.5, z: 0.5), "Vector3 slerp with one input as zero should behave like a regular lerp.")
        XCTAssertEqual (Vector3 (x: 1, y: 1, z: 1).slerp (to: Vector3 (), weight: 0.5), Vector3 (x: 0.5, y: 0.5, z: 0.5), "Vector3 slerp with one input as zero should behave like a regular lerp.")
        assertApproxEqual (Vector3 (x: 4, y: 6, z: 2).slerp (to: Vector3 (x: 8, y: 10, z: 3), weight: 0.5), Vector3 (x: 5.90194219811429941053, y: 8.06758688849378394534, z: 2.558307894718317120038), "Vector3 slerp should work as expected.")
        assertApproxEqual (vector1.slerp (to: vector2, weight: 0.5).length (), 6.25831088708303172, "Vector3 slerp with different length input should return a vector with an interpolated length.")
        assertApproxEqual (vector1.angleTo (vector1.slerp (to: vector2, weight: 0.5)) * 2, vector1.angleTo (vector2), "Vector3 slerp with different length input should return a vector with an interpolated angle.")
        XCTAssertEqual (vector1.cubicInterpolate (b: vector2, preA: Vector3 (), postB: Vector3 (x: 7, y: 7, z: 7), weight: 0.5), Vector3 (x: 2.375, y: 3.5, z: 4.625), "Vector3 cubicInterpolate should work as expected.")
        assertApproxEqual (vector1.cubicInterpolate (b: vector2, preA: Vector3 (), postB: Vector3 (x: 7, y: 7, z: 7), weight: 1.0 / 3.0), Vector3 (x: 1.851851940155029297, y: 2.962963104248046875, z: 4.074074268341064453), "Vector3 cubicInterpolate should work as expected.")
        XCTAssertEqual (Vector3 (x: 1, y: 0, z: 0).moveToward (to: Vector3 (x: 10, y: 0, z: 0), delta: 3), Vector3 (x: 4, y: 0, z: 0), "Vector3 moveToward should work as expected.")
    }

    func testLengthMethods () {
        let vector1: Vector3 = Vector3 (x: 10, y: 10, z: 10)
        let vector2: Vector3 = Vector3 (x: 20, y: 30, z: 40)
        XCTAssertEqual (vector1.lengthSquared (), 300, "Vector3 lengthSquared should work as expected and return exact result.")
        assertApproxEqual (vector1.length (), 10 * Double.sqrt3, "Vector3 length should work as expected.")
        XCTAssertEqual (vector2.lengthSquared (), 2900, "Vector3 lengthSquared should work as expected and return exact result.")
        assertApproxEqual (vector2.length (), 53.8516480713450403125, "Vector3 length should work as expected.")
        XCTAssertEqual (vector1.distanceSquaredTo (vector2), 1400, "Vector3 distanceSquaredTo should work as expected and return exact result.")
        assertApproxEqual (vector1.distanceTo (vector2), 37.41657386773941385584, "Vector3 distanceTo should work as expected.")
    }

    func testLimitingMethods () {
        let vector: Vector3 = Vector3 (x: 10, y: 10, z: 10)
        assertApproxEqual (vector.limitLength (), Vector3 (x: Float.sqrt13, y: Float.sqrt13, z: Float.sqrt13), "Vector3 limitLength should work as expected.")
        assertApproxEqual (vector.limitLength (5), Vector3 (x: Float.sqrt13, y: Float.sqrt13, z: Float.sqrt13) * 5, "Vector3 limitLength should work as expected.")
        
        XCTAssertEqual (Vector3 (x: -5, y: 5, z: 15).clamp (min: Vector3 (), max: vector), Vector3 (x: 0, y: 5, z: 10), "Vector3 clamp should work as expected.")
        XCTAssertEqual (vector.clamp (min: Vector3 (x: 0, y: 10, z: 15), max: Vector3 (x: 5, y: 10, z: 20)), Vector3 (x: 5, y: 10, z: 15), "Vector3 clamp should work as expected.")
    }

    func testNormalizationMethods () {
        XCTAssertEqual (Vector3 (x: 1, y: 0, z: 0).isNormalized (), true, "Vector3 isNormalized should return true for a normalized vector.")
        XCTAssertEqual (Vector3 (x: 1, y: 1, z: 1).isNormalized (), false, "Vector3 isNormalized should return false for a non-normalized vector.")
        XCTAssertEqual (Vector3 (x: 1, y: 0, z: 0).normalized (), Vector3 (x: 1, y: 0, z: 0), "Vector3 normalized should return the same vector for a normalized vector.")
        assertApproxEqual (Vector3 (x: 1, y: 1, z: 0).normalized (), Vector3 (x: Float.sqrt12, y: Float.sqrt12, z: 0), "Vector3 normalized should work as expected.")
        assertApproxEqual (Vector3 (x: 1, y: 1, z: 1).normalized (), Vector3 (x: Float.sqrt13, y: Float.sqrt13, z: Float.sqrt13), "Vector3 normalized should work as expected.")
        
        // Vector3().normalize() is not exposed
        //var vector: Vector3 = Vector3 (x: 3.2, y: -5.4, z: 6)
        //vector = vector.normalize ()
        //XCTAssertEqual (vector, Vector3 (x: 3.2, y: -5.4, z: 6).normalized (), "Vector3 normalize should convert same way as Vector3 normalized.")
        //assertApproxEqual (vector, Vector3 (x: 0.368522751763902980457, y: -0.621882143601586279522, z: 0.6909801595573180883585), "Vector3 normalize should work as expected.")
    }

    func testOperators () {
        let decimal1: Vector3 = Vector3 (x: 2.3, y: 4.9, z: 7.8)
        let decimal2: Vector3 = Vector3 (x: 1.2, y: 3.4, z: 5.6)
        let power1: Vector3 = Vector3 (x: 0.75, y: 1.5, z: 0.625)
        let power2: Vector3 = Vector3 (x: 0.5, y: 0.125, z: 0.25)
        let int1: Vector3 = Vector3 (x: 4, y: 5, z: 9)
        let int2: Vector3 = Vector3 (x: 1, y: 2, z: 3)
        
        assertApproxEqual ((decimal1 + decimal2), Vector3 (x: 3.5, y: 8.3, z: 13.4), "Vector3 addition should behave as expected.")
        XCTAssertEqual ((power1 + power2), Vector3 (x: 1.25, y: 1.625, z: 0.875), "Vector3 addition with powers of two should give exact results.")
        XCTAssertEqual ((int1 + int2), Vector3 (x: 5, y: 7, z: 12), "Vector3 addition with integers should give exact results.")
        
        assertApproxEqual ((decimal1 - decimal2), Vector3 (x: 1.1, y: 1.5, z: 2.2), "Vector3 subtraction should behave as expected.")
        XCTAssertEqual ((power1 - power2), Vector3 (x: 0.25, y: 1.375, z: 0.375), "Vector3 subtraction with powers of two should give exact results.")
        XCTAssertEqual ((int1 - int2), Vector3 (x: 3, y: 3, z: 6), "Vector3 subtraction with integers should give exact results.")
        
        assertApproxEqual ((decimal1 * decimal2), Vector3 (x: 2.76, y: 16.66, z: 43.68), "Vector3 multiplication should behave as expected.")
        XCTAssertEqual ((power1 * power2), Vector3 (x: 0.375, y: 0.1875, z: 0.15625), "Vector3 multiplication with powers of two should give exact results.")
        XCTAssertEqual ((int1 * int2), Vector3 (x: 4, y: 10, z: 27), "Vector3 multiplication with integers should give exact results.")
        
        assertApproxEqual ((decimal1 / decimal2), Vector3 (x: 1.91666666666666666, y: 1.44117647058823529, z: 1.39285714285714286), "Vector3 division should behave as expected.")
        XCTAssertEqual ((power1 / power2), Vector3 (x: 1.5, y: 12.0, z: 2.5), "Vector3 division with powers of two should give exact results.")
        XCTAssertEqual ((int1 / int2), Vector3 (x: 4, y: 2.5, z: 3), "Vector3 division with integers should give exact results.")
        
        assertApproxEqual ((decimal1 * 2), Vector3 (x: 4.6, y: 9.8, z: 15.6), "Vector3 multiplication should behave as expected.")
        XCTAssertEqual ((power1 * 2), Vector3 (x: 1.5, y: 3, z: 1.25), "Vector3 multiplication with powers of two should give exact results.")
        XCTAssertEqual ((int1 * 2), Vector3 (x: 8, y: 10, z: 18), "Vector3 multiplication with integers should give exact results.")
        
        assertApproxEqual ((decimal1 / 2), Vector3 (x: 1.15, y: 2.45, z: 3.9), "Vector3 division should behave as expected.")
        XCTAssertEqual ((power1 / 2), Vector3 (x: 0.375, y: 0.75, z: 0.3125), "Vector3 division with powers of two should give exact results.")
        XCTAssertEqual ((int1 / 2), Vector3 (x: 2, y: 2.5, z: 4.5), "Vector3 division with integers should give exact results.")
        
        XCTAssertEqual (Vector3i (from: decimal1), Vector3i (x: 2, y: 4, z: 7), "Vector3 cast to Vector3i should work as expected.")
        XCTAssertEqual (Vector3i (from: decimal2), Vector3i (x: 1, y: 3, z: 5), "Vector3 cast to Vector3i should work as expected.")
        XCTAssertEqual (Vector3 (from: Vector3i (x: 1, y: 2, z: 3)), Vector3 (x: 1, y: 2, z: 3), "Vector3 constructed from Vector3i should work as expected.")
        
        XCTAssertEqual (Variant (decimal1).description, "(2.3, 4.9, 7.8)", "Vector3 cast to String should work as expected.")
        XCTAssertEqual (Variant (decimal2).description, "(1.2, 3.4, 5.6)", "Vector3 cast to String should work as expected.")
        XCTAssertEqual (Variant (Vector3 (x: 9.7, y: 9.8, z: 9.9)).description, "(9.7, 9.8, 9.9)", "Vector3 cast to String should work as expected.")
        XCTAssertEqual (Variant (Vector3 (x: Float.e, y: Float.sqrt2, z: Float.sqrt3)).description, "(2.718282, 1.414214, 1.732051)", "Vector3 cast to String should print the correct amount of digits for realT = float.")
    }

    func testOtherMethods () {
        let vector: Vector3 = Vector3 (x: 1.2, y: 3.4, z: 5.6)
        assertApproxEqual (vector.directionTo (Vector3 ()), -vector.normalized (), "Vector3 directionTo should work as expected.")
        assertApproxEqual (Vector3 (x: 1, y: 1, z: 1).directionTo (Vector3 (x: 2, y: 2, z: 2)), Vector3 (x: Float.sqrt13, y: Float.sqrt13, z: Float.sqrt13), "Vector3 directionTo should work as expected.")
        assertApproxEqual (vector.inverse (), Vector3 (x: 1 / 1.2, y: 1 / 3.4, z: 1 / 5.6), "Vector3 inverse should work as expected.")
        assertApproxEqual (vector.posmod (mod: 2), Vector3 (x: 1.2, y: 1.4, z: 1.6), "Vector3 posmod should work as expected.")
        assertApproxEqual ((-vector).posmod (mod: 2), Vector3 (x: 0.8, y: 0.6, z: 0.4), "Vector3 posmod should work as expected.")
        assertApproxEqual (vector.posmodv (modv: Vector3 (x: 1, y: 2, z: 3)), Vector3 (x: 0.2, y: 1.4, z: 2.6), "Vector3 posmodv should work as expected.")
        assertApproxEqual ((-vector).posmodv (modv: Vector3 (x: 2, y: 3, z: 4)), Vector3 (x: 0.8, y: 2.6, z: 2.4), "Vector3 posmodv should work as expected.")
        
        assertApproxEqual (vector.rotated (axis: Vector3 (x: 0, y: 1, z: 0), angle: Double.tau), vector, "Vector3 rotated should work as expected.")
        assertApproxEqual (vector.rotated (axis: Vector3 (x: 0, y: 1, z: 0), angle: Double.tau / 4), Vector3 (x: 5.6, y: 3.4, z: -1.2), "Vector3 rotated should work as expected.")
        assertApproxEqual (vector.rotated (axis: Vector3 (x: 1, y: 0, z: 0), angle: Double.tau / 3), Vector3 (x: 1.2, y: -6.54974226119285642, z: 0.1444863728670914), "Vector3 rotated should work as expected.")
        assertApproxEqual (vector.rotated (axis: Vector3 (x: 0, y: 0, z: 1), angle: Double.tau / 2), vector.rotated (axis: Vector3 (x: 0, y: 0, z: 1), angle: Double.tau / -2), "Vector3 rotated should work as expected.")
        
        XCTAssertEqual (vector.snapped (step: Vector3 (x: 1, y: 1, z: 1)), Vector3 (x: 1, y: 3, z: 6), "Vector3 snapped to integers should be the same as rounding.")
        XCTAssertEqual (vector.snapped (step: Vector3 (x: 0.25, y: 0.25, z: 0.25)), Vector3 (x: 1.25, y: 3.5, z: 5.5), "Vector3 snapped to 0.25 should give exact results.")
        
        // Vector3().min() and Vector3.max() are not exposed
        //assertApproxEqual (Vector3 (x: 1.2, y: 2.5, z: 2.0), vector.min (Vector3 (x: 3.0, y: 2.5, z: 2.0)), "Vector3 min should return expected value.")
        //assertApproxEqual (Vector3 (x: 5.3, y: 3.4, z: 5.6), vector.max (Vector3 (x: 5.3, y: 2.0, z: 3.0)), "Vector3 max should return expected value.")
    }

    func testPlaneMethods () {
        let vector: Vector3 = Vector3 (x: 1.2, y: 3.4, z: 5.6)
        let vectorY: Vector3 = Vector3 (x: 0, y: 1, z: 0)
        let vectorNormal: Vector3 = Vector3 (x: 0.88763458893247992491, y: 0.26300284116517923701, z: 0.37806658417494515320)
        let vectorNonNormal: Vector3 = Vector3 (x: 5.4, y: 1.6, z: 2.3)
        XCTAssertEqual (vector.bounce (n: vectorY), Vector3 (x: 1.2, y: -3.4, z: 5.6), "Vector3 bounce on a plane with normal of the Y axis should.")
        assertApproxEqual (vector.bounce (n: vectorNormal), Vector3 (x: -6.0369629829775736287, y: 1.25571467171034855444, z: 2.517589840583626047), "Vector3 bounce with normal should return expected value.")
        XCTAssertEqual (vector.reflect (n: vectorY), Vector3 (x: -1.2, y: 3.4, z: -5.6), "Vector3 reflect on a plane with normal of the Y axis should.")
        assertApproxEqual (vector.reflect (n: vectorNormal), Vector3 (x: 6.0369629829775736287, y: -1.25571467171034855444, z: -2.517589840583626047), "Vector3 reflect with normal should return expected value.")
        XCTAssertEqual (vector.project (b: vectorY), Vector3 (x: 0, y: 3.4, z: 0), "Vector3 projected on the Y axis should only give the Y component.")
        assertApproxEqual (vector.project (b: vectorNormal), Vector3 (x: 3.61848149148878681437, y: 1.0721426641448257227776, z: 1.54120507970818697649), "Vector3 projected on a normal should return expected value.")
        XCTAssertEqual (vector.slide (n: vectorY), Vector3 (x: 1.2, y: 0, z: 5.6), "Vector3 slide on a plane with normal of the Y axis should set the Y to zero.")
        assertApproxEqual (vector.slide (n: vectorNormal), Vector3 (x: -2.41848149148878681437, y: 2.32785733585517427722237, z: 4.0587949202918130235), "Vector3 slide with normal should return expected value.")
        assertApproxEqual (vector.bounce (n: vectorNonNormal), Vector3 (), "Vector3 bounce should return empty Vector3 with non-normalized input.")
        assertApproxEqual (vector.reflect (n: vectorNonNormal), Vector3 (), "Vector3 reflect should return empty Vector3 with non-normalized input.")
        assertApproxEqual (vector.slide (n: vectorNonNormal), Vector3 (), "Vector3 slide should return empty Vector3 with non-normalized input.")
    }

    func testRoundingMethods () {
        let vector1: Vector3 = Vector3 (x: 1.2, y: 3.4, z: 5.6)
        let vector2: Vector3 = Vector3 (x: 1.2, y: -3.4, z: -5.6)
        XCTAssertEqual (vector1.abs (), vector1, "Vector3 abs should work as expected.")
        XCTAssertEqual (vector2.abs (), vector1, "Vector3 abs should work as expected.")
        
        XCTAssertEqual (vector1.ceil (), Vector3 (x: 2, y: 4, z: 6), "Vector3 ceil should work as expected.")
        XCTAssertEqual (vector2.ceil (), Vector3 (x: 2, y: -3, z: -5), "Vector3 ceil should work as expected.")
        
        XCTAssertEqual (vector1.floor (), Vector3 (x: 1, y: 3, z: 5), "Vector3 floor should work as expected.")
        XCTAssertEqual (vector2.floor (), Vector3 (x: 1, y: -4, z: -6), "Vector3 floor should work as expected.")
        
        XCTAssertEqual (vector1.round (), Vector3 (x: 1, y: 3, z: 6), "Vector3 round should work as expected.")
        XCTAssertEqual (vector2.round (), Vector3 (x: 1, y: -3, z: -6), "Vector3 round should work as expected.")
        
        XCTAssertEqual (vector1.sign (), Vector3 (x: 1, y: 1, z: 1), "Vector3 sign should work as expected.")
        XCTAssertEqual (vector2.sign (), Vector3 (x: 1, y: -1, z: -1), "Vector3 sign should work as expected.")
    }

    func testLinearAlgebraMethods () {
        let vectorX: Vector3 = Vector3 (x: 1, y: 0, z: 0)
        let vectorY: Vector3 = Vector3 (x: 0, y: 1, z: 0)
        let vectorZ: Vector3 = Vector3 (x: 0, y: 0, z: 1)
        let a: Vector3 = Vector3 (x: 3.5, y: 8.5, z: 2.3)
        let b: Vector3 = Vector3 (x: 5.2, y: 4.6, z: 7.8)
        XCTAssertEqual (vectorX.cross (with: vectorY), vectorZ, "Vector3 cross product of X and Y should give Z.")
        XCTAssertEqual (vectorY.cross (with: vectorX), -vectorZ, "Vector3 cross product of Y and X should give negative Z.")
        XCTAssertEqual (vectorY.cross (with: vectorZ), vectorX, "Vector3 cross product of Y and Z should give X.")
        XCTAssertEqual (vectorZ.cross (with: vectorX), vectorY, "Vector3 cross product of Z and X should give Y.")
        assertApproxEqual (a.cross (with: b), Vector3 (x: 55.72, y: -15.34, z: -28.1), "Vector3 cross should return expected value.")
        assertApproxEqual (Vector3 (x: -a.x, y: a.y, z: -a.z).cross (with: Vector3 (x: b.x, y: -b.y, z: b.z)), Vector3 (x: 55.72, y: 15.34, z: -28.1), "Vector2 cross should return expected value.")
        
        XCTAssertEqual (vectorX.dot (with: vectorY), 0.0, "Vector3 dot product of perpendicular vectors should be zero.")
        XCTAssertEqual (vectorX.dot (with: vectorX), 1.0, "Vector3 dot product of identical unit vectors should be one.")
        XCTAssertEqual ((vectorX * 10).dot (with: vectorX * 10), 100.0, "Vector3 dot product of same direction vectors should behave as expected.")
        assertApproxEqual (a.dot (with: b), 75.24, "Vector3 dot should return expected value.")
        assertApproxEqual (Vector3 (x: -a.x, y: a.y, z: -a.z).dot (with: Vector3 (x: b.x, y: -b.y, z: b.z)), -75.24, "Vector3 dot should return expected value.")
    }
    
    func testFiniteNumberChecks () {
        let infinite: [Float] = [.nan, .infinity, -.infinity]
        
        XCTAssertTrue (Vector3 (x: 0, y: 1, z: 2).isFinite (), "Vector3(x: 0, y: 1, z: 2) should be finite")
        
        for x in infinite {
            XCTAssertFalse (Vector3 (x: x, y: 1, z: 2).isFinite (), "Vector3 with one component infinite should not be finite.")
            XCTAssertFalse (Vector3 (x: 0, y: x, z: 2).isFinite (), "Vector3 with one component infinite should not be finite.")
            XCTAssertFalse (Vector3 (x: 0, y: 1, z: x).isFinite (), "Vector3 with one component infinite should not be finite.")
        }
        
        for x in infinite {
            for y in infinite {
                XCTAssertFalse (Vector3 (x: x, y: y, z: 2).isFinite (), "Vector3 with two components infinite should not be finite.")
                XCTAssertFalse (Vector3 (x: x, y: 1, z: y).isFinite (), "Vector3 with two components infinite should not be finite.")
                XCTAssertFalse (Vector3 (x: 0, y: x, z: y).isFinite (), "Vector3 with two components infinite should not be finite.")
            }
        }
        
        for x in infinite {
            for y in infinite {
                for z in infinite {
                    XCTAssertFalse (Vector3 (x: x, y: y, z: z).isFinite (), "Vector3 with three components infinite should not be finite.")
                }
            }
        }
    }
    
}
