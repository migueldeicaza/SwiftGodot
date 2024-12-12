//
//  Transform2D.covers.swift
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

extension Transform2D {
    
    public init(from: Transform2D) {
        self = from
    }
    
    public init(rotation: Float, position: Vector2) {
        self.init()
        let cr = cos(rotation)
        let sr = sin(rotation)
        
        self.x = Vector2(x: cr, y: sr)
        self.y = Vector2(x: -sr, y: cr)
        self.origin = position
    }
    
    public init(rotation: Float, scale: Vector2, skew: Float, position: Vector2) {
        self.init()
        self.x = Vector2(
            x: cos(rotation) * scale.x,
            y: sin(rotation) * scale.x
        )
        self.y = Vector2(
            x: -sin(rotation + skew) * scale.y,
            y: cos(rotation + skew) * scale.y
        )
        self.origin = position
    }
    
    public func inverse() -> Transform2D {
        var result = self
        // SWAP() macro: swap elements
        result.x.y = y.x
        result.y.x = x.y
        result.origin = basisXform(v: -result.origin)
        return result
    }
    
    public func affineInverse() -> Transform2D {
        var result = self
        let det = Float(determinant())
        let idet = 1.0 / det
        
        // Swap diagonals
        result.x.x = y.y
        result.y.y = x.x
        
        // Scale basis vectors
        result.x *= Vector2(x: idet, y: -idet)
        result.y *= Vector2(x: -idet, y: idet)
        
        // Transform the origin
        result.origin = basisXform(v: -result.origin)
        return result
    }
    
    public func getSkew() -> Double {
        let det = determinant()
        return acos(x.normalized().dot(with: y.normalized() * SwiftGodot.sign(det))) - (Double.pi * 0.5)
    }
    
    public func getRotation() -> Double {
        return Double(atan2(x.y, x.x))
    }
    
    public func getOrigin() -> Vector2 {
        return origin
    }
    
    /// Returns a copy of this transform with orthonormalized basis vectors using the Gram-Schmidt process.
    /// This ensures the basis vectors (x and y) are orthogonal (perpendicular) and normalized (length of 1).
    public func orthonormalized() -> Transform2D {
        // Applies Gram-Schmidt orthonormalization to the transform's basis vectors
        var result = self
        result.x = result.x.normalized()
        result.y = result.y - result.x * result.x.dot(with: result.y)
        result.y = result.y.normalized()
        
        return result
    }
    
    public func rotated(angle: Double) -> Transform2D {
        return Transform2D(rotation: Float(angle), position: Vector2()) * self
    }
    
    /// Just the above method reversed (not commutative)
    public func rotatedLocal(angle: Double) -> Transform2D {
        return self * Transform2D(rotation: Float(angle), position: Vector2())
    }
    
    public func scaled(scale: Vector2) -> Transform2D {
        // scale basis
        var result = scaleBasis(scale: scale)
        // scale origin
        result.origin *= scale
        return result
    }
    
    public func scaledLocal(scale: Vector2) -> Transform2D {
        return Transform2D(xAxis: x * Double(scale.x), yAxis: y * Double(scale.y), origin: origin)
    }
    
    public func translated(offset: Vector2) -> Transform2D {
        return Transform2D(xAxis: x, yAxis: y, origin: origin + offset)
    }
    
    public func translatedLocal(offset: Vector2) -> Transform2D {
        return Transform2D(xAxis: x, yAxis: y, origin: origin + basisXform(v: offset))
    }
    
    public func determinant() -> Double {
        return Double((x.x * y.y) - (x.y * y.x))
    }
    
    public func basisXform(v: Vector2) -> Vector2 {
        return Vector2(x: tdotx(v: v), y: tdoty(v: v))
    }
    
    public func basisXformInv(v: Vector2) -> Vector2 {
        return Vector2(x: Float(x.dot(with: v)), y: Float(y.dot(with: v)))
    }

#if false
    // Needs fixing.
    public func interpolateWith(xform: Transform2D, weight: Double) -> Transform2D {
        let p1 = origin
        let p2 = xform.origin
        
        let r1 = Float(getRotation())
        let r2 = Float(xform.getRotation())
        
        let s1 = getScale()
        let s2 = xform.getScale()
        
        // Slerp rotation
        let v1 = Vector2(x: cos(r1), y: sin(r1))
        let v2 = Vector2(x: cos(r2), y: sin(r2))
        
        var dot = v1.dot(with: v2)
        dot = dot.clamped(min: -1.0, max: 1.0)
        
        var v: Vector2
        
        if dot > 0.9995 {
            // Linearly interpolate to avoid numerical precision issues
            v = v1.lerp(to: v2, weight: weight).normalized()
        } else {
            let angle = weight * acos(dot)
            let v3 = (v2 - v1 * dot).normalized()
            v = v1 * cos(angle) + v3 * sin(angle)
        }
        
        // Construct matrix
        var res = Transform2D(rotation: Float(v.angle()), position: p1.lerp(to: p2, weight: weight))
        res = res.scaleBasis(scale: s1.lerp(to: s2, weight: weight))
        return res
    }
#endif

    public func isFinite() -> Bool {
        return x.isFinite() && y.isFinite() && origin.isFinite()
    }
    
    public func lookingAt(target: Vector2 = Vector2 (x: 0, y: 0)) -> Transform2D {
        var returnTrans = Transform2D(rotation: Float(getRotation()), position: origin)
        let targetPosition = affineInverse().xform(target)
        let newRotation = (targetPosition * getScale()).angle()
        returnTrans = returnTrans.rotated(angle: newRotation)
        return returnTrans
    }
    
    public subscript(index: Int64) -> Vector2 {
        get {
            switch index {
            case 0: return x
            case 1: return y
            case 2: return origin
            default: return Vector2.zero
            }
        }
        set {
            switch index {
            case 0: x = newValue
            case 1: y = newValue
            case 2: origin = newValue
            default: fatalError("Invalid index")
            }
        }
    }
    
    // Operators
    
    public static func * (lhs: Transform2D, rhs: Int64) -> Transform2D {
        var result = lhs
        result.x *= Double(rhs)
        result.y *= Double(rhs)
        result.origin *= Double(rhs)
        return result
    }

    public static func / (lhs: Transform2D, rhs: Int64) -> Transform2D {
        var result = lhs
        result.x /= Double(rhs)
        result.y /= Double(rhs)
        result.origin /= Double(rhs)
        return result
    }

    public static func * (lhs: Transform2D, rhs: Double) -> Transform2D {
        var result = lhs
        result.x *= rhs
        result.y *= rhs
        result.origin *= rhs
        return result
    }

    public static func / (lhs: Transform2D, rhs: Double) -> Transform2D {
        var result = lhs
        result.x /= rhs
        result.y /= rhs
        result.origin /= rhs
        return result
    }
    
    public static func == (lhs: Transform2D, rhs: Transform2D) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.origin == rhs.origin
    }
    
    public static func != (lhs: Transform2D, rhs: Transform2D) -> Bool {
        return !(lhs == rhs)
    }
    
    public static func * (lhs: Transform2D, rhs: Transform2D) -> Transform2D {
        var result = lhs
        result.origin = result.xform(rhs.origin)
        
        let x0 = result.tdotx(v: rhs.x)
        let x1 = result.tdoty(v: rhs.x)
        let y0 = result.tdotx(v: rhs.y)
        let y1 = result.tdoty(v: rhs.y)
        
        result.x.x = x0
        result.x.y = x1
        result.y.x = y0
        result.y.y = y1
        
        return result
    }
    
}
