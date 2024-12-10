import SwiftGodot

/// Like `Equatable`, but designed for testing.
///
/// I consider floating-point NaN equal to itself.
///
///  I also consider two floating-point numbers equal if they are within a few ulps of each other. We can't guarantee that the engine and the Swift covers will use exactly the same sequence of instructions for floating-point arithmetic, so one or the other can lose accuracy due to rounding of intermediate results. For example, in a debug build, `Vector4i / Float` uses a division instruction for each of the four components. But in an optimized engine build on ARM, `Vector4i / Float` first computes the reciprocal of the denominator, which incurs an extra rounding, and then uses SIMD multiplication to compute the quotients. That extra rounding can change the results by an ulp.
public protocol TestEquatable {
    func closeEnough(to other: Self) -> Bool
}

extension TestEquatable where Self: Equatable {
    // This default implementation works for integer-based types.
    public func closeEnough(to other: Self) -> Bool { self == other }
}

extension Bool: TestEquatable { }
extension Int64: TestEquatable { }
extension Vector2i: TestEquatable { }
extension Vector3i: TestEquatable { }
extension Vector4i: TestEquatable { }

extension Optional: TestEquatable where Wrapped: TestEquatable {
    public func closeEnough(to other: Optional<Wrapped>) -> Bool {
        switch (self, other) {
        case (nil, nil): return true
        case (.some(let a), .some(let b)): return a.closeEnough(to: b)
        default: return false
        }
    }
}

extension Float: TestEquatable {
    @TaskLocal public static var closeEnoughUlps: Self = 1

    public func closeEnough(to other: Float) -> Bool {
        if self == other {
            return true
        }
        if self.isNaN && other.isNaN {
            return true
        }
        // Don't allow opposite signs.
        guard (self <= 0 && other <= 0) || (self >= 0 && other >= 0) else { return false }
        let d = (self - other).magnitude
        let closeEnough = Self.closeEnoughUlps * min(self.ulp, other.ulp)
        if d <= closeEnough {
            return true
        }
        // Compute actual ulps difference for debugging test failures.
        let ulps = d / min(self.ulp, other.ulp)
        _ = ulps
        return false
    }
}

extension Double: TestEquatable {
    @TaskLocal public static var closeEnoughUlps: Self = 1

    public func closeEnough(to other: Double) -> Bool {
        if self == other {
            return true
        }
        if self.isNaN && other.isNaN {
            return true
        }
        // Don't allow opposite signs.
        guard (self <= 0 && other <= 0) || (self >= 0 && other >= 0) else { return false }
        let d = (self - other).magnitude
        let closeEnough = Self.closeEnoughUlps * min(self.ulp, other.ulp)
        if d <= closeEnough {
            return true
        }
        // Compute actual ulps difference for debugging test failures.
        let ulps = d / min(self.ulp, other.ulp)
        _ = ulps
        return false
    }
}

extension Vector2: TestEquatable {
    public func closeEnough(to other: Vector2) -> Bool {
        return self.x.closeEnough(to: other.x) && self.y.closeEnough(to: other.y)
    }
}

extension Vector3: TestEquatable {
    public func closeEnough(to other: Vector3) -> Bool {
        return self.x.closeEnough(to: other.x) && self.y.closeEnough(to: other.y) && self.z.closeEnough(to: other.z)
    }
}

extension Vector4: TestEquatable {
    public func closeEnough(to other: Vector4) -> Bool {
        return self.x.closeEnough(to: other.x) && self.y.closeEnough(to: other.y) && self.z.closeEnough(to: other.z) && self.w.closeEnough(to: other.w)
    }
}

extension Basis: TestEquatable {
    public func closeEnough(to other: Basis) -> Bool {
        return self.x.closeEnough(to: other.x) && self.y.closeEnough(to: other.y) && self.z.closeEnough(to: other.z)
    }
}

extension Transform2D: TestEquatable {
    public func closeEnough(to other: Transform2D) -> Bool {
        return self.x.closeEnough(to: other.x) && self.y.closeEnough(to: other.y) && self.origin.closeEnough(to: other.origin)
    }
}

extension Transform3D: TestEquatable {
    public func closeEnough(to other: Transform3D) -> Bool {
        return self.basis.closeEnough(to: other.basis) && self.origin.closeEnough(to: other.origin)
    }
}

extension Plane: TestEquatable {
    public func closeEnough(to other: Plane) -> Bool {
        return self.normal.closeEnough(to: other.normal) && self.d.closeEnough(to: other.d)
    }
}

extension Quaternion: TestEquatable {
    public func closeEnough(to other: Quaternion) -> Bool {
        return self.x.closeEnough(to: other.x) && self.y.closeEnough(to: other.y) && self.z.closeEnough(to: other.z) && self.w.closeEnough(to: other.w)
    }
}
