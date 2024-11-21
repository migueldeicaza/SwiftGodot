//
//  Vector2iTests.swift
//
//
//  Created by Mikhail Tishin on 21.10.2023.
//

import XCTest
import SwiftGodotTestability
import RegexBuilder
@testable import SwiftGodot

final class Vector2iTests: GodotTestCase {

    static let rx_ws = ZeroOrMore { ChoiceOf { " "; "\t" } }
    static let prefixCapture = Reference<Substring>()
    static let suffixCapture = Reference<Substring>()
    static let rx_check: Regex = Regex {
        Anchor.startOfLine
        Capture(as: prefixCapture) {
            rx_ws
            "check("
            OneOrMore {
                CharacterClass.anyNonNewline
            }
            ", is:"
            rx_ws
        }
        "\""
        ZeroOrMore {
            CharacterClass.anyNonNewline
        }
        "\""
        Capture(as: suffixCapture) {
            ")"
            rx_ws
        }
        Anchor.endOfLine
    }

#if CUSTOM_BUILTIN_IMPLEMENTATIONS
    // I only update the test cases if I'm calling the Godot engine, which is authoritative. In this case, I'm using Swift covers, and the point of the tests is to verify that the covers match the engine's behavior. So it would be incorrect to update the test cases in this case.
    static let shouldUpdateTestCases: Bool = false
#else
    static let shouldUpdateTestCases: Bool = ProcessInfo.processInfo.environment["UpdateSwiftCoverTestCases", default: ""] != ""
#endif

    func check<V>(
        _ actual: V,
        is expected: String,
        file: StaticString = #filePath,
        lineNumber: UInt = #line
    ) {
        guard Self.shouldUpdateTestCases else {
            XCTAssertEqual(String(describing: actual), expected, file: file, line: lineNumber)
            return
        }

        // I'm using Godot engine functions, not Swift cover implementations.
        // I treat the Godot engine as a test oracle: it produces the correct answers.

        let originalFile = try! String(contentsOfFile: file.description)
        var lines = originalFile.split(separator: "\n", omittingEmptySubsequences: false)
        let line = String(lines[Int(lineNumber) - 1])
        guard let match = line.wholeMatch(of: Self.rx_check) else {
            XCTFail("couldn't match check call", file: file, line: lineNumber)
            return
        }
        // String(reflecting:) quotes and escapes the description of `actual`.
        let newExpected = String(reflecting: String(describing: actual))
        let newLine = "\(match[Self.prefixCapture])\(newExpected)\(match[Self.suffixCapture])"
        lines[Int(lineNumber) - 1] = newLine[...]
        let newFile = lines.joined(separator: "\n")
        try! newFile.write(toFile: file.description, atomically: true, encoding: .utf8)
    }

    func testInitFrom() {
        check(Vector2i(from: Vector2i(x: 0, y: 0)), is: "Vector2i(x: 0, y: 0)")
        check(Vector2i(from: Vector2i(x: 1, y: 1)), is: "Vector2i(x: 1, y: 1)")
        check(Vector2i(from: Vector2i(x: 2, y: 2147483647)), is: "Vector2i(x: 2, y: 2147483647)")
        check(Vector2i(from: Vector2i(x: 3, y: -1)), is: "Vector2i(x: 3, y: -1)")
        check(Vector2i(from: Vector2i(x: 4, y: -2147483648)), is: "Vector2i(x: 4, y: -2147483648)")
    }

    func testOperatorUnaryMinus () {
        var value: Vector2i
        
        value = -Vector2i (x: -1, y: 2)
        XCTAssertEqual (value.x, 1)
        XCTAssertEqual (value.y, -2)
        
        value = -Vector2i (x: 3, y: -4)
        XCTAssertEqual (value.x, -3)
        XCTAssertEqual (value.y, 4)
        
        value = -Vector2i (x: Int32.max, y: Int32.max)
        XCTAssertEqual (value.x, Int32.min + 1)
        XCTAssertEqual (value.y, Int32.min + 1)
        
        value = -Vector2i (x: Int32.min + 1, y: Int32.min + 1)
        XCTAssertEqual (value.x, Int32.max)
        XCTAssertEqual (value.y, Int32.max)
        
        value = -Vector2i (x: Int32.min, y: Int32.min)
        XCTAssertEqual (value.x, Int32.min)
        XCTAssertEqual (value.y, Int32.min)
    }
    
    func testOperatorPlus () {
        var value: Vector2i
        
        value = Vector2i (x: 1, y: 2) + Vector2i (x: 3, y: 4)
        XCTAssertEqual (value.x, 4)
        XCTAssertEqual (value.y, 6)
        
        value = Vector2i (x: -5, y: 6) + Vector2i (x: 7, y: -8)
        XCTAssertEqual (value.x, 2)
        XCTAssertEqual (value.y, -2)
        
        value = Vector2i (x: Int32.max, y: Int32.min) + Vector2i (x: Int32.min, y: Int32.max)
        XCTAssertEqual (value.x, -1)
        XCTAssertEqual (value.y, -1)
        
        value = Vector2i (x: Int32.max, y: Int32.min) + Vector2i (x: Int32.max, y: Int32.min)
        XCTAssertEqual (value.x, -2)
        XCTAssertEqual (value.y, 0)
        
        value = Vector2i (x: Int32.max, y: 1) + Vector2i (x: 1, y: 2)
        XCTAssertEqual (value.x, Int32.min)
        XCTAssertEqual (value.y, 3)
        
        value = Vector2i (x: 1, y: Int32.min) + Vector2i (x: 2, y: -1)
        XCTAssertEqual (value.x, 3)
        XCTAssertEqual (value.y, Int32.max)
    }
    
    func testOperatorMinus () {
        var value: Vector2i
        
        value = Vector2i (x: 1, y: 2) - Vector2i (x: 3, y: 4)
        XCTAssertEqual (value.x, -2)
        XCTAssertEqual (value.y, -2)
        
        value = Vector2i (x: -5, y: 6) - Vector2i (x: 7, y: -8)
        XCTAssertEqual (value.x, -12)
        XCTAssertEqual (value.y, 14)
        
        value = Vector2i (x: Int32.min, y: Int32.max) - Vector2i (x: Int32.min, y: Int32.max)
        XCTAssertEqual (value.x, 0)
        XCTAssertEqual (value.y, 0)
        
        value = Vector2i (x: Int32.min, y: Int32.max) - Vector2i (x: Int32.max, y: Int32.min)
        XCTAssertEqual (value.x, 1)
        XCTAssertEqual (value.y, -1)
        
        value = Vector2i (x: Int32.min, y: Int32.max) - Vector2i (x: 2, y: -3)
        XCTAssertEqual (value.x, Int32.max - 1)
        XCTAssertEqual (value.y, Int32.min + 2)
        
        value = Vector2i (x: Int32.max - 1, y: Int32.min + 2) - Vector2i (x: -3, y: 4)
        XCTAssertEqual (value.x, Int32.min + 1)
        XCTAssertEqual (value.y, Int32.max - 1)
    }
    
}
