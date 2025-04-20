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
        enum EnumExample: Int, CaseIterable {
            case zero = 0
            case one = 1
            case two = 2
        }
        
        struct Wow: VariantConvertible {
            static func fromFastVariantOrThrow(_ variant: borrowing SwiftGodot.FastVariant) throws(SwiftGodot.VariantConversionError) -> Wow {
                Wow()
            }
            
            func toFastVariant() -> SwiftGodot.FastVariant? {
                nil
            }
        }
        
        class NoMacroExample {
            var meshInstance: MeshInstance3D? = nil
            var variant = 1.toVariant()
            var optionalVariant: Variant?
            var garray: VariantArray = VariantArray()
            var object = Object() as Object?
            var lala = [42, 31].min() ?? 10
            lazy var someNode = {
                Node3D()
            }()
            var wop = 42 as Int?
            var variantCollection = VariantCollection<Int>()
            var objectCollection = ObjectCollection<MeshInstance2D>()
            var enumExample = EnumExample.two
            var wow = Wow()
            var optionalWow = Wow()
        }
        
        XCTAssertEqual(_propInfo(at: \NoMacroExample.wow, name: "").propertyType, .nil)
        XCTAssertEqual(_propInfo(at: \NoMacroExample.optionalWow, name: "").propertyType, .nil)
        XCTAssertEqual(_propInfo(at: \NoMacroExample.variant, name: "").propertyType, .nil)
        XCTAssertEqual(_propInfo(at: \NoMacroExample.variant, name: "").usage, .nilIsVariant)
        XCTAssertEqual(_propInfo(at: \NoMacroExample.optionalVariant, name: "").propertyType, .nil)
        XCTAssertEqual(_propInfo(at: \NoMacroExample.garray, name: "").propertyType, .array)
        XCTAssertEqual(_propInfo(at: \NoMacroExample.object, name: "").propertyType, .object)
        XCTAssertEqual(_propInfo(at: \NoMacroExample.lala, name: "").propertyType, .int)
        XCTAssertEqual(_propInfo(at: \NoMacroExample.someNode, name: "").propertyType, .object)
        XCTAssertEqual(_propInfo(at: \NoMacroExample.wop, name: "").propertyType, .nil)
        XCTAssertEqual(_propInfo(at: \NoMacroExample.variantCollection, name: "").className, "Array[int]")
        XCTAssertEqual(_propInfo(at: \NoMacroExample.objectCollection, name: "").className, "Array[MeshInstance2D]")
        
        let enumPropInfo = _propInfo(at: \NoMacroExample.enumExample, name: "")
        XCTAssertEqual(enumPropInfo.propertyType, .int)
        XCTAssertEqual(enumPropInfo.hintStr, "zero:0,one:1,two:2")
        
        let meshInstancePropInfo = _propInfo(at: \NoMacroExample.meshInstance, name: "")
        XCTAssertEqual(meshInstancePropInfo.hint, .nodeType)
        XCTAssertEqual(meshInstancePropInfo.hintStr, "MeshInstance3D")
        
        let closure = { (a: Int, b: Int) -> Int in
            a + b
        }
        
        XCTAssertEqual(_invokeGetter(closure)?.gtype, .callable)
    }
}
