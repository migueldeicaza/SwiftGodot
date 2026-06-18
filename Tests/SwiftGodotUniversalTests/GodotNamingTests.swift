//
//  GodotNamingTests.swift
//
//  Verifies the Swift → Godot identifier conversion used when symbols are
//  registered with the engine. These tests build with the package's default
//  traits, so `automatic_godot_naming_convention` is enabled and the public
//  `_convert*` entry points perform the conversion.
//

import XCTest
import Foundation
@testable import SwiftGodot

final class GodotNamingTests: XCTestCase {

    // MARK: - Member names (camelCase / PascalCase -> snake_case)

    func testMemberNameConversion() {
        let cases: [(String, String)] = [
            ("computeSpeed", "compute_speed"),
            ("computeSpeedValue", "compute_speed_value"),
            ("makeHTTPRequest", "make_http_request"),
            ("HTTPServer", "http_server"),
            ("URLString", "url_string"),
            ("maxHealthPoints", "max_health_points"),
            ("maxHP", "max_hp"),
            ("playerID", "player_id"),
            ("getValue2", "get_value2"),
            ("vector2D", "vector2d"),
            ("position3D", "position3d"),
            ("run", "run"),
            ("_ready", "_ready"),
            ("_process", "_process"),
            // Already snake_case -> idempotent
            ("get_my_prop", "get_my_prop"),
            ("set_max_health_points", "set_max_health_points"),
            // get_/set_ prefixes combined with a camelCase tail
            ("get_myProp", "get_my_prop"),
            ("set_myProp", "set_my_prop"),
        ]

        for (input, expected) in cases {
            XCTAssertEqual(
                _convertMemberNameToMatchGodotConvention(input),
                expected,
                "member conversion of \"\(input)\""
            )
        }
    }

    func testMemberNameConversionIsIdempotent() {
        for input in ["computeSpeed", "HTTPServer", "get_myProp", "vector2D", "_ready"] {
            let once = _convertMemberNameToMatchGodotConvention(input)
            let twice = _convertMemberNameToMatchGodotConvention(once)
            XCTAssertEqual(once, twice, "conversion of \"\(input)\" should be idempotent")
        }
    }

    // MARK: - Enum case names (camelCase -> UPPER_SNAKE_CASE)

    func testEnumCaseNameConversion() {
        let cases: [(String, String)] = [
            ("fireDamage", "FIRE_DAMAGE"),
            ("iceDamage", "ICE_DAMAGE"),
            ("a", "A"),
            ("lowHP", "LOW_HP"),
            ("modeKinematic", "MODE_KINEMATIC"),
            ("vector2D", "VECTOR2D"),
        ]

        for (input, expected) in cases {
            XCTAssertEqual(
                _convertEnumCaseNameToMatchGodotConvention(input),
                expected,
                "enum case conversion of \"\(input)\""
            )
        }
    }

    // MARK: - Parity with the legacy regex implementation

    /// The new converter must reproduce the legacy `camelToSnake` behavior used
    /// historically by the generator and the macro library, including the
    /// `2_D`/`3_D` fix-ups.
    func testParityWithLegacyRegex() {
        let corpus = [
            "computeSpeed", "computeSpeedValue", "makeHTTPRequest", "HTTPServer",
            "URLString", "maxHealthPoints", "maxHP", "playerID", "getValue2",
            "vector2D", "position3D", "node2D", "size3D", "run", "_ready",
            "_process", "_input", "getMyProp", "setMyProp", "isOnFloor",
            "globalPosition", "zIndex", "useParentMaterial", "AABBValue",
        ]

        for input in corpus {
            XCTAssertEqual(
                _convertMemberNameToMatchGodotConvention(input),
                legacyCamelToSnake(input),
                "parity for \"\(input)\""
            )
        }
    }

    // Legacy reference implementation (NSRegularExpression-based), copied from
    // Generator/StringOperations.swift / MacroGodot.swift.
    private func legacyCamelToSnake(_ s: String) -> String {
        func processCamelCaseRegex(_ value: String, pattern: String) -> String? {
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: value.count)
            return regex?.stringByReplacingMatches(in: value, options: [], range: range, withTemplate: "$1_$2")
        }
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        let snake = processCamelCaseRegex(s, pattern: acronymPattern)
            .flatMap { processCamelCaseRegex($0, pattern: normalPattern) }?
            .lowercased() ?? s.lowercased()
        return snake
            .replacingOccurrences(of: "2_d", with: "2d")
            .replacingOccurrences(of: "3_d", with: "3d")
    }
}
