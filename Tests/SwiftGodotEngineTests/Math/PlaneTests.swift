// Based on godot/tests/core/math/test_plane.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class PlaneTests: GodotTestCase {
    
    func testConstructorMethods () {
        let plane: Plane = Plane (a: 32, b: 22, c: 16, d: 3)
        let planeVector: Plane  = Plane (normal: Vector3 (x: 32, y: 22, z: 16), d: 3)
        let planeCopyPlane: Plane = Plane (from: plane)
        XCTAssertEqual (plane, planeVector, "Planes created with same values but different methods should be equal.")
        XCTAssertEqual (plane, planeCopyPlane, "Planes created with same values but different methods should be equal.")
    }
    
    func testBasicGetters () {        
        let plane: Plane = Plane (a: 32, b: 22, c: 16, d: 3)
        let planeNormalized: Plane = Plane (a: 32.0 / 42, b: 22.0 / 42, c: 16.0 / 42, d: 3.0 / 42)
        XCTAssertEqual (plane.normal, Vector3 (x: 32, y: 22, z: 16), "normal getter should return the expected value.")
        XCTAssertEqual (plane.normalized (), planeNormalized, "normalized() should return a copy of the normalized value.")
    }
    
    func testBasicSetters () {
        var plane: Plane = Plane (a: 32, b: 22, c: 16, d: 3)
        plane.normal = Vector3 (x: 4, y: 2, z: 3)
        XCTAssertEqual (plane, Plane (a: 4, b: 2, c: 3, d: 3), "Setting normal should result in the expected plane.")
        plane = Plane (a: 32, b: 22, c: 16, d: 3).normalized ()
        XCTAssertEqual (plane, Plane (a: 32.0 / 42, b: 22.0 / 42, c: 16.0 / 42, d: 3.0 / 42), "normalize() should result in the expected plane.")
    }
    
    func testPlanePointOperations () {
        let plane: Plane = Plane (a: 32, b: 22, c: 16, d: 3)
        let yFacingPlane: Plane = Plane (a: 0, b: 1, c: 0, d: 4)
        XCTAssertEqual (plane.getCenter (), Vector3 (x: 32 * 3, y: 22 * 3, z: 16 * 3), "getCenter() should return a vector pointing to the center of the plane.")
        XCTAssertTrue (yFacingPlane.isPointOver (point: Vector3 (x: 0, y: 5, z: 0)), "isPointOver() should return the expected result.")
        XCTAssertEqual (yFacingPlane.getAnyPerpendicularNormal (), Vector3 (x: 1, y: 0, z: 0), "getAnyPerpendicularNormal() should return the expected result.")
    }
    
    func testHasPoint () {
        let xFacingPlane: Plane = Plane (a: 1, b: 0, c: 0, d: 0)
        let yFacingPlane: Plane = Plane (a: 0, b: 1, c: 0, d: 0)
        let zFacingPlane: Plane = Plane (a: 0, b: 0, c: 1, d: 0)
        
        let xAxisPoint: Vector3 = Vector3 (x: 10, y: 0, z: 0)
        let yAxisPoint: Vector3 = Vector3 (x: 0, y: 10, z: 0)
        let zAxisPoint: Vector3 = Vector3 (x: 0, y: 0, z: 10)
        
        let xFacingPlaneWithDOffset: Plane = Plane (a: 1, b: 0, c: 0, d: 1)
        let yXxisPointWithDOffset: Vector3 = Vector3 (x: 1, y: 10, z: 0)
        
        XCTAssertTrue (xFacingPlane.hasPoint (yAxisPoint), "hasPoint() with contained Vector3 should return the expected result.")
        XCTAssertTrue (xFacingPlane.hasPoint (zAxisPoint), "hasPoint() with contained Vector3 should return the expected result.")
        
        XCTAssertTrue (yFacingPlane.hasPoint (xAxisPoint), "hasPoint() with contained Vector3 should return the expected result.")
        XCTAssertTrue (yFacingPlane.hasPoint (zAxisPoint), "hasPoint() with contained Vector3 should return the expected result.")
        
        XCTAssertTrue (zFacingPlane.hasPoint (yAxisPoint), "hasPoint() with contained Vector3 should return the expected result.")
        XCTAssertTrue (zFacingPlane.hasPoint (xAxisPoint), "hasPoint() with contained Vector3 should return the expected result.")
        
        XCTAssertTrue (xFacingPlaneWithDOffset.hasPoint (yXxisPointWithDOffset), "hasPoint () with passed Vector3 should return the expected result.")
    }
    
    func testIntersection () {
        let xFacingPlane: Plane = Plane (a: 1, b: 0, c: 0, d: 1)
        let yFacingPlane: Plane = Plane (a: 0, b: 1, c: 0, d: 2)
        let zFacingPlane: Plane = Plane (a: 0, b: 0, c: 1, d: 3)
        
        var varOut: Variant
        var vecOut: Vector3?
        
        varOut = xFacingPlane.intersect3 (b: yFacingPlane, c: zFacingPlane)
        vecOut = Vector3 (varOut)
        XCTAssertEqual (varOut.gtype, .vector3, "intersect3() should return the expected result.")
        XCTAssertEqual (vecOut, Vector3 (x: 1, y: 2, z: 3), "intersect3() should return the expected result.")
        
        varOut = xFacingPlane.intersectsRay (from: Vector3 (x: 0, y: 1, z: 1), dir: Vector3 (x: 2, y: 0, z: 0))
        vecOut = Vector3 (varOut)
        XCTAssertEqual (varOut.gtype, .vector3, "intersectsRay() should return the expected result.")
        XCTAssertEqual (vecOut, Vector3 (x: 1, y: 1, z: 1), "intersectsRay() should return the expected result.")
        
        varOut = xFacingPlane.intersectsSegment (from: Vector3 (x: 0, y: 1, z: 1), to: Vector3 (x: 2, y: 1, z: 1))
        vecOut = Vector3 (varOut)
        XCTAssertEqual (varOut.gtype, .vector3, "intersectsSegment() should return the expected result.")
        XCTAssertEqual (vecOut, Vector3 (x: 1, y: 1, z: 1), "intersectsSegment() should return the expected result.")
    }
    
    func testFiniteNumberChecks () {
        let x: Vector3 = Vector3 (x: 0, y: 1, z: 2)
        let infinite: Vector3 = Vector3 (x: .nan, y: .nan, z: .nan)
        XCTAssertTrue (Plane (normal: x, point: .zero).isFinite (), "Plane with all components finite should be finite")
        XCTAssertFalse (Plane (normal: x, d: .nan).isFinite (), "Plane with one component infinite should not be finite.")
        XCTAssertFalse (Plane (normal: infinite, d: .zero).isFinite (), "Plane with one component infinite should not be finite.")
        XCTAssertFalse (Plane (normal: infinite, d: .nan).isFinite (), "Plane with two components infinite should not be finite.")
    }
    
}

extension Plane {
    
    func getAnyPerpendicularNormal () -> Vector3 {
        let p1: Vector3 = SwiftGodot.Vector3 (x: 1, y: 0, z: 0)
        let p2: Vector3 = Vector3 (x: 0, y: 1, z: 0)
        var p: Vector3 = normal.dot (with: p1) > 0.99 ? p2 : p1
        p -= normal * normal.dot (with: p)
        return p.normalized ()
    }
    
}
