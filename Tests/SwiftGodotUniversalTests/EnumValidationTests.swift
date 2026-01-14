//
//  EnumValidationTests.swift
//
//
//  Created by Caleb Cranney on 1/14/2026.
//

import XCTest
@testable import ExtensionApi

final class EnumValidationTests: XCTestCase {

    // MARK: - Mock Data
    struct MockValidatable: EnumConstrained {
        let validationValue: String
        let validationFieldName: String = "testField"
        let allowedValues: [String] = ["optionA", "optionB"]
    }

    struct MockContainer {
        let child: MockValidatable
    }

    struct MockArrayContainer {
        let children: [MockValidatable]
    }

    // MARK: - Logic Tests
    func testValidValuePasses() {
        let validItem = MockValidatable(validationValue: "optionA")

        XCTAssertNoThrow(try deepValidate(validItem), "Should not throw error for valid value 'optionA'")
    }

    func testInvalidValueThrows() {
        let invalidItem = MockValidatable(validationValue: "optionC")

        XCTAssertThrowsError(try deepValidate(invalidItem)) { error in
            guard let validationError = error as? InvalidEnumValueError else {
                XCTFail("Error should be of type InvalidEnumValueError")
                return
            }

            XCTAssertEqual(validationError.value, "optionC")
            XCTAssertEqual(validationError.field, "testField")
            XCTAssertTrue(validationError.errorDescription.contains("Expected one of: optionA, optionB"))
        }
    }

    // MARK: - Recursion Tests (Mirror)
    func testDeepValidationRecurseIntoStructs() {
        let validContainer = MockContainer(child: MockValidatable(validationValue: "optionA"))
        XCTAssertNoThrow(try deepValidate(validContainer))

        let invalidContainer = MockContainer(child: MockValidatable(validationValue: "invalid"))
        XCTAssertThrowsError(try deepValidate(invalidContainer))
    }

    func testDeepValidationRecurseIntoArrays() {
        let validList = MockArrayContainer(children: [
            MockValidatable(validationValue: "optionA"),
            MockValidatable(validationValue: "optionB")
        ])
        XCTAssertNoThrow(try deepValidate(validList))

        let invalidList = MockArrayContainer(children: [
            MockValidatable(validationValue: "optionA"),
            MockValidatable(validationValue: "badOption")
        ])
        XCTAssertThrowsError(try deepValidate(invalidList))
    }

    // MARK: - Real Type Tests (JGodotMeta)
    func testJGodotMetaExampleIntegration() {
        let validArg = JGodotArgument(name: "test", type: "someType", defaultValue: "default_value", meta: "int32")
        XCTAssertNoThrow(try deepValidate(validArg))

        let invalidArg = JGodotArgument(name: "test", type: "someType", defaultValue: "default_value", meta: "not_a_real_meta_type")
        XCTAssertThrowsError(try deepValidate(invalidArg)) { error in
            guard let err = error as? InvalidEnumValueError else { return XCTFail() }
            XCTAssertEqual(err.value, "not_a_real_meta_type")
            XCTAssertEqual(err.field, "meta")
        }
    }

    func testEmptyMetaIsIgnored() {
        let emptyArg = JGodotArgument(name: "test", type: "someType", defaultValue: "default_value", meta: nil)
        XCTAssertNoThrow(try deepValidate(emptyArg))
    }
}