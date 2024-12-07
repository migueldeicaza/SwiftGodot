@testable import SwiftGodot
@_spi(SwiftCovers) import SwiftGodot
import SwiftGodotTestability
import XCTest

@available(macOS 14, *)
extension Quaternion {
    static func gen(_ coordinateGen: TinyGen<Float>) -> TinyGen<Quaternion> {
        return TinyGenBuilder {
            coordinateGen
            coordinateGen
            coordinateGen
            coordinateGen
        }.map { Quaternion(x: $0, y: $1, z: $2, w: $3) }
    }

    static let mixedGen = gen(.mixedFloats)

    static let normalizedGen = TinyGenBuilder {
        Vector3.normalizedGen
        TinyGen<Float>.gaussianFloats
    }.map { Quaternion(axis: $0, angle: $1).normalized() }
}

@available(macOS 14, *)
final class QuaternionCoverTests: GodotTestCase {

    let weightGen = TinyGen<Double>.closedUnitRangeDoubles
                .map { $0 * 1.2 - 0.1 }
    let extendedWeightGen = TinyGen<Double>.closedUnitRangeDoubles
                .map { $0 * 3 - 1 }

    func testInitFromBasis() {
        forAll {
            Basis.mostlyRotationGen
        } checkCover: {
            Quaternion(from: $0.orthonormalized())
        }
    }

    func testInitFromAxisAndAngle() {
        forAll {
            Vector3.normalizedGen
            TinyGen<Float>.mixedFloats
        } checkCover: {
            Quaternion(axis: $0, angle: $1)
        }
    }

    func testInitFromArc() {
        forAll {
            Vector3.normalizedGen
            Vector3.normalizedGen
        } checkCover: {
            Quaternion(arcFrom: $0, arcTo: $1)
        }
    }

    func testNullaryCovers() {
        // Methods of the form quaternion.method().

        func checkMethod(
            _ method: (Quaternion) -> () -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                TinyGen.oneOf(gens: [
                    Quaternion.mixedGen,
                    Quaternion.normalizedGen,
                ])
            } checkCover: {
                method($0)()
            }
        }

