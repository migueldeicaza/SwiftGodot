//
//  File.swift
//  SwiftGodot
//
//  Created by Danny Youstra on 12/11/24.
//

@testable import SwiftGodot
import SwiftGodotTestability
import XCTest

@available(macOS 14, *)
extension Vector4 {
    static func gen(_ coordinateGen: TinyGen<Float>) -> TinyGen<Self> {
        return TinyGen { rng in
            let left = rng.left()
            let right = rng.right()
            return Vector4(
                x: coordinateGen(left.left()),
                y: coordinateGen(left.right()),
                z: coordinateGen(right.left()),
                w: coordinateGen(right.right())
            )
        }
    }

    static let mixed: TinyGen<Self> = gen(.mixedFloats)
}

@available(macOS 14, *)
final class Vector4CoverTests: GodotTestCase {
    
    func testInit() {
        forAll {
            Vector4.mixed
        } checkCover: {
            Vector4.init(from: $0)
        }
    }
    
    // Vector4.method()
    func testNullaryCovers() {
        func checkMethod(_ method: (Vector4) -> () -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector4.mixed
            } checkCover: { v in
                method(v)()
            }
        }
        
        checkMethod(Vector4.abs)
        checkMethod(Vector4.sign)
        checkMethod(Vector4.floor)
        checkMethod(Vector4.ceil)
        checkMethod(Vector4.round)
        checkMethod(Vector4.normalized)
    }
    
    func testUnaryDoubleCovers() {
        func checkMethod(_ method: (Vector4) -> (Double) -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector4.mixed
                TinyGen.mixedDoubles
            } checkCover: { (v, d) in
                method(v)(d)
            }
        }
        
        checkMethod(Vector4.snappedf)
    }
    
    func testUnaryVector4Covers() {
        func checkMethod(_ method: (Vector4) -> (Vector4) -> some TestEquatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector4.mixed
                Vector4.mixed
            } checkCover: { (v, d) in
                method(v)(d)
            }
        }
        
        checkMethod(Vector4.dot)
    }
    
    func testClamp() {
        forAll {
            Vector4.mixed
            Vector4.mixed
            Vector4.mixed
        } checkCover: {
            $0.clamp(min: $1, max: $2)
        }
    }
    
    func testClampf() {
        forAll {
            Vector4.mixed
            TinyGen.mixedDoubles
            TinyGen.mixedDoubles
        } checkCover: {
            $0.clampf(min: $1, max: $2)
        }
    }
    
    func testBinaryOperatorsVector4Vector4() {
        func checkOperator(
            _ op: (Vector4, Vector4) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector4.mixed
                Vector4.mixed
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
    
    func testBinaryOperatorsVector4Int64() {
        func checkOperator(
            _ op: (Vector4, Int64) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector4.mixed
                TinyGen.edgyInt64s
            } checkCover: {
                op($0, $1)
            }
        }

        checkOperator(*)
        checkOperator(/)
    }
    
    func testBinaryOperatorsVector4Double() {
        func checkOperator(
            _ op: (Vector4, Double) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector4.mixed
                TinyGen.mixedDoubles
            } checkCover: {
                op($0, $1)
            }
        }

        checkOperator(*)
        checkOperator(/)
    }
}


