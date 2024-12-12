//
//  File.swift
//  SwiftGodot
//
//  Created by Danny Youstra on 12/11/24.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

@available(macOS 14, *)
extension Vector3 {
    static func gen(_ coordinateGen: TinyGen<Float>) -> TinyGen<Self> {
        return TinyGen { rng in
            let right = rng.right()
            return Vector3(x: coordinateGen(rng.left()),
                           y: coordinateGen(right.left()),
                           z: coordinateGen(right.right())
            )
        }
    }
    
    static let normalized: TinyGen<Self> = TinyGen.build {
        TinyGen.gaussianFloats
        TinyGen.gaussianFloats
        TinyGen.gaussianFloats
    }.map { x, y, z in
        // https://stackoverflow.com/q/6283080/77567
        let d = (x * x + y * y + z * z).squareRoot()
        return Vector3(x: x / d, y: y / d, z: z / d)
    }

    static let mixed: TinyGen<Self> = gen(.mixedFloats)
    static let tinyGen: TinyGen<Self> = gen(TinyGen.gaussianFloats.map { $0 * 0.0001 })
}

@available(macOS 14, *)
final class Vector3CoverTests: GodotTestCase {
    
    func testInit() {
        forAll {
            Vector3.mixed
        } checkCover: {
            Vector3(from: $0)
        }
    }
    
    // Vector3.method()
    func testNullaryCovers() {
        func checkMethod(_ method: (Vector3) -> () -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector3.mixed
            } checkCover: { v in
                method(v)()
            }

        }
        
        checkMethod(Vector3.abs)
        checkMethod(Vector3.sign)
        checkMethod(Vector3.floor)
        checkMethod(Vector3.ceil)
        checkMethod(Vector3.round)
        checkMethod(Vector3.length)
        checkMethod(Vector3.lengthSquared)
        checkMethod(Vector3.round)
        checkMethod(Vector3.normalized)
        checkMethod(Vector3.octahedronEncode)
    }
    
    // Vector3.method(Vector3)
    func testUnaryVector3Covers() {
        func checkMethod(_ method: (Vector3) -> (Vector3) -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector3.mixed
                Vector3.mixed
            } checkCover: {
                method($0)($1)
            }
        }
        
        checkMethod(Vector3.cross)
        checkMethod(Vector3.dot)
        checkMethod(Vector3.outer)
        checkMethod(Vector3.distanceTo(_:))
    }
    
    // Vector3.method(Vector3)
    // Parameter V3 must be normalized
    func testUnaryNormalizedVector3Covers() {
        func checkMethod(_ method: (Vector3) -> (Vector3) -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector3.mixed
                Vector3.normalized
            } checkCover: {
                method($0)($1)
            }
        }
        
        checkMethod(Vector3.slide)
        checkMethod(Vector3.bounce)
        checkMethod(Vector3.reflect)
    }
    
    // Vector3.method(Double)
    func testUnaryDoubleCovers() {
        
        func checkMethod(_ method: (Vector3) -> (Double) -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector3.mixed
                TinyGen.mixedDoubles
            } checkCover: {
                method($0)($1)
            }
        }
        
        checkMethod(Vector3.snappedf)
        checkMethod(Vector3.limitLength(_:))
    }
    
    func testBinaryVector3DoubleCovers() {
        func checkMethod(_ method: (Vector3) -> (Vector3, Double) -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector3.mixed
                Vector3.mixed
                TinyGen.mixedDoubles
            } checkCover: {
                method($0)($1, $2)
            }
        }
        
        checkMethod(Vector3.slerp)
        checkMethod(Vector3.rotated)
        checkMethod(Vector3.moveToward)
    }
    
    func testClamp() {
        forAll {
            Vector3.mixed
            Vector3.mixed
            Vector3.mixed
        } checkCover: {
            $0.clamp(min: $1, max: $2)
        }
    }
    
    func testClampf() {
        forAll {
            Vector3.mixed
            TinyGen.mixedDoubles
            TinyGen.mixedDoubles
        } checkCover: {
            $0.clampf(min: $1, max: $2)
        }
    }
    
    // Static
    func testOctahedronDecode() {
        forAll {
            Vector2.mixed
        } checkCover: {
            Vector3.octahedronDecode(uv: $0)
        }
    }
    
    // Vector3 * Vector3.
    func testBinaryOperatorsVector3Vector3() {
        func checkOperator(
            _ op: (Vector3, Vector3) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector3.mixed
                Vector3.mixed
            } checkCover: {
                op($0, $1)
            }
        }

        // Arithmetic
        checkOperator(+)
        checkOperator(-)
        checkOperator(*)
        checkOperator(/)
        // Comparison
        checkOperator(==)
        checkOperator(!=)
        checkOperator(<)
        checkOperator(>)
        checkOperator(<=)
        checkOperator(>=)
    }
    
}
