// Based on godot/tests/core/math/test_geometry_2d.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Geometry2DTests: GodotTestCase {
    
    func testPointInCircle () {
        XCTAssertTrue (Geometry2D.isPointInCircle (point: Vector2 (x: 0, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0))
        
        XCTAssertTrue (Geometry2D.isPointInCircle (point: Vector2 (x: 0, y: 0), circlePosition: Vector2 (x: 11.99, y: 0), circleRadius: 12))
        XCTAssertTrue (Geometry2D.isPointInCircle (point: Vector2 (x: -11.99, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 12))
        
        XCTAssertFalse (Geometry2D.isPointInCircle (point: Vector2 (x: 0, y: 0), circlePosition: Vector2 (x: 12.01, y: 0), circleRadius: 12))
        XCTAssertFalse (Geometry2D.isPointInCircle (point: Vector2 (x: -12.01, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 12))
        
        XCTAssertTrue (Geometry2D.isPointInCircle (point: Vector2 (x: 7, y: -42), circlePosition: Vector2 (x: 4, y: -40), circleRadius: 3.7))
        XCTAssertFalse (Geometry2D.isPointInCircle (point: Vector2 (x: 7, y: -42), circlePosition: Vector2 (x: 4, y: -40), circleRadius: 3.5))
        
        // This tests points on the edge of the circle. They are treated as being inside the circle.
        XCTAssertTrue (Geometry2D.isPointInCircle (point: Vector2 (x: 1.0, y: 0.0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0))
        XCTAssertTrue (Geometry2D.isPointInCircle (point: Vector2 (x: 0.0, y: -1.0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0))
    }

    func testPointInTriangle () {
        XCTAssertTrue (Geometry2D.pointIsInsideTriangle (point: Vector2 (x: 0, y: 0), a: Vector2 (x: -1, y: 1), b: Vector2 (x: 0, y: -1), c: Vector2 (x: 1, y: 1)))
        XCTAssertFalse (Geometry2D.pointIsInsideTriangle (point: Vector2 (x: -1.01, y: 1.0), a: Vector2 (x: -1, y: 1), b: Vector2 (x: 0, y: -1), c: Vector2 (x: 1, y: 1)))
        
        XCTAssertTrue (Geometry2D.pointIsInsideTriangle (point: Vector2 (x: 3, y: 2.5), a: Vector2 (x: 1, y: 4), b: Vector2 (x: 3, y: 2), c: Vector2 (x: 5, y: 4)))
        XCTAssertTrue (Geometry2D.pointIsInsideTriangle (point: Vector2 (x: -3, y: -2.5), a: Vector2 (x: -1, y: -4), b: Vector2 (x: -3, y: -2), c: Vector2 (x: -5, y: -4)))
        XCTAssertFalse (Geometry2D.pointIsInsideTriangle (point: Vector2 (x: 0, y: 0), a: Vector2 (x: 1, y: 4), b: Vector2 (x: 3, y: 2), c: Vector2 (x: 5, y: 4)))
        
        // This tests points on the edge of the triangle. They are treated as being outside the triangle.
        // In `isPointInCircle` and `isPointInPolygon` they are treated as being inside, so in order the make
        // the behavior consistent this may change in the future (see issue #44717 and PR #44274).
        XCTAssertFalse (Geometry2D.pointIsInsideTriangle (point: Vector2 (x: 1, y: 1), a: Vector2 (x: -1, y: 1), b: Vector2 (x: 0, y: -1), c: Vector2 (x: 1, y: 1)))
        XCTAssertFalse (Geometry2D.pointIsInsideTriangle (point: Vector2 (x: 0, y: 1), a: Vector2 (x: -1, y: 1), b: Vector2 (x: 0, y: -1), c: Vector2 (x: 1, y: 1)))
    }
    
    func testPointInPolygon () {
        let p = PackedVector2Array ()
        XCTAssertFalse (Geometry2D.isPointInPolygon (point: Vector2 (x: 0, y: 0), polygon: p))
        
        p.pushBack (value: Vector2 (x: -88, y: 120))
        p.pushBack (value: Vector2 (x: -74, y: -38))
        p.pushBack (value: Vector2 (x: 135, y: -145))
        p.pushBack (value: Vector2 (x: 425, y: 70))
        p.pushBack (value: Vector2 (x: 68, y: 112))
        p.pushBack (value: Vector2 (x: -120, y: 370))
        p.pushBack (value: Vector2 (x: -323, y: -145))
        XCTAssertFalse (Geometry2D.isPointInPolygon (point: Vector2 (x: -350, y: 0), polygon: p))
        XCTAssertFalse (Geometry2D.isPointInPolygon (point: Vector2 (x: -110, y: 60), polygon: p))
        XCTAssertFalse (Geometry2D.isPointInPolygon (point: Vector2 (x: 412, y: 96), polygon: p))
        XCTAssertFalse (Geometry2D.isPointInPolygon (point: Vector2 (x: 83, y: 130), polygon: p))
        XCTAssertFalse (Geometry2D.isPointInPolygon (point: Vector2 (x: -320, y: -153), polygon: p))
        
        XCTAssertTrue (Geometry2D.isPointInPolygon (point: Vector2 (x: 0, y: 0), polygon: p))
        XCTAssertTrue (Geometry2D.isPointInPolygon (point: Vector2 (x: -230, y: 0), polygon: p))
        XCTAssertTrue (Geometry2D.isPointInPolygon (point: Vector2 (x: 130, y: -110), polygon: p))
        XCTAssertTrue (Geometry2D.isPointInPolygon (point: Vector2 (x: 370, y: 55), polygon: p))
        XCTAssertTrue (Geometry2D.isPointInPolygon (point: Vector2 (x: -160, y: 190), polygon: p))
        
        // This tests points on the edge of the polygon. They are treated as being inside the polygon.
        let c = Int (p.size ())
        for i in 0..<c {
            let p1 = p [i]
            XCTAssertTrue (Geometry2D.isPointInPolygon (point: p1, polygon: p))
            
            let p2 = p [(i + 1) % c]
            let midpoint = ((p1 + p2) * 0.5)
            XCTAssertTrue (Geometry2D.isPointInPolygon (point: midpoint, polygon: p))
        }
    }
    
    func testPolygonClockwise () {
        let p = PackedVector2Array ()
        XCTAssertFalse (Geometry2D.isPolygonClockwise (polygon: p))
        
        p.pushBack (value: Vector2 (x: 5, y: -5))
        p.pushBack (value: Vector2 (x: -1, y: -5))
        p.pushBack (value: Vector2 (x: -5, y: -1))
        p.pushBack (value: Vector2 (x: -1, y: 3))
        p.pushBack (value: Vector2 (x: 1, y: 5))
        XCTAssertTrue (Geometry2D.isPolygonClockwise (polygon: p))
        
        p.reverse ()
        XCTAssertFalse (Geometry2D.isPolygonClockwise (polygon: p))
    }

    func testLineIntersection () {
        var r: Variant
        
        r = Geometry2D.lineIntersectsLine (fromA: Vector2 (x: 2, y: 0), dirA: Vector2 (x: 0, y: 1), fromB: Vector2 (x: 0, y: 2), dirB: Vector2 (x: 1, y: 0))
        XCTAssertEqual (r.gtype, .vector2)
        XCTAssertEqual (Vector2 (r), Vector2 (x: 2, y: 2))
        
        r = Geometry2D.lineIntersectsLine (fromA: Vector2 (x: -1, y: 1), dirA: Vector2 (x: 1, y: -1), fromB: Vector2 (x: 4, y: 1), dirB: Vector2 (x: -1, y: -1))
        XCTAssertEqual (r.gtype, .vector2)
        XCTAssertEqual (Vector2 (r), Vector2 (x: 1.5, y: -1.5))
        
        r = Geometry2D.lineIntersectsLine (fromA: Vector2 (x: -1, y: 0), dirA: Vector2 (x: -1, y: -1), fromB: Vector2 (x: 1, y: 0), dirB: Vector2 (x: 1, y: -1))
        XCTAssertEqual (r.gtype, .vector2)
        XCTAssertEqual (Vector2 (r), Vector2 (x: 0, y: 1))
        
        r = Geometry2D.lineIntersectsLine (fromA: Vector2 (x: -1, y: 1), dirA: Vector2 (x: 1, y: -1), fromB: Vector2 (x: 0, y: 1), dirB: Vector2 (x: 1, y: -1))
        XCTAssertEqual (r.gtype, .nil, "Parallel lines should not intersect.")
    }

    func testSegmentIntersection () {
        var r: Variant
        
        r = Geometry2D.segmentIntersectsSegment (fromA: Vector2 (x: -1, y: 1), toA: Vector2 (x: 1, y: -1), fromB: Vector2 (x: 1, y: 1), toB: Vector2 (x: -1, y: -1))
        XCTAssertEqual (r.gtype, .vector2)
        XCTAssertEqual (Vector2 (r), Vector2 (x: 0, y: 0))
        
        r = Geometry2D.segmentIntersectsSegment (fromA: Vector2 (x: -1, y: 1), toA: Vector2 (x: 1, y: -1), fromB: Vector2 (x: 1, y: 1), toB: Vector2 (x: 0.1, y: 0.1))
        XCTAssertEqual (r.gtype, .nil)
        r = Geometry2D.segmentIntersectsSegment (fromA: Vector2 (x: -1, y: 1), toA: Vector2 (x: 1, y: -1), fromB: Vector2 (x: 0.1, y: 0.1), toB: Vector2 (x: 1, y: 1))
        XCTAssertEqual (r.gtype, .nil)
        
        r = Geometry2D.segmentIntersectsSegment (fromA: Vector2 (x: -1, y: 1), toA: Vector2 (x: 1, y: -1), fromB: Vector2 (x: 0, y: 1), toB: Vector2 (x: 2, y: -1))
        XCTAssertEqual (r.gtype, .nil, "Parallel segments should not intersect.")
        
        r = Geometry2D.segmentIntersectsSegment (fromA: Vector2 (x: 1, y: 2), toA: Vector2 (x: 3, y: 2), fromB: Vector2 (x: 0, y: 2), toB: Vector2 (x: -2, y: 2))
        XCTAssertEqual (r.gtype, .nil,"Non-overlapping collinear segments should not intersect.")
        
        r = Geometry2D.segmentIntersectsSegment (fromA: Vector2 (x: 0, y: 0), toA: Vector2 (x: 0, y: 1), fromB: Vector2 (x: 0, y: 0), toB: Vector2 (x: 1, y: 0))
        XCTAssertEqual (r.gtype, .vector2, "Touching segments should intersect.")
        XCTAssertEqual (Vector2 (r), Vector2 (x: 0, y: 0))
        
        r = Geometry2D.segmentIntersectsSegment (fromA: Vector2 (x: 0, y: 1), toA: Vector2 (x: 0, y: 0), fromB: Vector2 (x: 0, y: 0), toB: Vector2 (x: 1, y: 0))
        XCTAssertEqual (r.gtype, .vector2, "Touching segments should intersect.")
        XCTAssertEqual (Vector2 (r), Vector2 (x: 0, y: 0))
    }
    
    func testSegmentIntersectionWithCircle () {
        let minusOne: Double = -1.0
        let zero: Double = 0.0
        let oneQuarter: Double = 0.25
        let threeQuarters: Double = 0.75
        let one: Double = 1.0
        
        XCTAssertEqual (Geometry2D.segmentIntersectsCircle (segmentFrom: Vector2 (x: 0, y: 0), segmentTo: Vector2 (x: 4, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0), oneQuarter, "Segment from inside to outside of circle should intersect it.")
        XCTAssertEqual (Geometry2D.segmentIntersectsCircle (segmentFrom: Vector2 (x: 4, y: 0), segmentTo: Vector2 (x: 0, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0), threeQuarters, "Segment from outside to inside of circle should intersect it.")
        
        XCTAssertEqual (Geometry2D.segmentIntersectsCircle (segmentFrom: Vector2 (x: -2, y: 0), segmentTo: Vector2 (x: 2, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0), oneQuarter, "Segment running through circle should intersect it.")
        XCTAssertEqual (Geometry2D.segmentIntersectsCircle (segmentFrom: Vector2 (x: 2, y: 0), segmentTo: Vector2 (x: -2, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0), oneQuarter, "Segment running through circle should intersect it.")
        
        XCTAssertEqual (Geometry2D.segmentIntersectsCircle (segmentFrom: Vector2 (x: 0, y: 0), segmentTo: Vector2 (x: 1, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0), one, "Segment starting inside the circle and ending on the circle should intersect it")
        XCTAssertEqual (Geometry2D.segmentIntersectsCircle (segmentFrom: Vector2 (x: 1, y: 0), segmentTo: Vector2 (x: 0, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0), zero, "Segment starting on the circle and going inwards should intersect it")
        XCTAssertEqual (Geometry2D.segmentIntersectsCircle (segmentFrom: Vector2 (x: 1, y: 0), segmentTo: Vector2 (x: 2, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0), zero, "Segment starting on the circle and going outwards should intersect it")
        XCTAssertEqual (Geometry2D.segmentIntersectsCircle (segmentFrom: Vector2 (x: 2, y: 0), segmentTo: Vector2 (x: 1, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0), one, "Segment starting outside the circle and ending on the circle intersect it")
        
        XCTAssertEqual (Geometry2D.segmentIntersectsCircle (segmentFrom: Vector2 (x: -1, y: 0), segmentTo: Vector2 (x: 1, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 2.0), minusOne, "Segment completely within the circle should not intersect it")
        XCTAssertEqual (Geometry2D.segmentIntersectsCircle (segmentFrom: Vector2 (x: 1, y: 0), segmentTo: Vector2 (x: -1, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 2.0), minusOne, "Segment completely within the circle should not intersect it")
        XCTAssertEqual (Geometry2D.segmentIntersectsCircle (segmentFrom: Vector2 (x: 2, y: 0), segmentTo: Vector2 (x: 3, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0), minusOne, "Segment completely outside the circle should not intersect it")
        XCTAssertEqual (Geometry2D.segmentIntersectsCircle (segmentFrom: Vector2 (x: 3, y: 0), segmentTo: Vector2 (x: 2, y: 0), circlePosition: Vector2 (x: 0, y: 0), circleRadius: 1.0), minusOne, "Segment completely outside the circle should not intersect it")
    }

    func testClosestPointToSegment () {
        XCTAssertEqual (Geometry2D.getClosestPointToSegment (point: Vector2 (x: 4.1, y: 4.1), s1: Vector2 (x: -4, y: -4), s2: Vector2 (x: 4, y: 4)), Vector2 (x: 4, y: 4))
        XCTAssertEqual (Geometry2D.getClosestPointToSegment (point: Vector2 (x: -4.1, y: -4.1), s1: Vector2 (x: -4, y: -4), s2: Vector2 (x: 4, y: 4)), Vector2 (x: -4, y: -4))
        XCTAssertEqual (Geometry2D.getClosestPointToSegment (point: Vector2 (x: -1, y: 1), s1: Vector2 (x: -4, y: -4), s2: Vector2 (x: 4, y: 4)), Vector2 (x: 0, y: 0))
        
        XCTAssertEqual (Geometry2D.getClosestPointToSegment (point: Vector2 (x: -3, y: 4), s1: Vector2 (x: 1, y: -2), s2: Vector2 (x: 1, y: -2)), Vector2 (x: 1, y: -2), "Line segment is only a single point. This point should be the closest.")
    }

    func testClosestPointToUncappedSegment () {
        assertApproxEqual (Geometry2D.getClosestPointToSegmentUncapped (point: Vector2 (x: -1, y: 1), s1: Vector2 (x: -4, y: -4), s2: Vector2 (x: 4, y: 4)), Vector2 (x: 0, y: 0))
        assertApproxEqual (Geometry2D.getClosestPointToSegmentUncapped (point: Vector2 (x: -4, y: -6), s1: Vector2 (x: -4, y: -4), s2: Vector2 (x: 4, y: 4)), Vector2 (x: -5, y: -5))
        assertApproxEqual (Geometry2D.getClosestPointToSegmentUncapped (point: Vector2 (x: 4, y: 6), s1: Vector2 (x: -4, y: -4), s2: Vector2 (x: 4, y: 4)), Vector2 (x: 5, y: 5))
    }

    func testClosestPointsBetweenSegments () {
        var r: PackedVector2Array
        
        r = Geometry2D.getClosestPointsBetweenSegments (p1: Vector2 (x: 2, y: 2), q1: Vector2 (x: 3, y: 3), p2: Vector2 (x: 4, y: 4), q2: Vector2 (x: 4, y: 5))
        XCTAssertEqual (r.count, 2)
        XCTAssertEqual (r [safe: 0], Vector2 (x: 3, y: 3))
        XCTAssertEqual (r [safe: 1], Vector2 (x: 4, y: 4))
        
        r = Geometry2D.getClosestPointsBetweenSegments (p1: Vector2 (x: 0, y: 1), q1: Vector2 (x: -2, y: -1), p2: Vector2 (x: 0, y: 0), q2: Vector2 (x: 2, y: -2))
        XCTAssertEqual (r.count, 2)
        XCTAssertEqual (r [safe: 0], Vector2 (x: -0.5, y: 0.5))
        XCTAssertEqual (r [safe: 1], Vector2 (x: 0, y: 0))
        
        r = Geometry2D.getClosestPointsBetweenSegments (p1: Vector2 (x: -1, y: 1), q1: Vector2 (x: 1, y: -1), p2: Vector2 (x: 1, y: 1), q2: Vector2 (x: -1, y: -1))
        XCTAssertEqual (r.count, 2)
        XCTAssertEqual (r [safe: 0], Vector2 (x: 0, y: 0))
        XCTAssertEqual (r [safe: 1], Vector2 (x: 0, y: 0))
        
        r = Geometry2D.getClosestPointsBetweenSegments (p1: Vector2 (x: -3, y: 4), q1: Vector2 (x: -3, y: 4), p2: Vector2 (x: -4, y: 3), q2: Vector2 (x: -2, y: 3))
        XCTAssertEqual (r.count, 2)
        XCTAssertEqual (r [safe: 0], Vector2 (x: -3, y: 4), "1st line segment is only a point, this point should be the closest point to the 2nd line segment.")
        XCTAssertEqual (r [safe: 1], Vector2 (x: -3, y: 3), "1st line segment is only a point, this should not matter when determining the closest point on the 2nd line segment.")
        
        r = Geometry2D.getClosestPointsBetweenSegments (p1: Vector2 (x: -4, y: 3), q1: Vector2 (x: -2, y: 3), p2: Vector2 (x: -3, y: 4), q2: Vector2 (x: -3, y: 4))
        XCTAssertEqual (r.count, 2)
        XCTAssertEqual (r [safe: 0], Vector2 (x: -3, y: 3), "2nd line segment is only a point, this should not matter when determining the closest point on the 1st line segment.")
        XCTAssertEqual (r [safe: 1], Vector2 (x: -3, y: 4), "2nd line segment is only a point, this point should be the closest point to the 1st line segment.")
        
        r = Geometry2D.getClosestPointsBetweenSegments (p1: Vector2 (x: 5, y: -4), q1: Vector2 (x: 5, y: -4), p2: Vector2 (x: -2, y: 1), q2: Vector2 (x: -2, y: 1))
        XCTAssertEqual (r.count, 2)
        XCTAssertEqual (r [safe: 0], Vector2 (x: 5, y: -4), "Both line segments are only a point. On the 1st line segment, that point should be the closest point to the 2nd line segment.")
        XCTAssertEqual (r [safe: 1], Vector2 (x: -2, y: 1), "Both line segments are only a point. On the 2nd line segment, that point should be the closest point to the 1st line segment.")
    }

    func testMakeAtlas () {
        var result: GDictionary
        
        let r = PackedVector2Array ()
        r.pushBack (value: Vector2 (x: 2, y: 2))
        result = Geometry2D.makeAtlas (sizes: r)
        XCTAssertEqual (result.size (), 2)
        XCTAssertEqual (result ["size"], Variant (Vector2i (x: 2, y: 2)))
        XCTAssertEqual (result ["points"]?.description, "[(0, 0)]")
        
        r.clear ()
        result.clear ()
        r.pushBack (value: Vector2 (x: 1, y: 2))
        r.pushBack (value: Vector2 (x: 3, y: 4))
        r.pushBack (value: Vector2 (x: 5, y: 6))
        r.pushBack (value: Vector2 (x: 7, y: 8))
        result = Geometry2D.makeAtlas (sizes: r)
        XCTAssertEqual (result.size (), 2)
        XCTAssertEqual (PackedVector2Array (result ["points"] ?? Variant ())?.size (), r.size ())
    }
    
    func testPolygonIntersection () throws {
        let a = PackedVector2Array ()
        let b = PackedVector2Array ()
        var r: VariantCollection<PackedVector2Array>
        
        a.pushBack (value: Vector2 (x: 30, y: 60))
        a.pushBack (value: Vector2 (x: 70, y: 5))
        a.pushBack (value: Vector2 (x: 200, y: 40))
        a.pushBack (value: Vector2 (x: 80, y: 200))
        
        r = Geometry2D.intersectPolygons (polygonA: PackedVector2Array (), polygonB: PackedVector2Array ())
        XCTAssertTrue (r.isEmpty (), "Both polygons are empty. The intersection should also be empty.")
        
        r = Geometry2D.intersectPolygons (polygonA: a, polygonB: b)
        XCTAssertTrue (r.isEmpty (), "One polygon is empty. The intersection should also be empty.")
        
        // Basic intersection
        b.clear ()
        b.pushBack (value: Vector2 (x: 200, y: 300))
        b.pushBack (value: Vector2 (x: 90, y: 200))
        b.pushBack (value: Vector2 (x: 50, y: 100))
        b.pushBack (value: Vector2 (x: 200, y: 90))
        r = Geometry2D.intersectPolygons (polygonA: a, polygonB: b)
        XCTAssertEqual (r.size (), 1, "The polygons should intersect each other with 1 resulting intersection polygon.")
        XCTAssertEqual (r [safe: 0]?.size (), 3, "The resulting intersection polygon should have 3 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], Vector2 (x: 86.52174, y: 191.30436))
        assertApproxEqual (r [safe: 0]?[safe: 1], Vector2 (x: 50, y: 100))
        assertApproxEqual (r [safe: 0]?[safe: 2], Vector2 (x: 160.52632, y: 92.63157))
        
        // Intersection with one polygon being completely inside the other polygon
        b.clear ()
        b.pushBack (value: Vector2 (x: 80, y: 100))
        b.pushBack (value: Vector2 (x: 50, y: 50))
        b.pushBack (value: Vector2 (x: 150, y: 50))
        r = Geometry2D.intersectPolygons (polygonA: a, polygonB: b)
        XCTAssertEqual (r.size (), 1, "The polygons should intersect each other with 1 resulting intersection polygon.")
        XCTAssertEqual (r [safe: 0]?.size (), 3, "The resulting intersection polygon should have 3 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], b [0])
        assertApproxEqual (r [safe: 0]?[safe: 1], b [1])
        assertApproxEqual (r [safe: 0]?[safe: 2], b [2])
                
        // No intersection with 2 non-empty polygons
        b.clear ()
        b.pushBack (value: Vector2 (x: 150, y: 150))
        b.pushBack (value: Vector2 (x: 250, y: 100))
        b.pushBack (value: Vector2 (x: 300, y: 200))
        r = Geometry2D.intersectPolygons (polygonA: a, polygonB: b)
        XCTAssertTrue (r.isEmpty (), "The polygons should not intersect each other.")
                
        // Intersection with 2 resulting polygons
        a.clear ()
        a.pushBack (value: Vector2 (x: 70, y: 5))
        a.pushBack (value: Vector2 (x: 140, y: 7))
        a.pushBack (value: Vector2 (x: 100, y: 52))
        a.pushBack (value: Vector2 (x: 170, y: 50))
        a.pushBack (value: Vector2 (x: 60, y: 125))
        b.clear ()
        b.pushBack (value: Vector2 (x: 70, y: 105))
        b.pushBack (value: Vector2 (x: 115, y: 55))
        b.pushBack (value: Vector2 (x: 90, y: 15))
        b.pushBack (value: Vector2 (x: 160, y: 50))
        r = Geometry2D.intersectPolygons (polygonA: a, polygonB: b)
        XCTAssertEqual (r.size (), 2, "The polygons should intersect each other with 2 resulting intersection polygons.")
        XCTAssertEqual (r [safe: 0]?.size (), 4, "The resulting intersection polygon should have 4 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], Vector2 (x: 70, y: 105))
        assertApproxEqual (r [safe: 0]?[safe: 1], Vector2 (x: 115, y: 55))
        assertApproxEqual (r [safe: 0]?[safe: 2], Vector2 (x: 112.894737, y: 51.63158))
        assertApproxEqual (r [safe: 0]?[safe: 3], Vector2 (x: 159.509537, y: 50.299728))
        
        XCTAssertEqual (r [safe: 1]?.size (), 3, "The intersection polygon should have 3 vertices.")
        assertApproxEqual (r [safe: 1]?[safe: 0], Vector2 (x: 119.692307, y: 29.846149))
        assertApproxEqual (r [safe: 1]?[safe: 1], Vector2 (x: 107.706421, y: 43.33028))
        assertApproxEqual (r [safe: 1]?[safe: 2], Vector2 (x: 90, y: 15))
    }
    
    func testMergePolygons () {
        let a = PackedVector2Array ()
        let b = PackedVector2Array ()
        var r: VariantCollection<PackedVector2Array>
        
        a.pushBack (value: Vector2 (x: 225, y: 180))
        a.pushBack (value: Vector2 (x: 160, y: 230))
        a.pushBack (value: Vector2 (x: 20, y: 212))
        a.pushBack (value: Vector2 (x: 50, y: 115))
        
        // Both polygons are empty
        r = Geometry2D.mergePolygons (polygonA: PackedVector2Array (), polygonB: PackedVector2Array ())
        XCTAssertTrue (r.isEmpty (), "Both polygons are empty. The union should also be empty.")
        
        // One polygon is empty
        r = Geometry2D.mergePolygons (polygonA: a, polygonB: b)
        XCTAssertEqual (r.size (), 1, "One polygon is non-empty. There should be 1 resulting merged polygon.")
        XCTAssertEqual (r [safe: 0]?.size (), 4, "The resulting merged polygon should have 4 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], a [0])
        assertApproxEqual (r [safe: 0]?[safe: 1], a [1])
        assertApproxEqual (r [safe: 0]?[safe: 2], a [2])
        assertApproxEqual (r [safe: 0]?[safe: 3], a [3])
        
        // Basic merge with 2 polygons
        b.pushBack (value: Vector2 (x: 180, y: 190))
        b.pushBack (value: Vector2 (x: 60, y: 140))
        b.pushBack (value: Vector2 (x: 160, y: 80))
        r = Geometry2D.mergePolygons (polygonA: a, polygonB: b)
        XCTAssertEqual (r.size (), 1, "The merged polygons should result in 1 polygon.")
        XCTAssertEqual (r [safe: 0]?.size (), 7, "The resulting merged polygon should have 7 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], Vector2 (x: 174.791077, y: 161.350967))
        assertApproxEqual (r [safe: 0]?[safe: 1], Vector2 (x: 225, y: 180))
        assertApproxEqual (r [safe: 0]?[safe: 2], Vector2 (x: 160, y: 230))
        assertApproxEqual (r [safe: 0]?[safe: 3], Vector2 (x: 20, y: 212))
        assertApproxEqual (r [safe: 0]?[safe: 4], Vector2 (x: 50, y: 115))
        assertApproxEqual (r [safe: 0]?[safe: 5], Vector2 (x: 81.911758, y: 126.852943))
        assertApproxEqual (r [safe: 0]?[safe: 6], Vector2 (x: 160, y: 80))
        
        // Merge with 2 resulting merged polygons (outline and hole)
        b.clear ()
        b.pushBack (value: Vector2 (x: 180, y: 190))
        b.pushBack (value: Vector2 (x: 140, y: 125))
        b.pushBack (value: Vector2 (x: 60, y: 140))
        b.pushBack (value: Vector2 (x: 160, y: 80))
        r = Geometry2D.mergePolygons (polygonA: a, polygonB: b)
        XCTAssertEqual (r.size (), 2, "The merged polygons should result in 2 polygons.")
        
        XCTAssertTrue (!Geometry2D.isPolygonClockwise (polygon: r [safe: 0] ?? PackedVector2Array ()), "The merged polygon (outline) should be counter-clockwise.")
        XCTAssertEqual (r [safe: 0]?.size (), 7, "The resulting merged polygon (outline) should have 7 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], Vector2 (x: 174.791077, y: 161.350967))
        assertApproxEqual (r [safe: 0]?[safe: 1], Vector2 (x: 225, y: 180))
        assertApproxEqual (r [safe: 0]?[safe: 2], Vector2 (x: 160, y: 230))
        assertApproxEqual (r [safe: 0]?[safe: 3], Vector2 (x: 20, y: 212))
        assertApproxEqual (r [safe: 0]?[safe: 4], Vector2 (x: 50, y: 115))
        assertApproxEqual (r [safe: 0]?[safe: 5], Vector2 (x: 81.911758, y: 126.852943))
        assertApproxEqual (r [safe: 0]?[safe: 6], Vector2 (x: 160, y: 80))
        
        XCTAssertTrue (Geometry2D.isPolygonClockwise (polygon: r [safe: 1] ?? PackedVector2Array ()), "The resulting merged polygon (hole) should be clockwise.")
        XCTAssertEqual (r [safe: 1]?.size (), 3, "The resulting merged polygon (hole) should have 3 vertices.")
        assertApproxEqual (r [safe: 1]?[safe: 0], Vector2 (x: 98.083069, y: 132.859421))
        assertApproxEqual (r [safe: 1]?[safe: 1], Vector2 (x: 158.689453, y: 155.370377))
        assertApproxEqual (r [safe: 1]?[safe: 2], Vector2 (x: 140, y: 125))
    }

    func testClipPolygons () {
        let a = PackedVector2Array ()
        let b = PackedVector2Array ()
        var r: VariantCollection<PackedVector2Array>
        
        a.pushBack (value: Vector2 (x: 225, y: 180))
        a.pushBack (value: Vector2 (x: 160, y: 230))
        a.pushBack (value: Vector2 (x: 20, y: 212))
        a.pushBack (value: Vector2 (x: 50, y: 115))
        
        // Both polygons are empty
        r = Geometry2D.clipPolygons (polygonA: PackedVector2Array (), polygonB: PackedVector2Array ())
        XCTAssertTrue (r.isEmpty (), "Both polygons are empty. The clip should also be empty.")
        
        // Basic clip with one result polygon
        b.pushBack (value: Vector2 (x: 250, y: 170))
        b.pushBack (value: Vector2 (x: 175, y: 270))
        b.pushBack (value: Vector2 (x: 120, y: 260))
        b.pushBack (value: Vector2 (x: 25, y: 80))
        r = Geometry2D.clipPolygons (polygonA: a, polygonB: b)
        XCTAssertEqual (r.size (), 1, "The clipped polygons should result in 1 polygon.")
        XCTAssertEqual (r [safe: 0]?.size (), 3, "The resulting clipped polygon should have 3 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], Vector2 (x: 100.102173, y: 222.298843))
        assertApproxEqual (r [safe: 0]?[safe: 1], Vector2 (x: 20, y: 212))
        assertApproxEqual (r [safe: 0]?[safe: 2], Vector2 (x: 47.588089, y: 122.798492))
        
        // Polygon b completely overlaps polygon a
        b.clear ()
        b.pushBack (value: Vector2 (x: 250, y: 170))
        b.pushBack (value: Vector2 (x: 175, y: 270))
        b.pushBack (value: Vector2 (x: 10, y: 210))
        b.pushBack (value: Vector2 (x: 55, y: 80))
        r = Geometry2D.clipPolygons (polygonA: a, polygonB: b)
        XCTAssertTrue (r.isEmpty (), "Polygon 'b' completely overlaps polygon 'a'. This should result in no clipped polygons.")
        
        // Polygon a completely overlaps polygon b
        b.clear ()
        b.pushBack (value: Vector2 (x: 150, y: 200))
        b.pushBack (value: Vector2 (x: 65, y: 190))
        b.pushBack (value: Vector2 (x: 80, y: 140))
        r = Geometry2D.clipPolygons (polygonA: a, polygonB: b)
        XCTAssertEqual (r.size (), 2, "Polygon 'a' completely overlaps polygon 'b'. This should result in 2 clipped polygons.")
        XCTAssertEqual (r [safe: 0]?.size (), 4, "The resulting clipped polygon should have 4 vertices.")
        XCTAssertTrue (!Geometry2D.isPolygonClockwise (polygon: r [safe: 0] ?? PackedVector2Array ()), "The resulting clipped polygon (outline) should be counter-clockwise.")
        assertApproxEqual (r [safe: 0]?[safe: 0], a [0])
        assertApproxEqual (r [safe: 0]?[safe: 1], a [1])
        assertApproxEqual (r [safe: 0]?[safe: 2], a [2])
        assertApproxEqual (r [safe: 0]?[safe: 3], a [3])
        XCTAssertEqual (r [safe: 1]?.size (), 3, "The resulting clipped polygon should have 3 vertices.")
        XCTAssertTrue (Geometry2D.isPolygonClockwise (polygon: r [safe: 1] ?? PackedVector2Array ()), "The resulting clipped polygon (hole) should be clockwise.")
        assertApproxEqual (r [safe: 1]?[safe: 0], b [1])
        assertApproxEqual (r [safe: 1]?[safe: 1], b [0])
        assertApproxEqual (r [safe: 1]?[safe: 2], b [2])
    }
    
    func testExcludePolygons () {
        let a = PackedVector2Array ()
        let b = PackedVector2Array ()
        var r: VariantCollection<PackedVector2Array>
        
        a.pushBack (value: Vector2 (x: 225, y: 180))
        a.pushBack (value: Vector2 (x: 160, y: 230))
        a.pushBack (value: Vector2 (x: 20, y: 212))
        a.pushBack (value: Vector2 (x: 50, y: 115))
        
        // Both polygons are empty
        r = Geometry2D.excludePolygons (polygonA: PackedVector2Array (), polygonB: PackedVector2Array ())
        XCTAssertTrue (r.isEmpty (), "Both polygons are empty. The excluded polygon should also be empty.")
        
        // One polygon is empty
        r = Geometry2D.excludePolygons (polygonA: a, polygonB: b)
        XCTAssertEqual (r.size (), 1, "One polygon is non-empty. There should be 1 resulting excluded polygon.")
        XCTAssertEqual (r [safe: 0]?.size (), 4, "The resulting excluded polygon should have 4 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], a [0])
        assertApproxEqual (r [safe: 0]?[safe: 1], a [1])
        assertApproxEqual (r [safe: 0]?[safe: 2], a [2])
        assertApproxEqual (r [safe: 0]?[safe: 3], a [3])
        
        // Exclude with 2 resulting polygons (outline and hole)
        b.pushBack (value: Vector2 (x: 140, y: 160))
        b.pushBack (value: Vector2 (x: 150, y: 220))
        b.pushBack (value: Vector2 (x: 40, y: 200))
        b.pushBack (value: Vector2 (x: 60, y: 140))
        r = Geometry2D.excludePolygons (polygonA: a, polygonB: b)
        XCTAssertEqual (r.size (), 2, "There should be 2 resulting excluded polygons (outline and hole).")
        XCTAssertEqual (r [safe: 0]?.size (), 4, "The resulting excluded polygon should have 4 vertices.")
        XCTAssertTrue (!Geometry2D.isPolygonClockwise (polygon: r [safe: 0] ?? PackedVector2Array ()), "The resulting excluded polygon (outline) should be counter-clockwise.")
        assertApproxEqual (r [safe: 0]?[safe: 0], a [0])
        assertApproxEqual (r [safe: 0]?[safe: 1], a [1])
        assertApproxEqual (r [safe: 0]?[safe: 2], a [2])
        assertApproxEqual (r [safe: 0]?[safe: 3], a [3])
        XCTAssertEqual (r [safe: 1]?.size (), 4, "The resulting excluded polygon should have 4 vertices.")
        XCTAssertTrue (Geometry2D.isPolygonClockwise (polygon: r [safe: 1] ?? PackedVector2Array ()), "The resulting excluded polygon (hole) should be clockwise.")
        assertApproxEqual (r [safe: 1]?[safe: 0], Vector2 (x: 40, y: 200))
        assertApproxEqual (r [safe: 1]?[safe: 1], Vector2 (x: 150, y: 220))
        assertApproxEqual (r [safe: 1]?[safe: 2], Vector2 (x: 140, y: 160))
        assertApproxEqual (r [safe: 1]?[safe: 3], Vector2 (x: 60, y: 140))
    }

    func testIntersectPolylineWithPolygon () {
        let l = PackedVector2Array ()
        let p = PackedVector2Array ()
        var r: VariantCollection<PackedVector2Array>
        
        l.pushBack (value: Vector2 (x: 100, y: 90))
        l.pushBack (value: Vector2 (x: 120, y: 250))
        
        p.pushBack (value: Vector2 (x: 225, y: 180))
        p.pushBack (value: Vector2 (x: 160, y: 230))
        p.pushBack (value: Vector2 (x: 20, y: 212))
        p.pushBack (value: Vector2 (x: 50, y: 115))
        
        // Both line and polygon are empty
        r = Geometry2D.intersectPolylineWithPolygon (polyline: PackedVector2Array (), polygon: PackedVector2Array ())
        XCTAssertTrue (r.isEmpty (), "Both line and polygon are empty. The intersection line should also be empty.")
        
        // Line is non-empty and polygon is empty
        r = Geometry2D.intersectPolylineWithPolygon (polyline: l, polygon: PackedVector2Array ())
        XCTAssertTrue (r.isEmpty (), "The polygon is empty while the line is non-empty. The intersection line should be empty.")
        
        // Basic intersection with 1 resulting intersection line
        r = Geometry2D.intersectPolylineWithPolygon (polyline: l, polygon: p)
        XCTAssertEqual (r.size (), 1, "There should be 1 resulting intersection line.")
        XCTAssertEqual (r [safe: 0]?.size (), 2, "The resulting intersection line should have 2 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], Vector2 (x: 105.711609, y: 135.692886))
        assertApproxEqual (r [safe: 0]?[safe: 1], Vector2 (x: 116.805809, y: 224.446457))
        
        // Complex intersection with 2 resulting intersection lines
        l.clear ()
        l.pushBack (value: Vector2 (x: 100, y: 90))
        l.pushBack (value: Vector2 (x: 190, y: 255))
        l.pushBack (value: Vector2 (x: 135, y: 260))
        l.pushBack (value: Vector2 (x: 57, y: 200))
        l.pushBack (value: Vector2 (x: 50, y: 170))
        l.pushBack (value: Vector2 (x: 15, y: 155))
        r = Geometry2D.intersectPolylineWithPolygon (polyline: l, polygon: p)
        XCTAssertEqual (r.size (), 2, "There should be 2 resulting intersection lines.")
        XCTAssertEqual (r [safe: 0]?.size (), 2, "The resulting intersection line should have 2 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], Vector2 (x: 129.804565, y: 144.641693))
        assertApproxEqual (r [safe: 0]?[safe: 1], Vector2 (x: 171.527084, y: 221.132996))
        XCTAssertEqual (r [safe: 1]?.size (), 4, "The resulting intersection line should have 4 vertices.")
        assertApproxEqual (r [safe: 1]?[safe: 0], Vector2 (x: 83.15609, y: 220.120087))
        assertApproxEqual (r [safe: 1]?[safe: 1], Vector2 (x: 57, y: 200))
        assertApproxEqual (r [safe: 1]?[safe: 2], Vector2 (x: 50, y: 170))
        assertApproxEqual (r [safe: 1]?[safe: 3], Vector2 (x: 34.980492, y: 163.563065))
    }

    func testClipPolylineWithPolygon () {
        let l = PackedVector2Array ()
        let p = PackedVector2Array ()
        var r: VariantCollection<PackedVector2Array>
        
        l.pushBack (value: Vector2 (x: 70, y: 140))
        l.pushBack (value: Vector2 (x: 160, y: 320))
        
        p.pushBack (value: Vector2 (x: 225, y: 180))
        p.pushBack (value: Vector2 (x: 160, y: 230))
        p.pushBack (value: Vector2 (x: 20, y: 212))
        p.pushBack (value: Vector2 (x: 50, y: 115))
        
        // Both line and polygon are empty
        r = Geometry2D.clipPolylineWithPolygon (polyline: PackedVector2Array (), polygon: PackedVector2Array ())
        XCTAssertTrue (r.isEmpty (), "Both line and polygon are empty. The clipped line should also be empty.")
        
        // Polygon is empty and line is non-empty
        r = Geometry2D.clipPolylineWithPolygon (polyline: l, polygon: PackedVector2Array ())
        XCTAssertEqual (r.size (), 1, "There should be 1 resulting clipped line.")
        XCTAssertEqual (r [safe: 0]?.size (), 2, "The resulting clipped line should have 2 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], l [0])
        assertApproxEqual (r [safe: 0]?[safe: 1], l [1])
        
        // Basic clip with 1 resulting clipped line
        r = Geometry2D.clipPolylineWithPolygon (polyline: l, polygon: p)
        XCTAssertEqual (r.size (), 1, "There should be 1 resulting clipped line.")
        XCTAssertEqual (r [safe: 0]?.size (), 2, "The resulting clipped line should have 2 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], Vector2 (x: 111.908401, y: 223.816803))
        assertApproxEqual (r [safe: 0]?[safe: 1], Vector2 (x: 160, y: 320))
        
        // Complex clip with 2 resulting clipped lines
        l.clear ()
        l.pushBack (value: Vector2 (x: 55, y: 70))
        l.pushBack (value: Vector2 (x: 50, y: 190))
        l.pushBack (value: Vector2 (x: 120, y: 165))
        l.pushBack (value: Vector2 (x: 122, y: 250))
        l.pushBack (value: Vector2 (x: 160, y: 320))
        r = Geometry2D.clipPolylineWithPolygon (polyline: l, polygon: p)
        XCTAssertEqual (r.size (), 2, "There should be 2 resulting clipped lines.")
        XCTAssertEqual (r [safe: 0]?.size (), 3, "The resulting clipped line should have 3 vertices.")
        assertApproxEqual (r [safe: 0]?[safe: 0], Vector2 (x: 160, y: 320))
        assertApproxEqual (r [safe: 0]?[safe: 1], Vector2 (x: 122, y: 250))
        assertApproxEqual (r [safe: 0]?[safe: 2], Vector2 (x: 121.412682, y: 225.038757))
        XCTAssertEqual (r [safe: 1]?.size (), 2, "The resulting clipped line should have 2 vertices.")
        assertApproxEqual (r [safe: 1]?[safe: 0], Vector2 (x: 53.07737, y: 116.143021))
        assertApproxEqual (r [safe: 1]?[safe: 1], Vector2 (x: 55, y: 70))
    }

    func testConvexHull () {
        let a = PackedVector2Array ()
        var r = PackedVector2Array ()
        
        a.pushBack (value: Vector2 (x: -4, y: -8))
        a.pushBack (value: Vector2 (x: -10, y: -4))
        a.pushBack (value: Vector2 (x: 8, y: 2))
        a.pushBack (value: Vector2 (x: -6, y: 10))
        a.pushBack (value: Vector2 (x: -12, y: 4))
        a.pushBack (value: Vector2 (x: 10, y: -8))
        a.pushBack (value: Vector2 (x: 4, y: 8))
        
        // No points
        r = Geometry2D.convexHull (points: PackedVector2Array ())
        
        XCTAssertTrue (r.isEmpty (), "The convex hull should be empty if there are no input points.")
        
        // Single point
        let b = PackedVector2Array ()
        b.pushBack (value: Vector2 (x: 4, y: -3))
        
        r = Geometry2D.convexHull (points: b)
        XCTAssertEqual (r.size (), 1, "Convex hull should contain 1 point.")
        assertApproxEqual (r [safe: 0], b [0])
        
        // All points form the convex hull
        r = Geometry2D.convexHull (points: a)
        XCTAssertEqual (r.size (), 8, "Convex hull should contain 8 points.")
        assertApproxEqual (r [safe: 0], Vector2 (x: -12, y: 4))
        assertApproxEqual (r [safe: 1], Vector2 (x: -10, y: -4))
        assertApproxEqual (r [safe: 2], Vector2 (x: -4, y: -8))
        assertApproxEqual (r [safe: 3], Vector2 (x: 10, y: -8))
        assertApproxEqual (r [safe: 4], Vector2 (x: 8, y: 2))
        assertApproxEqual (r [safe: 5], Vector2 (x: 4, y: 8))
        assertApproxEqual (r [safe: 6], Vector2 (x: -6, y: 10))
        assertApproxEqual (r [safe: 7], Vector2 (x: -12, y: 4))
        
        // Add extra points inside original convex hull
        a.pushBack (value: Vector2 (x: -4, y: -8))
        a.pushBack (value: Vector2 (x: 0, y: 0))
        a.pushBack (value: Vector2 (x: 0, y: 8))
        a.pushBack (value: Vector2 (x: -10, y: -3))
        a.pushBack (value: Vector2 (x: 9, y: -4))
        a.pushBack (value: Vector2 (x: 6, y: 4))
        
        r = Geometry2D.convexHull (points: a)
        XCTAssertEqual (r.size (), 8, "Convex hull should contain 8 points.")
        assertApproxEqual (r [safe: 0], Vector2 (x: -12, y: 4))
        assertApproxEqual (r [safe: 1], Vector2 (x: -10, y: -4))
        assertApproxEqual (r [safe: 2], Vector2 (x: -4, y: -8))
        assertApproxEqual (r [safe: 3], Vector2 (x: 10, y: -8))
        assertApproxEqual (r [safe: 4], Vector2 (x: 8, y: 2))
        assertApproxEqual (r [safe: 5], Vector2 (x: 4, y: 8))
        assertApproxEqual (r [safe: 6], Vector2 (x: -6, y: 10))
        assertApproxEqual (r [safe: 7], Vector2 (x: -12, y: 4))
        
        // Add extra points on border of original convex hull
        a.pushBack (value: Vector2 (x: 9, y: -3))
        a.pushBack (value: Vector2 (x: -2, y: -8))
        
        r = Geometry2D.convexHull (points: a)
        XCTAssertEqual (r.size (), 8, "Convex hull should contain 8 points.")
        assertApproxEqual (r [safe: 0], Vector2 (x: -12, y: 4))
        assertApproxEqual (r [safe: 1], Vector2 (x: -10, y: -4))
        assertApproxEqual (r [safe: 2], Vector2 (x: -4, y: -8))
        assertApproxEqual (r [safe: 3], Vector2 (x: 10, y: -8))
        assertApproxEqual (r [safe: 4], Vector2 (x: 8, y: 2))
        assertApproxEqual (r [safe: 5], Vector2 (x: 4, y: 8))
        assertApproxEqual (r [safe: 6], Vector2 (x: -6, y: 10))
        assertApproxEqual (r [safe: 7], Vector2 (x: -12, y: 4))
        
        // Add extra points outside border of original convex hull
        a.pushBack (value: Vector2 (x: -11, y: -1))
        a.pushBack (value: Vector2 (x: 7, y: 6))
        
        r = Geometry2D.convexHull (points: a)
        XCTAssertEqual (r.size (), 10, "Convex hull should contain 10 points.")
        assertApproxEqual (r [safe: 0], Vector2 (x: -12, y: 4))
        assertApproxEqual (r [safe: 1], Vector2 (x: -11, y: -1))
        assertApproxEqual (r [safe: 2], Vector2 (x: -10, y: -4))
        assertApproxEqual (r [safe: 3], Vector2 (x: -4, y: -8))
        assertApproxEqual (r [safe: 4], Vector2 (x: 10, y: -8))
        assertApproxEqual (r [safe: 5], Vector2 (x: 8, y: 2))
        assertApproxEqual (r [safe: 6], Vector2 (x: 7, y: 6))
        assertApproxEqual (r [safe: 7], Vector2 (x: 4, y: 8))
        assertApproxEqual (r [safe: 8], Vector2 (x: -6, y: 10))
        assertApproxEqual (r [safe: 9], Vector2 (x: -12, y: 4))
    }
    
}
