//
//  MacroGodotExportSubgroupTests.swift
//  SwiftGodotMacrosTests
//
//  Created by Estevan Hernandez on 1/20/24.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftGodotMacroLibrary

final class MacroGodotExportSubroupTests: MacroGodotTestCase {
    override class var macros: [String: Macro.Type] {
        [
            "Godot": GodotMacro.self,
            "Export": GodotExport.self,
            "exportGroup": GodotMacroExportGroup.self,
            "exportSubgroup": GodotMacroExportSubgroup.self
        ]
    }
    
    func testGodotExportSubgroupWithAndWithoutPrefixWithGroup() {
        assertExpansion(
            of: """
            @Godot class Car: Node {
                #exportGroup("Vehicle")
                #exportSubgroup("VIN")
                @Export var vin: String = ""
                #exportSubgroup("YMMS", prefix: "ymms_")
                @Export var ymms_year: Int = 1998
                @Export var ymms_make: String = "Honda"
                @Export var ymms_model: String = "Odyssey"
                @Export var ymms_series: String = "LX"
            }
            """
        )
    }
}
