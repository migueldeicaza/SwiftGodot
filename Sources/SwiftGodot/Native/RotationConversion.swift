
extension BinaryFloatingPoint {
    /// Converts this floating point value assumed to be in degrees to radians.
    public var degreesToRadians: Self {
        return self / 180 * .pi
    }
    
    /// Convert this floating point value assumed to be in radians to degrees.
    public var radiansToDegrees: Self {
        return self * 180 / .pi
    }
}
