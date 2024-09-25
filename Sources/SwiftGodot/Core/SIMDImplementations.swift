//
//  SIMDImplementations.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 25/09/2024.
//

#if canImport(simd)
import simd

// MARK: Conversions

extension SIMD4 where Scalar == Float {
    init(_ vector: Vector4) {
        self.init(vector.x, vector.y, vector.z, vector.w)
    }
}

extension Vector4 {
    init(_ vector: SIMD4<Float>) {
        self.init(x: vector.x, y: vector.y, z: vector.z, w: vector.w)
    }
}

extension SIMD3 where Scalar == Float {
    init(_ vector: Vector3) {
        self.init(vector.x, vector.y, vector.z)
    }
}

extension Vector3 {
    init(_ vector: SIMD3<Float>) {
        self.init(x: vector.x, y: vector.y, z: vector.z)
    }
}

extension SIMD2 where Scalar == Float {
    init(_ vector: Vector2) {
        self.init(vector.x, vector.y)
    }
}

extension Vector2 {
    init(_ vector: SIMD2<Float>) {
        self.init(x: vector.x, y: vector.y)
    }
}

// MARK: Implementations

//public extension Vector3 {
//    static func * (lhs: Vector3, rhs: Vector3) -> Vector3 {
//        let lhs = SIMD3(lhs)
//        let rhs = SIMD3(rhs)
//        return Vector3(lhs * rhs)
//    }
//    
//    static func / (lhs: Vector3, rhs: Vector3) -> Vector3 {
//        let lhs = SIMD3(lhs)
//        let rhs = SIMD3(rhs)
//        return Vector3(lhs / rhs)
//    }
//    
//    static func + (lhs: Vector3, rhs: Vector3) -> Vector3 {
//        let lhs = SIMD3(lhs)
//        let rhs = SIMD3(rhs)
//        return Vector3(lhs + rhs)
//    }
//    
//    static func - (lhs: Vector3, rhs: Vector3) -> Vector3 {
//        let lhs = SIMD3(lhs)
//        let rhs = SIMD3(rhs)
//        return Vector3(lhs - rhs)
//    }
//    
//    static func * (lhs: Vector3, rhs: Float) -> Vector3 {
//        return Vector3(SIMD3(lhs) * rhs)
//    }
//    
//    static func * (lhs: Float, rhs: Vector3) -> Vector3 {
//        return Vector3(lhs * SIMD3(rhs))
//    }
//    
//    static func / (lhs: Vector3, rhs: Float) -> Vector3 {
//        return Vector3(SIMD3(lhs) / rhs)
//    }
//}

#endif
