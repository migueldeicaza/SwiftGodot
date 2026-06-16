//
//  MacroGodotEnumRegistrationTests.swift
//  SwiftGodotMacrosTests
//
//  Verifies that the @Godot macro emits a _registerEnumIfPossible call for every
//  nested enum declaration, regardless of the enum's conformances. Whether the
//  call actually registers anything is resolved at runtime by overloading, so the
//  macro emits the same call uniformly.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftGodotMacroLibrary

final class MacroGodotEnumRegistrationTests: MacroGodotTestCase {
    override class var macros: [String: Macro.Type] {
        [
            "Godot": GodotMacro.self,
            "Export": GodotExport.self,
        ]
    }

    func testRegistersEveryNestedEnumRegardlessOfConformance() {
        assertExpansion(
            of: """
            @Godot
            class EnumHost: Node {
                enum IntEnum: Int, CaseIterable {
                    case a
                    case b
                }
                enum Int64Enum: Int64, CaseIterable {
                    case low = -1
                    case high = 1
                }
                enum StringEnum: String, CaseIterable {
                    case one
                    case two
                }
                enum PlainEnum {
                    case alpha
                    case beta
                }
            }
            """
        )
    }

    func testRegistersNestedEnumAlongsideExportedProperty() {
        assertExpansion(
            of: """
            @Godot
            class Player: Node {
                enum State: Int, CaseIterable {
                    case idle
                    case running
                }
                @Export var state: State = .idle
            }
            """
        )
    }
}
