@_spi(SwiftCovers) import SwiftGodot

extension Vector3i {

    public init(from: Vector3i) {
        self = from
    }

    public init(from: Vector3) {
        self.init(
            x: cCastToInt32(from.x),
            y: cCastToInt32(from.y),
            z: cCastToInt32(from.z)
        )
    }

    public func minAxisIndex() -> Int64 {
        return (x < y ? (x < z ? Axis.x : Axis.z) : (y < z ? Axis.y : Axis.z)).rawValue
    }

    public func maxAxisIndex() -> Int64 {
        return (x < y ? (y < z ? Axis.z : Axis.y) : (x < z ? Axis.z : Axis.x)).rawValue
    }

    public func distanceTo(_ to: Vector3i) -> Double {
        return (to - self).length()
    }

    public func distanceSquaredTo(_ to: Vector3i) -> Int64 {
        return (to - self).lengthSquared()
    }

    public func length() -> Double {
        return Double(lengthSquared()).squareRoot()
    }

    public func lengthSquared() -> Int64 {
        let x = Int64(x)
        let y = Int64(y)
        let z = Int64(z)
        return x &* x &+ y &* y &+ z &* z
    }

    public func sign() -> Vector3i {
        return Vector3i(x: x.signum(), y: y.signum(), z: z.signum())
    }

    public func abs() -> Vector3i {
        return Vector3i(
            x: Int32(truncatingIfNeeded: x.magnitude),
            y: Int32(truncatingIfNeeded: y.magnitude),
            z: Int32(truncatingIfNeeded: z.magnitude)
        )
    }

    public func clamp(min: Vector3i, max: Vector3i) -> Vector3i {
        return Vector3i(
            x: x.clamped(min: min.x, max: max.x),
            y: y.clamped(min: min.y, max: max.y),
            z: z.clamped(min: min.z, max: max.z)
        )
    }

    public func clampi(min: Int64, max: Int64) -> Vector3i {
        let min = Int32(truncatingIfNeeded: min)
        let max = Int32(truncatingIfNeeded: max)
        return Vector3i(
            x: x.clamped(min: min, max: max),
            y: y.clamped(min: min, max: max),
            z: z.clamped(min: min, max: max)
        )
    }

    public func snappedi(step: Int64) -> Vector3i {
        let step = Double(Int32(truncatingIfNeeded: step))
        return Vector3i(
            x: cCastToInt32(Double(x).snapped(step: step)),
            y: cCastToInt32(Double(y).snapped(step: step)),
            z: cCastToInt32(Double(z).snapped(step: step))
        )
    }

    public func min(with: Vector3i) -> Vector3i {
        return Vector3i(
            x: Swift.min(x, with.x),
            y: Swift.min(y, with.y),
            z: Swift.min(z, with.z)
        )
    }

    public func mini(with: Int64) -> Vector3i {
        let i = Int32(truncatingIfNeeded: with)
        return Vector3i(
            x: Swift.min(x, i),
            y: Swift.min(y, i),
            z: Swift.min(z, i)
        )
    }

    public func max(with: Vector3i) -> Vector3i {
        return Vector3i(
            x: Swift.max(x, with.x),
            y: Swift.max(y, with.y),
            z: Swift.max(z, with.z)
        )
    }

    public func maxi(with: Int64) -> Vector3i {
        let i = Int32(truncatingIfNeeded: with)
        return Vector3i(
            x: Swift.max(x, i),
            y: Swift.max(y, i),
            z: Swift.max(z, i)
        )
    }

    public subscript(index: Int64) -> Int64 {
        get {
            return Int64(SIMD3(x, y, z)[Int(index)])
        }
        set {
            var simd = SIMD3(x, y, z)
            simd[Int(index)] = Int32(truncatingIfNeeded: newValue)
            (x, y, z) = (simd.x, simd.y, simd.z)
        }
    }

