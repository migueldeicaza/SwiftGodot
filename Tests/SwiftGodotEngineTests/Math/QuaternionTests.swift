// Based on godot/tests/core/math/test_quaternion.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class QuaternionTests: GodotTestCase {
    
    func testDefaultConstruct () {
        let q: Quaternion = Quaternion ()
        XCTAssertEqual (q.x, 0)
        XCTAssertEqual (q.y, 0)
        XCTAssertEqual (q.z, 0)
        XCTAssertEqual (q.w, 1)
    }
    
    func testConstructXYZW () {
        // Values are taken from actual use in another project & are valid (except roundoff error).
        let q = Quaternion (x: 0.2391, y: 0.099, z: 0.3696, w: 0.8924)
        XCTAssertEqual (q.x, 0.2391)
        XCTAssertEqual (q.y, 0.099)
        XCTAssertEqual (q.z, 0.3696)
        XCTAssertEqual (q.w, 0.8924)
    }
    
    func testConstructAxisAngle () {
        var q: Quaternion
        
        // Easy to visualize: 120 deg about X-axis.
        q = Quaternion (axis: Vector3 (x: 1.0, y: 0.0, z: 0.0), angle: Float (120).degreesToRadians)
        assertApproxEqual (q.x, 0.866025) // Sine of half the angle.
        assertApproxEqual (q.y, 0.0)
        assertApproxEqual (q.z, 0.0)
        assertApproxEqual (q.w, 0.5) // Cosine of half the angle.
        
        // Easy to visualize: 30 deg about Y-axis.
        q = Quaternion (axis: Vector3 (x: 0.0, y: 1.0, z: 0.0), angle: Float (30).degreesToRadians)
        assertApproxEqual (q.x, 0.0)
        assertApproxEqual (q.y, 0.258819) // Sine of half the angle.
        assertApproxEqual (q.z, 0.0)
        assertApproxEqual (q.w, 0.965926) // Cosine of half the angle.
        
        // Easy to visualize: 60 deg about Z-axis.
        q = Quaternion (axis: Vector3 (x: 0.0, y: 0.0, z: 1.0), angle: Float (60).degreesToRadians)
        assertApproxEqual (q.x, 0.0)
        assertApproxEqual (q.y, 0.0)
        assertApproxEqual (q.z, 0.5) // Sine of half the angle.
        assertApproxEqual (q.w, 0.866025) // Cosine of half the angle.
        
        
        // More complex & hard to visualize, so test w/ data from online calculator.
        let axis: Vector3 = Vector3 (x: 1.0, y: 2.0, z: 0.5)
        q = Quaternion (axis: axis.normalized (), angle: Float (35).degreesToRadians)
        assertApproxEqual (q.x, 0.131239)
        assertApproxEqual (q.y, 0.262478)
        assertApproxEqual (q.z, 0.0656194)
        assertApproxEqual (q.w, 0.953717)
    }
    
    func testConstructFromQuaternion () {
        let axis: Vector3 = Vector3 (x: 1.0, y: 2.0, z: 0.5)
        let qSrc: Quaternion = Quaternion (axis: axis.normalized (), angle: Float (35).degreesToRadians)
        let q: Quaternion = Quaternion (from: qSrc)
        assertApproxEqual (q.x, 0.131239)
        assertApproxEqual (q.y, 0.262478)
        assertApproxEqual (q.z, 0.0656194)
        assertApproxEqual (q.w, 0.953717)
    }
    
    func testConstructEulerSingleAxis () {
        let yaw: Float = Float (45.0).degreesToRadians
        let pitch: Float = Float (30.0).degreesToRadians
        let roll: Float = Float (10.0).degreesToRadians

        let eulerY: Vector3 = Vector3 (x: 0.0, y: yaw, z: 0.0)
        let qY: Quaternion = Quaternion.fromEuler (eulerY)
        assertApproxEqual (qY.x, 0.0)
        assertApproxEqual (qY.y, 0.382684)
        assertApproxEqual (qY.z, 0.0)
        assertApproxEqual (qY.w, 0.923879)
        
        let eulerP: Vector3 = Vector3 (x: pitch, y: 0.0, z: 0.0)
        let qP: Quaternion = Quaternion.fromEuler (eulerP)
        assertApproxEqual (qP.x, 0.258819)
        assertApproxEqual (qP.y, 0.0)
        assertApproxEqual (qP.z, 0.0)
        assertApproxEqual (qP.w, 0.965926)
        
        let eulerR: Vector3 = Vector3 (x: 0.0, y: 0.0, z: roll)
        let qR: Quaternion = Quaternion.fromEuler (eulerR)
        assertApproxEqual (qR.x, 0.0)
        assertApproxEqual (qR.y, 0.0)
        assertApproxEqual (qR.z, 0.0871558)
        assertApproxEqual (qR.w, 0.996195)
    }
    
    func testConstructEulerYXZDynamicAxes () {
        let yaw: Float = Float (45.0).degreesToRadians
        let pitch: Float = Float (30.0).degreesToRadians
        let roll: Float = Float (10.0).degreesToRadians

        // Generate YXZ comparison data (Z-then-X-then-Y) using single-axis Euler
        // constructor and quaternion product, both tested separately.
        let eulerY: Vector3 = Vector3 (x: 0.0, y: yaw, z: 0.0)
        let qY: Quaternion = Quaternion.fromEuler (eulerY)
        let eulerP: Vector3 = Vector3 (x: pitch, y: 0.0, z: 0.0)
        let qP: Quaternion = Quaternion.fromEuler (eulerP)
        let eulerR: Vector3 = Vector3 (x: 0.0, y: 0.0, z: roll)
        let qR: Quaternion = Quaternion.fromEuler (eulerR)

        // Instrinsically, Yaw-Y then Pitch-X then Roll-Z.
        // Extrinsically, Roll-Z is followed by Pitch-X, then Yaw-Y.
        let checkYxz: Quaternion = qY * qP * qR

        // Test construction from YXZ Euler angles.
        let eulerYxz: Vector3 = Vector3 (x: pitch, y: yaw, z: roll)
        let q: Quaternion = Quaternion.fromEuler (eulerYxz)
        assertApproxEqual (q, checkYxz)
    }
    
    func testConstructBasisEuler () {
        let yaw: Float = Float (45.0).degreesToRadians
        let pitch: Float = Float (30.0).degreesToRadians
        let roll: Float = Float (10.0).degreesToRadians
        let eulerYxz: Vector3 = Vector3 (x: pitch, y: yaw, z: roll)
        let qYxz: Quaternion = Quaternion.fromEuler (eulerYxz)
        let basisAxes: Basis = Basis.fromEuler (eulerYxz)
        let q: Quaternion = basisAxes.getRotationQuaternion ()
        assertApproxEqual (q, qYxz)
    }
    
    func testConstructBasisAxes () {
        func quatEulerYxzDeg (angle: Vector3) -> Quaternion {
            let yaw: Float = angle.y.degreesToRadians
            let pitch: Float = angle.x.degreesToRadians
            let roll: Float = angle.z.degreesToRadians

            // Generate YXZ (Z-then-X-then-Y) Quaternion using single-axis Euler
            // constructor and quaternion product, both tested separately.
            let qY: Quaternion = Quaternion.fromEuler (Vector3 (x: 0.0, y: yaw, z: 0.0))
            let qP: Quaternion = Quaternion.fromEuler (Vector3 (x: pitch, y: 0.0, z: 0.0))
            let qR: Quaternion = Quaternion.fromEuler (Vector3 (x: 0.0, y: 0.0, z: roll))
            // Roll-Z is followed by Pitch-X, then Yaw-Y.
            let qYxz: Quaternion = qY * qP * qR

            return qYxz
        }
        // Arbitrary Euler angles.
        let eulerYxz: Vector3 = Vector3 (x: Float (31.41).degreesToRadians, y: Float (-49.16).degreesToRadians, z: Float (12.34).degreesToRadians)
        // Basis vectors from online calculation of rotation matrix.
        let iUnit: Vector3 = Vector3 (x: 0.5545787, y: 0.1823950, z: 0.8118957)
        let jUnit: Vector3 = Vector3 (x: -0.5249245, y: 0.8337420, z: 0.1712555)
        let kUnit: Vector3 = Vector3 (x: -0.6456754, y: -0.5211586, z: 0.5581192)
        
        // Quaternion from online calculation.
        let qCalc: Quaternion = Quaternion (x: 0.2016913, y: -0.4245716, z: 0.206033, w: 0.8582598)
        // Quaternion from local calculation.
        let qLocal: Quaternion = quatEulerYxzDeg (angle: Vector3 (x: 31.41, y: -49.16, z: 12.34))
        // Quaternion from Euler angles constructor.
        let qEuler: Quaternion = Quaternion.fromEuler (eulerYxz)
        assertApproxEqual (qCalc, qLocal)
        assertApproxEqual (qLocal, qEuler)

        // Calculate Basis and construct Quaternion.
        // When this is written, C++ Basis class does not construct from basis vectors.
        // This is by design, but may be subject to change.
        // Workaround by constructing Basis from Euler angles.
        // basis_axes = Basis (i_unit, j_unit, k_unit);
        let basisAxes: Basis = Basis.fromEuler (eulerYxz)
        let q: Quaternion = basisAxes.getRotationQuaternion ()
        assertApproxEqual (basisAxes.x.x, iUnit.x)
        assertApproxEqual (basisAxes.y.x, iUnit.y)
        assertApproxEqual (basisAxes.z.x, iUnit.z)
        assertApproxEqual (basisAxes.x.y, jUnit.x)
        assertApproxEqual (basisAxes.y.y, jUnit.y)
        assertApproxEqual (basisAxes.z.y, jUnit.z)
        assertApproxEqual (basisAxes.x.z, kUnit.x)
        assertApproxEqual (basisAxes.y.z, kUnit.y)
        assertApproxEqual (basisAxes.z.z, kUnit.z)
        
        assertApproxEqual (q, qCalc)
        assertApproxEqual (q, qLocal)
        assertApproxEqual (q, qEuler)
        assertApproxEqual (q.x, 0.2016913)
        assertApproxEqual (q.y, -0.4245716)
        assertApproxEqual (q.z, 0.206033)
        assertApproxEqual (q.w, 0.8582598)
    }
    
    func testGetEulerOrders () {
        let x: Float = Float (45.0).degreesToRadians
        let y: Float = Float (30.0).degreesToRadians
        let z: Float = Float (10.0).degreesToRadians
        let euler: Vector3 = Vector3 (x: x, y: y, z: z)
        
        for order: Int64 in 0..<6 {
            let basis: Basis = Basis.fromEuler (euler, order: order)
            let q: Quaternion = basis.getRotationQuaternion ()
            let check: Vector3 = q.getEuler (order: order)
            assertApproxEqual (check.x, euler.x, "Quaternion getEuler() method should return the original angles.")
            assertApproxEqual (check.y, euler.y, "Quaternion getEuler() method should return the original angles.")
            assertApproxEqual (check.z, euler.z, "Quaternion getEuler() method should return the original angles.")
            let basisEuler: Vector3 = basis.getEuler (order: order)
            assertApproxEqual (check.x, basisEuler.x, "Quaternion getEuler() method should behave the same as Basis get_euler.")
            assertApproxEqual (check.y, basisEuler.y, "Quaternion getEuler() method should behave the same as Basis get_euler.")
            assertApproxEqual (check.z, basisEuler.z, "Quaternion getEuler() method should behave the same as Basis get_euler.")
        }
    }
    
    func testProductBook () {
        // Example from "Quaternions and Rotation Sequences" by Jack Kuipers, p. 108.
        let p: Quaternion = Quaternion (x: 1.0, y: -2.0, z: 1.0, w: 3.0)
        let q: Quaternion = Quaternion (x: -1.0, y: 2.0, z: 3.0, w: 2.0)
        let pq: Quaternion = p * q
        assertApproxEqual (pq.x, -9.0)
        assertApproxEqual (pq.y, -2.0)
        assertApproxEqual (pq.z, 11.0)
        assertApproxEqual (pq.w, 8.0)
    }
    
    func testProduct () {
        let yaw: Float = Float (45.0).degreesToRadians
        let pitch: Float = Float (30.0).degreesToRadians
        let roll: Float = Float (10.0).degreesToRadians
        
        let eulerY: Vector3 = Vector3 (x: 0.0, y: yaw, z: 0.0)
        let qY: Quaternion = Quaternion.fromEuler (eulerY)
        assertApproxEqual (qY.x, 0.0)
        assertApproxEqual (qY.y, 0.382684)
        assertApproxEqual (qY.z, 0.0)
        assertApproxEqual (qY.w, 0.923879)
        
        let eulerP: Vector3 = Vector3 (x: pitch, y: 0.0, z: 0.0)
        let qP: Quaternion = Quaternion.fromEuler (eulerP)
        assertApproxEqual (qP.x, 0.258819)
        assertApproxEqual (qP.y, 0.0)
        assertApproxEqual (qP.z, 0.0)
        assertApproxEqual (qP.w, 0.965926)
        
        let eulerR: Vector3 = Vector3 (x: 0.0, y: 0.0, z: roll)
        let qR: Quaternion = Quaternion.fromEuler (eulerR)
        assertApproxEqual (qR.x, 0.0)
        assertApproxEqual (qR.y, 0.0)
        assertApproxEqual (qR.z, 0.0871558)
        assertApproxEqual (qR.w, 0.996195)

        // Test ZYX dynamic-axes since test data is available online.
        // Rotate first about X axis, then new Y axis, then new Z axis.
        // (Godot uses YXZ Yaw-Pitch-Roll order).
        let qYP: Quaternion = qY * qP
        assertApproxEqual (qYP.x, 0.239118)
        assertApproxEqual (qYP.y, 0.369644)
        assertApproxEqual (qYP.z, -0.099046)
        assertApproxEqual (qYP.w, 0.892399)
        
        let qRYP: Quaternion = qR * qYP
        assertApproxEqual (qRYP.x, 0.205991)
        assertApproxEqual (qRYP.y, 0.389078)
        assertApproxEqual (qRYP.z, -0.0208912)
        assertApproxEqual (qRYP.w, 0.897636)
    }
    
    func testXformUnitVectors () {
        // Easy to visualize: 120 deg about X-axis.
        // Transform the i, j, & k unit vectors.
        var q: Quaternion = Quaternion (axis: Vector3 (x: 1.0, y: 0.0, z: 0.0), angle: Float (120).degreesToRadians)
        var iT: Vector3 = q * Vector3 (x: 1.0, y: 0.0, z: 0.0)
        var jT: Vector3 = q * Vector3 (x: 0.0, y: 1.0, z: 0.0)
        var kT: Vector3 = q * Vector3 (x: 0.0, y: 0.0, z: 1.0)
        
        assertApproxEqual (iT.x, 1.0)
        assertApproxEqual (iT.y, 0.0)
        assertApproxEqual (iT.z, 0.0)
        assertApproxEqual (jT.x, 0.0)
        assertApproxEqual (jT.y, -0.5)
        assertApproxEqual (jT.z, 0.866025)
        assertApproxEqual (kT.x, 0.0)
        assertApproxEqual (kT.y, -0.866025)
        assertApproxEqual (kT.z, -0.5)
        XCTAssertEqual (iT.length (), 1)
        XCTAssertEqual (jT.length (), 1)
        XCTAssertEqual (kT.length (), 1)
        
        // Easy to visualize: 30 deg about Y-axis.
        q = Quaternion (axis: Vector3 (x: 0.0, y: 1.0, z: 0.0), angle: Float (30).degreesToRadians)
        iT = q * Vector3 (x: 1.0, y: 0.0, z: 0.0)
        jT = q * Vector3 (x: 0.0, y: 1.0, z: 0.0)
        kT = q * Vector3 (x: 0.0, y: 0.0, z: 1.0)
        
        assertApproxEqual (iT.x, 0.866025)
        assertApproxEqual (iT.y, 0.0)
        assertApproxEqual (iT.z, -0.5)
        assertApproxEqual (jT.x, 0.0)
        assertApproxEqual (jT.y, 1.0)
        assertApproxEqual (jT.z, 0.0)
        assertApproxEqual (kT.x, 0.5)
        assertApproxEqual (kT.y, 0.0)
        assertApproxEqual (kT.z, 0.866025)
        XCTAssertEqual (iT.length (), 1)
        XCTAssertEqual (jT.length (), 1)
        XCTAssertEqual (kT.length (), 1)
        
        // Easy to visualize: 60 deg about Z-axis.
        q = Quaternion (axis: Vector3 (x: 0.0, y: 0.0, z: 1.0), angle: Float (60).degreesToRadians)
        iT = q * Vector3 (x: 1.0, y: 0.0, z: 0.0)
        jT = q * Vector3 (x: 0.0, y: 1.0, z: 0.0)
        kT = q * Vector3 (x: 0.0, y: 0.0, z: 1.0)
        
        assertApproxEqual (iT.x, 0.5)
        assertApproxEqual (iT.y, 0.866025)
        assertApproxEqual (iT.z, 0.0)
        assertApproxEqual (jT.x, -0.866025)
        assertApproxEqual (jT.y, 0.5)
        assertApproxEqual (jT.z, 0.0)
        assertApproxEqual (kT.x, 0.0)
        assertApproxEqual (kT.y, 0.0)
        assertApproxEqual (kT.z, 1.0)
        XCTAssertEqual (iT.length (), 1)
        XCTAssertEqual (jT.length (), 1)
        XCTAssertEqual (kT.length (), 1)
    }
    
    func testXformVector () {
        // Arbitrary quaternion rotates an arbitrary vector.
        let eulerYzx: Vector3 = Vector3 (x: Float (31.41).degreesToRadians, y: Float (-49.16).degreesToRadians, z: Float (12.34).degreesToRadians)
        let basisAxes: Basis = Basis.fromEuler (eulerYzx)
        let q: Quaternion = basisAxes.getRotationQuaternion ()
        
        let vArb: Vector3 = Vector3 (x: 3.0, y: 4.0, z: 5.0)
        let vRot: Vector3 = q * vArb
        let vCompare: Vector3 = basisAxes * vArb
        
        assertApproxEqual (vRot.lengthSquared (), vArb.lengthSquared ())
        assertApproxEqual (vRot, vCompare)
    }
    
    func testManyVectorXforms () {
        // Test vector xform for a single combination of Quaternion and Vector.
        func assertQuatVecRotate (eulerYzx: Vector3, vIn: Vector3) {
            let basisAxes: Basis = Basis.fromEuler (eulerYzx)
            let q: Quaternion = basisAxes.getRotationQuaternion ()
            
            let vRot: Vector3 = q * vIn
            let vCompare: Vector3 = basisAxes * vIn
            
            assertApproxEqual (vRot.lengthSquared (), vIn.lengthSquared ())
            assertApproxEqual (vRot, vCompare)
        }
        
        // Many arbitrary quaternions rotate many arbitrary vectors.
        // For each trial, check that rotation by Quaternion yields same result as
        // rotation by Basis.
        let steps: Int = 10 // Number of test steps in each dimension
        let delta: Float = 2.0 * Float.pi / Float (steps) // Angle increment per step
        let deltaVec: Float = 20.0 / Float (steps) // Vector increment per step
        var vecArb: Vector3 = Vector3 (x: 1.0, y: 1.0, z: 1.0)
        
        var xAngle: Float
        var yAngle: Float
        var zAngle: Float
        
        for i in 0..<steps {
            vecArb.x = -10.0 + Float (i) * deltaVec
            xAngle = Float (i) * delta - Float.pi
            for j in 0..<steps {
                vecArb.y = -10.0 + Float (j) * deltaVec
                yAngle = Float (j) * delta - Float.pi
                for k in 0..<steps {
                    vecArb.y = -10.0 + Float (k) * deltaVec
                    zAngle = Float (k) * delta - Float.pi
                    let eulerYzx: Vector3 = Vector3 (x: xAngle, y: yAngle, z: zAngle)
                    assertQuatVecRotate (eulerYzx: eulerYzx, vIn: vecArb)
                }
            }
        }
    }
    
    func testFiniteNumberChecks () {
        XCTAssertTrue (Quaternion (x: 0, y: 1, z: 2, w: 3).isFinite (), "Quaternion with all components finite should be finite")
        
        XCTAssertFalse (Quaternion (x: .nan, y: 1, z: 2, w: 3).isFinite (), "Quaternion with one component infinite should not be finite.")
        XCTAssertFalse (Quaternion (x: 0, y: .nan, z: 2, w: 3).isFinite (), "Quaternion with one component infinite should not be finite.")
        XCTAssertFalse (Quaternion (x: 0, y: 1, z: .nan, w: 3).isFinite (), "Quaternion with one component infinite should not be finite.")
        XCTAssertFalse (Quaternion (x: 0, y: 1, z: 2, w: .nan).isFinite (), "Quaternion with one component infinite should not be finite.")
        
        XCTAssertFalse (Quaternion (x: .nan, y: .nan, z: 2, w: 3).isFinite (), "Quaternion with two components infinite should not be finite.")
        XCTAssertFalse (Quaternion (x: .nan, y: 1, z: .nan, w: 3).isFinite (), "Quaternion with two components infinite should not be finite.")
        XCTAssertFalse (Quaternion (x: .nan, y: 1, z: 2, w: .nan).isFinite (), "Quaternion with two components infinite should not be finite.")
        XCTAssertFalse (Quaternion (x: 0, y: .nan, z: .nan, w: 3).isFinite (), "Quaternion with two components infinite should not be finite.")
        XCTAssertFalse (Quaternion (x: 0, y: .nan, z: 2, w: .nan).isFinite (), "Quaternion with two components infinite should not be finite.")
        XCTAssertFalse (Quaternion (x: 0, y: 1, z: .nan, w: .nan).isFinite (), "Quaternion with two components infinite should not be finite.")
        
        XCTAssertFalse (Quaternion (x: 0, y: .nan, z: .nan, w: .nan).isFinite (), "Quaternion with one component infinite should not be finite.")
        XCTAssertFalse (Quaternion (x: .nan, y: 1, z: .nan, w: .nan).isFinite (), "Quaternion with one component infinite should not be finite.")
        XCTAssertFalse (Quaternion (x: .nan, y: .nan, z: .nan, w: 3).isFinite (), "Quaternion with one component infinite should not be finite.")
        XCTAssertFalse (Quaternion (x: .nan, y: .nan, z: .nan, w: 3).isFinite (), "Quaternion with one component infinite should not be finite.")
        
        XCTAssertFalse (Quaternion (x: .nan, y: .nan, z: .nan, w: .nan).isFinite (), "Quaternion with four components infinite should not be finite.")
    }
    
}
