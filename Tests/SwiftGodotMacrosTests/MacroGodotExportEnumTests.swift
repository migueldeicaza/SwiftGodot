//
//  MacroGodotExportEnumTests.swift
//  SwiftGodotMacrosTests
//
//  Created by Estevan Hernandez on 11/29/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftGodotMacroLibrary

final class MacroGodotExportEnumTests: MacroGodotTestCase {
    override class var macros: [String: Macro.Type] {
        [
            "Godot": GodotMacro.self,
            "Export": GodotExport.self,
        ]
    }
    
    func testExportEnumGodot() {
        assertExpansion(
            of: """
            enum Demo: Int, CaseIterable {
                case first
            }
            enum Demo64: Int64, CaseIterable {
                case first
            }
            @Godot
            class SomeNode: Node {
                @Export(.enum) var demo: Demo
                @Export(.enum) var demo64: Demo64
            }
            """
        )
    }
}
