//
//  CustomBultinImplementations.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 25/09/2024.
//

import Foundation

#if CUSTOM_BUILTIN_IMPLEMENTATIONS

public extension Vector3 {
    static func * (lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
    }
    
    static func / (lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
    }
        
    static func + (lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
        
    static func - (lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
        
    static func * (lhs: Vector3, rhs: Float) -> Vector3 {
        Vector3(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
            
    static func * (lhs: Vector3, rhs: Double) -> Vector3 {
        return lhs * Float(rhs)
    }
        
    static func * (lhs: Float, rhs: Vector3) -> Vector3 {
        Vector3(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
    }
            
    static func * (lhs: Double, rhs: Vector3) -> Vector3 {
        return Float(lhs) * rhs
    }
        
    static func / (lhs: Vector3, rhs: Float) -> Vector3 {
        Vector3(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
        
    static func / (lhs: Vector3, rhs: Double) -> Vector3 {
        return lhs / Float(rhs)
    }
}

#endif
