//
//  Assertions.swift
//  SwiftGodotTestability
//
//  Assertion functions for Godot runtime tests
//

import SwiftGodot

// MARK: - Core Assertions

/// Assert that a condition is true
public func assertTrue(
    _ condition: Bool,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard !condition else { return }
    let msg = message.isEmpty ? "Expected true, got false" : message
    TestContext.current?.recordFailure(
        message: msg,
        file: String(describing: file),
        line: Int(line)
    )
}

/// Assert that a condition is false
public func assertFalse(
    _ condition: Bool,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    assertTrue(!condition, message.isEmpty ? "Expected false, got true" : message, file: file, line: line)
}

/// Assert that two values are equal
public func assertEqual<T: Equatable>(
    _ a: T?,
    _ b: T?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard a != b else { return }
    let msg = message.isEmpty ? "Expected \(String(describing: b)), got \(String(describing: a))" : message
    TestContext.current?.recordFailure(
        message: msg,
        file: String(describing: file),
        line: Int(line)
    )
}

/// Assert that two values are not equal
public func assertNotEqual<T: Equatable>(
    _ a: T?,
    _ b: T?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard a == b else { return }
    let msg = message.isEmpty ? "Expected values to differ, but both were \(String(describing: a))" : message
    TestContext.current?.recordFailure(
        message: msg,
        file: String(describing: file),
        line: Int(line)
    )
}

/// Assert that a value is nil
public func assertNil<T>(
    _ value: T?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard value != nil else { return }
    let msg = message.isEmpty ? "Expected nil, got \(String(describing: value))" : message
    TestContext.current?.recordFailure(
        message: msg,
        file: String(describing: file),
        line: Int(line)
    )
}

/// Assert that a value is not nil
public func assertNotNil<T>(
    _ value: T?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard value == nil else { return }
    let msg = message.isEmpty ? "Expected non-nil value, got nil" : message
    TestContext.current?.recordFailure(
        message: msg,
        file: String(describing: file),
        line: Int(line)
    )
}

/// Unconditionally fail the test
public func fail(
    _ message: String = "Test failed",
    file: StaticString = #file,
    line: UInt = #line
) {
    TestContext.current?.recordFailure(
        message: message,
        file: String(describing: file),
        line: Int(line)
    )
}

/// Assert that a value is greater than another
public func assertGreaterThan<T: Comparable>(
    _ a: T,
    _ b: T,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard a <= b else { return }
    let msg = message.isEmpty ? "Expected \(a) > \(b)" : message
    TestContext.current?.recordFailure(
        message: msg,
        file: String(describing: file),
        line: Int(line)
    )
}

/// Assert that a value is greater than or equal to another
public func assertGreaterThanOrEqual<T: Comparable>(
    _ a: T,
    _ b: T,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard a < b else { return }
    let msg = message.isEmpty ? "Expected \(a) >= \(b)" : message
    TestContext.current?.recordFailure(
        message: msg,
        file: String(describing: file),
        line: Int(line)
    )
}

/// Assert that a value is less than another
public func assertLessThan<T: Comparable>(
    _ a: T,
    _ b: T,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard a >= b else { return }
    let msg = message.isEmpty ? "Expected \(a) < \(b)" : message
    TestContext.current?.recordFailure(
        message: msg,
        file: String(describing: file),
        line: Int(line)
    )
}

/// Assert that a value is less than or equal to another
public func assertLessThanOrEqual<T: Comparable>(
    _ a: T,
    _ b: T,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard a > b else { return }
    let msg = message.isEmpty ? "Expected \(a) <= \(b)" : message
    TestContext.current?.recordFailure(
        message: msg,
        file: String(describing: file),
        line: Int(line)
    )
}

// MARK: - Approximate Equality (for floating point)

/// Asserts approximate equality of two floating point values based on Godot's `Math::is_equal_approx`
public func assertApproxEqual<T: FloatingPoint & ExpressibleByFloatLiteral>(
    _ a: T?,
    _ b: T?,
    epsilon: T = 0.00001,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    // Check for exact equality first, required to handle "infinity" values.
    guard a != b else { return }
    guard let a, let b else {
        assertEqual(a, b, message, file: file, line: line)
        return
    }

    // Then check for approximate equality.
    let tolerance: T = max(epsilon * abs(a), epsilon)
    if abs(a - b) > tolerance {
        let msg = message.isEmpty ? "Expected \(b) +/- \(tolerance), got \(a)" : message
        TestContext.current?.recordFailure(
            message: msg,
            file: String(describing: file),
            line: Int(line)
        )
    }
}

