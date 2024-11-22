// Make imported inlinable C functions available to generated source files in the SwiftGodot target.

@_implementationOnly import CWrappers

/// The Swift standard library offers no efficient way to cast a `Float` to an `Int32` with the same semantics as C and C++. This method calls an imported inlinable C function.
@_spi(SwiftCovers)
@inline(__always)
public func cCastToInt32(_ float: Float) -> Int32 {
    return int32_for_float(float)
}

/// The Swift standard library offers no efficient way to cast a `Double` to an `Int32` with the same semantics as C and C++. This method calls an imported inlinable C function.
@_spi(SwiftCovers)
@inline(__always)
public func cCastToInt32(_ double: Double) -> Int32 {
    return int32_for_double(double)
}

/// The Swift standard library offers no efficient way to divide an `Int32` by an `Int32` with the same semantics as C and C++. This method calls an imported inlinable C function.
@_spi(SwiftCovers)
@inline(__always)
public func cDivide(numerator: Int32, denominator: Int32) -> Int32 {
    return int32_divide(numerator, denominator)
}

/// The Swift standard library offers no efficient way to compute the remainder of dividing an `Int32` by an `Int32` with the same semantics as C and C++. This method calls an imported inlinable C function.
@_spi(SwiftCovers)
@inline(__always)
public func cRemainder(numerator: Int32, denominator: Int32) -> Int32 {
    return int32_remainder(numerator, denominator)
}

/// Various `clamp` cover methods use this.
extension Comparable {
    @_spi(SwiftCovers)
    @inline(__always)
    public func clamped(min: Self, max: Self) -> Self {
        return self < min ? min : self > max ? max : self
    }
}

extension Vector2i {
    /// Godot compares `Vector2i` lexicographically. This `tuple` property allows us a trivial cover implementation in Swift, because the Swift standard library has lexicographic comparison operators for tuples of up to six elements.
    @_spi(SwiftCovers)
    @inline(__always)
    public var tuple: (Int32, Int32) { (x, y) }
}

extension Vector3i {
    @_spi(SwiftCovers)
    @inline(__always)
    public var tuple: (Int32, Int32, Int32) { (x, y, z) }
}

@_spi(SwiftCovers)
@inline(__always)
public func sign(_ x: Float) -> Float {
    return x == 0 ? 0 : (x > 0 ? 1.0 : -1.0)
}

#if TESTABLE_SWIFT_COVERS

/// If true (the default), use Swift cover implementations where available instead of calling Godot engine functions. You should only use this for testing covers. It is not intended for production use.
@TaskLocal
internal var useSwiftCovers: Bool = true

#else
@_spi(SwiftCovers)
public let useSwiftCovers: Bool = {
    preconditionFailure("useSwiftCovers is only available if compilation condition TESTABLE_SWIFT_COVERS is set.")
}()
#endif
