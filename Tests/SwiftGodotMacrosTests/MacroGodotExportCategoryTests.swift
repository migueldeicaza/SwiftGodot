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
    
    func testGodotExportGroupProducesVariantCollectionPropertiesWithPrefixes_whenAllPropertiesAppearAfterexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                @Export var vins: VariantCollection<String> = ["00000000000000000"]
                #exportGroup("YMMS")
                @Export var years: VariantCollection<Int> = [1997]
            }
            """
        )
    }
    
    func testGodotExportGroupOnlyProducesVariantCollectionPropertiesWithPrefixes_whenPropertiesAppearAfterexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                @Export var vins: VariantCollection<String> = ["00000000000000000"]
                #exportGroup("YMMS")
                @Export var years: VariantCollection<Int> = [1997]
            }
            """
        )
    }
    
    func testGodotExportGroupProducesVariantCollectionPropertiesWithoutPrefixes_whenAllPropertiesAppearAfterexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                @Export var vins: VariantCollection<String> = ["00000000000000000"]
                @Export var years: VariantCollection<Int> = [1997]
                #exportGroup("Pointless")
            }
            """
        )
    }
    
    func testGodotExportGroupProducesVariantCollectionPropertiesWithDifferentPrefixes_whenPropertiesAppearAfterDifferentexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                #exportGroup("VIN")
                @Export var vins: VariantCollection<String> = [""]
                #exportGroup("YMM")
                @Export var years: VariantCollection<Int> = [1997]
                @Export var makes: VariantCollection<String> = ["HONDA"]
                @Export var models: VariantCollection<String> = ["ACCORD"]
                
            }
            """
        )
    }
    
    // TODO: and ObjectCollection as well ...
    
    func testGodotExportGroupProducesObjectCollectionPropertiesWithPrefixes_whenAllPropertiesAppearAfterexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                #exportGroup("Vehicle")
                @Export var makes: ObjectCollection<Node> = []
                @Export var model: ObjectCollection<Node> = []
            }
            """
        )
    }
    
    func testGodotExportGroupOnlyProducesObjectCollectionPropertiesWithPrefixes_whenPropertiesAppearAfterexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                @Export var vins: ObjectCollection<Node> = []
                #exportGroup("YMMS")
                @Export var years: ObjectCollection<Node> = []
            }
            """
        )
    }
    
    func testGodotExportGroupProducesObjectCollectionPropertiesWithoutPrefixes_whenAllPropertiesAppearAfterexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                @Export var vins: ObjectCollection<Node> = []
                @Export var years: ObjectCollection<Node> = []
                #exportGroup("Pointless")
            }
            """
        )
    }
    
    func testGodotExportGroupProducesObjectCollectionPropertiesWithDifferentPrefixes_whenPropertiesAppearAfterDifferentexportGroup() {
        assertExpansion(
            of: """
            @Godot
            class Car: Node {
                #exportGroup("VIN")
                @Export var vins: ObjectCollection<Node> = []
                #exportGroup("YMM")
                @Export var years: ObjectCollection<Node> = []
                @Export var makes: ObjectCollection<Node> = []
                @Export var models: ObjectCollection<Node> = []
                
            }
            """
        )
    }
    
    func testGodotExportGroupProducesPropertiesWithDifferentPrefixes_whenMixingVariantCollectionObjectCollectionAndNormalVariableProperties() {
        assertExpansion(
            of: """
            @Godot
            class Garage: Node {
                #exportGroup("Front Page")
                @Export var name: String = ""
                @Export var rating: Float = 0.0
                #exportGroup("More Details")
                @Export var reviews: VariantCollection<String> = []
                @Export var checkIns: ObjectCollection<CheckIn> = []
                @Export var address: String = ""
                #exportGroup("Hours and Insurance")
                @Export var daysOfOperation: VariantCollection<String> = []
                @Export var hours: VariantCollection<String> = []
                @Export var insuranceProvidersAccepted: ObjectCollection<InsuranceProvider> = []
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
                @Export var bar: VariantCollection<Bool> = [false]
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
                @Export var prefix1_prefixed_bool: VariantCollection<Bool> = [false]
                @Export var non_prefixed_bool: VariantCollection<Bool> = [false]
            }
            """            
        )
    }
}
