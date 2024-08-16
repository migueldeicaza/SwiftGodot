import MacroTesting
import XCTest

final class TextureLiteralMacroTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: allMacros) {
            super.invokeTest()
        }
    }

    func testMacroExpansion() {
        assertMacro {
            """
            let spriteTexture = #texture2DLiteral("res://assets/icon.png")
            """
        } expansion: {
            """
            let spriteTexture = {
                guard let texture: Texture2D = GD.load(path: "res://assets/icon.png") else {
                    GD.pushError("Texture could not be loaded.", "TestModule/Test.swift", 1)
                    preconditionFailure(
                        "Texture could not be loaded.",
                        file: "TestModule/Test.swift",
                        line: 1)
                }
                return texture
            }()
            """
        }
    }

    func testMacroExpansionFailure() {
        assertMacro {
            """
            let spriteTexture = #texture2DLiteral()
            """
        } diagnostics: {
            """
            let spriteTexture = #texture2DLiteral()
                                ┬──────────────────
                                ╰─ 🛑 Argument 'path' is missing.
            """
        }
    }
}
