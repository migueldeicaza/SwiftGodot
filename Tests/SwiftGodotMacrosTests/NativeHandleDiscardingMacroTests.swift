import MacroTesting
import XCTest

final class NativeHandleDiscardingMacroTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: allMacros) {
            super.invokeTest()
        }
    }

    func testNativeHandleDiscardingMacro() {
        assertMacro {
            """
            @NativeHandleDiscarding
            class MyNode: Sprite2D {
                var collider: CollisionShape2D?
            }
            """
        } expansion: {
            """
            class MyNode: Sprite2D {
                var collider: CollisionShape2D?

                required init(nativeHandle _: UnsafeRawPointer) {fatalError("init(nativeHandle:) has not been implemented")
                }
            }
            """
        }
    }

    func testNativeHandleDiscardingMacroDiagnostics() {
        assertMacro {
            """
            @NativeHandleDiscarding
            struct MyNode: Sprite2D {
                var collider: CollisionShape2D?
            }
            """
        } diagnostics: {
            """
            @NativeHandleDiscarding
            ╰─ 🛑 @NativeHandleDiscarding can only be applied to a 'class'
            struct MyNode: Sprite2D {
                var collider: CollisionShape2D?
            }
            """
        }
    }
}
