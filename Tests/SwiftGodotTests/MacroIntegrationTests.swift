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
            
            
            static func inferGTypes() -> [Variant.GType] {
                return [
                    _macroGodotGetVariablePropInfo(at: \NoMacroExample.object, name: "object").propertyType,
                    _macroGodotGetVariablePropInfo(at: \NoMacroExample.lala, name: "lala").propertyType,
                    _macroGodotGetVariablePropInfo(at: \NoMacroExample.someNode, name: "someNode").propertyType,
                    _macroGodotGetVariablePropInfo(at: \NoMacroExample.wop, name: "wop").propertyType
                ]
            }
        }
        
        XCTAssertEqual(NoMacroExample.inferGTypes(), [.object, .int, .object, .nil /* Aka Variant */])
    }
}
