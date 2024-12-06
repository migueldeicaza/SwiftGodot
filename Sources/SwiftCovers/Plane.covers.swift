@_spi(SwiftCovers) import SwiftGodot

extension Plane {

    public init(from: Plane) {
        self = from
    }

    public init(normal: Vector3) {
        self.init(normal: normal, d: 0)
    }

    public init(normal: Vector3, point: Vector3) {
        self.init(normal: normal, d: Float(normal.dot(with: point)))
    }

    public init(point1: Vector3, point2: Vector3, point3: Vector3) {
        let normal = ((point1 - point3).cross(with: point1 - point2)).normalized();
        self.init(normal: normal, d: Float(normal.dot(with: point1)))
    }


    public init(a: Float, b: Float, c: Float, d: Float) {
        self.init(normal: Vector3(x: a, y: b, z: c), d: d)
    }


    public func normalized() -> Plane {
        let l = Float(normal.length())
        return l == 0 ? Plane() : Plane(
            normal: Vector3(x: normal.x / l, y: normal.y / l, z: normal.z / l),
            d: d / l
        )
    }

    public func getCenter() -> Vector3 {
        return normal * Double(d)
    }

    public func isEqualApprox(toPlane: Plane) -> Bool {
        return normal.isEqualApprox(to: toPlane.normal) && GD.isEqualApprox(a: Double(d), b: Double(toPlane.d))
    }

    public func isFinite() -> Bool {
        return normal.isFinite() && GD.isFinite(x: Double(d))
    }

    public func isPointOver(point: Vector3) -> Bool {
        return normal.dot(with: point) > Double(d)
    }

    public func distanceTo(point: Vector3) -> Double {
        return normal.dot(with: point) - Double(d)
    }

    public func hasPoint(_ point: Vector3, tolerance: Double) -> Bool {
        let dist = (normal.dot(with: point) - Double(d)).magnitude
        return dist <= tolerance
    }

    public func project(point: Vector3) -> Vector3 {
        return point - normal * distanceTo(point: point)
    }

    public func intersect3(b: Plane, c: Plane) -> Variant? {
        let a = self

        let normal0 = a.normal
        let normal1 = b.normal
        let normal2 = c.normal

        let denom = normal0.cross(with: normal1).dot(with: normal2)

        guard !GD.isZeroApprox(x: denom) else {
            return nil
        }

        let p0 = normal1.cross(with: normal2) * Double(a.d)
        let p1 = normal2.cross(with: normal0) * Double(b.d)
        let p2 = normal0.cross(with: normal1) * Double(c.d)
        return Variant((p0 + p1 + p2) / denom)
    }

    public func intersectsRay(from: Vector3, dir: Vector3) -> Variant? {
        let den = normal.dot(with: dir)

        guard !GD.isZeroApprox(x: den) else {
            return nil
        }

        // Godot does this in Float, so I do too.
        let dist = (Float(normal.dot(with: from)) - d) / Float(den)
        if dist > Float(CMP_EPSILON) {
            return nil
        }

        return Variant(from - dir * Double(dist))
    }

    public func intersectsSegment(from: Vector3, to: Vector3) -> Variant? {
        let segment = from - to
        let den = normal.dot(with: segment)

        guard !GD.isZeroApprox(x: den) else {
            return nil
        }

        // Godot does this in Float, so I do too.
        let dist = (Float(normal.dot(with: from)) - d) / Float(den)
        if dist < -Float(CMP_EPSILON) || dist > (1.0 + Float(CMP_EPSILON)) {
            return nil
        }

        return Variant(from - segment * Double(dist))
    }

    public static func == (lhs: Plane, rhs: Plane) -> Bool {
        return lhs.tuple == rhs.tuple
    }

    public static func != (lhs: Plane, rhs: Plane) -> Bool {
        return !(lhs.tuple == rhs.tuple)
    }

    public static func * (lhs: Plane, rhs: Transform3D) -> Plane {
        let inv = rhs.affineInverse()
        let basisTransposed = rhs.basis.transposed()
        let point = inv * (lhs.normal * Double(lhs.d))
        let normal = (basisTransposed * lhs.normal).normalized()
        let d = normal.dot(with: point)
        return Plane(normal: normal, d: Float(d))
    }
}
