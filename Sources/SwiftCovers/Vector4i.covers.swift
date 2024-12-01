@_spi(SwiftCovers) import SwiftGodot

extension Vector4i {

    public init(from: Vector4i) {
        self = from
    }

    public init(from: Vector4) {
        self.init(
            x: cCastToInt32(from.x),
            y: cCastToInt32(from.y),
            z: cCastToInt32(from.z),
            w: cCastToInt32(from.w)
        )
    }

    public func minAxisIndex() -> Int64 {
	var minIndex: Int64 = 0
        var minValue = Int64(x)
        var me = self
        for i: Int64 in 1 ..< 4 {
            if me[i] <= minValue {
                minIndex = i
                minValue = Int64(me[i])
            }
        }
        return minIndex
    }

    public func maxAxisIndex() -> Int64 {
	var maxIndex: Int64 = 0
        var maxValue = Int64(x)
        var me = self
        for i: Int64 in 1 ..< 4 {
            if me[i] > maxValue {
                maxIndex = i
                maxValue = Int64(me[i])
            }
        }
        return maxIndex
    }

    public func length() -> Double {
        return Double(lengthSquared()).squareRoot()
    }

    public func lengthSquared() -> Int64 {
        let x = Int64(x)
        let y = Int64(y)
        let z = Int64(z)
        let w = Int64(w)
        return x &* x &+ y &* y &+ z &* z &+ w &* w
    }

    public func sign() -> Vector4i {
        return Vector4i(x: x.signum(), y: y.signum(), z: z.signum(), w: w.signum())
    }

    public func abs() -> Vector4i {
        return Vector4i(
            x: Int32(truncatingIfNeeded: x.magnitude),
            y: Int32(truncatingIfNeeded: y.magnitude),
            z: Int32(truncatingIfNeeded: z.magnitude),
            w: Int32(truncatingIfNeeded: w.magnitude)
        )
    }

    public func clamp(min: Vector4i, max: Vector4i) -> Vector4i {
        return Vector4i(
            x: x.clamped(min: min.x, max: max.x),
            y: y.clamped(min: min.y, max: max.y),
            z: z.clamped(min: min.z, max: max.z),
            w: w.clamped(min: min.w, max: max.w)
        )
    }

    public func clampi(min: Int64, max: Int64) -> Vector4i {
        let min = Int32(truncatingIfNeeded: min)
        let max = Int32(truncatingIfNeeded: max)
        return Vector4i(
            x: x.clamped(min: min, max: max),
            y: y.clamped(min: min, max: max),
            z: z.clamped(min: min, max: max),
            w: w.clamped(min: min, max: max)
        )
    }

    public func snappedi(step: Int64) -> Vector4i {
        let step = Double(Int32(truncatingIfNeeded: step))
        return Vector4i(
            x: cCastToInt32(Double(x).snapped(step: step)),
            y: cCastToInt32(Double(y).snapped(step: step)),
            z: cCastToInt32(Double(z).snapped(step: step)),
            w: cCastToInt32(Double(w).snapped(step: step))
        )
    }

    public func min(with: Vector4i) -> Vector4i {
        return Vector4i(
            x: Swift.min(x, with.x),
            y: Swift.min(y, with.y),
            z: Swift.min(z, with.z),
            w: Swift.min(w, with.w)
        )
    }

    public func mini(with: Int64) -> Vector4i {
        let i = Int32(truncatingIfNeeded: with)
        return Vector4i(
            x: Swift.min(x, i),
            y: Swift.min(y, i),
            z: Swift.min(z, i),
            w: Swift.min(w, i)
        )
    }

    public func max(with: Vector4i) -> Vector4i {
        return Vector4i(
            x: Swift.max(x, with.x),
            y: Swift.max(y, with.y),
            z: Swift.max(z, with.z),
            w: Swift.max(w, with.w)
        )
    }

    public func maxi(with: Int64) -> Vector4i {
        let i = Int32(truncatingIfNeeded: with)
        return Vector4i(
            x: Swift.max(x, i),
            y: Swift.max(y, i),
            z: Swift.max(z, i),
            w: Swift.max(w, i)
        )
    }

    public func distanceTo(_ to: Vector4i) -> Double {
        return (to - self).length()
    }

    public func distanceSquaredTo(_ to: Vector4i) -> Int64 {
        return (to - self).lengthSquared()
    }

    public subscript(index: Int64) -> Int64 {
        mutating get {
            return Int64(SIMD4(x, y, z, w)[Int(index)])
        }
        set {
            var simd = SIMD4(x, y, z, w)
            simd[Int(index)] = Int32(truncatingIfNeeded: newValue)
            (x, y, z, w) = (simd.x, simd.y, simd.z, simd.w)
        }
    }

