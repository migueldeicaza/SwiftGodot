//
//  Assertions.swift
//  SwiftGodotTestability
//
//  XCTest-compatible assertion functions for Godot runtime tests
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

// MARK: - XCTest Compatibility Aliases

/// XCTest compatibility alias for assertTrue
public func XCTAssertTrue(
    _ condition: Bool,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    assertTrue(condition, message, file: file, line: line)
}

/// XCTest compatibility alias for assertFalse
public func XCTAssertFalse(
    _ condition: Bool,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    assertFalse(condition, message, file: file, line: line)
}

/// XCTest compatibility alias for assertEqual
public func XCTAssertEqual<T: Equatable>(
    _ a: T?,
    _ b: T?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    assertEqual(a, b, message, file: file, line: line)
}

/// XCTest compatibility alias for assertNotEqual
public func XCTAssertNotEqual<T: Equatable>(
    _ a: T?,
    _ b: T?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    assertNotEqual(a, b, message, file: file, line: line)
}

/// XCTest compatibility alias for assertNil
public func XCTAssertNil<T>(
    _ value: T?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    assertNil(value, message, file: file, line: line)
}

/// XCTest compatibility alias for assertNotNil
public func XCTAssertNotNil<T>(
    _ value: T?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    assertNotNil(value, message, file: file, line: line)
}

/// XCTest compatibility alias for fail
public func XCTFail(
    _ message: String = "Test failed",
    file: StaticString = #file,
    line: UInt = #line
) {
    fail(message, file: file, line: line)
}

/// XCTest compatibility alias for assertGreaterThan
public func XCTAssertGreaterThan<T: Comparable>(
    _ a: T,
    _ b: T,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    assertGreaterThan(a, b, message, file: file, line: line)
}

/// XCTest compatibility alias for assertGreaterThanOrEqual
public func XCTAssertGreaterThanOrEqual<T: Comparable>(
    _ a: T,
    _ b: T,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    assertGreaterThanOrEqual(a, b, message, file: file, line: line)
}

/// XCTest compatibility alias for assertLessThan
public func XCTAssertLessThan<T: Comparable>(
    _ a: T,
    _ b: T,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    assertLessThan(a, b, message, file: file, line: line)
}

/// XCTest compatibility alias for assertLessThanOrEqual
public func XCTAssertLessThanOrEqual<T: Comparable>(
    _ a: T,
    _ b: T,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    assertLessThanOrEqual(a, b, message, file: file, line: line)
}

/// XCTest compatibility alias for assertTrue (XCTAssert is just XCTAssertTrue)
public func XCTAssert(
    _ condition: Bool,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    assertTrue(condition, message, file: file, line: line)
}

/// XCTest compatibility - assertEqual with accuracy for floating point
public func XCTAssertEqual<T: FloatingPoint>(
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

/// XCTest compatibility - unwrap optional or fail
public func XCTUnwrap<T>(
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

/// Error thrown by XCTUnwrap when value is nil
public enum UnwrapError: Error {
    case nilValue
}