/// Asserts approximate equality of two Vector2 by comparing each component
public func assertApproxEqual(
    _ a: Vector2?,
    _ b: Vector2?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard let a, let b else {
        assertEqual(a, b, message, file: file, line: line)
        return
    }
    assertApproxEqual(a.x, b.x, "Fail due to X. " + message, file: file, line: line)
    assertApproxEqual(a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
}

/// Asserts approximate equality of two Vector3 by comparing each component
public func assertApproxEqual(
    _ a: Vector3?,
    _ b: Vector3?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard let a, let b else {
        assertEqual(a, b, message, file: file, line: line)
        return
    }
    assertApproxEqual(a.x, b.x, "Fail due to X. " + message, file: file, line: line)
    assertApproxEqual(a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
    assertApproxEqual(a.z, b.z, "Fail due to Z. " + message, file: file, line: line)
}

/// Asserts approximate equality of two Vector4 by comparing each component
public func assertApproxEqual(
    _ a: Vector4?,
    _ b: Vector4?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard let a, let b else {
        assertEqual(a, b, message, file: file, line: line)
        return
    }
    assertApproxEqual(a.x, b.x, "Fail due to X. " + message, file: file, line: line)
    assertApproxEqual(a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
    assertApproxEqual(a.z, b.z, "Fail due to Z. " + message, file: file, line: line)
    assertApproxEqual(a.w, b.w, "Fail due to W. " + message, file: file, line: line)
}

/// Asserts approximate equality of two Quaternion by comparing each component
public func assertApproxEqual(
    _ a: Quaternion?,
    _ b: Quaternion?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard let a, let b else {
        assertEqual(a, b, message, file: file, line: line)
        return
    }
    assertApproxEqual(a.x, b.x, "Fail due to X. " + message, file: file, line: line)
    assertApproxEqual(a.y, b.y, "Fail due to Y. " + message, file: file, line: line)
    assertApproxEqual(a.z, b.z, "Fail due to Z. " + message, file: file, line: line)
    assertApproxEqual(a.w, b.w, "Fail due to W. " + message, file: file, line: line)
}

/// Asserts approximate equality of two Color by comparing each component
public func assertApproxEqual(
    _ a: Color?,
    _ b: Color?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard let a, let b else {
        assertEqual(a, b, message, file: file, line: line)
        return
    }
    assertApproxEqual(a.red, b.red, "Fail due to R. " + message, file: file, line: line)
    assertApproxEqual(a.green, b.green, "Fail due to G. " + message, file: file, line: line)
    assertApproxEqual(a.blue, b.blue, "Fail due to B. " + message, file: file, line: line)
    assertApproxEqual(a.alpha, b.alpha, "Fail due to A. " + message, file: file, line: line)
}

// MARK: - Floating-point and optional helpers

/// assertEqual with an absolute accuracy tolerance for floating point
public func assertEqual<T: FloatingPoint>(
    _ a: T,
    _ b: T,
    accuracy: T,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    if abs(a - b) > accuracy {
        let msg = message.isEmpty ? "Expected \(b) +/- \(accuracy), got \(a)" : message
        TestContext.current?.recordFailure(
            message: msg,
            file: String(describing: file),
            line: Int(line)
        )
    }
}

/// Unwrap an optional or record a failure and throw if it is nil
public func unwrapOrFail<T>(
    _ value: T?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) throws -> T {
    guard let unwrapped = value else {
        let msg = message.isEmpty ? "Expected non-nil value" : message
        TestContext.current?.recordFailure(
            message: msg,
            file: String(describing: file),
            line: Int(line)
        )
        throw UnwrapError.nilValue
    }
    return unwrapped
}

/// Error thrown by `unwrapOrFail` when value is nil
public enum UnwrapError: Error {
    case nilValue
}

// MARK: - Enum Registration Assertions

/// Assert that `enumName` is registered as an enum on Godot class `cls`, and that it
/// exposes exactly the given `cases` (case name -> integer value) as class constants.
///
/// Used to verify the `@Godot` macro's automatic nested-enum registration
/// (`_registerEnumIfPossible`) against Godot's `ClassDB`.
public func assertEnumRegistered(
    _ cls: StringName,
    _ enumName: StringName,
    cases: [String: Int],
    file: StaticString = #file,
    line: UInt = #line
) {
    guard ClassDB.classHasEnum(class: cls, name: enumName) else {
        TestContext.current?.recordFailure(
            message: "Expected class \(cls) to have enum \(enumName), but it does not",
            file: String(describing: file),
            line: Int(line)
        )
        return
    }

    let registered = ClassDB.classGetEnumConstants(class: cls, enum: enumName).map { String($0) }
    assertEqual(
        Set(registered),
        Set(cases.keys),
        "Enum \(cls).\(enumName) registered cases \(registered.sorted()), expected \(Array(cases.keys).sorted())",
        file: file,
        line: line
    )

    for (name, expected) in cases {
        let actual = ClassDB.classGetIntegerConstant(class: cls, name: StringName(name))
        assertEqual(
            actual,
            expected,
            "Enum constant \(cls).\(name) has value \(actual), expected \(expected)",
            file: file,
            line: line
        )
    }
}

/// Assert that `enumName` is NOT registered as an enum on Godot class `cls`.
///
/// Used to verify that nested enums which are not `CaseIterable` & `RawRepresentable`
/// with a `BinaryInteger` raw value resolve to the no-op `_registerEnumIfPossible`
/// overload and therefore register nothing.
public func assertEnumNotRegistered(
    _ cls: StringName,
    _ enumName: StringName,
    file: StaticString = #file,
    line: UInt = #line
) {
    assertFalse(
        ClassDB.classHasEnum(class: cls, name: enumName),
        "Expected class \(cls) to NOT have enum \(enumName), but it does",
        file: file,
        line: line
    )
}
