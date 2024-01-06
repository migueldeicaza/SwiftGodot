// Based on godot/tests/core/math/test_quaternion.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class QuaternionTests: GodotTestCase {
    
    private let accuracy: Float = 0.0001
    
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
        XCTAssertEqual (q.x, 0.866025, accuracy: accuracy) // Sine of half the angle.
        XCTAssertEqual (q.y, 0.0, accuracy: accuracy)
        XCTAssertEqual (q.z, 0.0, accuracy: accuracy)
        XCTAssertEqual (q.w, 0.5, accuracy: accuracy) // Cosine of half the angle.
        
        // Easy to visualize: 30 deg about Y-axis.
        q = Quaternion (axis: Vector3 (x: 0.0, y: 1.0, z: 0.0), angle: Float (30).degreesToRadians)
        XCTAssertEqual (q.x, 0.0, accuracy: accuracy)
        XCTAssertEqual (q.y, 0.258819, accuracy: accuracy) // Sine of half the angle.
        XCTAssertEqual (q.z, 0.0, accuracy: accuracy)
        XCTAssertEqual (q.w, 0.965926, accuracy: accuracy) // Cosine of half the angle.
        
        // Easy to visualize: 60 deg about Z-axis.
        q = Quaternion (axis: Vector3 (x: 0.0, y: 0.0, z: 1.0), angle: Float (60).degreesToRadians)
        XCTAssertEqual (q.x, 0.0, accuracy: accuracy)
        XCTAssertEqual (q.y, 0.0, accuracy: accuracy)
        XCTAssertEqual (q.z, 0.5, accuracy: accuracy) // Sine of half the angle.
        XCTAssertEqual (q.w, 0.866025, accuracy: accuracy) // Cosine of half the angle.
        
        
        // More complex & hard to visualize, so test w/ data from online calculator.
        let axis: Vector3 = Vector3 (x: 1.0, y: 2.0, z: 0.5)
        q = Quaternion (axis: axis.normalized (), angle: Float (35).degreesToRadians)
        XCTAssertEqual (q.x, 0.131239, accuracy: accuracy)
        XCTAssertEqual (q.y, 0.262478, accuracy: accuracy)
        XCTAssertEqual (q.z, 0.0656194, accuracy: accuracy)
        XCTAssertEqual (q.w, 0.953717, accuracy: accuracy)
    }
    
    func testConstructFromQuaternion () {
        let axis: Vector3 = Vector3 (x: 1.0, y: 2.0, z: 0.5)
        let qSrc: Quaternion = Quaternion (axis: axis.normalized (), angle: Float (35).degreesToRadians)
        let q: Quaternion = Quaternion (from: qSrc)
        XCTAssertEqual (q.x, 0.131239, accuracy: accuracy)
        XCTAssertEqual (q.y, 0.262478, accuracy: accuracy)
        XCTAssertEqual (q.z, 0.0656194, accuracy: accuracy)
        XCTAssertEqual (q.w, 0.953717, accuracy: accuracy)
    }
    
    func testConstructEulerSingleAxis () {
        let yaw: Float = Float (45.0).degreesToRadians
        let pitch: Float = Float (30.0).degreesToRadians
        let roll: Float = Float (10.0).degreesToRadians

        let eulerY: Vector3 = Vector3 (x: 0.0, y: yaw, z: 0.0)
        let qY: Quaternion = Quaternion.fromEuler (euler: eulerY)
        XCTAssertEqual (qY.x, 0.0, accuracy: accuracy)
        XCTAssertEqual (qY.y, 0.382684, accuracy: accuracy)
        XCTAssertEqual (qY.z, 0.0, accuracy: accuracy)
        XCTAssertEqual (qY.w, 0.923879, accuracy: accuracy)
        
        let eulerP: Vector3 = Vector3 (x: pitch, y: 0.0, z: 0.0)
        let qP: Quaternion = Quaternion.fromEuler (euler: eulerP)
        XCTAssertEqual (qP.x, 0.258819, accuracy: accuracy)
        XCTAssertEqual (qP.y, 0.0, accuracy: accuracy)
        XCTAssertEqual (qP.z, 0.0, accuracy: accuracy)
        XCTAssertEqual (qP.w, 0.965926, accuracy: accuracy)
        
        let eulerR: Vector3 = Vector3 (x: 0.0, y: 0.0, z: roll)
        let qR: Quaternion = Quaternion.fromEuler (euler: eulerR)
        XCTAssertEqual (qR.x, 0.0, accuracy: accuracy)
        XCTAssertEqual (qR.y, 0.0, accuracy: accuracy)
        XCTAssertEqual (qR.z, 0.0871558, accuracy: accuracy)
        XCTAssertEqual (qR.w, 0.996195, accuracy: accuracy)
    }
    
    func testConstructEulerYXZDynamicAxes () {
        let yaw: Float = Float (45.0).degreesToRadians
        let pitch: Float = Float (30.0).degreesToRadians
        let roll: Float = Float (10.0).degreesToRadians

        // Generate YXZ comparison data (Z-then-X-then-Y) using single-axis Euler
        // constructor and quaternion product, both tested separately.
        let eulerY: Vector3 = Vector3 (x: 0.0, y: yaw, z: 0.0)
        let qY: Quaternion = Quaternion.fromEuler (euler: eulerY)
        let eulerP: Vector3 = Vector3 (x: pitch, y: 0.0, z: 0.0)
        let qP: Quaternion = Quaternion.fromEuler (euler: eulerP)
        let eulerR: Vector3 = Vector3 (x: 0.0, y: 0.0, z: roll)
        let qR: Quaternion = Quaternion.fromEuler (euler: eulerR)

        // Instrinsically, Yaw-Y then Pitch-X then Roll-Z.
        // Extrinsically, Roll-Z is followed by Pitch-X, then Yaw-Y.
        let checkYxz: Quaternion = qY * qP * qR

        // Test construction from YXZ Euler angles.
        let eulerYxz: Vector3 = Vector3 (x: pitch, y: yaw, z: roll)
        let q: Quaternion = Quaternion.fromEuler (euler: eulerYxz)
        XCTAssertEqual (q.x, checkYxz.x, accuracy: accuracy)
        XCTAssertEqual (q.y, checkYxz.y, accuracy: accuracy)
        XCTAssertEqual (q.z, checkYxz.z, accuracy: accuracy)
        XCTAssertEqual (q.w, checkYxz.w, accuracy: accuracy)
    }
    
    func testConstructBasisEuler () {
        let yaw: Float = Float (45.0).degreesToRadians
        let pitch: Float = Float (30.0).degreesToRadians
        let roll: Float = Float (10.0).degreesToRadians
        let eulerYxz: Vector3 = Vector3 (x: pitch, y: yaw, z: roll)
        let qYxz: Quaternion = Quaternion.fromEuler (euler: eulerYxz)
        let basisAxes: Basis = Basis.fromEuler (euler: eulerYxz)
        let q: Quaternion = basisAxes.getRotationQuaternion ()
        XCTAssertEqual (q.x, qYxz.x, accuracy: accuracy)
        XCTAssertEqual (q.y, qYxz.y, accuracy: accuracy)
        XCTAssertEqual (q.z, qYxz.z, accuracy: accuracy)
        XCTAssertEqual (q.w, qYxz.w, accuracy: accuracy)
    }
    
    func testConstructBasisAxes () {
        func quatEulerYxzDeg (angle: Vector3) -> Quaternion {
            let yaw: Float = angle.y.degreesToRadians
            let pitch: Float = angle.x.degreesToRadians
            let roll: Float = angle.z.degreesToRadians

            // Generate YXZ (Z-then-X-then-Y) Quaternion using single-axis Euler
            // constructor and quaternion product, both tested separately.
            let qY: Quaternion = Quaternion.fromEuler (euler: Vector3 (x: 0.0, y: yaw, z: 0.0))
            let qP: Quaternion = Quaternion.fromEuler (euler: Vector3 (x: pitch, y: 0.0, z: 0.0))
            let qR: Quaternion = Quaternion.fromEuler (euler: Vector3 (x: 0.0, y: 0.0, z: roll))
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
        let qEuler: Quaternion = Quaternion.fromEuler (euler: eulerYxz)
        XCTAssertEqual (qCalc.x, qLocal.x, accuracy: accuracy)
        XCTAssertEqual (qCalc.y, qLocal.y, accuracy: accuracy)
        XCTAssertEqual (qCalc.z, qLocal.z, accuracy: accuracy)
        XCTAssertEqual (qCalc.w, qLocal.w, accuracy: accuracy)
        XCTAssertEqual (qLocal.x, qEuler.x, accuracy: accuracy)
        XCTAssertEqual (qLocal.y, qEuler.y, accuracy: accuracy)
        XCTAssertEqual (qLocal.z, qEuler.z, accuracy: accuracy)
        XCTAssertEqual (qLocal.w, qEuler.w, accuracy: accuracy)

        // Calculate Basis and construct Quaternion.
        // When this is written, C++ Basis class does not construct from basis vectors.
        // This is by design, but may be subject to change.
        // Workaround by constructing Basis from Euler angles.
        // basis_axes = Basis (i_unit, j_unit, k_unit);
        let basisAxes: Basis = Basis.fromEuler (euler: eulerYxz)
        let q: Quaternion = basisAxes.getRotationQuaternion ()
        XCTAssertEqual (basisAxes.x.x, iUnit.x, accuracy: accuracy)
        XCTAssertEqual (basisAxes.y.x, iUnit.y, accuracy: accuracy)
        XCTAssertEqual (basisAxes.z.x, iUnit.z, accuracy: accuracy)
        XCTAssertEqual (basisAxes.x.y, jUnit.x, accuracy: accuracy)
        XCTAssertEqual (basisAxes.y.y, jUnit.y, accuracy: accuracy)
        XCTAssertEqual (basisAxes.z.y, jUnit.z, accuracy: accuracy)
        XCTAssertEqual (basisAxes.x.z, kUnit.x, accuracy: accuracy)
        XCTAssertEqual (basisAxes.y.z, kUnit.y, accuracy: accuracy)
        XCTAssertEqual (basisAxes.z.z, kUnit.z, accuracy: accuracy)
        
        XCTAssertEqual (q.x, qCalc.x, accuracy: accuracy)
        XCTAssertEqual (q.y, qCalc.y, accuracy: accuracy)
        XCTAssertEqual (q.z, qCalc.z, accuracy: accuracy)
        XCTAssertEqual (q.w, qCalc.w, accuracy: accuracy)
        XCTAssertEqual (q.x, qLocal.x, accuracy: accuracy)
        XCTAssertEqual (q.y, qLocal.y, accuracy: accuracy)
        XCTAssertEqual (q.z, qLocal.z, accuracy: accuracy)
        XCTAssertEqual (q.w, qLocal.w, accuracy: accuracy)
        XCTAssertEqual (q.x, qEuler.x, accuracy: accuracy)
        XCTAssertEqual (q.y, qEuler.y, accuracy: accuracy)
        XCTAssertEqual (q.z, qEuler.z, accuracy: accuracy)
        XCTAssertEqual (q.w, qEuler.w, accuracy: accuracy)
        XCTAssertEqual (q.x, 0.2016913, accuracy: accuracy)
        XCTAssertEqual (q.y, -0.4245716, accuracy: accuracy)
        XCTAssertEqual (q.z, 0.206033, accuracy: accuracy)
        XCTAssertEqual (q.w, 0.8582598, accuracy: accuracy)
    }
    
    func testGetEulerOrders () {
        let x: Float = Float (45.0).degreesToRadians
        let y: Float = Float (30.0).degreesToRadians
        let z: Float = Float (10.0).degreesToRadians
        let euler: Vector3 = Vector3 (x: x, y: y, z: z)
        
        for order: Int64 in 0..<6 {
            let basis: Basis = Basis.fromEuler (euler: euler, order: order)
            let q: Quaternion = basis.getRotationQuaternion ()
            let check: Vector3 = q.getEuler (order: order)
            XCTAssertEqual (check.x, euler.x, accuracy: accuracy, "Quaternion getEuler() method should return the original angles.")
            XCTAssertEqual (check.y, euler.y, accuracy: accuracy, "Quaternion getEuler() method should return the original angles.")
            XCTAssertEqual (check.z, euler.z, accuracy: accuracy, "Quaternion getEuler() method should return the original angles.")
            let basisEuler: Vector3 = basis.getEuler (order: order)
            XCTAssertEqual (check.x, basisEuler.x, accuracy: accuracy, "Quaternion getEuler() method should behave the same as Basis get_euler.")
            XCTAssertEqual (check.y, basisEuler.y, accuracy: accuracy, "Quaternion getEuler() method should behave the same as Basis get_euler.")
            XCTAssertEqual (check.z, basisEuler.z, accuracy: accuracy, "Quaternion getEuler() method should behave the same as Basis get_euler.")
        }
    }
    
    func testProductBook () {
        // Example from "Quaternions and Rotation Sequences" by Jack Kuipers, p. 108.
        let p: Quaternion = Quaternion (x: 1.0, y: -2.0, z: 1.0, w: 3.0)
        let q: Quaternion = Quaternion (x: -1.0, y: 2.0, z: 3.0, w: 2.0)
        let pq: Quaternion = p * q
        XCTAssertEqual (pq.x, -9.0, accuracy: accuracy)
        XCTAssertEqual (pq.y, -2.0, accuracy: accuracy)
        XCTAssertEqual (pq.z, 11.0, accuracy: accuracy)
        XCTAssertEqual (pq.w, 8.0, accuracy: accuracy)
    }
    
    func testProduct () {
        let yaw: Float = Float (45.0).degreesToRadians
        let pitch: Float = Float (30.0).degreesToRadians
        let roll: Float = Float (10.0).degreesToRadians
        
        let eulerY: Vector3 = Vector3 (x: 0.0, y: yaw, z: 0.0)
        let qY: Quaternion = Quaternion.fromEuler (euler: eulerY)
        XCTAssertEqual (qY.x, 0.0, accuracy: accuracy)
        XCTAssertEqual (qY.y, 0.382684, accuracy: accuracy)
        XCTAssertEqual (qY.z, 0.0, accuracy: accuracy)
        XCTAssertEqual (qY.w, 0.923879, accuracy: accuracy)
        
        let eulerP: Vector3 = Vector3 (x: pitch, y: 0.0, z: 0.0)
        let qP: Quaternion = Quaternion.fromEuler (euler: eulerP)
        XCTAssertEqual (qP.x, 0.258819, accuracy: accuracy)
        XCTAssertEqual (qP.y, 0.0, accuracy: accuracy)
        XCTAssertEqual (qP.z, 0.0, accuracy: accuracy)
        XCTAssertEqual (qP.w, 0.965926, accuracy: accuracy)
        
        let eulerR: Vector3 = Vector3 (x: 0.0, y: 0.0, z: roll)
        let qR: Quaternion = Quaternion.fromEuler (euler: eulerR)
        XCTAssertEqual (qR.x, 0.0, accuracy: accuracy)
        XCTAssertEqual (qR.y, 0.0, accuracy: accuracy)
        XCTAssertEqual (qR.z, 0.0871558, accuracy: accuracy)
        XCTAssertEqual (qR.w, 0.996195, accuracy: accuracy)

        // Test ZYX dynamic-axes since test data is available online.
        // Rotate first about X axis, then new Y axis, then new Z axis.
        // (Godot uses YXZ Yaw-Pitch-Roll order).
        let qYP: Quaternion = qY * qP
        XCTAssertEqual (qYP.x, 0.239118, accuracy: accuracy)
        XCTAssertEqual (qYP.y, 0.369644, accuracy: accuracy)
        XCTAssertEqual (qYP.z, -0.099046, accuracy: accuracy)
        XCTAssertEqual (qYP.w, 0.892399, accuracy: accuracy)
        
        let qRYP: Quaternion = qR * qYP
        XCTAssertEqual (qRYP.x, 0.205991, accuracy: accuracy)
        XCTAssertEqual (qRYP.y, 0.389078, accuracy: accuracy)
        XCTAssertEqual (qRYP.z, -0.0208912, accuracy: accuracy)
        XCTAssertEqual (qRYP.w, 0.897636, accuracy: accuracy)
    }
    
    func testXformUnitVectors () {
        // Easy to visualize: 120 deg about X-axis.
        // Transform the i, j, & k unit vectors.
        var q: Quaternion = Quaternion (axis: Vector3 (x: 1.0, y: 0.0, z: 0.0), angle: Float (120).degreesToRadians)
        var iT: Vector3 = q * Vector3 (x: 1.0, y: 0.0, z: 0.0)
        var jT: Vector3 = q * Vector3 (x: 0.0, y: 1.0, z: 0.0)
        var kT: Vector3 = q * Vector3 (x: 0.0, y: 0.0, z: 1.0)
        
        XCTAssertEqual (iT.x, 1.0, accuracy: accuracy)
        XCTAssertEqual (iT.y, 0.0, accuracy: accuracy)
        XCTAssertEqual (iT.z, 0.0, accuracy: accuracy)
        XCTAssertEqual (jT.x, 0.0, accuracy: accuracy)
        XCTAssertEqual (jT.y, -0.5, accuracy: accuracy)
        XCTAssertEqual (jT.z, 0.866025, accuracy: accuracy)
        XCTAssertEqual (kT.x, 0.0, accuracy: accuracy)
        XCTAssertEqual (kT.y, -0.866025, accuracy: accuracy)
        XCTAssertEqual (kT.z, -0.5, accuracy: accuracy)
        XCTAssertEqual (iT.length (), 1)
        XCTAssertEqual (jT.length (), 1)
        XCTAssertEqual (kT.length (), 1)
        
        // Easy to visualize: 30 deg about Y-axis.
        q = Quaternion (axis: Vector3 (x: 0.0, y: 1.0, z: 0.0), angle: Float (30).degreesToRadians)
        iT = q * Vector3 (x: 1.0, y: 0.0, z: 0.0)
        jT = q * Vector3 (x: 0.0, y: 1.0, z: 0.0)
        kT = q * Vector3 (x: 0.0, y: 0.0, z: 1.0)
        
        XCTAssertEqual (iT.x, 0.866025, accuracy: accuracy)
        XCTAssertEqual (iT.y, 0.0, accuracy: accuracy)
        XCTAssertEqual (iT.z, -0.5, accuracy: accuracy)
        XCTAssertEqual (jT.x, 0.0, accuracy: accuracy)
        XCTAssertEqual (jT.y, 1.0, accuracy: accuracy)
        XCTAssertEqual (jT.z, 0.0, accuracy: accuracy)
        XCTAssertEqual (kT.x, 0.5, accuracy: accuracy)
        XCTAssertEqual (kT.y, 0.0, accuracy: accuracy)
        XCTAssertEqual (kT.z, 0.866025, accuracy: accuracy)
        XCTAssertEqual (iT.length (), 1)
        XCTAssertEqual (jT.length (), 1)
        XCTAssertEqual (kT.length (), 1)
        
        // Easy to visualize: 60 deg about Z-axis.
        q = Quaternion (axis: Vector3 (x: 0.0, y: 0.0, z: 1.0), angle: Float (60).degreesToRadians)
        iT = q * Vector3 (x: 1.0, y: 0.0, z: 0.0)
        jT = q * Vector3 (x: 0.0, y: 1.0, z: 0.0)
        kT = q * Vector3 (x: 0.0, y: 0.0, z: 1.0)
        
        XCTAssertEqual (iT.x, 0.5, accuracy: accuracy)
        XCTAssertEqual (iT.y, 0.866025, accuracy: accuracy)
        XCTAssertEqual (iT.z, 0.0, accuracy: accuracy)
        XCTAssertEqual (jT.x, -0.866025, accuracy: accuracy)
        XCTAssertEqual (jT.y, 0.5, accuracy: accuracy)
        XCTAssertEqual (jT.z, 0.0, accuracy: accuracy)
        XCTAssertEqual (kT.x, 0.0, accuracy: accuracy)
        XCTAssertEqual (kT.y, 0.0, accuracy: accuracy)
        XCTAssertEqual (kT.z, 1.0, accuracy: accuracy)
        XCTAssertEqual (iT.length (), 1)
        XCTAssertEqual (jT.length (), 1)
        XCTAssertEqual (kT.length (), 1)
    }
    
    func testXformVector () {
        // Arbitrary quaternion rotates an arbitrary vector.
        let eulerYzx: Vector3 = Vector3 (x: Float (31.41).degreesToRadians, y: Float (-49.16).degreesToRadians, z: Float (12.34).degreesToRadians)
        let basisAxes: Basis = Basis.fromEuler (euler: eulerYzx)
        let q: Quaternion = basisAxes.getRotationQuaternion ()
        
        let vArb: Vector3 = Vector3 (x: 3.0, y: 4.0, z: 5.0)
        let vRot: Vector3 = q * vArb
        let vCompare: Vector3 = basisAxes * vArb
        
        XCTAssertEqual (vRot.lengthSquared (), vArb.lengthSquared (), accuracy: Double (accuracy))
        XCTAssertEqual (vRot.x, vCompare.x, accuracy: accuracy)
        XCTAssertEqual (vRot.y, vCompare.y, accuracy: accuracy)
        XCTAssertEqual (vRot.z, vCompare.z, accuracy: accuracy)
    }
    
    func testManyVectorXforms () {
        // Test vector xform for a single combination of Quaternion and Vector.
        func assertQuatVecRotate (eulerYzx: Vector3, vIn: Vector3) {
            let basisAxes: Basis = Basis.fromEuler (euler: eulerYzx)
            let q: Quaternion = basisAxes.getRotationQuaternion ()
            
            let vRot: Vector3 = q * vIn
            let vCompare: Vector3 = basisAxes * vIn
            
            XCTAssertEqual (vRot.lengthSquared (), vIn.lengthSquared (), accuracy: Double (accuracy))
            XCTAssertEqual (vRot.x, vCompare.x, accuracy: accuracy)
            XCTAssertEqual (vRot.y, vCompare.y, accuracy: accuracy)
            XCTAssertEqual (vRot.z, vCompare.z, accuracy: accuracy)
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
