//
//  SwiftGodotNativeHandleDiscardingMacroTests.swift
//  SwiftGodot
//
//  Created by Marquis Kurt on 6/9/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftGodotMacroLibrary

final class NativeHandleDiscardingMacroTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "NativeHandleDiscarding": NativeHandleDiscardingMacro.self
    ]

    func testNativeHandleDiscardingMacro() {
        assertMacroExpansion(
            """
            @NativeHandleDiscarding
            class MyNode: Sprite2D {
                var collider: CollisionShape2D?
            }
            """,
            expandedSource: """

            class MyNode: Sprite2D {
                var collider: CollisionShape2D?

                required init(nativeHandle _: UnsafeRawPointer) {fatalError("init(nativeHandle:) has not been implemented")
                }
            }
            """,
            macros: testMacros
        )
    }

    func testNativeHandleDiscardingMacroDiagnostics() {
        assertMacroExpansion(
            """
            @NativeHandleDiscarding
            struct MyNode: Sprite2D {
                var collider: CollisionShape2D?
            }
            """,
            expandedSource: """
            
            struct MyNode: Sprite2D {
                var collider: CollisionShape2D?
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NativeHandleDiscarding can only be applied to a 'class'", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
}
