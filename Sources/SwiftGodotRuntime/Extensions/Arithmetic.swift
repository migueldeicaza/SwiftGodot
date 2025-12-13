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

prefix operator &-
@inline(__always) prefix func &- <T: SignedInteger & FixedWidthInteger> (_ i: T) -> T {
    return 0 &- i
}

public extension Vector2i {
    
    /// Returns the negative value of the Vector2i. This is the same as writing Vector2i(-v.x, -v.y). This operation flips the direction of the vector while keeping the same magnitude.
    static prefix func - (_ v: Self) -> Self {
        return Self (x: &-v.x, y: &-v.y)
    }
    
    static func += (left: inout Self, right: Self) {
        left = left + right
    }

    static func -= (left: inout Self, right: Self) {
        left = left - right
    }

    static func *= (left: inout Self, right: Self) {
        left = left * right
    }

    static func /= (left: inout Self, right: Self) {
        left = left / right
    }

    static func %= (left: inout Self, right: Self) {
        left = left % right
    }
}

public extension Vector2 {
    
    /// Returns the negative value of the Vector2. This is the same as writing Vector2(-v.x, -v.y). This operation flips the direction of the vector while keeping the same magnitude. With floats, the number zero can be either positive or negative.
    static prefix func - (_ v: Self) -> Self {
        return Self (x: -v.x, y: -v.y)
    }
    
    static func += (left: inout Self, right: Self) {
        left = left + right
    }

    static func -= (left: inout Self, right: Self) {
        left = left - right
    }

    static func *= (left: inout Self, right: Self) {
        left = left * right
    }

    static func /= (left: inout Self, right: Self) {
        left = left / right
    }
}

public extension Vector3i {
    
    /// Returns the negative value of the Vector3i. This is the same as writing Vector3i(-v.x, -v.y, -v.z). This operation flips the direction of the vector while keeping the same magnitude.
    static prefix func - (_ v: Self) -> Self {
        return Self (x: &-v.x, y: &-v.y, z: &-v.z)
    }
    
    static func += (left: inout Self, right: Self) {
        left = left + right
    }

    static func -= (left: inout Self, right: Self) {
        left = left - right
    }

    static func *= (left: inout Self, right: Self) {
        left = left * right
    }

    static func /= (left: inout Self, right: Self) {
        left = left / right
    }

    static func %= (left: inout Self, right: Self) {
        left = left % right
    }
}

public extension Vector3 {
    
    /// Returns the negative value of the Vector3. This is the same as writing Vector3(-v.x, -v.y, -v.z). This operation flips the direction of the vector while keeping the same magnitude. With floats, the number zero can be either positive or negative.
    static prefix func - (_ v: Self) -> Self {
        return Self (x: -v.x, y: -v.y, z: -v.z)
    }
    
    static func += (left: inout Self, right: Self) {
        left = left + right
    }

    static func -= (left: inout Self, right: Self) {
        left = left - right
    }

    static func *= (left: inout Self, right: Self) {
        left = left * right
    }

    static func /= (left: inout Self, right: Self) {
        left = left / right
    }
}

public extension Vector4i {
    
    /// Returns the negative value of the Vector4i. This is the same as writing Vector4i(-v.x, -v.y, -v.z, -v.w). This operation flips the direction of the vector while keeping the same magnitude.
    static prefix func - (_ v: Self) -> Self {
        return Self (x: &-v.x, y: &-v.y, z: &-v.z, w: &-v.w)
    }
    
    static func += (left: inout Self, right: Self) {
        left = left + right
    }

    static func -= (left: inout Self, right: Self) {
        left = left - right
    }

    static func *= (left: inout Self, right: Self) {
        left = left * right
    }

    static func /= (left: inout Self, right: Self) {
        left = left / right
    }

    static func %= (left: inout Self, right: Self) {
        left = left % right
    }
}

public extension Vector4 {
    
    /// Returns the negative value of the Vector4. This is the same as writing Vector4(-v.x, -v.y, -v.z, -v.w). This operation flips the direction of the vector while keeping the same magnitude. With floats, the number zero can be either positive or negative.
    static prefix func - (_ v: Self) -> Self {
        return Self (x: -v.x, y: -v.y, z: -v.z, w: -v.w)
    }
    
    static func += (left: inout Self, right: Self) {
        left = left + right
    }

    static func -= (left: inout Self, right: Self) {
        left = left - right
    }

    static func *= (left: inout Self, right: Self) {
        left = left * right
    }

    static func /= (left: inout Self, right: Self) {
        left = left / right
    }
}

public extension Plane {
    
    /// Returns the negative value of the Plane. This is the same as writing Plane(-p.normal, -p.d). This operation flips the direction of the normal vector and also flips the distance value, resulting in a Plane that is in the same place, but facing the opposite direction.
    static prefix func - (_ p: Self) -> Self {
        return Self (normal: -p.normal, d: -p.d)
    }
    
}

public extension Quaternion {
    
    /// Returns the negative value of the Quaternion. This is the same as writing Quaternion(-q.x, -q.y, -q.z, -q.w). This operation results in a quaternion that represents the same rotation.
    static prefix func - (_ q: Self) -> Self {
        return Self (x: -q.x, y: -q.y, z: -q.z, w: -q.w)
    }
    
}

public extension Color {
    
    /// Inverts the given color. This is equivalent to Color.WHITE - c or Color(1 - c.r, 1 - c.g, 1 - c.b, 1 - c.a). Unlike with inverted, the a component is inverted, too.
    static prefix func - (_ c: Self) -> Self {
        return Self (r: 1 - c.red, g: 1 - c.green, b: 1 - c.blue, a: 1 - c.alpha)
    }
    
}
