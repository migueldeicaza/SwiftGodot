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
            enum Character: Int64 {
                case chelsea
                case sky
            }
            @PickerNameProvider
            enum Character2: Int {
                case chelsea
                case sky
            }
            """,
            expandedSource: """

            enum Character: Int64 {
                case chelsea
                case sky
            }
            enum Character2: Int {
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

            extension Character2: CaseIterable {
            }
            
            extension Character2: Nameable {
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
    }
}
