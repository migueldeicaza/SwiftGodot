@testable import SwiftGodot
import SwiftGodotTestability
import XCTest

@available(macOS 14, *)
extension Basis {
    static func gen(_ coordinateGen: TinyGen<Float>) -> TinyGen<Self> {
        TinyGenBuilder {
            Vector3.gen(coordinateGen)
            Vector3.gen(coordinateGen)
            Vector3.gen(coordinateGen)
        }.map { Basis(xAxis: $0, yAxis: $1, zAxis: $2) }
    }

    static let mixedGen = gen(TinyGen.mixedFloats)

    static let rotationGen = TinyGenBuilder {
        Vector3.normalizedGen
        TinyGen.gaussianFloats
    }.map { Basis(axis: $0, angle: $1) }

    static let scaleRotationGen = TinyGenBuilder {
        rotationGen
        Vector3.gen(TinyGen.gaussianFloats.map { exp($0 * 0.1) })
    }.map { $0.scaled(scale: $1) }
}

@available(macOS 14, *)
final class BasisCoverTests: GodotTestCase {

    func testInitAxisAngle() {
        Float.$closeEnoughUlps.withValue(250) {
            forAll {
                Vector3.normalizedGen
                TinyGen.mixedFloats
            } checkCover: {
                Basis(axis: $0, angle: $1)
            }
        }
    }

    func testInitFromBasis() {
        forAll {
            Basis.mixedGen
        } checkCover: {
            Basis(from: $0)
        }
    }

    func testInitFromQuaternion() {
        forAll {
            Quaternion.mixedGen
        } checkCover: {
            Basis(from: $0)
        }
    }

    func testInverse() {
        forAll {
            Basis.scaleRotationGen
        } checkCover: {
            $0.inverse()
        }
    }

    func testNullaryCovers() {
        // Methods of the form basis.method().

        func checkMethod(
            _ method: (Basis) -> () -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Basis.mixedGen
            } checkCover: {
                method($0)()
            }
        }

        checkMethod(Basis.transposed)
        checkMethod(Basis.orthonormalized)
        checkMethod(Basis.determinant)
        checkMethod(Basis.getScale)
        checkMethod(Basis.isFinite)

        func checkScaleRotationMethod(
            _ method: (Basis) -> () -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Basis.scaleRotationGen
            } checkCover: {
                method($0)()
            }
        }

        checkScaleRotationMethod(Basis.getRotationQuaternion)
    }

    func testIsConformal() {
        forAll {
            TinyGen.oneOf(gens: [
                // These will generally not be conformal.
                Basis.mixedGen,

                // These will generally be conformal.
                TinyGenBuilder {
                    Basis.rotationGen
                    TinyGen.gaussianFloats.map { $0 * 0.001 }
                }.map { $0.scaled(scale: Vector3(x: $1, y: $1, z: $1)) }
            ])
        } checkCover: {
            $0.isConformal()
        }
    }

    func testRotated() {
        Float.$closeEnoughUlps.withValue(640) {
            forAll {
                Basis.mixedGen
                Vector3.normalizedGen // axis
                TinyGen.mixedDoubles // angle
            } checkCover: {
                $0.rotated(axis: $1, angle: $2)
            }
        }
    }

    func testUnaryMethod_Vector3() {
        // Methods of the form basis.method().

        func checkMethod(
            _ method: (Basis) -> (Vector3) -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Basis.mixedGen
                Vector3.mixedGen
            } checkCover: {
                method($0)($1)
            }
        }

        checkMethod(Basis.scaled(scale:))
        checkMethod(Basis.tdotx)
        checkMethod(Basis.tdoty)
        checkMethod(Basis.tdotz)
    }

    func testSlerp() {
        Float.$closeEnoughUlps.withValue(2) {
            forAll {
                Basis.rotationGen
                Basis.rotationGen
                TinyGen.closedUnitRangeDoubles.map { $0 * 2 - 0.5}
            } checkCover: {
                $0.slerp(to: $1, weight: $2)
            }
        }
    }

}
