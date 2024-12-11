//
//  Transform3DCoverTests.swift
//  SwiftGodot
//
//  Created by Danny Youstra on 12/11/24.
//

@testable import SwiftGodot
import SwiftGodotTestability
import XCTest

@available(macOS 14, *)
extension Transform3D {
    static func gen(_ coordinateGen: TinyGen<Vector3>) -> TinyGen<Self> {
        return TinyGen { rng in
            let left = rng.left()
            let right = rng.right()
            return Transform3D(xAxis: coordinateGen(left.left()),
                               yAxis: coordinateGen(left.right()),
                               zAxis: coordinateGen(right.left()),
                               origin: coordinateGen(right.right())
            )
        }
    }

    static let mixed: TinyGen<Self> = gen(Vector3.mixed)
}

@available(macOS 14, *)
final class Transform3DCoverTests: GodotTestCase {
    
    func testInit() {
        forAll {
            Transform3D.mixed
        } checkCover: {
            Transform3D.init(from: $0)
        }
    }
    
    func testInitV3V3V3V3() {
        forAll {
            Vector3.mixed
            Vector3.mixed
            Vector3.mixed
            Vector3.mixed
        } checkCover: {
            Transform3D.init(xAxis: $0, yAxis: $1, zAxis: $2, origin: $3)
        }
    }
    
    // Transform3D.method()
    func testNullaryCovers() {
        func checkMethod(_ method: (Transform3D) -> () -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Transform3D.mixed
            } checkCover: { t in
                method(t)()
            }
        }
        
        checkMethod(Transform3D.inverse)
        checkMethod(Transform3D.affineInverse)
        checkMethod(Transform3D.orthonormalized)
        checkMethod(Transform3D.isFinite)
    }
    
    // Transform3D.method(Vector3)
    func testUnaryVector3Covers() {
        func checkMethod(_ method: (Transform3D) -> (Vector3) -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Transform3D.mixed
                Vector3.mixed
            } checkCover: { (t, v) in
                method(t)(v)
            }
        }
        
        checkMethod(Transform3D.scaled)
        checkMethod(Transform3D.scaledLocal)
        checkMethod(Transform3D.translated)
        checkMethod(Transform3D.translatedLocal)
    }
    
    // Transform3D.method(Vector3, Double)
    func testBinaryVector3DoubleCovers() {
        func checkMethod(_ method: (Transform3D) -> (Vector3, Double) -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Transform3D.mixed
                Vector3.mixed
                TinyGen.mixedDoubles
            } checkCover: { (t, v, d) in
                method(t)(v,d)
            }
        }
        
        checkMethod(Transform3D.rotated)
        checkMethod(Transform3D.rotatedLocal)
    }
    
    func testLookingAt() {
        forAll {
            Transform3D.mixed
            Vector3.mixed
            Vector3.mixed
        } checkCover: {
            $0.lookingAt(target: $1, up: $2)
        }
    }
    
    func testInterpolateWith() {
        forAll {
            Transform3D.mixed
            Transform3D.mixed
            TinyGen.mixedDoubles
        } checkCover: {
            $0.interpolateWith(xform: $1, weight: $2)
        }
    }
    
    // Operators
    
    func testBinaryOperatorsTransform3DTransform3D() {
        func checkOperator(
            _ op: (Transform3D, Transform3D) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Transform3D.mixed
                Transform3D.mixed
            } checkCover: {
                op($0, $1)
            }
        }
        
        // Arithmetic
        checkOperator(*)
        // Comparison
        checkOperator(==)
        checkOperator(!=)
    }
    
    func testBinaryOperatorsTransform3DDouble() {
        func checkOperator(
            _ op: (Transform3D, Double) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Transform3D.mixed
                TinyGen.mixedDoubles
            } checkCover: {
                op($0, $1)
            }
        }
        
        checkOperator(*)
        checkOperator(/)
    }
    
    func testBinaryOperatorsTransform3DInt64() {
        func checkOperator(
            _ op: (Transform3D, Int64) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Transform3D.mixed
                TinyGen.edgyInt64s
            } checkCover: {
                op($0, $1)
            }
        }
        
        checkOperator(*)
        checkOperator(/)
    }
    
    func testBinaryOperatorMultiplyVector3() {
        forAll {
            Transform3D.mixed
            Vector3.mixed
        } checkCover: {
            $0 * $1
        }
    }
    
}
