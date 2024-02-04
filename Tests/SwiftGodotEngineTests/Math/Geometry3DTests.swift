// Based on godot/tests/core/math/test_geometry_3d.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Geometry3DTests: GodotTestCase {
    
    func testClosestPointsBetweenSegments () {
        let r = Geometry3D.getClosestPointsBetweenSegments (p1: Vector3 (x: 1, y: -1, z: 1), p2: Vector3 (x: 1, y: 1, z: -1), q1: Vector3 (x: -1, y: -2, z: -1), q2: Vector3 (x: -1, y: 1, z: 1))
        assertApproxEqual (r [safe: 0], Vector3 (x: 1, y: -0.2, z: 0.2))
        assertApproxEqual (r [safe: 1], Vector3 (x: -1, y: -0.2, z: 0.2))
    }

    func testBuildBoxPlanes () {
        let extents: Vector3 = Vector3 (x: 5, y: 5, z: 20)
        let box = Geometry3D.buildBoxPlanes (extents: extents)
        XCTAssertEqual (box.size (), 6)
        XCTAssertEqual (extents.x, box [safe: 0]?.d)
        XCTAssertEqual (box [safe: 0]?.normal, Vector3 (x: 1, y: 0, z: 0))
        XCTAssertEqual (extents.x, box [safe: 1]?.d)
        XCTAssertEqual (box [safe: 1]?.normal, Vector3 (x: -1, y: 0, z: 0))
        XCTAssertEqual (extents.y, box [safe: 2]?.d)
        XCTAssertEqual (box [safe: 2]?.normal, Vector3 (x: 0, y: 1, z: 0))
        XCTAssertEqual (extents.y, box [safe: 3]?.d)
        XCTAssertEqual (box [safe: 3]?.normal, Vector3 (x: 0, y: -1, z: 0))
        XCTAssertEqual (extents.z, box [safe: 4]?.d)
        XCTAssertEqual (box [safe: 4]?.normal, Vector3 (x: 0, y: 0, z: 1))
        XCTAssertEqual (extents.z, box [safe: 5]?.d)
        XCTAssertEqual (box [safe: 5]?.normal, Vector3 (x: 0, y: 0, z: -1))
    }

    func testBuildCapsulePlanes () {
        let capsule = Geometry3D.buildCapsulePlanes (radius: 10, height: 20, sides: 6, lats: 10)
        XCTAssertEqual (capsule.size (), 126)
    }

    func testBuildCylinderPlanes () {
        let planes = Geometry3D.buildCylinderPlanes (radius: 3.0, height: 10.0, sides: 10)
        XCTAssertEqual (planes.size (), 12)
    }
    
    func testClipPolygon () {
        let boxPlanes = Geometry3D.buildBoxPlanes (extents: Vector3 (x: 5, y: 10, z: 5))
        let box = Geometry3D.computeConvexMeshPoints (planes: boxPlanes)
        var output = Geometry3D.clipPolygon (points: box, plane: Plane ())
        XCTAssertEqual (output, box)
        output = Geometry3D.clipPolygon (points: box, plane: Plane (normal: Vector3 (x: 0, y: 1, z: 0), point: Vector3 (x: 0, y: 3, z: 0)))
        XCTAssertTrue (output != box)
    }

    func testComputeConvexMeshPoints () {
        let cube = PackedVector3Array ()
        cube.pushBack (value: Vector3 (x: -5, y: -5, z: -5))
        cube.pushBack (value: Vector3 (x: 5, y: -5, z: -5))
        cube.pushBack (value: Vector3 (x: -5, y: 5, z: -5))
        cube.pushBack (value: Vector3 (x: 5, y: 5, z: -5))
        cube.pushBack (value: Vector3 (x: -5, y: -5, z: 5))
        cube.pushBack (value: Vector3 (x: 5, y: -5, z: 5))
        cube.pushBack (value: Vector3 (x: -5, y: 5, z: 5))
        cube.pushBack (value: Vector3 (x: 5, y: 5, z: 5))
        let boxPlanes = Geometry3D.buildBoxPlanes (extents: Vector3 (x: 5, y: 5, z: 5))
        XCTAssertEqual (Geometry3D.computeConvexMeshPoints (planes: boxPlanes), cube)
    }

    func testGetClosestPointToSegment () {
        let output: Vector3 = Geometry3D.getClosestPointToSegment (point: Vector3 (x: 2, y: 1, z: 4), s1: Vector3 (x: 1, y: 1, z: 1), s2: Vector3 (x: 5, y: 5, z: 5))
        assertApproxEqual (output, Vector3 (x: 2.33333, y: 2.33333, z: 2.33333))
    }

    func testDoesRayIntersectTriangle () {
        var result: Variant
        result = Geometry3D.rayIntersectsTriangle (from: Vector3 (x: 0, y: 1, z: 1), dir: Vector3 (x: 0, y: 0, z: -10), a: Vector3 (x: 0, y: 3, z: 0), b: Vector3 (x: -3, y: 0, z: 0), c: Vector3 (x: 3, y: 0, z: 0))
        XCTAssertEqual (result.gtype, .vector3)
        XCTAssertEqual (Vector3 (result), Vector3 (x: 0, y: 1, z: 0))
        result = Geometry3D.rayIntersectsTriangle (from: Vector3 (x: 5, y: 10, z: 1), dir: Vector3 (x: 0, y: 0, z: -10), a: Vector3 (x: 0, y: 3, z: 0), b: Vector3 (x: -3, y: 0, z: 0), c: Vector3 (x: 3, y: 0, z: 0))
        XCTAssertEqual (result.gtype, .nil)
        result = Geometry3D.rayIntersectsTriangle (from: Vector3 (x: 0, y: 1, z: 1), dir: Vector3 (x: 0, y: 0, z: 10), a: Vector3 (x: 0, y: 3, z: 0), b: Vector3 (x: -3, y: 0, z: 0), c: Vector3 (x: 3, y: 0, z: 0))
        XCTAssertEqual (result.gtype, .nil)
    }

    func testDoesSegmentIntersectConvex () {
        let boxPlanes = Geometry3D.buildBoxPlanes (extents: Vector3 (x: 5, y: 5, z: 5))
        var result: PackedVector3Array
        result = Geometry3D.segmentIntersectsConvex (from: Vector3 (x: 10, y: 10, z: 10), to: Vector3 (x: 0, y: 0, z: 0), planes: boxPlanes)
        XCTAssertFalse (result.isEmpty ())
        result = Geometry3D.segmentIntersectsConvex (from: Vector3 (x: 10, y: 10, z: 10), to: Vector3 (x: 5, y: 5, z: 5), planes: boxPlanes)
        XCTAssertFalse (result.isEmpty ())
        result = Geometry3D.segmentIntersectsConvex (from: Vector3 (x: 10, y: 10, z: 10), to: Vector3 (x: 6, y: 5, z: 5), planes: boxPlanes)
        XCTAssertTrue (result.isEmpty ())
    }

    func testSegmentIntersectsCylinder () {
        var result: PackedVector3Array
        result = Geometry3D.segmentIntersectsCylinder (from: Vector3 (x: 10, y: 10, z: 10), to: Vector3 (x: 0, y: 0, z: 0), height: 5, radius: 5)
        XCTAssertFalse (result.isEmpty ())
        result = Geometry3D.segmentIntersectsCylinder (from: Vector3 (x: 10, y: 10, z: 10), to: Vector3 (x: 6, y: 6, z: 6), height: 5, radius: 5)
        XCTAssertTrue (result.isEmpty ())
    }

    func testSegmentIntersectsSphere () {
        var result: PackedVector3Array
        result = Geometry3D.segmentIntersectsSphere (from: Vector3 (x: 10, y: 10, z: 10), to: Vector3 (x: 0, y: 0, z: 0), spherePosition: Vector3 (x: 0, y: 0, z: 0), sphereRadius: 5)
        XCTAssertFalse (result.isEmpty ())
        result = Geometry3D.segmentIntersectsSphere (from: Vector3 (x: 10, y: 10, z: 10), to: Vector3 (x: 0, y: 0, z: 2.5), spherePosition: Vector3 (x: 0, y: 0, z: 0), sphereRadius: 5)
        XCTAssertFalse (result.isEmpty ())
        result = Geometry3D.segmentIntersectsSphere (from: Vector3 (x: 10, y: 10, z: 10), to: Vector3 (x: 5, y: 5, z: 5), spherePosition: Vector3 (x: 0, y: 0, z: 0), sphereRadius: 5)
        XCTAssertTrue (result.isEmpty ())
    }

    func testSegmentIntersectsTriangle () {
        var result: Variant
        result = Geometry3D.segmentIntersectsTriangle (from: Vector3 (x: 1, y: 1, z: 1), to: Vector3 (x: -1, y: -1, z: -1), a: Vector3 (x: -3, y: 0, z: 0), b: Vector3 (x: 0, y: 3, z: 0), c: Vector3 (x: 3, y: 0, z: 0))
        XCTAssertEqual (result.gtype, .vector3)
        result = Geometry3D.segmentIntersectsTriangle (from: Vector3 (x: 1, y: 1, z: 1), to: Vector3 (x: 3, y: 0, z: 0), a: Vector3 (x: -3, y: 0, z: 0), b: Vector3 (x: 0, y: 3, z: 0), c: Vector3 (x: 3, y: 0, z: 0))
        XCTAssertEqual (result.gtype, .vector3)
        result = Geometry3D.segmentIntersectsTriangle (from: Vector3 (x: 1, y: 1, z: 1), to: Vector3 (x: 10, y: -1, z: -1), a: Vector3 (x: -3, y: 0, z: 0), b: Vector3 (x: 0, y: 3, z: 0), c: Vector3 (x: 3, y: 0, z: 0))
        XCTAssertEqual (result.gtype, .nil)
    }
    
}