    public static func * (lhs: Vector3i, rhs: Int64) -> Vector3i {
        let f = Int32(truncatingIfNeeded: rhs)
        return Vector3i(
            x: lhs.x &* f,
            y: lhs.y &* f,
            z: lhs.z &* f
        )
    }

    public static func / (lhs: Vector3i, rhs: Int64) -> Vector3i {
        let rhs = Int32(truncatingIfNeeded: rhs)
        return Self(
            x: cDivide(numerator: lhs.x, denominator: rhs),
            y: cDivide(numerator: lhs.y, denominator: rhs),
            z: cDivide(numerator: lhs.z, denominator: rhs)
        )
    }

    public static func % (lhs: Vector3i, rhs: Int64) -> Vector3i {
        let rhs = Int32(truncatingIfNeeded: rhs)
        return Self(
            x: cRemainder(numerator: lhs.x, denominator: rhs),
            y: cRemainder(numerator: lhs.y, denominator: rhs),
            z: cRemainder(numerator: lhs.z, denominator: rhs)
        )
    }

    public static func * (lhs: Vector3i, rhs: Double) -> Vector3 {
        let rhs = Float(rhs)
        return Vector3(
            x: Float(lhs.x) * rhs,
            y: Float(lhs.y) * rhs,
            z: Float(lhs.z) * rhs
        )
    }

    public static func / (lhs: Vector3i, rhs: Double) -> Vector3 {
        let rhs = Float(rhs)
        return Vector3(
            x: Float(lhs.x) / rhs,
            y: Float(lhs.y) / rhs,
            z: Float(lhs.z) / rhs
        )
    }

    public static func == (lhs: Vector3i, rhs: Vector3i) -> Bool {
        return lhs.tuple == rhs.tuple
    }

    public static func != (lhs: Vector3i, rhs: Vector3i) -> Bool {
        return !(lhs == rhs)
    }

    public static func < (lhs: Vector3i, rhs: Vector3i) -> Bool {
        return lhs.tuple < rhs.tuple
    }

    public static func <= (lhs: Vector3i, rhs: Vector3i) -> Bool {
        return lhs.tuple <= rhs.tuple
    }

    public static func > (lhs: Vector3i, rhs: Vector3i) -> Bool {
        return lhs.tuple > rhs.tuple
    }

    public static func >= (lhs: Vector3i, rhs: Vector3i) -> Bool {
        return lhs.tuple >= rhs.tuple
    }

    public static func + (lhs: Vector3i, rhs: Vector3i) -> Vector3i {
        return Vector3i(
            x: lhs.x &+ rhs.x,
            y: lhs.y &+ rhs.y,
            z: lhs.z &+ rhs.z
        )
    }

    public static func - (lhs: Vector3i, rhs: Vector3i) -> Vector3i {
        return Vector3i(
            x: lhs.x &- rhs.x,
            y: lhs.y &- rhs.y,
            z: lhs.z &- rhs.z
        )
    }

    public static func * (lhs: Vector3i, rhs: Vector3i) -> Vector3i {
        return Vector3i(
            x: lhs.x &* rhs.x,
            y: lhs.y &* rhs.y,
            z: lhs.z &* rhs.z
        )
    }

    public static func / (lhs: Vector3i, rhs: Vector3i) -> Vector3i {
        return Vector3i(
            x: cDivide(numerator: lhs.x, denominator: rhs.x),
            y: cDivide(numerator: lhs.y, denominator: rhs.y),
            z: cDivide(numerator: lhs.z, denominator: rhs.z)
        )
    }

    public static func % (lhs: Vector3i, rhs: Vector3i) -> Vector3i {
        return Vector3i(
            x: cRemainder(numerator: lhs.x, denominator: rhs.x),
            y: cRemainder(numerator: lhs.y, denominator: rhs.y),
            z: cRemainder(numerator: lhs.z, denominator: rhs.z)
        )
    }

}
