//
//  MacroIntegrationTests.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 10/04/2025.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class MacroIntegrationTests {
    public func testCorrectPropInfoInferrenceWithoutMacro() {
        enum EnumExample: Int, CaseIterable {
            case zero = 0
            case one = 1
            case two = 2
        }

        struct Wow: VariantConvertible {
            static func fromVariantOrThrow(_ variant: borrowing SwiftGodotRuntime.Variant) throws(SwiftGodot.VariantConversionError) -> Wow {
                Wow()
            }

            func toVariant() -> SwiftGodotRuntime.Variant? {
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

        assertEqual(_propInfo(at: \NoMacroExample.wow, name: "").propertyType, .nil)
        assertEqual(_propInfo(at: \NoMacroExample.optionalWow, name: "").propertyType, .nil)
        assertEqual(_propInfo(at: \NoMacroExample.variant, name: "").propertyType, .nil)
        assertEqual(_propInfo(at: \NoMacroExample.variant, name: "").usage, [.nilIsVariant, .default])
        assertEqual(_propInfo(at: \NoMacroExample.optionalVariant, name: "").propertyType, .nil)
        assertEqual(_propInfo(at: \NoMacroExample.garray, name: "").propertyType, .array)
        assertEqual(_propInfo(at: \NoMacroExample.object, name: "").propertyType, .object)
        assertEqual(_propInfo(at: \NoMacroExample.lala, name: "").propertyType, .int)
        assertEqual(_propInfo(at: \NoMacroExample.someNode, name: "").propertyType, .object)
        assertEqual(_propInfo(at: \NoMacroExample.wop, name: "").propertyType, .nil)
        assertEqual(_propInfo(at: \NoMacroExample.variantCollection, name: "").className, "Array[int]")
        assertEqual(_propInfo(at: \NoMacroExample.objectCollection, name: "").className, "Array[MeshInstance2D]")

        let enumPropInfo = _propInfo(at: \NoMacroExample.enumExample, name: "")
        assertEqual(enumPropInfo.propertyType, .int)
        assertEqual(enumPropInfo.hintStr, "zero:0,one:1,two:2")

        let meshInstancePropInfo = _propInfo(at: \NoMacroExample.meshInstance, name: "")
        assertEqual(meshInstancePropInfo.hint, .nodeType)
        assertEqual(meshInstancePropInfo.hintStr, "MeshInstance3D")

        let closure = { (a: Int, b: Int) -> Int in
            a + b
        }

        assertEqual(_invokeGetter(closure)?.gtype, .callable)
    }

    func testCorrectRegistrationSequence() {
        class A: Object {
            override class var classInitializationLevel: ExtensionInitializationLevel {
                .core
            }
        }

        class B: A {
            override class var classInitializationLevel: ExtensionInitializationLevel {
                .servers
            }
        }

        class C: B {
            override class var classInitializationLevel: ExtensionInitializationLevel {
                .scene
            }
        }

        class D0: C {
            override class var classInitializationLevel: ExtensionInitializationLevel {
                .editor
            }
        }

        class D1: C {
            override class var classInitializationLevel: ExtensionInitializationLevel {
                .editor
            }
        }

        var types: [ExtensionInitializationLevel: [Object.Type]] = [:]
        do {
            types = try [A.self, B.self, C.self, D0.self, D1.self].prepareForRegistration()
        } catch {
            fail("\(error)")
            return
        }

        assertEqual(types[.core]?.contains(where: { $0 == A.self}), true)
        assertEqual(types[.servers]?.contains(where: { $0 == B.self}), true)
        assertEqual(types[.scene]?.contains(where: { $0 == C.self}), true)
        assertEqual(types[.editor]?.contains(where: { $0 == D0.self}), true)
        assertEqual(types[.editor]?.contains(where: { $0 == D1.self}), true)

        assertEqual(types[.core]?.count, 1)
        assertEqual(types[.servers]?.count, 1)
        assertEqual(types[.scene]?.count, 1)
        assertEqual(types[.editor]?.count, 2)

        assertEqual(minimumInitializationLevel(for: types), .core)

        class E: Object {
            override class var classInitializationLevel: ExtensionInitializationLevel {
                .scene
            }
        }

        class F: E {
            override class var classInitializationLevel: ExtensionInitializationLevel {
                .core
            }
        }

        do {
            types = try [E.self, F.self].prepareForRegistration()
            fail()
        } catch {
            // expected error
        }

        assertEqual(minimumInitializationLevel(for: [:]), .editor)

        class G: Object {
        }

        do {
            types = try [G.self].prepareForRegistration()
            assertEqual(minimumInitializationLevel(for: types), .scene)
        } catch {
            fail("\(error)")
            return
        }
    }

    /// Tests that the `SwiftGodot._propInfo` is selecting the overload
    /// that is able to resolve the optional-DemoProbe into a .nodeType and a DemoProbe
    func testPropertyRegistration() {
        let detected = SwiftGodot._propInfo(
            at: \DemoProbe.value,
            name: "value",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        assertEqual(detected.hint, .nodeType)
        assertEqual(detected.hintStr, "DemoProbe")
        print(detected)
    }

}

@Godot
class DemoProbe: Node {
    var value: DemoProbe? = nil
}
