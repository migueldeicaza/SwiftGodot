//
//  MacroGodotExportCollectionTests.swift
//  SwiftGodotMacrosTests
//
//  Created by Estevan Hernandez on 11/29/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftGodotMacroLibrary

final class MacroGodotExportCollectionTests: MacroGodotTestCase {
    override class var macros: [String: Macro.Type] {
        [
            "Godot": GodotMacro.self,
            "Export": GodotExport.self,
        ]
    }

    func testExportGenericArrayStringGodotMacro() {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Export
                var greetings: VariantCollection<String> = []
            }
            """
        )
    }
    
    func testExportArrayStringMacro() {        
        assertExpansion(
            of: """
            @Export var greetings: VariantCollection<String> = []
            """
        )
    }
    
    func testExportGenericArrayStringMacro() {
        assertExpansion(
            of: """
            @Export var greetings: VariantCollection<String> = []
            """
        )
    }
    
    func testExportConstantGenericArrayStringMacro() {
        assertExpansion(
            of: """
            @Export let greetings: VariantCollection<String> = []
            """
        )
    }
    
    func testExportVariantArray() {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Export var someArray: VariantArray = VariantArray()
            }
            """
        )
    }
    
    func testExportArrayIntGodotMacro() {
        assertExpansion(of: """
            @Godot
            class SomeNode: Node {
                @Export var someNumbers: VariantCollection<Int> = []
            }
            """
        )
    }

    func testExportArraysIntGodotMacro() throws {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Export var someNumbers: VariantCollection<Int> = []
                @Export var someOtherNumbers: VariantCollection<Int> = []
            }
            """
        )
    }
    
    func testGodotExportTwoStringArrays() throws {
        assertExpansion(
            of: """
            import SwiftGodot

            @Godot
            class ArrayTest: Node {
               @Export var firstNames: VariantCollection<String> = ["Thelonius"]
               @Export var lastNames: VariantCollection<String> = ["Monk"]
            }
            """
        )
    }
    
    func testExportObjectCollection() throws {
        assertExpansion(
            of: """
            @Export var greetings: ObjectCollection<Node3D> = []
            """
        )
    }
    
    func testGodotExportObjectCollection() throws {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Export var greetings: ObjectCollection<Node3D> = []
            }
            """
        )
    }
}
