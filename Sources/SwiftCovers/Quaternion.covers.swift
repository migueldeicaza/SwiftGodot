#if canImport(Darwin)
import Darwin
#elseif os(Windows)
import ucrt
import WinSDK
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#else
#error("Unable to identify your C library.")
#endif

@_spi(SwiftCovers) import SwiftGodot

extension Quaternion {

    public init(from: Quaternion) {
        self = from
    }

    public init(from: Basis) {
        var m = from
        let trace = Float(m[0][0]) + Float(m[1][1]) + Float(m[2][2])
        var v = SIMD4<Float>()
        if trace > 0 {
            var s = (trace + 1.0).squareRoot()
            v[3] = s * 0.5
            s = 0.5 / s
            v[0] = Float(m[1][2] - m[2][1]) * s
            v[1] = Float(m[2][0] - m[0][2]) * s
            v[2] = Float(m[0][1] - m[1][0]) * s
        } else {
            let i: Int64 = m[0][0] < m[1][1] ? (m[1][1] < m[2][2] ? 2 : 1) : (m[0][0] < m[2][2] ? 2 : 0)
            let j: Int64 = (i + 1) % 3
            let k: Int64 = (i + 2) % 3

            var s = (Float(m[i][i]) - Float(m[j][j]) - Float(m[k][k]) + 1.0).squareRoot()
            v[Int(truncatingIfNeeded: i)] = s * 0.5
            s = 0.5 / s

            v[3] = (Float(m[j][k]) - Float(m[k][j])) * s
            v[Int(truncatingIfNeeded: j)] = (Float(m[i][j]) + Float(m[j][i])) * s
            v[Int(truncatingIfNeeded: k)] = (Float(m[i][k]) + Float(m[k][i])) * s
        }
        self.init(x: v[0], y: v[1], z: v[2], w: v[3])
    }

    public init(axis: Vector3, angle: Float) {
        let d = Float(axis.length())
        if d == 0 {
            self.init(x: 0, y: 0, z: 0, w: 0)
        } else {
            let sinAngle = sin(angle * 0.5)
            let cosAngle = cos(angle * 0.5)
            let s = sinAngle / d
            self.init(x: axis.x * s, y: axis.y * s, z: axis.z * s, w: cosAngle)
        }
    }

    public init(arcFrom: Vector3, arcTo: Vector3) {
        let c = arcFrom.cross(with: arcTo)
        let d = Float(arcFrom.dot(with: arcTo))

        if d < -1.0 + Float(CMP_EPSILON) {
            self.init(x: 0, y: 1, z: 0, w: 0)
        } else {
            let s = ((1.0 + d) * 2.0).squareRoot()
            let rs = 1 / s
            self.init(x: c.x * rs, y: c.y * rs, z: c.z * rs, w: s * 0.5)
        }
    }

    public func length() -> Double {
        return Double(Float(lengthSquared()).squareRoot())
    }

    public func lengthSquared() -> Double {
        return self.dot(with: self)
    }

    public func normalized() -> Quaternion {
        return self / length()
    }

    public func isNormalized() -> Bool {
        return GD.isEqualApprox(Float(lengthSquared()), 1, tolerance: Float(UNIT_EPSILON))
    }

    public func isEqualApprox(to: Quaternion) -> Bool {
        return GD.isEqualApprox(x, to.x) && GD.isEqualApprox(y, to.y) && GD.isEqualApprox(z, to.z) && GD.isEqualApprox(w, to.w)
    }

    public func isFinite() -> Bool {
        return x.isFinite && y.isFinite && z.isFinite && w.isFinite
    }

    public func inverse() -> Quaternion {
        return Quaternion(x: -x, y: -y, z: -z, w: w)
    }

    public func log() -> Quaternion {
        let v = getAxis() * getAngle()
        return Quaternion(x: v.x, y: v.y, z: v.z, w: 0)
    }

    public func exp() -> Quaternion {
        var v = Vector3(x: x, y: y, z: z)
        let theta = Float(v.length())
        v = v.normalized()
        if theta < Float(CMP_EPSILON) || !v.isNormalized() {
            return Quaternion(x: 0, y: 0, z: 0, w: 1)
        } else {
            return Quaternion(axis: v, angle: theta)
        }
    }

