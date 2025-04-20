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
                var greetings: TypedArray<String> = []
            }
            """
        )
    }
    
    func testExportArrayStringMacro() {        
        assertExpansion(
            of: """
            @Export var greetings: TypedArray<String> = []
            """
        )
    }
    
    func testExportGenericArrayStringMacro() {
        assertExpansion(
            of: """
            @Export var greetings: TypedArray<String> = []
            """
        )
    }
    
    func testExportConstantGenericArrayStringMacro() {
        assertExpansion(
            of: """
            @Export let greetings: TypedArray<String> = []
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
                @Export var someNumbers: TypedArray<Int> = []
            }
            """
        )
    }

    func testExportArraysIntGodotMacro() throws {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Export var someNumbers: TypedArray<Int> = []
                @Export var someOtherNumbers: TypedArray<Int> = []
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
               @Export var firstNames: TypedArray<String> = ["Thelonius"]
               @Export var lastNames: TypedArray<String> = ["Monk"]
            }
            """
        )
    }
    
    func testExportTypedArray() throws {
        assertExpansion(
            of: """
            @Export var greetings: TypedArray<Node3D> = []
            """
        )
    }
    
    func testGodotExportTypedArray() throws {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Export var greetings: TypedArray<Node3D> = []
            }
            """
        )
    }
}
