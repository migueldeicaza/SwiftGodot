//
//  Basis.covers.swift
//  SwiftGodot
//
//  Created by Danny Youstra on 12/3/24.
//

@_spi(SwiftCovers) import SwiftGodot
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


extension Basis {
    
    public init(axis: Vector3, angle: Float) {
        // Rotation matrix from axis and angle, see https://en.wikipedia.org/wiki/Rotation_matrix#Rotation_matrix_from_axis_angle

        guard axis.isNormalized() else {
            self.init()
            return
        }

        let axisSq = axis * axis
        
        let cosine = cosf(angle)
        let sine = sinf(angle)
        let t = 1.0 - cosine
        
        // Diagonals
        let xx = axisSq.x + cosine * (1.0 - axisSq.x)
        let yy = axisSq.y + cosine * (1.0 - axisSq.y)
        let zz = axisSq.z + cosine * (1.0 - axisSq.z)
        
        // Off-diagonals
        var xyzt = axis.x * axis.y * t
        var zyxs = axis.z * sine
        let xy = xyzt - zyxs
        let yx = xyzt + zyxs
        
        xyzt = axis.x * axis.z * t
        zyxs = axis.y * sine
        let xz = xyzt + zyxs
        let zx = xyzt - zyxs
        
        xyzt = axis.y * axis.z * t
        zyxs = axis.x * sine
        let yz = xyzt - zyxs
        let zy = xyzt + zyxs
        
        // Column vectors to create Basis
        self.init(
            xAxis: Vector3(x: xx, y: xy, z: xz),
            yAxis: Vector3(x: yx, y: yy, z: yz),
            zAxis: Vector3(x: zx, y: zy, z: zz)
        )
    }

    public init(from: Basis) {
        self = from
    }

    public init(from: Quaternion) {
        let d = Float(from.lengthSquared())
        let s = 2 / d
        let xs = from.x * s, ys = from.y * s, zs = from.z * s
        let wx = from.w * xs, wy = from.w * ys, wz = from.w * zs
        let xx = from.x * xs, xy = from.x * ys, xz = from.x * zs
	let yy = from.y * ys, yz = from.y * zs, zz = from.z * zs
        self.init(
            xAxis: Vector3(x: 1 - (yy + zz), y: xy - wz, z: xz + wy),
            yAxis: Vector3(x: xy + wz, y: 1 - (xx + zz), z: yz - wx),
            zAxis: Vector3(x: xz - wy, y: yz + wx, z: 1 - (xx + yy))
        )
    }

    public func inverse() -> Basis {
        var cols = self

        func cofac(_ r1: Int64, _ c1: Int64, _ r2: Int64, _ c2: Int64) -> Float {
            return Float(cols[c1][r1]) * Float(cols[c2][r2]) - Float(cols[c2][r1]) * Float(cols[c1][r2])
        }

        let co = (cofac(1, 1, 2, 2), cofac(1, 2, 2, 0), cofac(1, 0, 2, 1))

        let det = Float(cols[0][0]) * co.0 + Float(cols[1][0]) * co.1 + Float(cols[2][0]) * co.2

        let s = 1 / det

        return Basis(
            xAxis: Vector3(x: co.0 * s, y: cofac(0, 2, 2, 1) * s, z: cofac(0, 1, 1, 2) * s),
            yAxis: Vector3(x: co.1 * s, y: cofac(0, 0, 2, 2) * s, z: cofac(0, 2, 1, 0) * s),
            zAxis: Vector3(x: co.2 * s, y: cofac(0, 1, 2, 0) * s, z: cofac(0, 0, 1, 1) * s)
        )
    }

    public func transposed() -> Basis {
        var answer = self
        swap(&answer.x.y, &answer.y.x)
        swap(&answer.x.z, &answer.z.x)
        swap(&answer.y.z, &answer.z.y)
        return answer
    }