    public static func * (lhs: Vector4i, rhs: Int64) -> Vector4i {
        let f = Int32(truncatingIfNeeded: rhs)
        return Vector4i(
            x: lhs.x &* f,
            y: lhs.y &* f,
            z: lhs.z &* f,
            w: lhs.w &* f
        )
    }

    public static func / (lhs: Vector4i, rhs: Int64) -> Vector4i {
        let rhs = Int32(truncatingIfNeeded: rhs)
        return Vector4i(
            x: cDivide(numerator: lhs.x, denominator: rhs),
            y: cDivide(numerator: lhs.y, denominator: rhs),
            z: cDivide(numerator: lhs.z, denominator: rhs),
            w: cDivide(numerator: lhs.w, denominator: rhs)
        )
    }

    public static func % (lhs: Vector4i, rhs: Int64) -> Vector4i {
        let rhs = Int32(truncatingIfNeeded: rhs)
        return Vector4i(
            x: cRemainder(numerator: lhs.x, denominator: rhs),
            y: cRemainder(numerator: lhs.y, denominator: rhs),
            z: cRemainder(numerator: lhs.z, denominator: rhs),
            w: cRemainder(numerator: lhs.w, denominator: rhs)
        )
    }

    public static func * (lhs: Vector4i, rhs: Double) -> Vector4 {
        let rhs = Float(rhs)
        return Vector4(
            x: Float(lhs.x) * rhs,
            y: Float(lhs.y) * rhs,
            z: Float(lhs.z) * rhs,
            w: Float(lhs.w) * rhs
        )
    }

    public static func / (lhs: Vector4i, rhs: Double) -> Vector4 {
        let rhs = Float(rhs)
        return Vector4(
            x: Float(lhs.x) / rhs,
            y: Float(lhs.y) / rhs,
            z: Float(lhs.z) / rhs,
            w: Float(lhs.w) / rhs
        )
    }

    public static func == (lhs: Vector4i, rhs: Vector4i) -> Bool {
        return lhs.tuple == rhs.tuple
    }

    public static func != (lhs: Vector4i, rhs: Vector4i) -> Bool {
        return !(lhs.tuple == rhs.tuple)
    }

    public static func < (lhs: Vector4i, rhs: Vector4i) -> Bool {
        return lhs.tuple < rhs.tuple
    }

    public static func <= (lhs: Vector4i, rhs: Vector4i) -> Bool {
        return lhs.tuple <= rhs.tuple
    }

    public static func > (lhs: Vector4i, rhs: Vector4i) -> Bool {
        return lhs.tuple > rhs.tuple
    }

    public static func >= (lhs: Vector4i, rhs: Vector4i) -> Bool {
        return lhs.tuple >= rhs.tuple
    }

    public static func + (lhs: Vector4i, rhs: Vector4i) -> Vector4i {
        return Vector4i(
            x: lhs.x &+ rhs.x,
            y: lhs.y &+ rhs.y,
            z: lhs.z &+ rhs.z,
            w: lhs.w &+ rhs.w
        )
    }

    public static func - (lhs: Vector4i, rhs: Vector4i) -> Vector4i {
        return Vector4i(
            x: lhs.x &- rhs.x,
            y: lhs.y &- rhs.y,
            z: lhs.z &- rhs.z,
            w: lhs.w &- rhs.w
        )
    }

    public static func * (lhs: Vector4i, rhs: Vector4i) -> Vector4i {
        return Vector4i(
            x: lhs.x &* rhs.x,
            y: lhs.y &* rhs.y,
            z: lhs.z &* rhs.z,
            w: lhs.w &* rhs.w
        )
    }

    public static func / (lhs: Vector4i, rhs: Vector4i) -> Vector4i {
        return Vector4i(
            x: cDivide(numerator: lhs.x, denominator: rhs.x),
            y: cDivide(numerator: lhs.y, denominator: rhs.y),
            z: cDivide(numerator: lhs.z, denominator: rhs.z),
            w: cDivide(numerator: lhs.w, denominator: rhs.w)
        )
    }

    public static func % (lhs: Vector4i, rhs: Vector4i) -> Vector4i {
        return Vector4i(
            x: cRemainder(numerator: lhs.x, denominator: rhs.x),
            y: cRemainder(numerator: lhs.y, denominator: rhs.y),
            z: cRemainder(numerator: lhs.z, denominator: rhs.z),
            w: cRemainder(numerator: lhs.w, denominator: rhs.w)
        )
    }
}
