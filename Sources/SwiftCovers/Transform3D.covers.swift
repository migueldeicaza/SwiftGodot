//
//  Transform3D.covers.swift
//  SwiftGodot
//
//  Created by Danny Youstra on 12/11/24.
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

extension Transform3D {
    
    public init(from: Transform3D) {
        self = from
    }
    
    public init(xAxis: Vector3, yAxis: Vector3, zAxis: Vector3, origin: Vector3) {
        self.init()
        // Transpose the axes when creating the basis to match engine's row-major order
        self.basis = Basis(
            xAxis: Vector3(x: xAxis.x, y: yAxis.x, z: zAxis.x),
            yAxis: Vector3(x: xAxis.y, y: yAxis.y, z: zAxis.y),
            zAxis: Vector3(x: xAxis.z, y: yAxis.z, z: zAxis.z)
        )
        self.origin = origin
    }
    
    public func inverse() -> Transform3D {
        var result = self
        result.basis = result.basis.transposed()
        result.origin = result.basis.xform(-origin)
        return result
    }
    
    public func affineInverse() -> Transform3D {
        var result = self
        result.basis = result.basis.inverse()
        result.origin = result.basis.xform(-origin)
        return result
    }

    public func orthonormalized() -> Transform3D {
        var result = self
        result.basis = result.basis.orthonormalized()
        return result
    }

    public func scaled(scale: Vector3) -> Transform3D {
        return Transform3D(
            basis: basis.scaled(scale: scale),
            origin: origin * scale
        )
    }
    
    public func rotated(axis: Vector3, angle: Double) -> Transform3D {
        let rotationBasis = Basis(axis: axis, angle: Float(angle))
        return Transform3D(basis: rotationBasis * basis, origin: rotationBasis.xform(origin))
    }
    
    public func rotatedLocal(axis: Vector3, angle: Double) -> Transform3D {
        let rotationBasis = Basis(axis: axis, angle: Float(angle))
        return Transform3D(basis: basis * rotationBasis, origin: origin)
    }
    
    public func scaledLocal(scale: Vector3) -> Transform3D {
        return Transform3D(
            basis: basis.scaledLocal(scale: scale),
            origin: origin
        )
    }

    public func translated(offset: Vector3) -> Transform3D {
        return Transform3D(basis: basis, origin: origin + offset)
    }

    public func translatedLocal(offset: Vector3) -> Transform3D {
        return Transform3D(basis: basis, origin: origin + basis.xform(offset))
    }

    public func lookingAt(target: Vector3, up: Vector3 = Vector3(x: 0, y: 1, z: 0)) -> Transform3D {
        var result = self
        result.basis = Basis.lookingAt(target: target - origin, up: up)
        return result
    }
    
    public func interpolateWith(xform: Transform3D, weight: Double) -> Transform3D {
        let srcScale = basis.getScale()
        let srcRot = basis.getRotationQuaternion()
        let srcLoc = origin
        
        let dstScale = xform.basis.getScale()
        let dstRot = xform.basis.getRotationQuaternion()
        let dstLoc = xform.origin
        
        var result = Transform3D()
        // Create basis from interpolated quaternion and scale it
        result.basis = Basis(from: srcRot.slerp(to: dstRot, weight: weight).normalized())
        result.basis = result.basis.scaled(scale: srcScale.lerp(to: dstScale, weight: weight))
        result.origin = srcLoc.lerp(to: dstLoc, weight: weight)
        
        return result
    }
    
    public func isFinite() -> Bool {
        return basis.isFinite() && origin.isFinite()
    }
    
    public static func * (lhs: Transform3D, rhs: Double) -> Transform3D {
        var result = lhs
        result.basis = result.basis * rhs
        result.origin = result.origin * rhs
        return result
    }
    
    public static func / (lhs: Transform3D, rhs: Double) -> Transform3D {
        var result = lhs
        result.basis = result.basis / rhs
        result.origin = result.origin / rhs
        return result
    }
    
    public static func * (lhs: Transform3D, rhs: Int64) -> Transform3D  {
        var result = lhs
        result.basis = result.basis * rhs
        result.origin = result.origin * rhs
        return result
    }
    
    public static func / (lhs: Transform3D, rhs: Int64) -> Transform3D  {
        var result = lhs
        result.basis = result.basis / rhs
        result.origin = result.origin / rhs
        return result
    }
    
    public static func * (lhs: Transform3D, rhs: Vector3) -> Vector3 {
        return lhs.basis.xform(rhs) + lhs.origin
    }
    
//    public static func * (lhs: Transform3D, rhs: Plane) -> Plane  {
//        
//    }
//    
//    public static func * (lhs: Transform3D, rhs: AABB) -> AABB  {
//        
//    }
    
    public static func == (lhs: Transform3D, rhs: Transform3D) -> Bool {
        return lhs.basis == rhs.basis && lhs.origin == rhs.origin
    }
    
    public static func != (lhs: Transform3D, rhs: Transform3D) -> Bool {
        return !(lhs == rhs)
    }
    
    public static func * (lhs: Transform3D, rhs: Transform3D) -> Transform3D {
        var result = lhs
        result.origin = result.basis.xform(rhs.origin) + result.origin
        result.basis = result.basis * rhs.basis
        return result
    }
    
    public static func * (lhs: Transform3D, rhs: PackedVector3Array) -> PackedVector3Array {
        for (i, v3) in rhs.enumerated() {
            rhs[i] = lhs.basis.xform(v3) + lhs.origin
        }
        return rhs
    }
    
}