        checkMethod(Quaternion.length)
        checkMethod(Quaternion.lengthSquared)
        checkMethod(Quaternion.normalized)
        checkMethod(Quaternion.isFinite)
        checkMethod(Quaternion.getAxis)
        checkMethod(Quaternion.getAngle)
        checkMethod(Quaternion.log)
        checkMethod(Quaternion.exp)
    }

    func testIsNormalized() {
        let perturbation = TinyGen<Double>.gaussianDoubles
            .map { Float(exp(0.001 * $0)) }

        forAll {
            TinyGen.oneOf(gens: [
                // Some arbitrary values including weird values.
                Quaternion.mixedGen,

                // Some definitely normalized values.
                Quaternion.normalizedGen,

                // Some normalized values with slight tweaking that might be enough to make them seem denormalized.
                TinyGenBuilder {
                    Quaternion.normalizedGen
                    perturbation
                    perturbation
                    perturbation
                    perturbation
                }.map { q, dx, dy, dz, dw in
                    Quaternion(x: q.x * dx, y: q.y * dy, z: q.z * dz, w: q.w * dw)
                }
            ])
        } checkCover: {
            $0.isNormalized()
        }
    }

    func testIsEqualApprox() {
        let perturbation = TinyGen<Double>.gaussianDoubles
            .map { Float(exp(0.000007 * $0)) }

        forAll {
            Quaternion.mixedGen
            perturbation
            perturbation
            perturbation
            perturbation
        } checkCover: { q1, dx, dy, dz, dw in
            let q2 = Quaternion(x: q1.x * dx, y: q1.y * dy, z: q1.z * dz, w: q1.w * dw)
            return q1.isEqualApprox(to: q2)
        }
    }

    func testInverse() {
        forAll {
            Quaternion.normalizedGen
        } checkCover: {
            $0.inverse()
        }
    }

    func testAngleTo() {
        forAll {
            Quaternion.mixedGen
            Quaternion.mixedGen
        } checkCover: {
            $0.angleTo($1)
        }
    }

    func testDot() {
        forAll {
            Quaternion.mixedGen
            Quaternion.mixedGen
        } checkCover: {
            $0.dot(with: $1)
        }
    }

    func testSlerp() {
        forAll {
            Quaternion.normalizedGen
            Quaternion.normalizedGen
            weightGen
        } checkCover: {
            $0.slerp(to: $1, weight: $2)
        }
    }

    func testSlerpni() {
        forAll {
            Quaternion.normalizedGen
            Quaternion.normalizedGen
            weightGen
        } checkCover: {
            $0.slerpni(to: $1, weight: $2)
        }
    }

    func testSphericalCubicInterpolate() {
        forAll {
            Quaternion.normalizedGen
            Quaternion.normalizedGen
            Quaternion.normalizedGen
            Quaternion.normalizedGen
            weightGen
        } checkCover: {
            $0.sphericalCubicInterpolate(b: $1, preA: $2, postB: $3, weight: $4)
        }
    }

    func testSphericalCubicInterpolateInTime() {
        forAll {
            Quaternion.normalizedGen
            Quaternion.normalizedGen
            Quaternion.normalizedGen
            Quaternion.normalizedGen
            weightGen
            extendedWeightGen
            extendedWeightGen
            extendedWeightGen
        } checkCover: {
            $0.sphericalCubicInterpolateInTime(b: $1, preA: $2, postB: $3, weight: $4, bT: $5, preAT: $6, postBT: $7)
        }
    }

    func testGetEuler() {
        forAll {
            Quaternion.normalizedGen
            TinyGen<EulerOrder>.oneOf(values: EulerOrder.allCases)
        } checkCover: {
            $0.getEuler(order: $1.rawValue)
        }
    }

    func testFromEuler() {
        forAll {
            Vector3.mixedGen
        } checkCover: {
            Quaternion.fromEuler($0)
        }
    }

    func testSubscriptGet() {
        forAll {
            Quaternion.mixedGen
            TinyGen<Int64>.oneOf(values: Array(0 ... 3))
        } checkCover: { q, axis in
            var q = q
            return q[axis]
        }
    }

    func testSubscriptSet() {
        forAll {
            Quaternion.mixedGen
            TinyGen<Int64>.oneOf(values: Array(0 ... 3))
            TinyGen.mixedDoubles
        } checkCover: { q, axis, newValue in
            var q = q
            q[axis] = newValue
            return q
        }
    }

    func testTimesInt64() {
        forAll {
            Quaternion.mixedGen
            TinyGen.edgyInt64s
        } checkCover: {
            $0 * $1
        }
    }

    func testDividedByInt64() {
        forAll {
            Quaternion.mixedGen
            TinyGen.edgyInt64s
        } checkCover: {
            $0 / $1
        }
    }

    func testTimesDouble() {
        forAll {
            Quaternion.mixedGen
            TinyGen.mixedDoubles
        } checkCover: {
            $0 * $1
        }
    }

    func testDividedByDouble() {
        forAll {
            Quaternion.mixedGen
            TinyGen.mixedDoubles
        } checkCover: {
            $0 / $1
        }
    }

    func testTimesVector3() {
        forAll {
            Quaternion.normalizedGen
            Vector3.mixedGen
        } checkCover: {
            $0 * $1
        }
    }

    func testEquality() {
        forAll {
            TinyGen.oneOf(gens: [
                // Same value twice so they are equal.
                Quaternion.mixedGen.map { ($0, $0) },
                TinyGenBuilder {
                    Quaternion.mixedGen
                    Quaternion.mixedGen
                }
            ])
        } checkCover: {
            $0 == $1
        }
    }

    func testInequality() {
        forAll {
            TinyGen.oneOf(gens: [
                // Same value twice so they are equal.
                Quaternion.mixedGen.map { ($0, $0) },
                TinyGenBuilder {
                    Quaternion.mixedGen
                    Quaternion.mixedGen
                }
            ])
        } checkCover: {
            $0 != $1
        }
    }

    func testBinaryOperators() {
        // Operators of the form q1 ~ q2.

        func checkOperator(
            _ op: (Quaternion, Quaternion) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Quaternion.mixedGen
                Quaternion.mixedGen
            } checkCover: {
                op($0, $1)
            }
        }

        checkOperator(+)
        checkOperator(-)
        checkOperator(*)
    }
}
