// Based on godot/tests/core/math/test_aabb.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class AABBTests: GodotTestCase {
    
    func testConstructorMethods () {
        let aabb: AABB = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        let aabbCopy: AABB = AABB (from: aabb)
        XCTAssertEqual (aabb, aabbCopy, "AABBs created with the same dimensions but by different methods should be equal.")
    }
    
    func testStringConversion () {
        let aabb: AABB = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        XCTAssertEqual (Variant (aabb).description, "[P: (-1.5, 2, -2.5), S: (4, 5, 6)]", "The string representation should match the expected value.")
    }
    
    func testBasicGetters () {
        let aabb: AABB = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        XCTAssertEqual (aabb.position, Vector3 (x: -1.5, y: 2, z: -2.5), "position getter should return the expected value.")
        XCTAssertEqual (aabb.size, Vector3 (x: 4, y: 5, z: 6), "size getter should return the expected value.")
        XCTAssertEqual (aabb.end, Vector3 (x: 2.5, y: 7, z: 3.5), "end getter should return the expected value.")
        XCTAssertEqual (aabb.getCenter (), Vector3 (x: 0.5, y: 4.5, z: 0.5), "getCenter() should return the expected value.")
    }
    
    func testBasicSetters () {
        var aabb: AABB
        
        aabb = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        aabb.end = Vector3 (x: 100, y: 0, z: 100)
        XCTAssertEqual (aabb, AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 101.5, y: -2, z: 102.5)), "Setting end should result in the expected AABB.")
        
        aabb = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        aabb.position = Vector3 (x: -1000, y: -2000, z: -3000)
        XCTAssertEqual (aabb, AABB (position: Vector3 (x: -1000, y: -2000, z: -3000), size: Vector3 (x: 4, y: 5, z: 6)), "Setting position should result in the expected AABB.")

        aabb = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        aabb.size = Vector3 (x: 0, y: 0, z: -50)
        XCTAssertEqual (aabb, AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 0, y: 0, z: -50)), "Setting position should result in the expected AABB.")
    }
    
    func testVolumeGetters () {
        var aabb: AABB
        
        aabb = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        XCTAssertEqual (aabb.getVolume (), 120, "getVolume() should return the expected value with positive size.")
        XCTAssertTrue (aabb.hasVolume (), "Non-empty volumetric AABB should have a volume.")
        
        aabb = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: -4, y: 5, z: 6))
        XCTAssertEqual (aabb.getVolume (), -120, "getVolume() should return the expected value with negative size (1 component).")
        
        aabb = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: -4, y: -5, z: 6))
        XCTAssertEqual (aabb.getVolume (), 120, "getVolume() should return the expected value with positive size (2 components).")
        
        aabb = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: -4, y: -5, z: -6))
        XCTAssertEqual (aabb.getVolume (), -120, "getVolume() should return the expected value with negative size (3 components).")
        
        aabb = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 0, z: 6))
        XCTAssertFalse (aabb.hasVolume (), "Non-empty flat AABB should not have a volume.")
        
        aabb = AABB ()
        XCTAssertFalse (aabb.hasVolume (), "Empty AABB should not have a volume.")
    }
    
    func testSurfaceGetters () {
        var aabb: AABB
        
        aabb = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        XCTAssertTrue (aabb.hasSurface (), "Non-empty volumetric AABB should have an surface.")
        
        aabb = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 0, z: 6))
        XCTAssertTrue (aabb.hasSurface (), "Non-empty flat AABB should have a surface.")
        
        aabb = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 0, z: 0))
        XCTAssertTrue (aabb.hasSurface (), "Non-empty linear AABB should have a surface.")
        
        aabb = AABB ()
        XCTAssertFalse (aabb.hasSurface (), "Empty AABB should not have an surface.")
    }
    
    func testIntersection () {
        let aabbBig: AABB = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        var aabbSmall: AABB
        
        aabbSmall = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 1, y: 1, z: 1))
        XCTAssertTrue (aabbBig.intersects (with: aabbSmall), "intersects() with fully contained AABB (touching the edge) should return the expected result.")
        
        aabbSmall = AABB (position: Vector3 (x: 0.5, y: 1.5, z: -2), size: Vector3 (x: 1, y: 1, z: 1))
        XCTAssertTrue (aabbBig.intersects (with: aabbSmall), "intersects() with partially contained AABB (overflowing on Y axis) should return the expected result.")
        
        aabbSmall = AABB (position: Vector3 (x: 10, y: -10, z: -10), size: Vector3 (x: 1, y: 1, z: 1))
        XCTAssertFalse (aabbBig.intersects (with: aabbSmall), "intersects() with non-contained AABB should return the expected result.")
        
        aabbSmall = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 1, y: 1, z: 1))
        XCTAssertEqual (aabbBig.intersection (with: aabbSmall), aabbSmall, "intersection() with fully contained AABB (touching the edge) should return the expected result.")
        
        aabbSmall = AABB (position: Vector3 (x: 0.5, y: 1.5, z: -2), size: Vector3 (x: 1, y: 1, z: 1))
        XCTAssertEqual (aabbBig.intersection (with: aabbSmall), AABB (position: Vector3 (x: 0.5, y: 2, z: -2), size: Vector3 (x: 1, y: 0.5, z: 1)), "intersection() with partially contained AABB (overflowing on Y axis) should return the expected result.")
        
        aabbSmall = AABB (position: Vector3 (x: 10, y: -10, z: -10), size: Vector3 (x: 1, y: 1, z: 1))
        XCTAssertEqual (aabbBig.intersection (with: aabbSmall), AABB (), "intersection() with non-contained AABB should return the expected result.")
        
        XCTAssertTrue (aabbBig.intersectsPlane (Plane (normal: Vector3 (x: 0, y: 1, z: 0), d: 4)), "intersectsPlane() should return the expected result.")
        XCTAssertTrue (aabbBig.intersectsPlane (Plane (normal: Vector3 (x: 0, y: -1, z: 0), d: -4)), "intersectsPlane() should return the expected result.")
        XCTAssertFalse (aabbBig.intersectsPlane (Plane (normal: Vector3 (x: 0, y: 1, z: 0), d: 200)), "intersectsPlane() should return the expected result.")
        
        XCTAssertNotEqual (aabbBig.intersectsSegment (from: Vector3 (x: 1, y: 3, z: 0), to: Vector3 (x: 0, y: 3, z: 0)).gtype, Variant.GType.nil, "intersectsSegment() should return the expected result.")
        XCTAssertNotEqual (aabbBig.intersectsSegment (from: Vector3 (x: 0, y: 3, z: 0), to: Vector3 (x: 0, y: -300, z: 0)).gtype, Variant.GType.nil, "intersectsSegment() should return the expected result.")
        XCTAssertNotEqual (aabbBig.intersectsSegment (from: Vector3 (x: -50, y: 3, z: -50), to: Vector3 (x: 50, y: 3, z: 50)).gtype, Variant.GType.nil, "intersectsSegment() should return the expected result.")
        XCTAssertEqual (aabbBig.intersectsSegment (from: Vector3 (x: -50, y: 25, z: -50), to: Vector3 (x: 50, y: 25, z: 50)).gtype, Variant.GType.nil, "intersectsSegment() should return the expected result.")
        XCTAssertNotEqual (aabbBig.intersectsSegment (from: Vector3 (x: 0, y: 3, z: 0), to: Vector3 (x: 0, y: 3, z: 0)).gtype, Variant.GType.nil, "intersectsSegment() should return the expected result with segment of length 0.")
        XCTAssertEqual (aabbBig.intersectsSegment (from: Vector3 (x: 0, y: 300, z: 0), to: Vector3 (x: 0, y: 300, z: 0)).gtype, Variant.GType.nil, "intersectsSegment() should return the expected result with segment of length 0.")
    }
    
    func testMerging () {
        let aabbBig: AABB = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        var aabbSmall: AABB
        
        aabbSmall = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 1, y: 1, z: 1))
        XCTAssertEqual (aabbBig.merge (with: aabbSmall), aabbBig, "merge() with fully contained AABB (touching the edge) should return the expected result.")
        
        aabbSmall = AABB (position: Vector3 (x: 0.5, y: 1.5, z: -2), size: Vector3 (x: 1, y: 1, z: 1))
        XCTAssertEqual (aabbBig.merge (with: aabbSmall), AABB (position: Vector3 (x: -1.5, y: 1.5, z: -2.5), size: Vector3 (x: 4, y: 5.5, z: 6)), "merge() with partially contained AABB (overflowing on Y axis) should return the expected result.")
        
        aabbSmall = AABB (position: Vector3 (x: 10, y: -10, z: -10), size: Vector3 (x: 1, y: 1, z: 1))
        XCTAssertEqual (aabbBig.merge (with: aabbSmall), AABB (position: Vector3 (x: -1.5, y: -10, z: -10), size: Vector3 (x: 12.5, y: 17, z: 13.5)), "merge() with non-contained AABB should return the expected result.")
    }
    
    func testEncloses () {
        let aabbBig: AABB = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        var aabbSmall: AABB
        
        aabbSmall = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 1, y: 1, z: 1))
        XCTAssertTrue (aabbBig.encloses (with: aabbSmall), "encloses() with fully contained AABB (touching the edge) should return the expected result.")
        
        aabbSmall = AABB (position: Vector3 (x: 0.5, y: 1.5, z: -2), size: Vector3 (x: 1, y: 1, z: 1))
        XCTAssertFalse (aabbBig.encloses (with: aabbSmall), "encloses() with partially contained AABB (overflowing on Y axis) should return the expected result.")
        
        aabbSmall = AABB (position: Vector3 (x: 10, y: -10, z: -10), size: Vector3 (x: 1, y: 1, z: 1))
        XCTAssertFalse (aabbBig.encloses (with: aabbSmall), "encloses() with non-contained AABB should return the expected result.")
    }
    
    func testGetEndpoints () {
        let aabb: AABB = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        XCTAssertEqual (aabb.getEndpoint (idx: 0), Vector3 (x: -1.5, y: 2, z: -2.5), "The endpoint at index 0 should match the expected value.")
        XCTAssertEqual (aabb.getEndpoint (idx: 1), Vector3 (x: -1.5, y: 2, z: 3.5), "The endpoint at index 1 should match the expected value.")
        XCTAssertEqual (aabb.getEndpoint (idx: 2), Vector3 (x: -1.5, y: 7, z: -2.5), "The endpoint at index 2 should match the expected value.")
        XCTAssertEqual (aabb.getEndpoint (idx: 3), Vector3 (x: -1.5, y: 7, z: 3.5), "The endpoint at index 3 should match the expected value.")
        XCTAssertEqual (aabb.getEndpoint (idx: 4), Vector3 (x: 2.5, y: 2, z: -2.5), "The endpoint at index 4 should match the expected value.")
        XCTAssertEqual (aabb.getEndpoint (idx: 5), Vector3 (x: 2.5, y: 2, z: 3.5), "The endpoint at index 5 should match the expected value.")
        XCTAssertEqual (aabb.getEndpoint (idx: 6), Vector3 (x: 2.5, y: 7, z: -2.5), "The endpoint at index 6 should match the expected value.")
        XCTAssertEqual (aabb.getEndpoint (idx: 7), Vector3 (x: 2.5, y: 7, z: 3.5), "The endpoint at index 7 should match the expected value.")
        XCTAssertEqual (aabb.getEndpoint (idx: 8), Vector3 (), "The endpoint at invalid index 8 should match the expected value.")
        XCTAssertEqual (aabb.getEndpoint (idx: -1), Vector3 (), "The endpoint at invalid index -1 should match the expected value.")
    }
    
    func testGetLongestShortestAxis () {
        let aabb: AABB = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        XCTAssertEqual (aabb.getLongestAxis (), Vector3 (x: 0, y: 0, z: 1), "getLongestAxis() should return the expected value.")
        XCTAssertEqual (aabb.getLongestAxisIndex (), Int64 (Vector3.Axis.z.rawValue), "getLongestAxisIndex() should return the expected value.")
        XCTAssertEqual (aabb.getLongestAxisSize (), 6, "getLongestAxisSize() should return the expected value.")
        XCTAssertEqual (aabb.getShortestAxis (), Vector3 (x: 1, y: 0, z: 0), "getShortestAxis() should return the expected value.")
        XCTAssertEqual (aabb.getShortestAxisIndex (), Int64 (Vector3.Axis.x.rawValue), "getShortestAxisIndex() should return the expected value.")
        XCTAssertEqual (aabb.getShortestAxisSize (), 4, "getShortestAxisSize() should return the expected value.")
    }
    
    func testGetSupport () {
        let aabb: AABB = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        XCTAssertEqual (aabb.getSupport (dir: Vector3 (x: 1, y: 0, z: 0)), Vector3 (x: 2.5, y: 2, z: -2.5), "getSupport() should return the expected value.")
        XCTAssertEqual (aabb.getSupport (dir: Vector3 (x: 0.5, y: 1, z: 0)), Vector3 (x: 2.5, y: 7, z: -2.5), "getSupport() should return the expected value.")
        XCTAssertEqual (aabb.getSupport (dir: Vector3 (x: 0.5, y: 1, z: -400)), Vector3 (x: 2.5, y: 7, z: -2.5), "getSupport() should return the expected value.")
        XCTAssertEqual (aabb.getSupport (dir: Vector3 (x: 0, y: -1, z: 0)), Vector3 (x: -1.5, y: 2, z: -2.5), "getSupport() should return the expected value.")
        XCTAssertEqual (aabb.getSupport (dir: Vector3 (x: 0, y: -0.1, z: 0)), Vector3 (x: -1.5, y: 2, z: -2.5), "getSupport() should return the expected value.")
        XCTAssertEqual (aabb.getSupport (dir: Vector3 ()), Vector3 (x: -1.5, y: 2, z: -2.5), "getSupport() should return the expected value with a null vector.")
    }
    
    func testGrow () {
        let aabb: AABB = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        XCTAssertEqual (aabb.grow (by: 0.25), AABB (position: Vector3 (x: -1.75, y: 1.75, z: -2.75), size: Vector3 (x: 4.5, y: 5.5, z: 6.5)), "grow() with positive value should return the expected AABB.")
        XCTAssertEqual (aabb.grow (by: -0.25), AABB (position: Vector3 (x: -1.25, y: 2.25, z: -2.25), size: Vector3 (x: 3.5, y: 4.5, z: 5.5)), "grow() with negative value should return the expected AABB.")
        XCTAssertEqual (aabb.grow (by: -10), AABB (position: Vector3 (x: 8.5, y: 12, z: 7.5), size: Vector3 (x: -16, y: -15, z: -14)), "grow() with large negative value should return the expected AABB.")
    }
    
    func testHasPoint () {
        let aabb: AABB = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        
        XCTAssertTrue (aabb.hasPoint (Vector3 (x: -1, y: 3, z: 0)), "hasPoint() with contained point should return the expected value.")
        XCTAssertTrue (aabb.hasPoint (Vector3 (x: 2, y: 3, z: 0)), "hasPoint() with contained point should return the expected value.")
        XCTAssertFalse (aabb.hasPoint (Vector3 (x: -20, y: 0, z: 0)), "hasPoint() with non-contained point should return the expected value.")
        
        XCTAssertTrue (aabb.hasPoint (Vector3 (x: -1.5, y: 3, z: 0)), "hasPoint() with positive size should include point on near face (X axis).")
        XCTAssertTrue (aabb.hasPoint (Vector3 (x: 2.5, y: 3, z: 0)), "hasPoint() with positive size should include point on far face (X axis).")
        XCTAssertTrue (aabb.hasPoint (Vector3 (x: 0, y: 2, z: 0)), "hasPoint() with positive size should include point on near face (Y axis).")
        XCTAssertTrue (aabb.hasPoint (Vector3 (x: 0, y: 7, z: 0)), "hasPoint() with positive size should include point on far face (Y axis).")
        XCTAssertTrue (aabb.hasPoint (Vector3 (x: 0, y: 3, z: -2.5)), "hasPoint() with positive size should include point on near face (Z axis).")
        XCTAssertTrue (aabb.hasPoint (Vector3 (x: 0, y: 3, z: 3.5)), "hasPoint() with positive size should include point on far face (Z axis).")
    }
    
    func testExpanding () {
        let aabb: AABB = AABB (position: Vector3 (x: -1.5, y: 2, z: -2.5), size: Vector3 (x: 4, y: 5, z: 6))
        XCTAssertEqual (aabb.expand (toPoint: Vector3 (x: -1, y: 3, z: 0)), aabb, "expand() with contained point should return the expected AABB.")
        XCTAssertEqual (aabb.expand (toPoint: Vector3 (x: 2, y: 3, z: 0)), aabb, "expand() with contained point should return the expected AABB.")
        XCTAssertEqual (aabb.expand (toPoint: Vector3 (x: -1.5, y: 3, z: 0)), aabb, "expand() with contained point on negative edge should return the expected AABB.")
        XCTAssertEqual (aabb.expand (toPoint: Vector3 (x: 2.5, y: 3, z: 0)), aabb, "expand() with contained point on positive edge should return the expected AABB.")
        XCTAssertEqual (aabb.expand (toPoint: Vector3 (x: -20, y: 0, z: 0)), AABB (position: Vector3 (x: -20, y: 0, z: -2.5), size: Vector3 (x: 22.5, y: 7, z: 6)), "expand() with non-contained point should return the expected AABB.")
    }
    
    func testFiniteNumberChecks () {
        let x: Vector3 = Vector3 (x: 0, y: 1, z: 2)
        let infinite: Vector3 = Vector3 (x: .nan, y: .nan, z: .nan)
        XCTAssertTrue (AABB (position: x, size: x).isFinite (), "AABB with all components finite should be finite")
        XCTAssertFalse (AABB (position: infinite, size: x).isFinite (), "AABB with one component infinite should not be finite.")
        XCTAssertFalse (AABB (position: x, size: infinite).isFinite (), "AABB with one component infinite should not be finite.")
        XCTAssertFalse (AABB (position: infinite, size: infinite).isFinite (), "AABB with two components infinite should not be finite.")
    }
    
}
