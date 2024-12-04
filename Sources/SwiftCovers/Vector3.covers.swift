//
//  Vector3.covers.swift
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

extension Vector3 {
    
    public func cross(with: Vector3) -> Vector3 {
        return Vector3(
            x: (y * with.z) - (z * with.y),
            y: (z * with.x) - (x * with.z),
            z: (x * with.y) - (y * with.x)
        )
    }
    
    public func dot(with: Vector3) -> Double {
        return Double(x * with.x + y * with.y + z * with.z)
    }
    
    public func abs() -> Vector3 {
        return Vector3(
            x: Swift.abs(x),
            y: Swift.abs(y),
            z: Swift.abs(z)
        )
    }
    
    public func sign() -> Vector3 {
        return Vector3(
            x: SwiftGodot.sign(x),
            y: SwiftGodot.sign(y),
            z: SwiftGodot.sign(z)
        )
    }
    
    public func floor() -> Vector3 {
        return Vector3(
            x: _math.floor(x),
            y: _math.floor(y),
            z: _math.floor(z)
        )
    }
    
    public func ceil() -> Vector3 {
        return Vector3(
            x: _math.ceil(x),
            y: _math.ceil(y),
            z: _math.ceil(z)
        )
    }
    
    public func round() -> Vector3 {
        return Vector3(
            x: _math.round(x),
            y: _math.round(y),
            z: _math.round(z)
        )
    }
    
   public func slerp(to: Vector3, weight: Double) -> Vector3 {
        // This method seems more complicated than it really is, since we write out
        // the internals of some methods for efficiency (mainly, checking length).
        let startLengthSq = lengthSquared()
        let endLengthSq = to.lengthSquared()
        
        // Zero length vectors have no angle, so the best we can do is either lerp or throw an error.
        if startLengthSq == 0.0 || endLengthSq == 0.0 {
            return lerp(to: to, weight: weight)
        }
        
        var axis = cross(with: to)
        let axisLengthSq = axis.lengthSquared()
        
        // Colinear vectors have no rotation axis or angle between them, so the best we can do is lerp.
        if axisLengthSq == 0.0 {
            return lerp(to: to, weight: weight)
        }
        
        axis /= sqrt(axisLengthSq)
        let startLength = sqrt(startLengthSq)
        let resultLength = startLength.lerp(to: sqrt(endLengthSq), weight: weight)
        let angle = angleTo(to)
        
        return rotated(axis: axis, angle: angle * weight) * (resultLength / startLength)
    }
    
    public func rotated(axis: Vector3, angle: Double) -> Vector3 {
        // basis subscript getter is mutating by default
        var basisV = Basis(axis: axis, angle: Float(angle))
        return Vector3(x: Float(basisV[0].dot(with: self)),
                       y: Float(basisV[1].dot(with: self)),
                       z: Float(basisV[2].dot(with: self))
        )
    }
    
    public func clamp(min: Vector3, max: Vector3) -> Vector3 {
        return Vector3(x: x.clamped(min: min.x, max: max.x),
                       y: y.clamped(min: min.y, max: max.y),
                       z: z.clamped(min: min.z, max: max.z)
        )
    }
    
    public func clampf(min: Double, max: Double) -> Vector3 {
        return Vector3(x: x.clamped(min: Float(min), max: Float(max)),
                       y: y.clamped(min: Float(min), max: Float(max)),
                       z: z.clamped(min: Float(min), max: Float(max))
        )
    }
    
    public func snappedf(step: Double) -> Vector3 {
        return Vector3(x: x.snapped(step: Float(step)),
                       y: y.snapped(step: Float(step)),
                       z: z.snapped(step: Float(step))
        )
    }
    
    public func limitLength(_ length: Double = 1.0) -> Vector3 {
        let beforeLen = self.length()
        var result = self
        if (beforeLen > 0 && length < beforeLen) {
            result = result / beforeLen
            result = result * length
        }
        return result
    }
    
    public func moveToward(to: Vector3, delta: Double) -> Vector3 {
        let result = to - self
        let newLen = result.length()
        return newLen <= delta || newLen < CMP_EPSILON ? to : self + result / newLen * delta
    }
    
    public func slide(n: Vector3) -> Vector3 {
        return self - n * self.dot(with: n)
    }
    
    public func bounce(n: Vector3) -> Vector3 {
        return -reflect(n: n)
    }
    
