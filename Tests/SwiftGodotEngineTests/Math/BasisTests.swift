// Based on godot/tests/core/math/test_basis.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class BasisTests: GodotTestCase {
    
    /// This test:
    /// 1. Converts the rotation vector from deg to rad.
    /// 2. Converts euler to basis.
    /// 3. Converts the above basis back into euler.
    /// 4. Converts the above euler into basis again.
    /// 5. Compares the basis obtained in step 2 with the basis of step 4
    ///
    /// The conversion "basis to euler", done in the step 3, may be different from
    /// the original euler, even if the final rotation are the same.
    /// This happens because there are more ways to represents the same rotation,
    /// both valid, using eulers.
    /// For this reason is necessary to convert that euler back to basis and finally
    /// compares it.
    ///
    /// In this way we can assert that both functions: basis to euler / euler to basis
    /// are correct.
    private func assertRotation (eulerDegrees: Vector3, eulerOrder: EulerOrder, file: StaticString = #file, line: UInt = #line) {
        let rawEulerOrder: Int64 = Int64 (eulerOrder.rawValue)
        
        // Euler to rotation
        let originalEuler: Vector3 = Vector3 (x: eulerDegrees.x.degreesToRadians, y: eulerDegrees.y.degreesToRadians, z: eulerDegrees.z.degreesToRadians)
        let toRotation: Basis = Basis.fromEuler (originalEuler)

        // Euler from rotation
        let eulerFromRotation: Vector3 = toRotation.getEuler (order: rawEulerOrder)
        let rotationFromComputedEuler: Basis = Basis.fromEuler (eulerFromRotation, order: rawEulerOrder)
        
        var res: Basis = toRotation.inverse () * rotationFromComputedEuler
        
        XCTAssert ((res.x - Vector3 (x: 1, y: 0, z: 0)).length () <= 0.1, "Fail due to X \(res.x)", file: file, line: line)
        XCTAssert ((res.y - Vector3 (x: 0, y: 1, z: 0)).length () <= 0.1, "Fail due to Y \(res.y)", file: file, line: line)
        XCTAssert ((res.z - Vector3 (x: 0, y: 0, z: 1)).length () <= 0.1, "Fail due to Z \(res.z)", file: file, line: line)
        
        // Double check `toRotation` decomposing with XYZ rotation order.
        
        let rawXyzEulerOrder: Int64 = Int64 (EulerOrder.xyz.rawValue)
        let eulerXyzFromRotation: Vector3 = toRotation.getEuler (order: rawXyzEulerOrder)
        let rotationFromXyzComputedEuler: Basis = Basis.fromEuler (eulerXyzFromRotation, order: rawXyzEulerOrder)
        
        res = toRotation.inverse () * rotationFromXyzComputedEuler
        
        XCTAssert ((res.x - Vector3 (x: 1, y: 0, z: 0)).length () <= 0.1, "Double check with XYZ rot order failed, due to X \(res.x)")
        XCTAssert ((res.y - Vector3 (x: 0, y: 1, z: 0)).length () <= 0.1, "Double check with XYZ rot order failed, due to Y \(res.y)")
        XCTAssert ((res.z - Vector3 (x: 0, y: 0, z: 1)).length () <= 0.1, "Double check with XYZ rot order failed, due to Z \(res.z)")
    }
    
    func testEulerConversions () {
        let eulerOrders: [EulerOrder] = [
            EulerOrder.xyz,
            EulerOrder.xzy,
            EulerOrder.yzx,
            EulerOrder.yxz,
            EulerOrder.zxy,
            EulerOrder.zyx,
        ]
        let vectors: [Vector3] = [
            Vector3 (x: 0.0, y: 0.0, z: 0.0),
            Vector3 (x: 0.5, y: 0.5, z: 0.5),
            Vector3 (x: -0.5, y: -0.5, z: -0.5),
            Vector3 (x: 40.0, y: 40.0, z: 40.0),
            Vector3 (x: -40.0, y: -40.0, z: -40.0),
            Vector3 (x: 0.0, y: 0.0, z: -90.0),
            Vector3 (x: 0.0, y: -90.0, z: 0.0),
            Vector3 (x: -90.0, y: 0.0, z: 0.0),
            Vector3 (x: 0.0, y: 0.0, z: 90.0),
            Vector3 (x: 0.0, y: 90.0, z: 0.0),
            Vector3 (x: 90.0, y: 0.0, z: 0.0),
            Vector3 (x: 0.0, y: 0.0, z: -30.0),
            Vector3 (x: 0.0, y: -30.0, z: 0.0),
            Vector3 (x: -30.0, y: 0.0, z: 0.0),
            Vector3 (x: 0.0, y: 0.0, z: 30.0),
            Vector3 (x: 0.0, y: 30.0, z: 0.0),
            Vector3 (x: 30.0, y: 0.0, z: 0.0),
            Vector3 (x: 0.5, y: 50.0, z: 20.0),
            Vector3 (x: -0.5, y: -50.0, z: -20.0),
            Vector3 (x: 0.5, y: 0.0, z: 90.0),
            Vector3 (x: 0.5, y: 0.0, z: -90.0),
            Vector3 (x: 360.0, y: 360.0, z: 360.0),
            Vector3 (x: -360.0, y: -360.0, z: -360.0),
            Vector3 (x: -90.0, y: 60.0, z: -90.0),
            Vector3 (x: 90.0, y: 60.0, z: -90.0),
            Vector3 (x: 90.0, y: -60.0, z: -90.0),
            Vector3 (x: -90.0, y: -60.0, z: -90.0),
            Vector3 (x: -90.0, y: 60.0, z: 90.0),
            Vector3 (x: 90.0, y: 60.0, z: 90.0),
            Vector3 (x: 90.0, y: -60.0, z: 90.0),
            Vector3 (x: -90.0, y: -60.0, z: 90.0),
            Vector3 (x: 60.0, y: 90.0, z: -40.0),
            Vector3 (x: 60.0, y: -90.0, z: -40.0),
            Vector3 (x: -60.0, y: -90.0, z: -40.0),
            Vector3 (x: -60.0, y: 90.0, z: 40.0),
            Vector3 (x: 60.0, y: 90.0, z: 40.0),
            Vector3 (x: 60.0, y: -90.0, z: 40.0),
            Vector3 (x: -60.0, y: -90.0, z: 40.0),
            Vector3 (x: -90.0, y: 90.0, z: -90.0),
            Vector3 (x: 90.0, y: 90.0, z: -90.0),
            Vector3 (x: 90.0, y: -90.0, z: -90.0),
            Vector3 (x: -90.0, y: -90.0, z: -90.0),
            Vector3 (x: -90.0, y: 90.0, z: 90.0),
            Vector3 (x: 90.0, y: 90.0, z: 90.0),
            Vector3 (x: 90.0, y: -90.0, z: 90.0),
            Vector3 (x: 20.0, y: 150.0, z: 30.0),
            Vector3 (x: 20.0, y: -150.0, z: 30.0),
            Vector3 (x: -120.0, y: -150.0, z: 30.0),
            Vector3 (x: -120.0, y: -150.0, z: -130.0),
            Vector3 (x: 120.0, y: -150.0, z: -130.0),
            Vector3 (x: 120.0, y: 150.0, z: -130.0),
            Vector3 (x: 120.0, y: 150.0, z: 130.0),
        ]
        for eulerOrder in eulerOrders {
            for vector in vectors {
                assertRotation (eulerDegrees: vector, eulerOrder: eulerOrder)
            }
        }
    }
    
    func testEulerConversionsRandom () {
        let eulerOrders: [EulerOrder] = [
            EulerOrder.xyz,
            EulerOrder.xzy,
            EulerOrder.yzx,
            EulerOrder.yxz,
            EulerOrder.zxy,
            EulerOrder.zyx,
        ]
        var vectors: [Vector3] = []
        let rng = RandomNumberGenerator ()
        for _ in 0..<100 {
            vectors.append (Vector3 (
                x: Float (rng.randfRange (from: -1800, to: 1800)),
                y: Float (rng.randfRange (from: -1800, to: 1800)),
                z: Float (rng.randfRange (from: -1800, to: 1800))))
        }
        for eulerOrder in eulerOrders {
            for vector in vectors {
                assertRotation (eulerDegrees: vector, eulerOrder: eulerOrder)
            }
        }
    }
    
    func testGetAxisAngle () {
        var basis: Basis
        var axis: Vector3
        
        // Testing the singularity when the angle is 0°.
        basis = Basis (xAxis: Vector3 (x: 1, y: 0, z: 0), yAxis: Vector3 (x: 0, y: 1, z: 0), zAxis: Vector3 (x: 0, y: 0, z: 1))
        XCTAssertEqual (basis.getRotationQuaternion ().getAngle (), 0)
        
        // Testing the singularity when the angle is 180°.
        basis = Basis (xAxis: Vector3 (x: -1, y: 0, z: 0), yAxis: Vector3 (x: 0, y: 1, z: 0), zAxis: Vector3 (x: 0, y: 0, z: -1))
        assertApproxEqual (Float (basis.getRotationQuaternion ().getAngle ()), Float.pi)
        
        // Testing reversing the an axis (of an 30° angle).
        
        let rad30: Float = Float (30).degreesToRadians
        let cos30: Float = cos (rad30)
        
        basis = Basis (xAxis: Vector3 (x: cos30, y: -0.5, z: 0), yAxis: Vector3 (x: 0.5, y: cos30, z: 0), zAxis: Vector3 (x: 0, y: 0, z: 1))
        assertApproxEqual (Float (basis.getRotationQuaternion ().getAngle ()), rad30)
        axis = basis.getRotationQuaternion ().getAxis ()
        assertApproxEqual (axis.x, 0.0)
        assertApproxEqual (axis.y, 0.0)
        assertApproxEqual (axis.z, 1.0)
        
        basis = Basis (xAxis: Vector3 (x: cos30, y: 0.5, z: 0), yAxis: Vector3 (x: -0.5, y: cos30, z: 0), zAxis: Vector3 (x: 0, y: 0, z: 1))
        assertApproxEqual (Float (basis.getRotationQuaternion ().getAngle ()), rad30)
        axis = basis.getRotationQuaternion ().getAxis ()
        assertApproxEqual (axis.x, 0.0)
        assertApproxEqual (axis.y, 0.0)
        assertApproxEqual (axis.z, -1.0)
        
        // Testing a rotation of 90° on x-y-z.
        
        basis = Basis (xAxis: Vector3 (x: 1, y: 0, z: 0), yAxis: Vector3 (x: 0, y: 0, z: -1), zAxis: Vector3 (x: 0, y: 1, z: 0))
        assertApproxEqual (Float (basis.getRotationQuaternion ().getAngle ()), Float.pi / 2)
        axis = basis.getRotationQuaternion ().getAxis ()
        assertApproxEqual (axis.x, 1.0)
        assertApproxEqual (axis.y, 0.0)
        assertApproxEqual (axis.z, 0.0)
        
        basis = Basis (xAxis: Vector3 (x: 0, y: 0, z: 1), yAxis: Vector3 (x: 0, y: 1, z: 0), zAxis: Vector3 (x: -1, y: 0, z: 0))
        assertApproxEqual (Float (basis.getRotationQuaternion ().getAngle ()), Float.pi / 2)
        axis = basis.getRotationQuaternion ().getAxis ()
        assertApproxEqual (axis.x, 0.0)
        assertApproxEqual (axis.y, 1.0)
        assertApproxEqual (axis.z, 0.0)
        
        basis = Basis (xAxis: Vector3 (x: 0, y: -1, z: 0), yAxis: Vector3 (x: 1, y: 0, z: 0), zAxis: Vector3 (x: 0, y: 0, z: 1))
        assertApproxEqual (Float (basis.getRotationQuaternion ().getAngle ()), Float.pi / 2)
        axis = basis.getRotationQuaternion ().getAxis ()
        assertApproxEqual (axis.x, 0.0)
        assertApproxEqual (axis.y, 0.0)
        assertApproxEqual (axis.z, 1.0)
        
        // Regression test: checks that the method returns a small angle (not 0).
        // The min angle possible with float is 0.001rad.
        basis = Basis (xAxis: Vector3 (x: 1, y: 0, z: 0), yAxis: Vector3 (x: 0, y: 0.9999995, z: -0.001), zAxis: Vector3 (x: 0, y: 0.001, z: 0.9999995))
        assertApproxEqual (Float (basis.getRotationQuaternion ().getAngle ()), 0.001, epsilon: 0.0001)
        
        // Regression test: checks that the method returns an angle which is a number (not NaN)
        basis = Basis (xAxis: Vector3 (x: 1.00000024, y: 0, z: 0.000100001693), yAxis: Vector3 (x: 0, y: 1, z: 0), zAxis: Vector3 (x: -0.000100009143, y: 0, z: 1.00000024))
        XCTAssertFalse (basis.getRotationQuaternion ().getAngle ().isNaN)
    }
    
    func testFiniteNumberChecks () {
        let x: Vector3 = Vector3 (x: 0, y: 1, z: 2)
        let infinite: Vector3 = Vector3 (x: .nan, y: .nan, z: .nan)

        XCTAssertTrue (Basis (xAxis: x, yAxis: x, zAxis: x).isFinite (), "Basis with all components finite should be finite")
        
        XCTAssertFalse (Basis (xAxis: infinite, yAxis: x, zAxis: x).isFinite (), "Basis with one component infinite should not be finite.")
        XCTAssertFalse (Basis (xAxis: x, yAxis: infinite, zAxis: x).isFinite (), "Basis with one component infinite should not be finite.")
        XCTAssertFalse (Basis (xAxis: x, yAxis: x, zAxis: infinite).isFinite (), "Basis with one component infinite should not be finite.")

        XCTAssertFalse (Basis (xAxis: infinite, yAxis: infinite, zAxis: x).isFinite (), "Basis with two components infinite should not be finite.")
        XCTAssertFalse (Basis (xAxis: infinite, yAxis: x, zAxis: infinite).isFinite (), "Basis with two components infinite should not be finite.")
        XCTAssertFalse (Basis (xAxis: x, yAxis: infinite, zAxis: infinite).isFinite (), "Basis with two components infinite should not be finite.")
        
        XCTAssertFalse (Basis (xAxis: infinite, yAxis: infinite, zAxis: infinite).isFinite (), "Basis with three components infinite should not be finite.")
    }
    
    func testIsConformalChecks () {
        var basis: Basis
        
        basis = Basis ()
        XCTAssertTrue (basis.isConformal (), "Identity Basis should be conformal.")
        
        basis = Basis.fromEuler (Vector3 (x: 1.2, y: 3.4, z: 5.6))
        XCTAssertTrue (basis.isConformal (), "Basis with only rotation should be conformal.")
        
        basis = Basis.fromScale (Vector3 (x: -1, y: -1, z: -1))
        XCTAssertTrue (basis.isConformal (), "Basis with only a flip should be conformal.")
        
        basis = Basis.fromScale (Vector3 (x: 1.2, y: 1.2, z: 1.2))
        XCTAssertTrue (basis.isConformal (), "Basis with only uniform scale should be conformal.")
        
        basis = Basis (xAxis: Vector3 (x: 3, y: 4, z: 0), yAxis: Vector3 (x: 4, y: -3, z: 0.0), zAxis: Vector3 (x: 0, y: 0, z: 5))
        XCTAssertTrue (basis.isConformal (), "Basis with a flip, rotation, and uniform scale should be conformal.")
        
        basis = Basis.fromScale (Vector3 (x: 1.2, y: 3.4, z: 5.6))
        XCTAssertFalse (basis.isConformal (), "Basis with non-uniform scale should not be conformal.")
        
        basis = Basis (xAxis: Vector3 (x: Float.sqrt12, y: Float.sqrt12, z: 0), yAxis: Vector3 (x: 0, y: 1, z: 0), zAxis: Vector3 (x: 0, y: 0, z: 1))
        XCTAssertFalse (basis.isConformal (), "Basis with the X axis skewed 45 degrees should not be conformal.")
    }
    
}
