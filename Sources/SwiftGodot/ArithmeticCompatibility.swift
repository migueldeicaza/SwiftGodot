import SwiftGodotRuntime

// Preserve source compatibility for client code that writes `vector * 2` or `color / 2`
// now that generated builtins expose both Int64 and Double scalar overloads.
public extension Vector2 {
    static func * (lhs: Self, rhs: Int) -> Self { lhs * Int64(rhs) }
    static func / (lhs: Self, rhs: Int) -> Self { lhs / Int64(rhs) }
}

public extension Vector3 {
    static func * (lhs: Self, rhs: Int) -> Self { lhs * Int64(rhs) }
    static func / (lhs: Self, rhs: Int) -> Self { lhs / Int64(rhs) }
}

public extension Vector4 {
    static func * (lhs: Self, rhs: Int) -> Self { lhs * Int64(rhs) }
    static func / (lhs: Self, rhs: Int) -> Self { lhs / Int64(rhs) }
}

public extension Color {
    static func * (lhs: Self, rhs: Int) -> Self { lhs * Int64(rhs) }
    static func / (lhs: Self, rhs: Int) -> Self { lhs / Int64(rhs) }
}

public extension Vector2i {
    static func * (lhs: Self, rhs: Int) -> Self { lhs * Int64(rhs) }
    static func / (lhs: Self, rhs: Int) -> Self { lhs / Int64(rhs) }
}

public extension Vector3i {
    static func * (lhs: Self, rhs: Int) -> Self { lhs * Int64(rhs) }
    static func / (lhs: Self, rhs: Int) -> Self { lhs / Int64(rhs) }
}

public extension Vector4i {
    static func * (lhs: Self, rhs: Int) -> Self { lhs * Int64(rhs) }
    static func / (lhs: Self, rhs: Int) -> Self { lhs / Int64(rhs) }
}
