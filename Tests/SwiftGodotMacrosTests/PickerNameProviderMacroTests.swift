//
//  SwiftGodotNamePickerMacroTests.swift
//  SwiftGodot
//
//  Created by Marquis Kurt on 6/9/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftGodotMacroLibrary

final class PickerNameProviderMacroTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "PickerNameProvider": PickerNameProviderMacro.self
    ]
    
    func testPickerNameProviderMacro() {
        assertMacroExpansion(
            """
            @PickerNameProvider
            enum Character: Int {
                case chelsea
                case sky
            }
            """,
            expandedSource: """

            enum Character: Int {
                case chelsea
                case sky
            }

            extension Character: CaseIterable {
            }
            
            extension Character: Nameable {
                var name: String {
                    switch self {
                    case .chelsea:
                        return "Chelsea"
                    case .sky:
                        return "Sky"
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testPickerNameProviderMacroDiagnostics() {
        assertMacroExpansion(
            """
            @PickerNameProvider
            struct Character {
            }
            """,
            expandedSource: """

            struct Character {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@PickerNameProvider can only be applied to an 'enum'", line: 1, column: 1)
            ],
            macros: testMacros
        )

        assertMacroExpansion(
            """
            @PickerNameProvider
            enum Character {
                case chelsea
                case sky
            }
            """,
            expandedSource: """

            enum Character {
                case chelsea
                case sky
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@PickerNameProvider requires an Int backing", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
}
