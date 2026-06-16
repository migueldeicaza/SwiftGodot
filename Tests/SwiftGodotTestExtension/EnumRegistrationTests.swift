//
//  EnumRegistrationTests.swift
//  SwiftGodotTestExtension
//
//  End-to-end tests for the @Godot macro's automatic nested-enum registration.
//
//  The macro emits SwiftGodotRuntime._registerEnumIfPossible(...) for every nested
//  enum. The constrained overload registers CaseIterable & RawRepresentable enums
//  with a BinaryInteger raw value as Godot class constants; a @_disfavoredOverload
//  no-op handles every other enum. These tests assert both behaviors against Godot's
//  live ClassDB, and verify the cross-feature contract with @Export enum properties.
//

import SwiftGodot

// MARK: - Class under test

@Godot
class EnumRegistrationHost: Node {
    // Qualifying enums: CaseIterable & RawRepresentable with a BinaryInteger raw value.
    // These should be registered as Godot class enums with integer constants.
    enum IntEnum: Int, CaseIterable {
        case a = 0
        case b = 1
        case c = 2
    }

    enum Int64Enum: Int64, CaseIterable {
        case low = -5
        case high = 100
    }

    enum Int32Enum: Int32, CaseIterable {
        case x = 7
        case y = 8
    }

    enum UInt8Enum: UInt8, CaseIterable {
        case small = 3
        case big = 200
    }

    // Non-qualifying enums: each must resolve to the no-op overload (proven by the fact
    // that this file compiles) and register nothing with Godot.
    enum StringEnum: String, CaseIterable {
        case one
        case two
    }

    enum PlainEnum {
        case alpha
        case beta
    }

    enum NonIterableIntEnum: Int {
        case p = 1
        case q = 2
    }

    // Cross-feature: an exported property whose type is an auto-registered enum.
    @Export var mode: IntEnum = .a
}

// MARK: - Tests

@SwiftGodotTestSuite
final class EnumRegistrationTests {
    public static var registeredTypes: [Object.Type] {
        [EnumRegistrationHost.self]
    }

    func testIntEnumRegistered() {
        assertEnumRegistered("EnumRegistrationHost", "IntEnum", cases: [
            "a": 0, "b": 1, "c": 2,
        ])
    }

    func testInt64EnumRegistered() {
        // Includes a negative raw value to confirm signed values round-trip.
        assertEnumRegistered("EnumRegistrationHost", "Int64Enum", cases: [
            "low": -5, "high": 100,
        ])
    }

    func testInt32EnumRegistered() {
        assertEnumRegistered("EnumRegistrationHost", "Int32Enum", cases: [
            "x": 7, "y": 8,
        ])
    }

    func testUInt8EnumRegistered() {
        // Confirms an unsigned, narrower-than-Int64 raw value registers correctly.
        assertEnumRegistered("EnumRegistrationHost", "UInt8Enum", cases: [
            "small": 3, "big": 200,
        ])
    }

    func testNonConformingEnumsAreNotRegistered() {
        // String-backed (RawValue is not a BinaryInteger).
        assertEnumNotRegistered("EnumRegistrationHost", "StringEnum")
        // No raw value, not CaseIterable.
        assertEnumNotRegistered("EnumRegistrationHost", "PlainEnum")
        // RawRepresentable Int but not CaseIterable.
        assertEnumNotRegistered("EnumRegistrationHost", "NonIterableIntEnum")
    }

    func testRegisteredEnumListContainsExactlyTheQualifyingEnums() {
        let enums = Set(ClassDB.classGetEnumList(class: "EnumRegistrationHost", noInheritance: true).map { String($0) })
        assertEqual(enums, ["IntEnum", "Int64Enum", "Int32Enum", "UInt8Enum"])
    }

    func testExportedEnumPropertyMetadataMatchesRegistration() {
        // The @Export property's metadata (class_name + classIsEnum usage) must line up
        // with the registered constants: Godot's native convention is a property whose
        // class_name is "Class.Enum" while the constants live under the bare enum name.
        let host = EnumRegistrationHost()
        defer { host.free() }

        var found = false
        for prop in host.getPropertyList() {
            guard let nameV = prop["name"], let name = String(nameV), name == "mode" else { continue }

            found = true

            if let classV = prop["class_name"] {
                assertEqual(String(classV), "EnumRegistrationHost.IntEnum")
            } else {
                fail("'mode' property is missing a class_name")
            }

            if let flagsV = prop["usage"], let iflags = Int(flagsV) {
                let flags = PropertyUsageFlags(rawValue: iflags)
                assertTrue(flags.contains(.classIsEnum), "'mode' property should have the classIsEnum usage flag")
            } else {
                fail("'mode' property is missing usage flags")
            }
        }

        assertTrue(found, "Expected to find an exported 'mode' property on EnumRegistrationHost")
    }
}
