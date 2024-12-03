@testable import SwiftGodot
import SwiftGodotTestability
import XCTest

extension Vector3i {
    static func gen(_ coordinateGen: TinyGen<Int32>) -> TinyGen<Self> {
        return TinyGen { rng in
            let right = rng.right()
            return Vector3i(
                x: coordinateGen(rng.left()),
                y: coordinateGen(right.left()),
                z: coordinateGen(right.right())
            )
        }
    }

    static let edgy: TinyGen<Self> = gen(.edgyInt32s)
    static let safe: TinyGen<Self> = gen(.safeInt32s)
}

@available(macOS 14, *)
extension Vector3 {
    static func gen(_ coordinateGen: TinyGen<Float>) -> TinyGen<Self> {
        return TinyGen { rng in
            let right = rng.right()
            return Vector3(
                x: coordinateGen(rng.left()),
                y: coordinateGen(right.left()),
                z: coordinateGen(right.right())
            )
        }
    }

    static let mixed: TinyGen<Self> = gen(.mixedFloats)
}

@available(macOS 14, *)
final class Vector3iCoverTests: GodotTestCase {

    func testInitFromVector3i() {
        forAll {
            Vector3i.edgy
        } checkCover: {
            Vector3i(from: $0)
        }
    }

    func testInitFromVector3() {
        forAll {
            TinyGen.oneOf(gens: [
                Vector3.mixed,
                Vector3.gen(TinyGen.edgyInt32s.map { Float($0) })
            ])
        } checkCover: {
            Vector3i(from: $0)
        }
    }

    func testNullaryCovers() {
        // Methods of the form Vector3i.method().

        func checkMethod(
            _ method: (Vector3i) -> () -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector3i.edgy
            } checkCover: {
                method($0)()
            }
        }

