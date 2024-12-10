//
//  Vector4.covers.swift
//  SwiftGodot
//
//  Created by Danny Youstra on 12/10/24.
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

extension Vector4 {
    
    public init(from: Vector4) {
        self = from
    }
    
    public func dot(with: Vector4) -> Double {
        return Double(x * with.x + y * with.y + z * with.z + w * with.w)
    }
    
    public func abs() -> Vector4 {
        return Vector4(
            x: Swift.abs(x),
            y: Swift.abs(y),
            z: Swift.abs(z),
            w: Swift.abs(w)
        )
    }
    
    public func sign() -> Vector4 {
        return Vector4(
            x: SwiftGodot.sign(x),
            y: SwiftGodot.sign(y),
            z: SwiftGodot.sign(z),
            w: SwiftGodot.sign(w)
        )
    }
    
    public func floor() -> Vector4 {
        return Vector4(
            x: _math.floor(x),
            y: _math.floor(y),
            z: _math.floor(z),
            w: _math.floor(w)
        )
    }

    public func ceil() -> Vector4 {
        return Vector4(
            x: _math.ceil(x),
            y: _math.ceil(y),
            z: _math.ceil(z),
            w: _math.ceil(w)
        )
    }

    public func round() -> Vector4 {
        return Vector4(
            x: _math.round(x),
            y: _math.round(y),
            z: _math.round(z),
            w: _math.round(w)
        )
    }
    
    public func clamp(min: Vector4, max: Vector4) -> Vector4 {
        return Vector4(
            x: x.clamped(min: min.x, max: max.x),
            y: y.clamped(min: min.y, max: max.y),
            z: z.clamped(min: min.z, max: max.z),
            w: w.clamped(min: min.w, max: max.w)
        )
    }
    
    public func clampf(min: Double, max: Double) -> Vector4 {
        return Vector4(
            x: x.clamped(min: Float(min), max: Float(max)),
            y: y.clamped(min: Float(min), max: Float(max)),
            z: z.clamped(min: Float(min), max: Float(max)),
            w: w.clamped(min: Float(min), max: Float(max))
        )
    }

    public func snappedf(step: Double) -> Vector4 {
        return Vector4(
            x: x.snapped(step: Float(step)),
            y: y.snapped(step: Float(step)),
            z: z.snapped(step: Float(step)),
            w: w.snapped(step: Float(step))
        )
    }

    public func normalized() -> Vector4 {
        var result = self
        let lensq = Float(lengthSquared())
        if lensq != 0 {
            let len = sqrt(lensq)
            result = Vector4(x: x / len, y: y / len, z: z / len, w: w / len)
        }
        return result
    }
    
    // Arithmetic Operators

    public static func + (lhs: Vector4, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z, w: lhs.w + rhs.w)
    }

    public static func - (lhs: Vector4, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z, w: lhs.w - rhs.w)
    }

    public static func * (lhs: Vector4, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z, w: lhs.w * rhs.w)
    }

    public static func / (lhs: Vector4, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z, w: lhs.w / rhs.w)
    }

    public static func * (lhs: Vector4, rhs: Int64) -> Vector4 {
        return Vector4(
            x: lhs.x * Float(rhs),
            y: lhs.y * Float(rhs),
            z: lhs.z * Float(rhs),
            w: lhs.w * Float(rhs)
        )
    }

    public static func * (lhs: Vector4, rhs: Double) -> Vector4 {
        return Vector4(
            x: lhs.x * Float(rhs),
            y: lhs.y * Float(rhs),
            z: lhs.z * Float(rhs),
            w: lhs.w * Float(rhs)
        )
    }

    public static func / (lhs: Vector4, rhs: Int64) -> Vector4 {
        return Vector4(
            x: lhs.x / Float(rhs),
            y: lhs.y / Float(rhs),
            z: lhs.z / Float(rhs),
            w: lhs.w / Float(rhs)
        )
    }

    public static func / (lhs: Vector4, rhs: Double) -> Vector4 {
        return Vector4(
            x: lhs.x / Float(rhs),
            y: lhs.y / Float(rhs),
            z: lhs.z / Float(rhs),
            w: lhs.w / Float(rhs)
        )
    }

    // Comparison Operators

    public static func == (lhs: Vector4, rhs: Vector4) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.w == rhs.w
    }

    public static func != (lhs: Vector4, rhs: Vector4) -> Bool {
        return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z || lhs.w != rhs.w
    }

    public static func < (lhs: Vector4, rhs: Vector4) -> Bool {
        if lhs.x == rhs.x {
            if lhs.y == rhs.y {
                if lhs.z == rhs.z {
                    return lhs.w < rhs.w
                }
                return lhs.z < rhs.z
            }
            return lhs.y < rhs.y
        }
        return lhs.x < rhs.x
    }

    public static func > (lhs: Vector4, rhs: Vector4) -> Bool {
        if lhs.x == rhs.x {
            if lhs.y == rhs.y {
                if lhs.z == rhs.z {
                    return lhs.w > rhs.w
                }
                return lhs.z > rhs.z
            }
            return lhs.y > rhs.y
        }
        return lhs.x > rhs.x
    }

    public static func <= (lhs: Vector4, rhs: Vector4) -> Bool {
        if lhs.x == rhs.x {
            if lhs.y == rhs.y {
                if lhs.z == rhs.z {
                    return lhs.w <= rhs.w
                }
                return lhs.z < rhs.z
            }
            return lhs.y < rhs.y
        }
        return lhs.x < rhs.x
    }

    public static func >= (lhs: Vector4, rhs: Vector4) -> Bool {
        if lhs.x == rhs.x {
            if lhs.y == rhs.y {
                if lhs.z == rhs.z {
                    return lhs.w >= rhs.w
                }
                return lhs.z > rhs.z
            }
            return lhs.y > rhs.y
        }
        return lhs.x > rhs.x
    }

    
}
