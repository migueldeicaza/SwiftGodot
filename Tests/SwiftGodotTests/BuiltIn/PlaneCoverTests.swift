@testable import SwiftGodot
@_spi(SwiftCovers) import SwiftGodot
import SwiftGodotTestability
import XCTest

@available(macOS 14, *)
extension Plane {
    static func gen(normal: TinyGen<Vector3>, d: TinyGen<Float>) -> TinyGen<Self> {
        return TinyGen { rng in
            return Plane(normal: normal(rng.left()), d: d(rng.right()))
        }
    }

    // Vanishingly small chance that the normal is zero.
    static let nonZeroGen: TinyGen<Self> = gen(normal: Vector3.mixed, d: TinyGen.mixedFloats)

    static let maybeZeroGen: TinyGen<Self> = TinyGen.biasedOneOf(gens: [
        (99, nonZeroGen),
        (1, TinyGen.gaussianFloats.map { Plane(normal: .zero, d: $0) })
    ])
}

@available(macOS 14, *)
extension Basis {
    static let mostlyRotationGen: TinyGen<Self> = TinyGenBuilder {
        Vector3.normalized // rotation axis
        TinyGen.gaussianDoubles.map { $0 } // rotation angle
        TinyGen.gaussianFloats.map { exp($0 * 0.0001) } // x scale
        TinyGen.gaussianFloats.map { exp($0 * 0.0001) } // y scale
        TinyGen.gaussianFloats.map { exp($0 * 0.0001) } // z scale
    }.map { axis, angle, x, y, z in
        Basis()
            .rotated(axis: axis, angle: angle)
            .scaled(scale: Vector3(x: x, y: y, z: z))
    }
}

@available(macOS 14, *)
extension Transform3D {
    static let gaussianGen: TinyGen<Self> = TinyGenBuilder {
        Basis.mostlyRotationGen
        Vector3.mixed
    }.map { Transform3D(basis: $0, origin: $1) }
}

@available(macOS 14, *)
final class PlaneCoverTests: GodotTestCase {

    func testInitFromPlane() {
        forAll {
            Plane.maybeZeroGen
        } checkCover: {
            Plane(from: $0)
        }
    }

    func testInitNormal() {
        forAll {
            Vector3.mixed
        } checkCover: {
            Plane(normal: $0)
        }
    }

    func testInitNormalPoint() {
        forAll {
            Vector3.mixed
            Vector3.mixed
        } checkCover: {
            Plane(normal: $0, point: $1)
        }
    }

    func testInitThreePoints() {
        forAll {
            Vector3.mixed
            Vector3.mixed
            Vector3.mixed
        } checkCover: {
            Plane(point1: $0, point2: $1, point3: $2)
        }
    }

    func testInitFourFloats() {
        forAll {
            TinyGen<Float>.mixedFloats
            TinyGen<Float>.mixedFloats
            TinyGen<Float>.mixedFloats
            TinyGen<Float>.mixedFloats
        } checkCover: {
            Plane(a: $0, b: $1, c: $2, d: $3)
        }
    }

    func testNullaryCovers() {
        // Methods of the form Plane.method().

        func checkMethod(
            _ method: (Plane) -> () -> some TestEquatable,
            filePath: StaticString = #filePath, line: UInt = #line
        ) {
            forAll(filePath: filePath, line: line) {
                Plane.maybeZeroGen
            } checkCover: {
                method($0)()
            }
        }

        checkMethod(Plane.normalized)
        checkMethod(Plane.getCenter)
        checkMethod(Plane.isFinite)
    }

    func testIsEqualApprox() {
        let perturbationGen = TinyGen.closedUnitRangeDoubles.map {
            Float(1.0 + 4.0 * ($0 - 0.5) * CMP_EPSILON)
        }

        forAll {
            Plane.maybeZeroGen
            Vector3.gen(perturbationGen)
            perturbationGen // for d
        } checkCover: { p0, n, d in
            var p1 = p0
            p1.normal *= n
            p1.d *= d
            return p0.isEqualApprox(toPlane: p1)
        }
    }

    func testPlaneTimesTransform() {
        forAll {
            Plane.maybeZeroGen
            Transform3D.gaussianGen
        } checkCover: { plane, xform in
            plane * xform
        }
    }

    func testIsPointOver() {
        forAll {
            Plane.maybeZeroGen
            Vector3.mixed
        } checkCover: {
            $0.isPointOver(point: $1)
        }
    }

    func testDistanceToPoint() {
        forAll {
            Plane.maybeZeroGen
            Vector3.mixed
        } checkCover: {
            // Godot ncasts to float, so I do too.
            Float($0.distanceTo(point: $1))
        }
    }

    func testHasPoint() {
        forAll {
            Plane.nonZeroGen
            Vector3.normalized
            TinyGen<Double>.gaussianDoubles.map { 0.0001 * $0 } // offset
            TinyGen<Double>.gaussianDoubles.map { (0.0001 * $0).magnitude } // tolerance
        } checkCover: { plane, ray, offset, tolerance in
            // Find the ray/plane intersection point, and move it along the plane normal so the distance from the point to the plane is offset.
            let point = ray * ((offset + Double(plane.d)) / plane.normal.dot(with: ray))
            return plane.hasPoint(point, tolerance: tolerance)
        }
    }

    func testProject() {
        forAll {
            Plane.nonZeroGen
            Vector3.normalized
            TinyGen<Double>.gaussianDoubles.map { 100.0 * $0 }
        } checkCover: { plane, ray, distance in
            let point = ray * distance
            return plane.project(point: point)
        }
    }

    func testIntersect3() {
        forAll {
            Plane.maybeZeroGen
            Plane.maybeZeroGen
            Plane.maybeZeroGen
        } checkCover: { (a: Plane, b: Plane, c: Plane) in
            a.intersect3(b: b, c: c).flatMap { Vector3($0) }
        }
    }

    func testIntersectsRay() {
        forAll {
            Plane.maybeZeroGen
            Vector3.normalized
            Vector3.normalized
        } checkCover: { plane, start, heading in
            plane.intersectsRay(from: start, dir: heading).flatMap { Vector3($0) }
        }
    }

    func testIntersectsSegment() {
        forAll {
            Plane.maybeZeroGen
            Vector3.normalized
            Vector3.normalized
        } checkCover: { plane, start, end in
            plane.intersectsSegment(from: start, to: end).flatMap { Vector3($0) }
        }
    }

    func testEquals() {
        forAll {
            Plane.maybeZeroGen
            Plane.maybeZeroGen
        } checkCover: {
            $0 == $1
        }

        forAll {
            Plane.maybeZeroGen
        } checkCover: {
            $0 == $0
        }
    }

    func testNotEquals() {
        forAll {
            Plane.maybeZeroGen
            Plane.maybeZeroGen
        } checkCover: {
            $0 != $1
        }

        forAll {
            Plane.maybeZeroGen
        } checkCover: {
            $0 != $0
        }
    }

    func testPlaneTimesTransform3D() {
        forAll {
            Plane.maybeZeroGen
            Transform3D.gaussianGen
        } checkCover: {
            $0 * $1
        }
    }
}
