//
//  Transform2DCoverTests.swift
//  SwiftGodot
//
//  Created by Danny Youstra on 12/11/24.
//

@testable import SwiftGodot
import SwiftGodotTestability
import XCTest

@available(macOS 14, *)
extension Transform2D {
    static func gen(_ coordinateGen: TinyGen<Vector2>) -> TinyGen<Self> {
        return TinyGen { rng in
            let left = rng.left()
            return Transform2D(xAxis: coordinateGen(left.left()),
                               yAxis: coordinateGen(left.right()),
                               origin: coordinateGen(rng.right())
            )
        }
    }

    static let mixed: TinyGen<Self> = gen(Vector2.mixed)
}


@available(macOS 14, *)
final class Transform2DCoverTests: GodotTestCase {
    
    func testInit() {
        forAll {
            Transform2D.mixed
        } checkCover: {
            Transform2D.init(from: $0)
        }
    }
    
    func testInitFloatVector2() {
        forAll {
            TinyGen.mixedFloats
            Vector2.mixed
        } checkCover: {
            Transform2D.init(rotation: $0, position: $1)
        }
    }
    
    func testInitFloatVector2FloatVector2() {
        forAll {
            TinyGen.mixedFloats
            Vector2.mixed
            TinyGen.mixedFloats
            Vector2.mixed
        } checkCover: {
            Transform2D.init(rotation: $0, scale: $1, skew: $2, position: $3)
        }
    }
    
    // Transform2D.method()
    func testNullaryCovers() {
        func checkMethod(_ method: (Transform2D) -> () -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Transform2D.mixed
            } checkCover: { t in
                method(t)()
            }
        }
        
        checkMethod(Transform2D.inverse)
        checkMethod(Transform2D.affineInverse)
        checkMethod(Transform2D.getSkew)
        checkMethod(Transform2D.getRotation)
        checkMethod(Transform2D.getOrigin)
        checkMethod(Transform2D.orthonormalized)
        checkMethod(Transform2D.determinant)
        checkMethod(Transform2D.isFinite)
    }
    
    // Transform2D.method(Vector2)
    func testUnaryVector2Covers() {
        func checkMethod(_ method: (Transform2D) -> (Vector2) -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Transform2D.mixed
                Vector2.mixed
            } checkCover: { (t, v) in
                method(t)(v)
            }
        }
        
        checkMethod(Transform2D.scaled)
        checkMethod(Transform2D.scaledLocal)
        checkMethod(Transform2D.translated)
        checkMethod(Transform2D.translatedLocal)
        checkMethod(Transform2D.basisXform)
        checkMethod(Transform2D.basisXformInv)
        checkMethod(Transform2D.lookingAt)
    }
    
    // Transform2D.method(Double)
    func testUnaryDoubleCovers() {
        func checkMethod(_ method: (Transform2D) -> (Double) -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Transform2D.mixed
                TinyGen.mixedDoubles
            } checkCover: { (t, d) in
                method(t)(d)
            }
        }
        
        checkMethod(Transform2D.rotated)
        checkMethod(Transform2D.rotatedLocal)
    }
    
    func testInterpolateWith() {
        forAll {
            Transform2D.mixed
            Transform2D.mixed
            TinyGen.mixedDoubles
        } checkCover: {
            $0.interpolateWith(xform: $1, weight: $2)
        }
    }
    
    func testSubscriptGet() {
        forAll {
            Transform2D.mixed
            TinyGen.edgyInt64s
        } checkCover: { (t, i) in
            var mutT = t
            return mutT[i]
        }
    }
    
    func testSubscriptSet() {
        forAll {
            Transform2D.mixed
            TinyGen.oneOf(values: Vector3.Axis.allCases)
            Vector2.mixed
        } checkCover: { (t, index, val) in
            var mutT = t
            mutT[index.rawValue] = val
            return mutT
        }
    }
    
    func testBinaryOperatorsTransform2DTransform2D() {
        func checkOperator(
            _ op: (Transform2D, Transform2D) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Transform2D.mixed
                Transform2D.mixed
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
    
    func testBinaryOperatorsTransform2DDouble() {
        func checkOperator(
            _ op: (Transform2D, Double) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Transform2D.mixed
                TinyGen.mixedDoubles
            } checkCover: {
                op($0, $1)
            }
        }
        
        checkOperator(*)
        checkOperator(/)
    }
    
    func testBinaryOperatorsTransform2DInt64() {
        func checkOperator(
            _ op: (Transform2D, Int64) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Transform2D.mixed
                TinyGen.edgyInt64s
            } checkCover: {
                op($0, $1)
            }
        }
        
        checkOperator(*)
        checkOperator(/)
    }
    
}
