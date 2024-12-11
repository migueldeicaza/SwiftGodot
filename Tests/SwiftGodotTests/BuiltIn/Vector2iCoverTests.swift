@testable import SwiftGodot
import SwiftGodotTestability
import XCTest

extension Vector2i {
    static func gen(_ coordinateGen: TinyGen<Int32>) -> TinyGen<Self> {
        return TinyGen { rng in
            return Vector2i(x: coordinateGen(rng.left()), y: coordinateGen(rng.right()))
        }
    }

    static let edgy: TinyGen<Self> = gen(.edgyInt32s)
}

@available(macOS 14, *)
final class Vector2iCoverTests: GodotTestCase {

    func testInitFromVector2i() {
        forAll {
            Vector2i.edgy
        } checkCover: {
            Vector2i(from: $0)
        }
    }

    func testInitFromVector2() {
        forAll {
            TinyGen.oneOf(gens: [
                Vector2.mixed,
                Vector2.gen(TinyGen.edgyInt32s.map { Float($0) })
            ])
        } checkCover: {
            Vector2i(from: $0)
        }
    }

    func testNullaryCovers() {
        // Methods of the form Vector2i.method().

        func checkMethod(
            _ method: (Vector2i) -> () -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector2i.edgy
            } checkCover: {
                method($0)()
            }
        }

        checkMethod(Vector2i.aspect)
        checkMethod(Vector2i.maxAxisIndex)
        checkMethod(Vector2i.minAxisIndex)
        checkMethod(Vector2i.length)
        checkMethod(Vector2i.lengthSquared)
        checkMethod(Vector2i.sign)
        checkMethod(Vector2i.abs)
    }

    func testUnaryCovers_Vector2i() {
        // Methods of the form Vector2i.method(Vector2i).

        func checkMethod(
            _ method: (Vector2i) -> (Vector2i) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector2i.edgy
                Vector2i.edgy
            } checkCover: {
                method($0)($1)
            }
        }

        checkMethod(Vector2i.distanceTo)
        checkMethod(Vector2i.distanceSquaredTo)
        checkMethod(Vector2i.min(with:))
        checkMethod(Vector2i.max(with:))
    }

    func testClamp() {
        forAll {
            Vector2i.edgy
            Vector2i.edgy
            Vector2i.edgy
        } checkCover: {
            $0.clamp(min: $1, max: $2)
        }
    }

    func testClampi() {
        forAll {
            Vector2i.edgy
            TinyGen.edgyInt64s
            TinyGen.edgyInt64s
        } checkCover: {
            $0.clampi(min: $1, max: $2)
        }
    }

    func testUnaryCovers_Int64() {
        // Methods of the form Vector2i.method(Int64).

        func checkMethod(
            _ method: (Vector2i) -> (Int64) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector2i.edgy
                TinyGen.edgyInt64s
            } checkCover: {
                method($0)($1)
            }
        }

        checkMethod(Vector2i.snappedi)
        checkMethod(Vector2i.mini)
        checkMethod(Vector2i.maxi)
    }

    func testSubscriptGet() {
        forAll {
            Vector2i.edgy
            TinyGen.oneOf(values: Vector2i.Axis.allCases)
        } checkCover: {
            var v = $0
            return v[$1.rawValue]
        }
    }

    func testSubscriptSet() {
        forAll {
            Vector2i.edgy
            TinyGen.oneOf(values: Vector2i.Axis.allCases)
            TinyGen.edgyInt64s
        } checkCover: {
            var v = $0
            v[$1.rawValue] = $2
            return v
        }
    }

    func testBinaryOperators_Vector2i_Vector2i() throws {
        // Operators of the form Vector2i * Vector2i.

        func checkOperator(
            _ op: (Vector2i, Vector2i) -> Vector2i,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            forAll(filePath: filePath, line: line) {
                Vector2i.edgy
                Vector2i.edgy
            } checkCover: {
                op($0, $1)
            }
        }

        try checkOperator(+)
        try checkOperator(-)
        try checkOperator(*)
        try checkOperator(/)

        // try checkOperator(%)
        //
        // The `Vector2i % Vector2i` operator is implemented incorrectly by Godot, for any gdextension that uses the ptrcall API. It performs `Vector2i / Vector2i` instead of what it's supposed to do.
        //
        // See https://github.com/godotengine/godot/issues/99518 for details.
        //
        // Note that it isn't enough for the bug to be fixed in the Godot project. The libgodot project also needs to be fixed, because that's what SwiftGodot actually uses.
        // https://github.com/migueldeicaza/libgodot
    }

    func testComparisonOperators_Vector2i_Vector2i() throws {
        // Operators of the form Vector2i == Vector2i.

        func checkOperator(
            _ op: (Vector2i, Vector2i) -> Bool,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            forAll(filePath: filePath, line: line) {
                Vector2i.edgy
                Vector2i.edgy
            } checkCover: {
                op($0, $1)
            }

            forAll(filePath: filePath, line: line) {
                Vector2i.edgy
            } checkCover: {
                op($0, $0)
            }
        }

        try checkOperator(==)
        try checkOperator(!=)
        try checkOperator(<)
        try checkOperator(<=)
        try checkOperator(>)
        try checkOperator(>=)
    }

    func testBinaryOperators_Vector2i_Int64() throws {
        // Operators of the form Vector2i * Int64.

        func checkOperator(
            _ op: (Vector2i, Int64) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) throws {
            forAll(filePath: filePath, line: line) {
                Vector2i.edgy
                TinyGen.edgyInt64s
            } checkCover: {
                op($0, $1)
            }
        }

        try checkOperator(*)
        try checkOperator(/)
        try checkOperator(%)
    }

    func testTimesInt64() {
        forAll {
            Vector2i.edgy
            TinyGen.mixedDoubles
        } checkCover: {
            $0 * $1
        }
    }

    func testDividedByInt64() {
        forAll {
            Vector2i.edgy
            TinyGen.mixedDoubles
        } checkCover: {
            $0 / $1
        }
    }
}
