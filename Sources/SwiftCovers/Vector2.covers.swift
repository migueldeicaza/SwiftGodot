//
//  Vector2.covers.swift
//  SwiftGodot
//
//  Created by Danny Youstra on 11/19/24.
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


extension Vector2 {
    
    public func angle() -> Double {
        return Double(atan2(x, y))
    }
    
    public static func fromAngle(_ angle: Double) -> Vector2 {
        let fAngle = Float(angle)
        return Vector2(x: cos(fAngle), y: sin(fAngle))
    }
    
    public func length() -> Double {
        return Double(sqrt(x * x + y * y))
    }
    
    public func lengthSquared() -> Double {
        return Double(x * x + y * y)
    }
    
    public func normalized() -> Vector2 {
        var len = x * x + y * y
        var result = self
        if len != 0 {
            len = sqrt(len)
            result = Vector2(x: x / len, y: y / len)
        }
        return result
    }
    
    public func distanceTo(_ to: Vector2) -> Double {
        return Double(sqrt((x - to.x) * (x - to.x) + (y - to.y) * (y - to.y)))
    }
    
    public func distanceSquaredTo(_ to: Vector2) -> Double {
        return Double((x - to.x) * (x - to.x) + (y - to.y) * (y - to.y))
    }
    
    public func angleTo(_ to: Vector2) -> Double {
        return atan2(cross(with: to), dot(with: to))
    }
    
    public func angleToPoint(to: Vector2) -> Double {
        return (to - self).angle()
    }
    
    public func dot(with: Vector2) -> Double {
        return Double(x * with.x + y * with.y)
    }
    
    public func cross(with: Vector2) -> Double {
        return Double(x * with.y - y * with.x)
    }
    
    public func sign() -> Vector2 {
        return Vector2(x: SwiftGodot.sign(x), y: SwiftGodot.sign(y))
    }
    
    public func floor() -> Vector2 {
        return Vector2(x: _math.floor(x), y: _math.floor(y))
    }
    
    public func ceil() -> Vector2 {
        return Vector2(x: _math.ceil(x), y: _math.ceil(y))
    }
    
    public func round() -> Vector2 {
        return Vector2(x: _math.round(x), y: _math.round(y))
    }
    
    public func rotated(angle: Double) -> Vector2 {
        let sin = Float(sin(angle))
        let cos = Float(cos(angle))
        return Vector2(
            x: x * cos - y * sin,
            y: x * sin + y * cos
        )
    }
    
    public func project(b: Vector2) -> Vector2 {
        return b * (dot(with: b) / b.lengthSquared())
    }
    
    public func clamp(min: Vector2, max: Vector2) -> Vector2 {
        return Vector2(
            x: x.clamped(min: min.x, max: max.x),
            y: y.clamped(min: min.y, max: max.y)
        )
    }
    
    public func clampf(min: Double, max: Double) -> Vector2 {
        return Vector2(
            x: x.clamped(min: Float(min), max: Float(max)),
            y: y.clamped(min: Float(min), max: Float(max))
        )
    }
    
    public func snappedf(step: Double) -> Vector2 {
        return Vector2(
            x: x.snapped(step: Float(step)),
            y: y.snapped(step: Float(step))
        )
    }
    
    public func limitLength(_ length: Double = 1.0) -> Vector2 {
        let beforeLen = self.length()
        var result = self
        if (beforeLen > 0 && length < beforeLen) {
            result = result / beforeLen
            result = result * length
        }
        return result
    }
    
    public func moveToward(to: Vector2, delta: Double) -> Vector2 {        
        let result = to - self
        let newLen = result.length()
        return newLen <= delta || newLen < CMP_EPSILON ? to : self + result / newLen * delta
    }
    
    public func slide(n: Vector2) -> Vector2 {
        return self - n * self.dot(with: n)
    }
    
    public func bounce(n: Vector2) -> Vector2 {
        return -reflect(line: n)
    }
    
    public func reflect(line: Vector2) -> Vector2 {
        /// Reflection requires a scale by 2, but float * Vector2 is not overloaded
        return Vector2(x: 2, y: 2) * line * self.dot(with: line) - self
    }
    
    
}