    public func reflect(n: Vector3) -> Vector3 {
        /// Reflection requires a scale by 2, but Float * Vector3 is not overloaded
        return Vector3(x: 2, y: 2, z: 2) * n * self.dot(with: n) - self
    }
    
    public func octahedronEncode() -> Vector2 {
        let n = self / Double((Swift.abs(x) + Swift.abs(y) + Swift.abs(z)))
        var o = Vector2()
        
        if n.z >= 0.0 {
            o.x = n.x
            o.y = n.y
        } else {
            o.x = (1.0 - Swift.abs(n.y)) * (n.x >= 0.0 ? 1.0 : -1.0)
            o.y = (1.0 - Swift.abs(n.x)) * (n.y >= 0.0 ? 1.0 : -1.0)
        }
        
        o.x = o.x * 0.5 + 0.5
        o.y = o.y * 0.5 + 0.5
        return o
    }
    
    public static func octahedronDecode(uv: Vector2) -> Vector3 {
        let f = Vector2(x: uv.x * 2.0 - 1.0, y: uv.y * 2.0 - 1.0)
        var n = Vector3(x: f.x, y: f.y, z: 1.0 - Swift.abs(f.x) - Swift.abs(f.y))
        let t = -n.z.clamped(min: 0, max: 1)
        
        n.x += n.x >= 0 ? -t : t
        n.y += n.y >= 0 ? -t : t
        return n.normalized()
    }
    
    public func outer(with: Vector3) -> Basis {
        return Basis(xAxis: Vector3(x: x * with.x, y: x * with.y, z: x * with.z),
                     yAxis: Vector3(x: y * with.x, y: y * with.y, z: y * with.z),
                     zAxis: Vector3(x: z * with.x, y: z * with.y, z: z * with.z)
        )
    }
    
    public func normalized() -> Vector3 {
        var result = self
        let lensq = Float(lengthSquared())
        if lensq != 0 {
            let len = sqrt(lensq)
            result = Vector3(x: x / len, y: y / len, z: z / len)
        }
        return result
    }
    
    // Arithmetic Operators
    
    public static func + (lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    public static func - (lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    public static func * (lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
    }
    
    public static func / (lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
    }
    
    public static func * (lhs: Vector3, rhs: Int64) -> Vector3  {
        return Vector3(
            x: lhs.x * Float(rhs),
            y: lhs.y * Float(rhs),
            z: lhs.z * Float(rhs)
        )
    }
    
    public static func * (lhs: Vector3, rhs: Double) -> Vector3  {
        return Vector3(
            x: lhs.x * Float(rhs),
            y: lhs.y * Float(rhs),
            z: lhs.z * Float(rhs)
        )
    }
    
    public static func / (lhs: Vector3, rhs: Int64) -> Vector3  {
        return Vector3(
            x: lhs.x / Float(rhs),
            y: lhs.y / Float(rhs),
            z: lhs.z / Float(rhs)
        )
    }
    
    public static func / (lhs: Vector3, rhs: Double) -> Vector3  {
        return Vector3(
            x: lhs.x / Float(rhs),
            y: lhs.y / Float(rhs),
            z: lhs.z / Float(rhs)
        )
    }
    
    // Comparison Operators
    
    public static func == (lhs: Vector3, rhs: Vector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    
    public static func != (lhs: Vector3, rhs: Vector3) -> Bool {
        return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z
    }
    
    public static func < (lhs: Vector3, rhs: Vector3) -> Bool {
        if lhs.x == rhs.x {
            if lhs.y == rhs.y {
                return lhs.z < rhs.z
            }
            return lhs.y < rhs.y
        }
        return lhs.x < rhs.x
    }
    
    public static func > (lhs: Vector3, rhs: Vector3) -> Bool {
        if lhs.x == rhs.x {
            if lhs.y == rhs.y {
                return lhs.z > rhs.z
            }
            return lhs.y > rhs.y
        }
        return lhs.x > rhs.x
    }
    
    public static func <= (lhs: Vector3, rhs: Vector3) -> Bool {
        if lhs.x == rhs.x {
            if lhs.y == rhs.y {
                return lhs.z <= rhs.z
            }
            return lhs.y < rhs.y
        }
        return lhs.x < rhs.x
    }
    
    public static func >= (lhs: Vector3, rhs: Vector3) -> Bool {
        if lhs.x == rhs.x {
            if lhs.y == rhs.y {
                return lhs.z >= rhs.z
            }
            return lhs.y > rhs.y
        }
        return lhs.x > rhs.x
    }
    
}
