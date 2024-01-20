import Foundation

public protocol Snappable {
    /// Returns a new value snapped to the nearest multiple of the specified step.
    func snapped(step: Self) -> Self
}

extension Numeric where Self: FloatingPoint & ExpressibleByFloatLiteral {
    public func snapped(step: Self) -> Self {
        if step.isZero {
            return self
        }
        return floor(self / step + 0.5) * step
    }
}

extension Numeric where Self: SignedInteger {
    public func snapped(step: Self) -> Self {
        return Self(Double(self).snapped(step: Double(step)))
    }
}

extension Vector2: Snappable {
    public func snapped(step: Self) -> Self {
        return Self(x: self.x.snapped(step: step.x),
                    y: self.y.snapped(step: step.y))
    }
}

extension Vector3: Snappable {
    public func snapped(step: Self) -> Self {
        return Self(x: self.x.snapped(step: step.x),
                    y: self.y.snapped(step: step.y),
                    z: self.z.snapped(step: step.z))
    }
}

extension Vector4: Snappable {
    public func snapped(step: Self) -> Self {
        return Self(x: self.x.snapped(step: step.x),
                    y: self.y.snapped(step: step.y),
                    z: self.z.snapped(step: step.z),
                    w: self.w.snapped(step: step.w))
    }
}

extension Vector2i: Snappable {
    public func snapped(step: Self) -> Self {
        return Self(x: self.x.snapped(step: step.x),
                    y: self.y.snapped(step: step.y))
    }
}

extension Vector3i: Snappable {
    public func snapped(step: Self) -> Self {
        return Self(x: self.x.snapped(step: step.x),
                    y: self.y.snapped(step: step.y),
                    z: self.z.snapped(step: step.z))
    }
}

extension Vector4i: Snappable {
    public func snapped(step: Self) -> Self {
        return Self(x: self.x.snapped(step: step.x),
                    y: self.y.snapped(step: step.y),
                    z: self.z.snapped(step: step.z),
                    w: self.w.snapped(step: step.w))
    }
}

