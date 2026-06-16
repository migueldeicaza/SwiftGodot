// Based on godot/tests/core/math/test_vector2i.h



@testable import SwiftGodot

@SwiftGodotTestSuite
final class EngineVector2iTests {

    public func testConstructorMethods () {
        let vectorEmpty: Vector2i = Vector2i ()
        let vectorZero: Vector2i = Vector2i (x: 0, y: 0)
        assertEqual (vectorEmpty, vectorZero, "Vector2i Constructor with no inputs should return a zero Vector2i.")
    }

    public func testAxisMethods () {
        var vector: Vector2i = Vector2i (x: 2, y: 3)
        assertEqual (vector.maxAxisIndex (), Vector2i.Axis.y.rawValue, "Vector2i maxAxisIndex should work as expected.")
        assertEqual (vector.minAxisIndex (), Vector2i.Axis.x.rawValue, "Vector2i minAxisIndex should work as expected.")
        assertEqual (vector [vector.minAxisIndex ()], 2, "Vector2i array operator should work as expected.")
        vector [Vector2i.Axis.y.rawValue] = 5
        assertEqual (vector [Vector2i.Axis.y.rawValue], 5, "Vector2i array operator setter should work as expected.")
    }

    public func testClampMethod () {
        let vector: Vector2i = Vector2i (x: 10, y: 10)
        assertEqual (Vector2i (x: -5, y: 15).clamp (min: Vector2i (), max: vector), Vector2i (x: 0, y: 10), "Vector2i clamp should work as expected.")
        assertEqual (vector.clamp (min: Vector2i (x: 0, y: 15), max: Vector2i (x: 5, y: 20)), Vector2i (x: 5, y: 15), "Vector2i clamp should work as expected.")
    }

    public func testLengthMethods () {
        let vector1: Vector2i = Vector2i (x: 10, y: 10)
        let vector2: Vector2i = Vector2i (x: 20, y: 30)
        assertEqual (vector1.lengthSquared (), 200, "Vector2i lengthSquared should work as expected and return exact result.")
        assertEqual (vector1.length (), 10 * Double.sqrt2, "Vector2i length should work as expected.")
        assertEqual (vector2.lengthSquared (), 1300, "Vector2i lengthSquared should work as expected and return exact result.")
        assertEqual (vector2.length (), 36.05551275463989293119, "Vector2i length should work as expected.")
    }

    public func testOperators () {
        let vector1: Vector2i = Vector2i (x: 5, y: 9)
        let vector2: Vector2i = Vector2i (x: 2, y: 3)
        
        assertEqual ((vector1 + vector2), Vector2i (x: 7, y: 12), "Vector2i addition with integers should give exact results.")
        assertEqual ((vector1 - vector2), Vector2i (x: 3, y: 6), "Vector2i subtraction with integers should give exact results.")
        assertEqual ((vector1 * vector2), Vector2i (x: 10, y: 27), "Vector2i multiplication with integers should give exact results.")
        assertEqual ((vector1 / vector2), Vector2i (x: 2, y: 3), "Vector2i division with integers should give exact results.")
        
        assertEqual ((vector1 * 2), Vector2i (x: 10, y: 18), "Vector2i multiplication with integers should give exact results.")
        assertEqual ((vector1 / 2), Vector2i (x: 2, y: 4), "Vector2i division with integers should give exact results.")
        
        assertEqual (Vector2 (from: vector1), Vector2 (x: 5, y: 9), "Vector2i cast to Vector2 should work as expected.")
        assertEqual (Vector2 (from: vector2), Vector2 (x: 2, y: 3), "Vector2i cast to Vector2 should work as expected.")
        assertEqual (Vector2i (from: Vector2 (x: 1.1, y: 2.9)), Vector2i (x: 1, y: 2), "Vector2i constructed from Vector2 should work as expected.")
    }

    public func testOtherMethods () {
        let vector: Vector2i = Vector2i (x: 1, y: 3)
        assertApproxEqual (vector.aspect (), 1.0 / 3.0, "Vector2i aspect should work as expected.")
        
        // Vector2i().min and Vector2i().max are not exposed
        //assertEqual (vector.min (Vector2i (x: 3, y: 2)), Vector2i (x: 1, y: 2), "Vector2i min should return expected value.")
        //assertEqual (vector.max (Vector2i (x: 5, y: 2)), Vector2i (x: 5, y: 3), "Vector2i max should return expected value.")
        
        assertEqual (vector.snapped (step: Vector2i (x: 4, y: 2)), Vector2i (x: 0, y: 4), "Vector2i snapped should work as expected.")
    }

    public func testAbsAndSignMethods () {
        let vector1: Vector2i = Vector2i (x: 1, y: 3)
        let vector2: Vector2i = Vector2i (x: 1, y: -3)
        assertEqual (vector1.abs (), vector1, "Vector2i abs should work as expected.")
        assertEqual (vector2.abs (), vector1, "Vector2i abs should work as expected.")
        
        assertEqual (vector1.sign (), Vector2i (x: 1, y: 1), "Vector2i sign should work as expected.")
        assertEqual (vector2.sign (), Vector2i (x: 1, y: -1), "Vector2i sign should work as expected.")
    }
    
}
