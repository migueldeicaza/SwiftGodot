//
//  SceneTreeMacroTests.swift
//  SwiftGodot
//
//  Created by Marquis Kurt on 21/6/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftGodotMacroLibrary

final class SceneTreeMacroTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "SceneTree": SceneTreeMacro.self
    ]

    func testMacroExpansion() {
        assertMacroExpansion(
            """
            class MyNode: Node {
                @SceneTree(path: "Entities/CharacterBody2D")
                var character: CharacterBody2D?
            }
            """,
            expandedSource: """
            class MyNode: Node {
                var character: CharacterBody2D? {
                    get {
                        getNodeOrNull(path: NodePath(stringLiteral: "Entities/CharacterBody2D")) as? CharacterBody2D
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testMacroMissingPathDiagnostic() {
        assertMacroExpansion(
            """
            class MyNode: Node {
                @SceneTree
                var character: CharacterBody2D?
            }
            """,
            expandedSource: """
            class MyNode: Node {
                var character: CharacterBody2D? {
                    get {
                        getNodeOrNull(path: NodePath(stringLiteral: "")) as? Node
                    }
                }
            }
            """,
            diagnostics: [
                .init(message: "Missing argument 'path'", line: 2, column: 5)
            ],
            macros: testMacros
        )
    }

    func testMacroNotOptionalDiagnostic() {
        assertMacroExpansion(
            """
            class MyNode: Node {
                @SceneTree(path: "Entities/CharacterBody2D")
                var character: CharacterBody2D
            }
            """,
            expandedSource: """
            class MyNode: Node {
                var character: CharacterBody2D {
                    get {
                        getNodeOrNull(path: NodePath(stringLiteral: "Entities/CharacterBody2D")) as? CharacterBody2D
                    }
                }
            }
            """,
            diagnostics: [
                .init(message: "Stored properties with SceneTree must be marked as Optional",
                      line: 2,
                      column: 5,
                      fixIts: [
                        .init(message: "Mark as Optional")
                      ])
            ],
            macros: testMacros
        )
    }
}
