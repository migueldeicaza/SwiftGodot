import MacroTesting
import XCTest

final class SceneTreeMacroTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: allMacros) {
            super.invokeTest()
        }
    }

    func testMacroExpansion() {
        assertMacro {
            """
            class MyNode: Node {
                @SceneTree(path: "Entities/CharacterBody2D")
                var character: CharacterBody2D?
            }
            """
        } expansion: {
            """
            class MyNode: Node {
                var character: CharacterBody2D? {
                    get {
                        getNodeOrNull(path: NodePath(stringLiteral: "Entities/CharacterBody2D")) as? CharacterBody2D
                    }
                }
            }
            """
        }
    }

    func testMacroExpansionWithImplicitlyUnwrappedOptional() {
        assertMacro {
            """
            class MyNode: Node {
                @SceneTree(path: "Entities/CharacterBody2D")
                var character: CharacterBody2D!
            }
            """
        } expansion: {
            """
            class MyNode: Node {
                var character: CharacterBody2D! {
                    get {
                        getNodeOrNull(path: NodePath(stringLiteral: "Entities/CharacterBody2D")) as? CharacterBody2D
                    }
                }
            }
            """
        }
    }

    func testMacroExpansionWithDefaultArgument() {
        assertMacro {
            """
            class MyNode: Node {
                @SceneTree var character: CharacterBody2D?
            }
            """
        } expansion: {
            """
            class MyNode: Node {
                var character: CharacterBody2D? {
                    get {
                        getNodeOrNull(path: NodePath(stringLiteral: "character")) as? CharacterBody2D
                    }
                }
            }
            """
        }
    }

    func testMacroNotOptionalDiagnostic() {
        assertMacro {
            """
            class MyNode: Node {
                @SceneTree(path: "Entities/CharacterBody2D")
                var character: CharacterBody2D
            }
            """
        } diagnostics: {
            """
            class MyNode: Node {
                @SceneTree(path: "Entities/CharacterBody2D")
                ╰─ 🛑 Stored properties with SceneTree must be marked as Optional
                   ✏️ Mark as Optional
                var character: CharacterBody2D
            }
            """
        } fixes: {
            """
            class MyNode: Node {
                @SceneTree(path: "Entities/CharacterBody2D")
                var character: CharacterBody2D?
            }
            """
        } expansion: {
            """
            class MyNode: Node {
                var character: CharacterBody2D? {
                    get {
                        getNodeOrNull(path: NodePath(stringLiteral: "Entities/CharacterBody2D")) as? CharacterBody2D
                    }
                }
            }
            """
        }
    }
}