    public func orthonormalized() -> Basis {
	// Gram-Schmidt Process

        var x = Vector3(x: self.x.x, y: self.y.x, z: self.z.x)
        var y = Vector3(x: self.x.y, y: self.y.y, z: self.z.y)
        var z = Vector3(x: self.x.z, y: self.y.z, z: self.z.z)

        x = x.normalized()
        y = y - x * x.dot(with: y)
        y = y.normalized()
        z = (z - x * x.dot(with: z)) - y * y.dot(with: z)
        z = z.normalized()

        return Basis(
            xAxis: Vector3(x: x.x, y: y.x, z: z.x),
            yAxis: Vector3(x: x.y, y: y.y, z: z.y),
            zAxis: Vector3(x: x.z, y: y.z, z: z.z)
        )
    }

    public func determinant() -> Double {
        var me = self
        let minor0 = Float(me[0][0]) * (Float(me[1][1]) * Float(me[2][2]) - Float(me[1][2]) * Float(me[2][1]))
        let minor1 = Float(me[0][1]) * (Float(me[1][0]) * Float(me[2][2]) - Float(me[1][2]) * Float(me[2][0]))
        let minor2 = Float(me[0][2]) * (Float(me[1][0]) * Float(me[2][1]) - Float(me[1][1]) * Float(me[2][0]))
        return Double(minor0 - minor1 + minor2)
    }

    public func rotated(axis: Vector3, angle: Double) -> Basis {
        return Basis(axis: axis, angle: Float(angle)) * self
    }

    public func scaled(scale: Vector3) -> Basis {
        var answer = self
        answer.x.x *= scale.x
        answer.x.y *= scale.x
        answer.x.z *= scale.x
        answer.y.x *= scale.y
        answer.y.y *= scale.y
        answer.y.z *= scale.y
        answer.z.x *= scale.z
        answer.z.y *= scale.z
        answer.z.z *= scale.z
        return answer
    }

    public func getScale() -> Vector3 {
        func axisScale(_ axis: KeyPath<Vector3, Float>) -> Float {
            func square(_ n: Float) -> Float { n * n }
            return (square(x[keyPath: axis]) + square(y[keyPath: axis]) + square(z[keyPath: axis])).squareRoot()
        }
        let detSign = Float(sign(determinant()))
        return Vector3(
            x: detSign * axisScale(\.x),
            y: detSign * axisScale(\.y),
            z: detSign * axisScale(\.z)
        )
    }

    // public func getEuler(order: Int64 = 2) -> Vector3
    // Omitted because it's six ugly cases and probably dominated by atan2 anyway.

    public func tdotx(with: Vector3) -> Double {
        return Double(x.x * with.x + y.x * with.y + z.x * with.z)
    }

    public func tdoty(with: Vector3) -> Double {
        return Double(x.y * with.x + y.y * with.y + z.y * with.z)
    }

    public func tdotz(with: Vector3) -> Double {
        return Double(x.z * with.x + y.z * with.y + z.z * with.z)
    }

    public func slerp(to: Basis, weight: Double) -> Basis {
        let qFrom = Quaternion(from: self)
        let qTo = Quaternion(from: to)
        var b = Basis(from: qFrom.slerp(to: qTo, weight: weight))
        b.x *= Double(Float(self.x.length()).lerp(to: Float(to.x.length()), weight: weight))
        b.y *= Double(Float(self.y.length()).lerp(to: Float(to.y.length()), weight: weight))
        b.z *= Double(Float(self.z.length()).lerp(to: Float(to.z.length()), weight: weight))
        return b
    }

    public func isConformal() -> Bool {
        let x = Vector3(x: self.x.x, y: self.y.x, z: self.z.x)
        let y = Vector3(x: self.x.y, y: self.y.y, z: self.z.y)
        let z = Vector3(x: self.x.z, y: self.y.z, z: self.z.z)
        let xLengthSquared = Float(x.lengthSquared())
        return (
            GD.isEqualApprox(xLengthSquared, Float(y.lengthSquared()))
            && GD.isEqualApprox(xLengthSquared, Float(z.lengthSquared()))
            && GD.isZeroApprox(Float(x.dot(with: y)))
            && GD.isZeroApprox(Float(x.dot(with: z)))
            && GD.isZeroApprox(Float(y.dot(with: z)))
        )
    }

}
