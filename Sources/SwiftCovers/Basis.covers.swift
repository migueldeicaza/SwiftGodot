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
        // The axis Vector3 should be normalized.
        
        let axisSq = Vector3(
                    x: axis.x * axis.x,
                    y: axis.y * axis.y,
                    z: axis.z * axis.z
                )
        
        let cosine = cos(angle)
        let sine = sin(angle)
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
            xAxis: Vector3(x: xx, y: yx, z: zx),
            yAxis: Vector3(x: xy, y: yy, z: zy),
            zAxis: Vector3(x: xz, y: yz, z: zz)
        )
    }
    
}
