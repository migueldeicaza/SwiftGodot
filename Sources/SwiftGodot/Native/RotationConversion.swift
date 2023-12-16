import Foundation

extension BinaryFloatingPoint {
    /// Convert given degrees value to radians.
    public var degreesToRadians: Self {
        return self / 180 * .pi
    }
    
    /// Convert given radians value to degrees.
    public var radiansToDegreess: Self {
        return self * 180 / .pi
    }
}
