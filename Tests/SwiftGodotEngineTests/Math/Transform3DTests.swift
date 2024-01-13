// Based on godot/tests/core/math/test_transform_3d.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Transform3DTests: GodotTestCase {
    
    private func createDummyTransform () -> Transform3D {
        return Transform3D (basis: Basis (xAxis: Vector3 (x: 1, y: 2, z: 3), yAxis: Vector3 (x: 4, y: 5, z: 6), zAxis: Vector3 (x: 7, y: 8, z: 9)), origin: Vector3 (x: 10, y: 11, z: 12))
    }
    
    private func identity () -> Transform3D {
        return Transform3D ()
    }
    
    func testTranslation () {
        let offset: Vector3 = Vector3 (x: 1, y: 2, z: 3)
        
        // Both versions should give the same result applied to identity.
        XCTAssertEqual (identity ().translated (offset: offset), identity ().translatedLocal (offset: offset))
        
        // Check both versions against left and right multiplications.
        let orig: Transform3D = createDummyTransform ()
        let T: Transform3D = identity ().translated (offset: offset)
        XCTAssertEqual (orig.translated (offset: offset), T * orig)
        XCTAssertEqual (orig.translatedLocal (offset: offset), orig * T)
    }

    func testScaling () {
        let scaling: Vector3 = Vector3 (x: 1, y: 2, z: 3)
        
        // Both versions should give the same result applied to identity.
        XCTAssertEqual (identity ().scaled (scale: scaling), identity ().scaledLocal (scale: scaling))
        
        // Check both versions against left and right multiplications.
        let orig: Transform3D = createDummyTransform ()
        let S: Transform3D = identity ().scaled (scale: scaling)
        XCTAssertEqual (orig.scaled (scale: scaling), S * orig)
        XCTAssertEqual (orig.scaledLocal (scale: scaling), orig * S)
    }

    func testRotation () {
        let axis: Vector3 = Vector3 (x: 1, y: 2, z: 3).normalized ()
        let phi: Double = 1.0
        
        // Both versions should give the same result applied to identity.
        XCTAssertEqual (identity ().rotated (axis: axis, angle: phi), identity ().rotatedLocal (axis: axis, angle: phi))
        
        // Check both versions against left and right multiplications.
        let orig: Transform3D = createDummyTransform ()
        let R: Transform3D = identity ().rotated (axis: axis, angle: phi)
        XCTAssertEqual (orig.rotated (axis: axis, angle: phi), R * orig)
        XCTAssertEqual (orig.rotatedLocal (axis: axis, angle: phi), orig * R)
    }

    func testFiniteNumberChecks () {
        let y: Vector3 = Vector3 (x: 0, y: 1, z: 2)
        let infiniteVec: Vector3 = Vector3 (x: .nan, y: .nan, z: .nan)
        let x: Basis = Basis (xAxis: y, yAxis: y, zAxis: y)
        let infiniteBasis: Basis = Basis (xAxis: infiniteVec, yAxis: infiniteVec, zAxis: infiniteVec)
        
        XCTAssertTrue (Transform3D (basis: x, origin: y).isFinite (), "Transform3D with all components finite should be finite")
        
        XCTAssertFalse (Transform3D (basis: x, origin: infiniteVec).isFinite (), "Transform3D with one component infinite should not be finite.")
        XCTAssertFalse (Transform3D (basis: infiniteBasis, origin: y).isFinite (), "Transform3D with one component infinite should not be finite.")
        
        XCTAssertFalse (Transform3D (basis: infiniteBasis, origin: infiniteVec).isFinite (), "Transform3D with two components infinite should not be finite.")
    }
    
}