    public func angleTo(_ to: Quaternion) -> Double {
        let d = Float(self.dot(with: to))
        let u = d * d * 2 - 1
        return Double(GD.acosf(u))
    }

    public func dot(with: Quaternion) -> Double {
        return Double((self.simd * with.simd).sum())
    }

    public func slerp(to: Quaternion, weight: Double) -> Quaternion {
        // calc cosine
        var cosom = Float(self.dot(with: to))
        let to1: Quaternion
        // adjust signs (if necessary)
        if cosom < 0 {
            cosom = -cosom
            to1 = -to
        } else {
            to1 = to
        }

        let scale0, scale1: Float
        let weight = Float(weight)

        // calculate coefficients
        if 1 - cosom > Float(CMP_EPSILON) {
            // standard case (slerp)
            let omega = GD.acosf(cosom)
            let sinom = sinf(omega)
            scale0 = Float(sin((1 - Double(weight)) * Double(omega)) / Double(sinom))
            scale1 = sinf(weight * omega) / sinom
        } else {
            // "from" and "to" quaternions are very close
            //  ... so we can do a linear interpolation
            scale0 = 1 - weight
            scale1 = weight
        }

	// calculate final values
        return Quaternion(
            x: scale0 * x + scale1 * to1.x,
            y: scale0 * y + scale1 * to1.y,
            z: scale0 * z + scale1 * to1.z,
            w: scale0 * w + scale1 * to1.w
        )
    }

    public func slerpni(to: Quaternion, weight: Double) -> Quaternion {
        let dot = Float(self.dot(with: to))

        if dot.magnitude > 0.9999 {
            return self
        }

        let weight = Float(weight)
        let theta = GD.acosf(dot)
        let sinT = 1 / sinf(theta)
        let newFactor = sinf(weight * theta) * sinT
        let invFactor = sinf((1 - weight) * theta) * sinT

        return Quaternion(
            x: invFactor * self.x + newFactor * to.x,
            y: invFactor * self.y + newFactor * to.y,
            z: invFactor * self.z + newFactor * to.z,
            w: invFactor * self.w + newFactor * to.w
        )
    }

    public func sphericalCubicInterpolate(b: Quaternion, preA: Quaternion, postB: Quaternion, weight: Double) -> Quaternion {
        // Align flip phases.
        let qFrom = Basis(from: self).getRotationQuaternion()

        var qPre = Basis(from: preA).getRotationQuaternion()
        var qTo = Basis(from: b).getRotationQuaternion()
        var qPost = Basis(from: postB).getRotationQuaternion()

        // Flip quaternions to shortest path if necessary.
        let flip1 = qFrom.dot(with: qPre).sign == .minus
        if flip1 { qPre = -qPre }
        let flip2 = qFrom.dot(with: qTo).sign == .minus
        if flip2 { qTo = -qTo }
        let flip3 = flip2 ? qTo.dot(with: qPost) <= 0 : qTo.dot(with: qPost).sign == .minus
        if flip3 { qPost = -qPost }

        let fWeight = Float(weight)

        // Calc by Expmap in from_q space.
        let q1: Quaternion
        do {
            let lnFrom = Quaternion(x: 0, y: 0, z: 0, w: 0)
            let qFromInverse = qFrom.inverse()
            let lnTo = (qFromInverse * qTo).log()
            let lnPre = (qFromInverse * qPre).log()
            let lnPost = (qFromInverse * qPost).log()
            let ln = Quaternion(
                x:GD.cubicInterpolate(from: lnFrom.x, to: lnTo.x, pre: lnPre.x, post: lnPost.x, weight: fWeight),
                y:GD.cubicInterpolate(from: lnFrom.y, to: lnTo.y, pre: lnPre.y, post: lnPost.y, weight: fWeight),
                z:GD.cubicInterpolate(from: lnFrom.z, to: lnTo.z, pre: lnPre.z, post: lnPost.z, weight: fWeight),
                w: 0
            )
            q1 = qFrom * ln.exp()
        }

        // Calc by Expmap in to_q space.
        let q2: Quaternion
        do {
            let qToInverse = qTo.inverse()
            let lnFrom = (qToInverse * qFrom).log()
            let lnTo = Quaternion(x: 0, y: 0, z: 0, w: 0)
            let lnPre = (qToInverse * qPre).log()
            let lnPost = (qToInverse * qPost).log()
            let ln = Quaternion(
                x: GD.cubicInterpolate(from: lnFrom.x, to: lnTo.x, pre: lnPre.x, post: lnPost.x, weight: fWeight),
                y: GD.cubicInterpolate(from: lnFrom.y, to: lnTo.y, pre: lnPre.y, post: lnPost.y, weight: fWeight),
                z: GD.cubicInterpolate(from: lnFrom.z, to: lnTo.z, pre: lnPre.z, post: lnPost.z, weight: fWeight),
                w: 0
            )
            q2 = qTo * ln.exp()
        }

        return q1.slerp(to: q2, weight: weight)
    }

