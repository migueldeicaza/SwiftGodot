//
//  Vector2CoverTests.swift
//  SwiftGodot
//
//  Created by Danny Youstra on 12/10/24.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

@available(macOS 14, *)
extension Vector2 {
    static func gen(_ coordinateGen: TinyGen<Float>) -> TinyGen<Self> {
        return TinyGen { rng in
            return Vector2(x: coordinateGen(rng.left()), y: coordinateGen(rng.right()))
        }
    }

    static let mixed: TinyGen<Self> = gen(.mixedFloats)
}

@available(macOS 14, *)
final class Vector2CoverTests: GodotTestCase {
    
    func testInit() {
        forAll {
            Vector2.mixed
        } checkCover {
            Vector2(from: $0)
        }
    }
    
    // Vector2.method()
    func testNullaryCovers() {
        
        func checkMethod(_ method: (Vector2) -> () -> some Equatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector2.mixed
            } checkCover: { v in
                method(v)()
            }

        }
        
        try checkMethod(Vector2.angle)
        try checkMethod(Vector2.length)
        try checkMethod(Vector2.lengthSquared)
        try checkMethod(Vector2.normalized)
        try checkMethod(Vector2.sign)
        try checkMethod(Vector2.floor)
        try checkMethod(Vector2.ceil)
        try checkMethod(Vector2.round)
    }

    // Vector2.method(Double)
    func testUnaryDoubleCovers() {
        
        func checkMethod(_ method: (Vector2) -> (Double) -> some Equatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector2.mixed
                TinyGen.mixedDoubles
            } checkCover: {
                method($0)($1)
            }
        }
        
        try checkMethod(Vector2.rotated)
        try checkMethod(Vector2.snappedf)
        try checkMethod(Vector2.limitLength)
    }
    
    // Vector2.method(Vector2)
    func testUnaryCovers() {
        
        func checkMethod(_ method: (Vector2) -> (Vector2) -> some Equatable,
                         filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector2.mixed
                Vector2.mixed
            } checkCover {
                method($0)($1)
            }
        }
        
        try checkMethod(Vector2.distanceTo(_:))
        try checkMethod(Vector2.distanceSquaredTo(_:))
        try checkMethod(Vector2.angleTo(_:))
        try checkMethod(Vector2.angleToPoint)
        try checkMethod(Vector2.dot)
        try checkMethod(Vector2.cross)
        try checkMethod(Vector2.project)
        try checkMethod(Vector2.slide)
        try checkMethod(Vector2.bounce)
        try checkMethod(Vector2.reflect(line:))
    }
    
    // Static
    func testFromAngle() {
        forAll {
            TinyGen.mixedDoubles
        } checkCover {
            Vector2.fromAngle($0)
        }
    }
    
    func testClamp() {
        forAll {
            Vector2.mixed
            Vector2.mixed
            Vector2.mixed
        } checkCover {
            $0.clamp(min: $1, max: $2)
        }
    }
    
    func testClampf() {
        forAll {
            Vector2.mixed
            TinyGen.mixedDoubles
            TinyGen.mixedDoubles
        } checkCover {
            $0.clampf($1, $2)
        }
    }
    
    func testMoveToward() {
        forAll {
            Vector2.mixed
            Vector2.mixed
            TinyGen.mixedDoubles
        } checkCover {
            $0.moveToward(to: $1, delta: $2)
        }
    }
    
    // Operator Covers
    
    func testBinaryOperators_Vector2i_Vector2i() {
        // Operators of the form Vector2i * Vector2i.

        func checkOperator(
            _ op: (Vector2, Vector2) -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector2.mixed
                Vector2.mixed
            } checkCover {
                op($0, $1)
            }
        }
        
        // Arithmetic Operators
        try checkOperator(+)
        try checkOperator(-)
        try checkOperator(*)
        try checkOperator(/)
        // Comparison Operators
        try checkOperator(==)
        try checkOperator(!=)
        try checkOperator(<)
        try checkOperator(<=)
        try checkOperator(>)
        try checkOperator(>=)
    }
    
    func testBinaryOperators_Vector2i_Int64() {
        // Operators of the form Vector2i * Int64.

        func checkOperator(
            _ op: (Vector2, Int64) -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector2.mixed
                TinyGen.mixedInt64s
            } checkCover {
                op($0, $1)
            }
        }

        try checkOperator(/)
        try checkOperator(*)
    }
    
    func testBinaryOperators_Vector2i_Double() {
        // Operators of the form Vector2i * Int64.

        func checkOperator(
            _ op: (Vector2, Double) -> some Equatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector2.mixed
                TinyGen.mixedDoubles
            } checkCover {
                op($0, $1)
            }
        }

        try checkOperator(/)
        try checkOperator(*)
    }
}
