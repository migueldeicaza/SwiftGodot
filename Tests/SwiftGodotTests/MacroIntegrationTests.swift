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
            var variantCollection = TypedArray<Int>()
            var objectCollection = TypedArray<MeshInstance2D?>()
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
    
    func testCorrectRegistrationSequence() {
        class A: Object {
            override class var classInitializationLevel: GDExtension.InitializationLevel {
                .core
            }
        }
        
        class B: A {
            override class var classInitializationLevel: GDExtension.InitializationLevel {
                .servers
            }
        }
        
        class C: B {
            override class var classInitializationLevel: GDExtension.InitializationLevel {
                .scene
            }
        }
        
        class D0: C {
            override class var classInitializationLevel: GDExtension.InitializationLevel {
                .editor
            }
        }
        
        class D1: C {
            override class var classInitializationLevel: GDExtension.InitializationLevel {
                .editor
            }
        }
        
        var types: [GDExtension.InitializationLevel: [Object.Type]] = [:]
        do {
            types = try [A.self, B.self, C.self, D0.self, D1.self].prepareForRegistration()
        } catch {
            XCTFail("\(error)")
            return
        }
        
        XCTAssertEqual(types[.core]?.contains(where: { $0 == A.self}), true)
        XCTAssertEqual(types[.servers]?.contains(where: { $0 == B.self}), true)
        XCTAssertEqual(types[.scene]?.contains(where: { $0 == C.self}), true)
        XCTAssertEqual(types[.editor]?.contains(where: { $0 == D0.self}), true)
        XCTAssertEqual(types[.editor]?.contains(where: { $0 == D1.self}), true)
        
        XCTAssertEqual(types[.core]?.count, 1)
        XCTAssertEqual(types[.servers]?.count, 1)
        XCTAssertEqual(types[.scene]?.count, 1)
        XCTAssertEqual(types[.editor]?.count, 2)
        
        XCTAssertEqual(minimumInitializationLevel(for: types), .core)
        
        class E: Object {
            override class var classInitializationLevel: GDExtension.InitializationLevel {
                .scene
            }
        }
        
        class F: E {
            override class var classInitializationLevel: GDExtension.InitializationLevel {
                .core
            }
        }
        
        do {
            types = try [E.self, F.self].prepareForRegistration()
            XCTFail()
        } catch {
            // expected error
        }
        
        XCTAssertEqual(minimumInitializationLevel(for: [:]), .editor)
        
        class G: Object {
        }
                
        do {
            types = try [G.self].prepareForRegistration()
            XCTAssertEqual(minimumInitializationLevel(for: types), .scene)
        } catch {
            XCTFail("\(error)")
            return
        }
    }
}
