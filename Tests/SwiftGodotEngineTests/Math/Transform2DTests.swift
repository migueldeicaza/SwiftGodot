// Based on godot/tests/core/math/test_transform_2d.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Transform2DTests: GodotTestCase {
    
    private func createDummyTransform () -> Transform2D {
        return Transform2D (xAxis: Vector2 (x: 1, y: 2), yAxis: Vector2 (x: 3, y: 4), origin: Vector2 (x: 5, y: 6))
    }
    
    private func identity () -> Transform2D {
        return Transform2D ()
    }
    
    func testTranslation () {
        let offset: Vector2 = Vector2 (x: 1, y: 2)
        
        // Both versions should give the same result applied to identity.
        XCTAssertEqual (identity ().translated (offset: offset), identity ().translatedLocal (offset: offset))
        
        // Check both versions against left and right multiplications.
        let orig: Transform2D = createDummyTransform ()
        let T: Transform2D = identity ().translated (offset: offset)
        XCTAssertEqual (orig.translated (offset: offset), T * orig)
        XCTAssertEqual (orig.translatedLocal (offset: offset), orig * T)
    }

    func testScaling () {
        let scaling: Vector2 = Vector2 (x: 1, y: 2)
        
        // Both versions should give the same result applied to identity.
        XCTAssertEqual (identity ().scaled (scale: scaling), identity ().scaledLocal (scale: scaling))
        
        // Check both versions against left and right multiplications.
        let orig: Transform2D = createDummyTransform ()
        let S: Transform2D = identity ().scaled (scale: scaling)
        XCTAssertEqual (orig.scaled (scale: scaling), S * orig)
        XCTAssertEqual (orig.scaledLocal (scale: scaling), orig * S)
    }

    func testRotation () {
        let phi: Double = 1.0
        
        // Both versions should give the same result applied to identity.
        XCTAssertEqual (identity ().rotated (angle: phi), identity ().rotatedLocal (angle: phi))
        
        // Check both versions against left and right multiplications.
        let orig: Transform2D = createDummyTransform ()
        let R: Transform2D = identity ().rotated (angle: phi)
        XCTAssertEqual (orig.rotated (angle: phi), R * orig)
        XCTAssertEqual (orig.rotatedLocal (angle: phi), orig * R)
    }

    func testInterpolation () {
        let rotateScaleSkewPos: Transform2D = Transform2D (rotation: Float (170.0).degreesToRadians, scale: Vector2 (x: 3.6, y: 8.0), skew: Float (20.0).degreesToRadians, position: Vector2 (x: 2.4, y: 6.8))
        let rotateScaleSkewPosHalfway: Transform2D = Transform2D (rotation: Float (85.0).degreesToRadians, scale: Vector2 (x: 2.3, y: 4.5), skew: Float (10.0).degreesToRadians, position: Vector2 (x: 1.2, y: 3.4))
        var interpolated: Transform2D = Transform2D ().interpolateWith (xform: rotateScaleSkewPos, weight: 0.5)
        XCTAssertTrue (interpolated.getOrigin ().isEqualApprox (to: rotateScaleSkewPosHalfway.getOrigin ()))
        XCTAssertEqual (interpolated.getRotation (), rotateScaleSkewPosHalfway.getRotation ())
        XCTAssertTrue (interpolated.getScale ().isEqualApprox (to: rotateScaleSkewPosHalfway.getScale ()))
        XCTAssertEqual (interpolated.getSkew (), rotateScaleSkewPosHalfway.getSkew ())
        XCTAssertTrue (interpolated.isEqualApprox (xform: rotateScaleSkewPosHalfway))
        interpolated = rotateScaleSkewPos.interpolateWith (xform: Transform2D (), weight: 0.5)
        XCTAssertTrue (interpolated.isEqualApprox (xform: rotateScaleSkewPosHalfway))
    }

    func testFiniteNumberChecks () {
        let x: Vector2 = Vector2 (x: 0, y: 1)
        let infinite: Vector2 = Vector2 (x: .nan, y: .nan)
        
        XCTAssertTrue (Transform2D (xAxis: x, yAxis: x, origin: x).isFinite (), "Transform2D with all components finite should be finite")
        
        XCTAssertFalse (Transform2D (xAxis: infinite, yAxis: x, origin: x).isFinite (), "Transform2D with one component infinite should not be finite.")
        XCTAssertFalse (Transform2D (xAxis: x, yAxis: infinite, origin: x).isFinite (), "Transform2D with one component infinite should not be finite.")
        XCTAssertFalse (Transform2D (xAxis: x, yAxis: x, origin: infinite).isFinite (), "Transform2D with one component infinite should not be finite.")
        
        XCTAssertFalse (Transform2D (xAxis: infinite, yAxis: infinite, origin: x).isFinite (), "Transform2D with two components infinite should not be finite.")
        XCTAssertFalse (Transform2D (xAxis: infinite, yAxis: x, origin: infinite).isFinite (), "Transform2D with two components infinite should not be finite.")
        XCTAssertFalse (Transform2D (xAxis: x, yAxis: infinite, origin: infinite).isFinite (), "Transform2D with two components infinite should not be finite.")
        
        XCTAssertFalse (Transform2D (xAxis: infinite, yAxis: infinite, origin: infinite).isFinite (), "Transform2D with three components infinite should not be finite.")
    }

    func testIsConformalChecks () {
        XCTAssertTrue (Transform2D ().isConformal (), "Identity Transform2D should be conformal.")
        XCTAssertTrue (Transform2D (rotation: 1.2, position: Vector2 ()).isConformal (), "Transform2D with only rotation should be conformal.")
        XCTAssertTrue (Transform2D (xAxis: Vector2 (x: 1, y: 0), yAxis: Vector2 (x: 0, y: -1), origin: Vector2 ()).isConformal (), "Transform2D with only a flip should be conformal.")
        XCTAssertTrue (Transform2D (xAxis: Vector2 (x: 1.2, y: 0), yAxis: Vector2 (x: 0, y: 1.2), origin: Vector2 ()).isConformal (), "Transform2D with only uniform scale should be conformal.")
        XCTAssertTrue (Transform2D (xAxis: Vector2 (x: 1.2, y: 3.4), yAxis: Vector2 (x: 3.4, y: -1.2), origin: Vector2 ()).isConformal (), "Transform2D with a flip, rotation, and uniform scale should be conformal.")
        XCTAssertFalse (Transform2D (xAxis: Vector2 (x: 1.2, y: 0), yAxis: Vector2 (x: 0, y: 3.4), origin: Vector2 ()).isConformal (), "Transform2D with non-uniform scale should not be conformal.")
        XCTAssertFalse (Transform2D (xAxis: Vector2 (x: Float.sqrt12, y: Float.sqrt12), yAxis: Vector2 (x: 0, y: 1), origin: Vector2 ()).isConformal (), "Transform2D with the X axis skewed 45 degrees should not be conformal.")
    }
    
}
