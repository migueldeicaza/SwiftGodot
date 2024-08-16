import MacroTesting
import XCTest

final class PickerNameProviderMacroTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: allMacros) {
            super.invokeTest()
        }
    }

    func testPickerNameProviderMacro() {
        assertMacro {
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
            """
        } expansion: {
            """
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
            """
        }
    }

    func testPickerNameProviderMacroDiagnostics() {
        assertMacro {
            """
            @PickerNameProvider
            struct Character {
            }
            """
        } diagnostics: {
            """
            @PickerNameProvider
            ╰─ 🛑 @PickerNameProvider can only be applied to an 'enum'
            struct Character {
            }
            """
        }
    }
}
