//
//  SwiftGodotInitSwiftExtensionMacroTests.swift
//  SwiftGodot
//
//  Created by Marquis Kurt on 6/9/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftGodot
import SwiftGodotMacroLibrary

final class InitSwiftExtensionMacroTests: MacroGodotTestCase {
    override class var macros: [String : any Macro.Type] {
        ["initSwiftExtension": InitSwiftExtensionMacro.self]
    }
    
    func testInitWithSwiftExtensionMacroWithTypes() {
        assertExpansion(of: """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", types: [ChrysalisNode.self, CaterpillarNode.self, ButterflyNode.self])            
            """
        )
    }
    
    func testInitSwiftExtensionMacroWithUnspecifiedTypes() {
        assertExpansion(of: """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point")
            """
        )
    }

    func testInitSwiftExtensionMacroWithEmptyTypes() {
        assertExpansion(of: """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", types: [])
            """
        )
    }

    func testInitSwiftExtensionMacroWithSceneTypesOnly() {
        assertExpansion(of: """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", sceneTypes: [ChrysalisNode.self]
            """
        )
    }

    func testInitSwiftExtensionMacroWithEditorTypes() {
        assertExpansion(of: """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", editorTypes: [CaterpillarNode.self])
            """
        )
    }

    func testInitSwiftExtensionMacroWithCoreTypes() {
        assertExpansion(of: """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", coreTypes: [ChrysalisNode.self]
            """
        )
    }

    func testInitSwiftExtensionMacroWithServerTypes() {
        assertExpansion(of: """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", serverTypes: [ButterflyNode.self])
            """
        )
    }

    func testInitSwiftExtensionMacroWithAllTypes() {
        assertExpansion(of: """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", coreTypes: [EggNode.self], editorTypes: [CaterpillarNode.self], sceneTypes: [ChrysalisNode.self], serverTypes: [ButterflyNode.self])
            """
        )
    }
}
