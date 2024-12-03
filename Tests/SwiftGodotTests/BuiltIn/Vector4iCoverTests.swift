@testable import SwiftGodot
import SwiftGodotTestability
import XCTest

extension Vector4i {
    static func gen(_ coordinateGen: TinyGen<Int32>) -> TinyGen<Self> {
        return TinyGen { rng in
            let left = rng.left()
            let right = rng.right()
            return Vector4i(
                x: coordinateGen(left.left()),
                y: coordinateGen(left.right()),
                z: coordinateGen(right.left()),
                w: coordinateGen(right.right())
            )
        }
    }

    static let edgy: TinyGen<Self> = gen(.edgyInt32s)
    static let safe: TinyGen<Self> = gen(.safeInt32s)
}

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
final class Vector4iCoverTests: GodotTestCase {

    func testInitFromVector4i() throws {
        forAll {
            Vector4i.edgy
        } checkCover: {
            Vector4i(from: $0)
        }
    }

    func testInitFromVector4() throws {
        forAll {
            TinyGen.oneOf(gens: [
                Vector4.mixed,
                Vector4.gen(TinyGen.edgyInt32s.map { Float($0) })
            ])
        } checkCover: {
            Vector4i(from: $0)
        }
    }

    func testNullaryCovers() throws {
        // Methods of the form Vector4i.method().

        func checkMethod(
            _ method: (Vector4i) -> () -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            forAll(filePath: filePath, line: line) {
                Vector4i.edgy
            } checkCover: {
                method($0)()
            }
        }

        try checkMethod(Vector4i.maxAxisIndex)
        try checkMethod(Vector4i.minAxisIndex)
        try checkMethod(Vector4i.length)
        try checkMethod(Vector4i.lengthSquared)
        try checkMethod(Vector4i.sign)
        try checkMethod(Vector4i.abs)
    }

    func testUnaryCovers_Vector4i() throws {
        // Methods of the form Vector4i.method(Vector4i).

        func checkMethod(
            _ method: (Vector4i) -> (Vector4i) -> some TestEquatable,
            forVectors vectors: TinyGen<Vector4i>,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            forAll(filePath: filePath, line: line) {
                vectors
                vectors
            } checkCover: {
                method($0)($1)
            }
        }

        try checkMethod(Vector4i.distanceTo, forVectors: Vector4i.safe)
        try checkMethod(Vector4i.distanceSquaredTo, forVectors: Vector4i.safe)
        try checkMethod(Vector4i.min(with:), forVectors: Vector4i.edgy)
        try checkMethod(Vector4i.max(with:), forVectors: Vector4i.edgy)
    }

    func testClamp() throws {
        forAll {
            Vector4i.edgy
            Vector4i.edgy
            Vector4i.edgy
        } checkCover: {
            $0.clamp(min: $1, max: $2)
        }
    }

    func testClampi() throws {
        forAll {
            Vector4i.edgy
            TinyGen.edgyInt64s
            TinyGen.edgyInt64s
        } checkCover: {
            $0.clampi(min: $1, max: $2)
        }
    }

    func testUnaryCovers_Int64() {
        func checkMethod(
            _ method: (Vector4i) -> (Int64) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector4i.edgy
                TinyGen.edgyInt64s
            } checkCover: {
                method($0)($1)
            }
        }

        checkMethod(Vector4i.snappedi)
        checkMethod(Vector4i.mini)
        checkMethod(Vector4i.maxi)
    }

    func testSubscriptGet() throws {
        forAll {
            Vector4i.edgy
            TinyGen.oneOf(values: Vector4i.Axis.allCases)
        } checkCover: {
            var v = $0
            return v[$1.rawValue]
        }
    }

    func testSubscriptSet() throws {
        forAll {
            Vector4i.edgy
            TinyGen.oneOf(values: Vector4i.Axis.allCases)
            TinyGen.edgyInt64s
        } checkCover: {
            var v = $0
            v[$1.rawValue] = $2
            return v
        }
    }

    func testBinaryOperators_Vector4i_Vector4i() throws {
        // Operators of the form Vector4i * Vector4i.

        func checkOperator(
            _ op: (Vector4i, Vector4i) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            forAll(filePath: filePath, line: line) {
                Vector4i.edgy
                Vector4i.edgy
            } checkCover: {
                op($0, $1)
            }
        }

        try checkOperator(==)
        try checkOperator(!=)
        try checkOperator(<)
        try checkOperator(<=)
        try checkOperator(>)
        try checkOperator(>=)
        try checkOperator(+)
        try checkOperator(-)
        try checkOperator(*)
        try checkOperator(/)
        try checkOperator(%)
    }

    func testBinaryOperators_Vector4i_Int64() throws {
        // Operators of the form Vector4i * Int64.

        func checkOperator(
            _ op: (Vector4i, Int64) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            forAll(filePath: filePath, line: line) {
                Vector4i.edgy
                TinyGen.edgyInt64s
            } checkCover: {
                op($0, $1)
            }
        }

        try checkOperator(*)
        try checkOperator(/)
        try checkOperator(%)
    }

    func testTimesInt64() throws {
        forAll {
            Vector4i.edgy
            TinyGen.mixedDoubles
        } checkCover: {
            $0 * $1
        }
    }

    func testDividedByInt64() throws {
        forAll {
            Vector4i.edgy
            TinyGen.mixedDoubles
        } checkCover: {
            $0 / $1
        }
    }
}
