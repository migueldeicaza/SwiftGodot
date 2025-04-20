//
//  MacroGodotExportGroupTests.swift
//  SwiftGodotMacrosTests
//
//  Created by Estevan Hernandez on 12/4/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftGodotMacroLibrary
import SwiftSyntax
import SwiftParser
import SwiftSyntaxMacroExpansion

final class MacroGodotExportGroupTests: MacroGodotTestCase {
    override class var macros: [String: Macro.Type] {
        [
            "Godot": GodotMacro.self,
            "Export": GodotExport.self,
            "exportGroup": GodotMacroExportGroup.self
        ]
    }
    
    func testGodotExportGroupWithPrefix() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                #exportGroup("Vehicle", prefix: "vehicle_")
                @Export var vehicle_make: String = "Mazda"
                @Export var vehicle_model: String = "RX7"
            }
            """
        )
    }
    
    func testGodotExportGroupProducesPropertiesWithPrefixes_whenAllPropertiesAppearAfterexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                #exportGroup("Vehicle")
                @Export var make: String = "Mazda"
                @Export var model: String = "RX7"
            }
            """
        )
    }
    
    func testGodotExportGroupOnlyProducesPropertiesWithPrefixes_whenPropertiesAppearAfterexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                @Export var vin: String = "00000000000000000"
                #exportGroup("YMMS")
                @Export var year: Int = 1997
            }
            """
        )
    }
    
    func testGodotExportGroupProducesPropertiesWithoutPrefixes_whenAllPropertiesAppearAfterexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                @Export var vin: String = "00000000000000000"
                @Export var year: Int = 1997
                #exportGroup("Pointless")
            }
            """
        )
    }
    
    func testGodotExportGroupProducesPropertiesWithDifferentPrefixes_whenPropertiesAppearAfterDifferentexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                #exportGroup("VIN")
                @Export var vin: String = ""
                #exportGroup("YMM")
                @Export var year: Int = 1997
                @Export var make: String = "HONDA"
                @Export var model: String = "ACCORD"
                
            }
            """
        )
    }
    
    func testGodotExportGroupProducesTypedArrayPropertiesWithPrefixes_whenAllPropertiesAppearAfterexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                @Export var vins: TypedArray<String> = ["00000000000000000"]
                #exportGroup("YMMS")
                @Export var years: TypedArray<Int> = [1997]
            }
            """
        )
    }
    
    func testGodotExportGroupOnlyProducesTypedArrayPropertiesWithPrefixes_whenPropertiesAppearAfterexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                @Export var vins: TypedArray<String> = ["00000000000000000"]
                #exportGroup("YMMS")
                @Export var years: TypedArray<Int> = [1997]
            }
            """
        )
    }
    
    func testGodotExportGroupProducesTypedArrayPropertiesWithoutPrefixes_whenAllPropertiesAppearAfterexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                @Export var vins: TypedArray<String> = ["00000000000000000"]
                @Export var years: TypedArray<Int> = [1997]
                #exportGroup("Pointless")
            }
            """
        )
    }
    
    func testGodotExportGroupProducesTypedArrayPropertiesWithDifferentPrefixes_whenPropertiesAppearAfterDifferentexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                #exportGroup("VIN")
                @Export var vins: TypedArray<String> = [""]
                #exportGroup("YMM")
                @Export var years: TypedArray<Int> = [1997]
                @Export var makes: TypedArray<String> = ["HONDA"]
                @Export var models: TypedArray<String> = ["ACCORD"]
                
            }
            """
        )
    }        
    
    func testGodotExportGroupProducesPropertiesWithDifferentPrefixes_whenMixingTypedArrayTypedArrayAndNormalVariableProperties() {
        assertExpansion(
            of: """
            @Godot
            class Garage: Node {
                #exportGroup("Front Page")
                @Export var name: String = ""
                @Export var rating: Float = 0.0
                #exportGroup("More Details")
                @Export var reviews: TypedArray<String> = []
                @Export var checkIns: TypedArray<CheckIn> = []
                @Export var address: String = ""
                #exportGroup("Hours and Insurance")
                @Export var daysOfOperation: TypedArray<String> = []
                @Export var hours: TypedArray<String> = []
                @Export var insuranceProvidersAccepted: TypedArray<InsuranceProvider> = []
            }
            """
        )
    }
    
    func testGodotExportGroupWithPrefixTerminatedWithNoMatchingExports() {
        assertExpansion(
            of: """
            @Godot
            class Garage: Node {
                #exportGroup("Example", prefix: "example")
                @Export var bar: Bool = false
            }
            """
        )
    }
    
    func testGodotExportGroupWithPrefixTerminatedWithOneMatchingExport() {
        assertExpansion(
            of: """
            @Godot
            public class Issue353: Node {
                #exportGroup("Group With a Prefix", prefix: "prefix1")
                @Export var prefix1_prefixed_bool: Bool = true
                @Export var non_prefixed_bool: Bool = true
            }
            """
        )
    }
    
    func testGodotExportGroupWithPrefixTerminatedWithNoMatchingCollectionExports() {
        assertExpansion(
            of: """
            @Godot
            class Garage: Node {
                #exportGroup("Example", prefix: "example")
                @Export var bar: TypedArray<Bool> = [false]
            }
            """
        )
    }
    
    func testGodotExportGroupWithPrefixTerminatedWithOneMatchingCollectionExport() {
        assertExpansion(
            of: """
            @Godot
            public class Issue353: Node {
                #exportGroup("Group With a Prefix", prefix: "prefix1")
                @Export var prefix1_prefixed_bool: TypedArray<Bool> = [false]
                @Export var non_prefixed_bool: TypedArray<Bool> = [false]
            }
            """            
        )
    }
}