    public func sphericalCubicInterpolateInTime(b: Quaternion, preA: Quaternion, postB: Quaternion, weight: Double, bT: Double, preAT: Double, postBT: Double) -> Quaternion {
        // Align flip phases.
        let qFrom = Basis(from: self).getRotationQuaternion()
        var qPre = Basis(from: preA).getRotationQuaternion()
        var qTo = Basis(from: b).getRotationQuaternion()
        var qPost = Basis(from: postB).getRotationQuaternion()

        // Flip quaternions to shortest path if necessary.
        let flip1 = qFrom.dot(with: qPre).sign == .minus
        if flip1 { qPre = -qPre }
        let flip2 = qFrom.dot(with: qTo).sign == .minus
        if flip2 { qTo = -qTo }
        let flip3 = flip2 ? qTo.dot(with: qPost) <= 0 : qTo.dot(with: qPost).sign == .minus
        if flip3 { qPost = -qPost }

        let fWeight = Float(weight)
        let toT = Float(bT)
        let preT = Float(preAT)
        let postT = Float(postBT)

	// Calc by Expmap in from_q space.
        let q1: Quaternion
        do {
            let lnFrom = Quaternion(x: 0, y: 0, z: 0, w: 0)
            let qFromInverse = qFrom.inverse()
            let lnTo = (qFromInverse * qTo).log()
            let lnPre = (qFromInverse * qPre).log()
            let lnPost = (qFromInverse * qPost).log()
            let ln = Quaternion(
                x: GD.cubicInterpolateInTime(from: lnFrom.x, to: lnTo.x, pre: lnPre.x, post: lnPost.x, weight: fWeight, toT: toT, preT: preT, postT: postT),
                y: GD.cubicInterpolateInTime(from: lnFrom.y, to: lnTo.y, pre: lnPre.y, post: lnPost.y, weight: fWeight, toT: toT, preT: preT, postT: postT),
                z: GD.cubicInterpolateInTime(from: lnFrom.z, to: lnTo.z, pre: lnPre.z, post: lnPost.z, weight: fWeight, toT: toT, preT: preT, postT: postT),
                w: 0
            )
            q1 = qFrom * ln.exp()
        }

        // Calc by Expmap in to_q space.
        let q2: Quaternion
        do {
            let qToInverse = qTo.inverse()
            let lnFrom = (qToInverse * qFrom).log()
            let lnTo = Quaternion(x: 0, y: 0, z: 0, w: 0)
            let lnPre = (qToInverse * qPre).log()
            let lnPost = (qToInverse * qPost).log()
            let ln = Quaternion(
                x: GD.cubicInterpolateInTime(from: lnFrom.x, to: lnTo.x, pre: lnPre.x, post: lnPost.x, weight: fWeight, toT: toT, preT: preT, postT: postT),
                y: GD.cubicInterpolateInTime(from: lnFrom.y, to: lnTo.y, pre: lnPre.y, post: lnPost.y, weight: fWeight, toT: toT, preT: preT, postT: postT),
                z: GD.cubicInterpolateInTime(from: lnFrom.z, to: lnTo.z, pre: lnPre.z, post: lnPost.z, weight: fWeight, toT: toT, preT: preT, postT: postT),
                w: 0
            )
            q2 = qTo * ln.exp()
        }

        return q1.slerp(to: q2, weight: weight)
    }

