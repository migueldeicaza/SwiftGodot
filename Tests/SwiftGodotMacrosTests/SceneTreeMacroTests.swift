//
//  SceneTreeMacroTests.swift
//  SwiftGodot
//
//  Created by Marquis Kurt on 21/6/23.
//

import SwiftGodotMacroLibrary
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class SceneTreeMacroTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "SceneTree": SceneTreeMacro.self,
        "Node": SceneTreeMacro.self,
    ]

    func testSceneTreeMacroExpansion() {
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

    func testSceneTreeMacroExpansionWithImplicitlyUnwrappedOptional() {
        assertMacroExpansion(
            """
            class MyNode: Node {
                @SceneTree(path: "Entities/CharacterBody2D")
                var character: CharacterBody2D!
            }
            """,
            expandedSource: """
            class MyNode: Node {
                var character: CharacterBody2D! {
                    get {
                        getNodeOrNull(path: NodePath(stringLiteral: "Entities/CharacterBody2D")) as? CharacterBody2D
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testSceneTreeMacroExpansionWithDefaultArgument() {
        assertMacroExpansion(
            """
            class MyNode: Node {
                @SceneTree var character: CharacterBody2D?
            }
            """,
            expandedSource: """
            class MyNode: Node {
                var character: CharacterBody2D? {
                    get {
                        getNodeOrNull(path: NodePath(stringLiteral: "character")) as? CharacterBody2D
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testNodeMacroExpansionWithOptional() {
        assertMacroExpansion(
            """
            class MyNode: Node {
                @Node("Entities/CharacterBody2D")
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

    func testNodeMacroExpansion() {
        assertMacroExpansion(
            """
            class MyNode: Node {
                @Node("Entities/CharacterBody2D")
                var character: CharacterBody2D
            }
            """,
            expandedSource: """
            class MyNode: Node {
                var character: CharacterBody2D {
                    get {
                        getNodeOrNull(path: NodePath(stringLiteral: "Entities/CharacterBody2D")) as! CharacterBody2D
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testNodeMacroExpansionWithDefaultArgument() {
        assertMacroExpansion(
            """
            class MyNode: Node {
                @Node var character: CharacterBody2D?
            }
            """,
            expandedSource: """
            class MyNode: Node {
                var character: CharacterBody2D? {
                    get {
                        getNodeOrNull(path: NodePath(stringLiteral: "character")) as? CharacterBody2D
                    }
                }
            }
            """,
            macros: testMacros
        )
    }
}
