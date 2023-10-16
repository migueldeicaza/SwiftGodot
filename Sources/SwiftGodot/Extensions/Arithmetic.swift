//
//  Arithmetic.swift
//
//
//  Created by Mikhail Tishin on 15.10.2023.
//

public protocol IntScalable {
    
    static func / (lhs: Self, rhs: Int64) -> Self
    static func * (lhs: Self, rhs: Int64) -> Self
    
}

public extension IntScalable {
    
    static func / (lhs: Self, rhs: Int) -> Self {
        return lhs / Int64(rhs)
    }
    
    static func * (lhs: Self, rhs: Int) -> Self {
        return lhs * Int64(rhs)
    }
    
    static func /= (_ lhs: inout Self, _ rhs: Int) {
        lhs = lhs / rhs
    }
    
    static func *= (_ lhs: inout Self, _ rhs: Int) {
        lhs = lhs * rhs
    }
    
}

public protocol DoubleScalable {
    
    static func / (lhs: Self, rhs: Double) -> Self
    static func * (lhs: Self, rhs: Double) -> Self
    
}

public extension DoubleScalable {
    
    static func /= (_ lhs: inout Self, _ rhs: Double) {
        lhs = lhs / rhs
    }
    
    static func *= (_ lhs: inout Self, _ rhs: Double) {
        lhs = lhs * rhs
    }
    
}

extension Vector2i: IntScalable {}
extension Vector3i: IntScalable {}
extension Vector4i: IntScalable {}
extension Vector2: IntScalable & DoubleScalable {}
extension Vector3: IntScalable & DoubleScalable {}
extension Vector4: IntScalable & DoubleScalable {}
extension Quaternion: IntScalable & DoubleScalable {}
extension Color: IntScalable & DoubleScalable {}
