import SwiftGodot

extension Vector2i {
    public typealias Component = Int32

    public init(from: Vector2i) {
        self = from
    }

    static public func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    static public func != (lhs: Self, rhs: Self) -> Bool {
        return !(lhs == rhs)
    }

    static public func / (lhs: Self, rhs: Int64) -> Self {
        let rhs = Int32(truncatingIfNeeded: rhs)
        return Self(
            x: lhs.x.dividedReportingOverflow(by: rhs).partialValue,
            y: lhs.y.dividedReportingOverflow(by: rhs).partialValue
        )
    }
}