    public func getEuler(order: Int64 = 2) -> Vector3 {
        return Basis(from: self).getEuler(order: order)
    }

    public static func fromEuler(_ euler: Vector3) -> Quaternion {
        // R = Y(a1).X(a2).Z(a3) convention for Euler angles.
        // Conversion to quaternion as listed in https://ntrs.nasa.gov/archive/nasa/casi.ntrs.nasa.gov/19770024290.pdf (page A-6)
        // a3 is the angle of the first rotation, following the notation in this reference.

        let half_a1 = euler.y * 0.5
        let half_a2 = euler.x * 0.5
        let half_a3 = euler.z * 0.5

        let cos_a1 = cosf(half_a1)
        let sin_a1 = sinf(half_a1)
        let cos_a2 = cosf(half_a2)
        let sin_a2 = sinf(half_a2)
        let cos_a3 = cosf(half_a3)
        let sin_a3 = sinf(half_a3)

        return Quaternion(
            x: sin_a1 * cos_a2 * sin_a3 + cos_a1 * sin_a2 * cos_a3,
            y: sin_a1 * cos_a2 * cos_a3 - cos_a1 * sin_a2 * sin_a3,
            z: -sin_a1 * sin_a2 * cos_a3 + cos_a1 * cos_a2 * sin_a3,
            w: sin_a1 * sin_a2 * sin_a3 + cos_a1 * cos_a2 * cos_a3
        )
    }

    public func getAxis() -> Vector3 {
        if w.magnitude > 1 - Float(CMP_EPSILON) {
            return Vector3(x: x, y: y, z: z)
        }

        let r = 1 / (1 - w * w).squareRoot()
        return Vector3(x: x * r, y: y * r, z: z * r)
    }

    public func getAngle() -> Double {
	return Double(2 * GD.acosf(w))
    }

    public subscript(index: Int64) -> Double {
        mutating get {
            return Double(simd[Int(index)])
        }
        set {
            var simd = simd
            simd[Int(index)] = Float(newValue)
            (x, y, z, w) = (simd.x, simd.y, simd.z, simd.w)
        }
    }

    public static func * (lhs: Quaternion, rhs: Int64) -> Quaternion {
        return lhs * Float(rhs)
    }

    public static func / (lhs: Quaternion, rhs: Int64) -> Quaternion {
        return lhs * (1 / Float(rhs))
    }

    public static func * (lhs: Quaternion, rhs: Double) -> Quaternion {
        return lhs * Float(rhs)
    }

    public static func / (lhs: Quaternion, rhs: Double) -> Quaternion {
        return lhs * (1 / Float(rhs))
    }

    public static func * (lhs: Quaternion, rhs: Vector3) -> Vector3 {
        let u = Vector3(x: lhs.x, y: lhs.y, z: lhs.z)
        let uv = u.cross(with: rhs)
        return rhs + ((uv * Double(lhs.w)) + u.cross(with: uv)) * 2
    }

    public static func == (lhs: Quaternion, rhs: Quaternion) -> Bool {
        return lhs.tuple == rhs.tuple
    }

    public static func != (lhs: Quaternion, rhs: Quaternion) -> Bool {
        return !(lhs.tuple == rhs.tuple)
    }

    public static func + (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
        return Quaternion(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z, w: lhs.w + rhs.w)
    }

    public static func - (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
        return Quaternion(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z, w: lhs.w - rhs.w)
    }

    public static func * (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
        let xx = lhs.w * rhs.x + lhs.x * rhs.w + lhs.y * rhs.z - lhs.z * rhs.y
        let yy = lhs.w * rhs.y + lhs.y * rhs.w + lhs.z * rhs.x - lhs.x * rhs.z
        let zz = lhs.w * rhs.z + lhs.z * rhs.w + lhs.x * rhs.y - lhs.y * rhs.x
        let ww = lhs.w * rhs.w - lhs.x * rhs.x - lhs.y * rhs.y - lhs.z * rhs.z
        return Quaternion(x: xx, y: yy, z: zz, w: ww)
    }
}