        checkMethod(Vector3i.maxAxisIndex)
        checkMethod(Vector3i.minAxisIndex)
        checkMethod(Vector3i.length)
        checkMethod(Vector3i.lengthSquared)
        checkMethod(Vector3i.sign)
        checkMethod(Vector3i.abs)
    }

    func testUnaryCovers_Vector3i() {
        // Methods of the form Vector3i.method(Vector3i).

        func checkMethod(
            _ method: (Vector3i) -> (Vector3i) -> some TestEquatable,
            forVectors vectors: TinyGen<Vector3i>,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                vectors
                vectors
            } checkCover: {
                method($0)($1)
            }
        }

        /// ## Why I restrict the test inputs for `distanceTo` and `distanceSquaredTo`
        ///
        /// Consider this program:
        ///
        /// ```swift
        /// let a = Vector3i(x: .min, y: .min, z: .min)
        /// let b = Vector3i(x: 1, y: .min, z: .min)
        /// let answer = a.distanceTo(b)
        /// ```
        ///
        /// Remarkably, this produces different output depending on whether libgodot was compiled with optimization or not.
        ///
        /// The Godot implementation looks like this:
        ///
        /// ```c++
        /// double Vector3i::distance_to(const Vector3i &p_to) const {
        ///     return (p_to - *this).length();
        /// }
        ///
        /// int64_t Vector3i::length_squared() const {
        ///     return x * (int64_t)x + y * (int64_t)y + z * (int64_t)z;
        /// }
        ///
        /// double Vector3i::length() const {
        ///     return Math::sqrt((double)length_squared());
        /// }
        /// ```
        ///
        /// Note in particular the cast `(int64_t)` in `length_squared`. So the treatment of the X coordinate in a non-optimized build is (using Swift notation):
        ///
        /// ```swift
        ///    square(signExtend(Int32(1) &- Int32.min))
        /// ==
        ///    square(signExtend(0x0000_0001 &- 0x8000_0000))
        /// == // overflow!
        ///    square(signExtend(0x8000_0001))
        /// ==
        ///    square(0xffff_ffff_8000_0001)
        /// ==
        ///    0x3fff_ffff_0000_0001
        /// ```
        ///
        /// But `1 &- Int32.min` is signed integer overflow, and in C++, signed integer overflow is undefined behavior. The optimizer is allowed to assume that undefined behavior doesn't happen. Clang chooses to assume that `b.x - a.x` does not overflow (where, remember, `b.x` and `a.x` are `Int32`). If `b.x - a.x` doesn't overflow, then `Int64(b.x) - Int64(a.x)` is mathematically equal to `b.x - a.x`. So clang's optimizer treats the X coordinate like this:
        ///
        /// ```swift
        ///    square(signExtend(Int32(1)) &- signExtend(Int32.min))
        /// =
        ///    square(0x0000_0000_0000_0001 &- 0xffff_ffff_8000_0000
        /// = // no overflow!
        ///    square(0x0000_0000_8000_0001)
        /// =
        ///    0x4000_0001_0000_0001
        /// ```
        ///
        /// The difference between the two computations is big enough that the `distanceTo` answer is 2147483647.0 in a debug build and 2147483649.0 in a release build.
        ///
        /// I can't know here whether I've been linked to a debug libgodot or a release libgodot. So I simply avoid testing `distanceTo` and `distanceSquaredTo` with inputs that could cause signed integer overflow.

        checkMethod(Vector3i.distanceTo, forVectors: Vector3i.safe)
        checkMethod(Vector3i.distanceSquaredTo, forVectors: Vector3i.safe)
        checkMethod(Vector3i.min(with:), forVectors: Vector3i.edgy)
        checkMethod(Vector3i.max(with:), forVectors: Vector3i.edgy)
    }

    func testClamp() {
        forAll {
            Vector3i.edgy
            Vector3i.edgy
            Vector3i.edgy
        } checkCover: {
            $0.clamp(min: $1, max: $2)
        }
    }

    func testClampi() {
        forAll {
            Vector3i.edgy
            TinyGen.edgyInt64s
            TinyGen.edgyInt64s
        } checkCover: {
            $0.clampi(min: $1, max: $2)
        }
    }

    func testUnaryCovers_Int64() {
        func checkMethod(
            _ method: (Vector3i) -> (Int64) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector3i.edgy
                TinyGen.edgyInt64s
            } checkCover: {
                method($0)($1)
            }
        }

        checkMethod(Vector3i.snappedi)
        checkMethod(Vector3i.mini)
        checkMethod(Vector3i.maxi)
    }

    func testSubscriptGet() {
        forAll {
            Vector3i.edgy
            TinyGen.oneOf(values: Vector3i.Axis.allCases)
        } checkCover: {
            var v = $0
            return v[$1.rawValue]
        }
    }

    func testSubscriptSet() {
        forAll {
            Vector3i.edgy
            TinyGen.oneOf(values: Vector3i.Axis.allCases)
            TinyGen.edgyInt64s
        } checkCover: {
            var v = $0
            v[$1.rawValue] = $2
            return v
        }
    }

    func testBinaryOperators_Vector3i_Vector3i() {
        // Operators of the form Vector3i * Vector3i.

        func checkOperator(
            _ op: (Vector3i, Vector3i) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector3i.edgy
                Vector3i.edgy
            } checkCover: {
                op($0, $1)
            }
        }

        checkOperator(==)
        checkOperator(!=)
        checkOperator(<)
        checkOperator(<=)
        checkOperator(>)
        checkOperator(>=)
        checkOperator(+)
        checkOperator(-)
        checkOperator(*)
        checkOperator(/)
        checkOperator(%)
    }

    func testBinaryOperators_Vector3i_Int64() {
        // Operators of the form Vector3i * Int64.

        func checkOperator(
            _ op: (Vector3i, Int64) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Vector3i.edgy
                TinyGen.edgyInt64s
            } checkCover: {
                op($0, $1)
            }
        }

        checkOperator(*)
        checkOperator(/)
        checkOperator(%)
    }

    func testTimesInt64() {
        forAll {
            Vector3i.edgy
            TinyGen.mixedDoubles
        } checkCover: {
            $0 * $1
        }
    }

    func testDividedByInt64() {
        forAll {
            Vector3i.edgy
            TinyGen.mixedDoubles
        } checkCover: {
            $0 / $1
        }
    }
}
