//
//  TextureLiteralMacroTests.swift
//  SwiftGodot
//
//  Created by Marquis Kurt on 6/11/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftGodotMacroLibrary

final class TextureLiteralMacroTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "texture2DLiteral": Texture2DLiteralMacro.self
    ]

    func testMacroExpansion() {
        assertMacroExpansion(
            """
            let spriteTexture = #texture2DLiteral("res://assets/icon.png")
            """,
            expandedSource: """
            let spriteTexture = {
                guard let texture: Texture2D = GD.load(path: "res://assets/icon.png") else {
                    preconditionFailure(
                        "Texture could not be loaded.",
                        file: "TestModule/test.swift",
                        line: 1)
                }
                return texture
            }()
            """,
            macros: testMacros
        )
    }

    func testMacroExpansionFailure() {
        assertMacroExpansion(
            """
            let spriteTexture = #texture2DLiteral()
            """,
            expandedSource: """
            let spriteTexture = ""
            """,
            diagnostics: [
                .init(message: "Argument 'path' is missing.", line: 1, column: 21)
            ],
            macros: testMacros
        )
    }
}
