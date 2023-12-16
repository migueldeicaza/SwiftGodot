import Foundation

public protocol LinearInterpolation {
    /// Linearly interpolate from self to the given value considering the weight.
    /// '0' would return 'self'
    /// '1' would return the 'to' value
    ///
    /// - parameter to:     The initial value.
    /// - parameter weight: The value the interpolate the value by.
    ///
    /// - returns: The interpolated value.
    func lerp(to: Self, weight: any BinaryFloatingPoint) -> Self
}

extension BinaryFloatingPoint {
    /// Inverse linear interpolation. 'self' is the result of a lerp from - to of an unknown weight
    /// Calling this function calculates the weight value that was used.
    ///
    /// - parameter from: The first value in the lerp function.
    /// - parameter to:   The second value of the lerp function.
    ///
    /// - returns: The weight that corresponds to the inverse linear interpolation.
    public func inverseLerp(from: Self, to: Self) -> any BinaryFloatingPoint {
        guard from != to else {
            // Avoid division by zero when from and to are equal
            return 0
        }
        
        let clampedSelf = max(min(self, to), from)
        let result = (clampedSelf - from) / (to - from)
        return result
    }
}

extension Int: LinearInterpolation {
    public func lerp(to: Int, weight: any BinaryFloatingPoint) -> Int {
        let from = Double(self)
        let to = Double(to)
        return Int(from.lerp(to: to, weight: weight))
    }
}

extension Double: LinearInterpolation {
    public func lerp(to: Double, weight: any BinaryFloatingPoint) -> Double {
        let clampedWeight = max(0.0, min(1.0, Double(weight)))
        return self + (to - self) * clampedWeight
    }
}

extension Float: LinearInterpolation {
    public func lerp(to: Float, weight: any BinaryFloatingPoint) -> Float {
        let clampedWeight = max(0.0, min(1.0, Float(weight)))
        return self + (to - self) * clampedWeight
    }
}

extension Vector2: LinearInterpolation {
    public func lerp(to: Self, weight: any BinaryFloatingPoint) -> Vector2 {
        return Vector2(x: self.x.lerp(to: to.x, weight: weight),
                       y: self.y.lerp(to: to.y, weight: weight))
    }
}

extension Vector3: LinearInterpolation {
    public func lerp(to: Self, weight: any BinaryFloatingPoint) -> Vector3 {
        return Vector3(x: self.x.lerp(to: to.x, weight: weight),
                       y: self.y.lerp(to: to.y, weight: weight),
                       z: self.z.lerp(to: to.z, weight: weight))
    }
}

extension Vector4: LinearInterpolation {
    public func lerp(to: Self, weight: any BinaryFloatingPoint) -> Vector4 {
        return Vector4(x: self.x.lerp(to: to.x, weight: weight),
                       y: self.y.lerp(to: to.y, weight: weight),
                       z: self.z.lerp(to: to.z, weight: weight),
                       w: self.w.lerp(to: to.w, weight: weight))
    }
}

extension Color: LinearInterpolation {
    public func lerp(to: Self, weight: any BinaryFloatingPoint) -> Color {
        return Color(r: self.red.lerp(to: to.red, weight: weight),
                     g: self.green.lerp(to: to.green, weight: weight),
                     b: self.blue.lerp(to: to.blue, weight: weight),
                     a: self.alpha.lerp(to: to.alpha, weight: weight))
    }
}
