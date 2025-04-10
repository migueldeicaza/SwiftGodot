//
//  MacroIntegrationTests.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 10/04/2025.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class MacroIntegrationTests: GodotTestCase {
    func testCorrectPropInfoInferrenceWithoutMacro() {
        class NoMacroExample {
            var object = Object() as Object?
            
            var lala = [42, 31].min() ?? 10
            
            lazy var someNode = {
                Node3D()
            }()
            
            var wop = 42 as Int?
            
            var variantCollection = VariantCollection<Int>()
            var objectCollection = ObjectCollection<MeshInstance2D>()
        }
            
        XCTAssertEqual(_macroGodotGetVariablePropInfo(at: \NoMacroExample.object, name: "").propertyType, .object)
        XCTAssertEqual(_macroGodotGetVariablePropInfo(at: \NoMacroExample.lala, name: "").propertyType, .int)
        XCTAssertEqual(_macroGodotGetVariablePropInfo(at: \NoMacroExample.someNode, name: "").propertyType, .object)
        XCTAssertEqual(_macroGodotGetVariablePropInfo(at: \NoMacroExample.wop, name: "").propertyType, .nil)
        XCTAssertEqual(_macroGodotGetVariablePropInfo(at: \NoMacroExample.variantCollection, name: "").className, "Array[int]")
        XCTAssertEqual(_macroGodotGetVariablePropInfo(at: \NoMacroExample.objectCollection, name: "").className, "Array[MeshInstance2D]")
        
        let a = _macroGodotGetVariablePropInfo(at: \NoMacroExample.objectCollection, name: "")
        print(a)
    }
}
