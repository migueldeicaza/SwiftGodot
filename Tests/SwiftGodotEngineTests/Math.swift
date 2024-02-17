
extension Double {
    
    static let sqrt12: Double = Double (1.0 / 2.0).squareRoot ()
    static let sqrt13: Double = Double (1.0 / 3.0).squareRoot ()
    static let sqrt2: Double = Double (2).squareRoot ()
    static let sqrt3: Double = Double (3).squareRoot ()
    static let tau: Double = 2 * Double.pi
    static let e: Double = 2.7182818284590452353602874714
    
}


extension Float {
    
    static let sqrt12: Float = Float (Double.sqrt12)
    static let sqrt13: Float = Float (Double.sqrt13)
    static let sqrt2: Float = Float (Double.sqrt2)
    static let sqrt3: Float = Float (Double.sqrt3)
    static let tau: Float = Float (Double.tau)
    static let e: Float = Float (Double.e)
    
}

extension FloatingPoint where Self: ExpressibleByFloatLiteral {
    
    func isEqualApprox(_ b: Self, epsilon: Self = 0.00001) -> Bool {
        let tolerance: Self = max (epsilon * abs (self), epsilon)
        return abs (self - b) < tolerance
    }
    
}

extension Collection {
    
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains (index) ? self [index] : nil
    }
    
}
