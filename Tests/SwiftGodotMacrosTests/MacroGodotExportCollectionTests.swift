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
    
    func testExportArrayStringGodotMacroFails() {
        assertMacroExpansion("""
            @Godot
            class SomeNode: Node {
                @Export var greetings: [String]
            }
            """,
            expandedSource: """
            class SomeNode: Node {
                var greetings: [String]
            }
            """,
            diagnostics: [
                .init(message: "@Export attribute can not be applied to Array types, use a VariantCollection, or an ObjectCollection instead", line: 3, column: 5),
                .init(message: "@Export attribute can not be applied to Array types, use a VariantCollection, or an ObjectCollection instead", line: 1, column: 1)
            ],
             macros: Self.macros
        )
    }
    
    func testExportArrayStringMacroFails() {
        assertMacroExpansion("""
            @Export
            var greetings: [String]
            """,
            expandedSource: """
            var greetings: [String]
            """,
            diagnostics: [
                .init(message: "@Export attribute can not be applied to Array types, use a VariantCollection, or an ObjectCollection instead", line: 1, column: 1)
            ],
            macros: Self.macros
        )
    }

    func testExportGenericArrayStringGodotMacro() {
        assertMacroExpansion("""
            @Godot
            class SomeNode: Node {
                @Export
                var greetings: VariantCollection<String> = []
            }
            """,
            expandedSource: """
            class SomeNode: Node {
                var greetings: VariantCollection<String> = []

                func _mproxy_get_greetings(args: borrowing Arguments) -> Variant? {
                    return Variant(greetings.array)
                }

                func _mproxy_set_greetings(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `greetings`, no arguments")
                        return nil
                    }

                    guard let variant = arg else {
                        GD.printErr("Unable to set `greetings`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(String.self)) else {
                        return nil
                    }
                    greetings.array = gArray
                    return nil
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static let _initializeClass: Void = {
                    let className = StringName("SomeNode")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<SomeNode> (name: className)
                    let _pgreetings = PropInfo (
                        propertyType: .array,
                        propertyName: "greetings",
                        className: StringName("Array[String]"),
                        hint: .arrayType,
                        hintStr: "String",
                        usage: .default)
                    classInfo.registerMethod (name: "get_greetings", flags: .default, returnValue: _pgreetings, arguments: [], function: SomeNode._mproxy_get_greetings)
                    classInfo.registerMethod (name: "set_greetings", flags: .default, returnValue: nil, arguments: [_pgreetings], function: SomeNode._mproxy_set_greetings)
                    classInfo.registerProperty (_pgreetings, getter: "get_greetings", setter: "set_greetings")
                } ()
            }
            """,
            macros: Self.macros
        )
    }
    
    func testExportArrayStringMacro() {        
        assertMacroExpansion("""
            @Export var greetings: VariantCollection<String> = []
            """,
            expandedSource: """
            var greetings: VariantCollection<String> = []

            func _mproxy_get_greetings(args: borrowing Arguments) -> Variant? {
                return Variant(greetings.array)
            }

            func _mproxy_set_greetings(args: borrowing Arguments) -> Variant? {
                guard let arg = args.first else {
                    GD.printErr("Unable to set `greetings`, no arguments")
                    return nil
                }

                guard let variant = arg else {
                    GD.printErr("Unable to set `greetings`, argument is `nil`")
                    return nil
                }
                guard let gArray = GArray(variant),
                      gArray.isTyped(),
                      gArray.isSameTyped(array: GArray(String.self)) else {
                    return nil
                }
                greetings.array = gArray
                return nil
            }
            """,
            macros: Self.macros
        )
    }
    
    func testExportGenericArrayStringMacro() {
        assertMacroExpansion("""
            @Export var greetings: VariantCollection<String> = []
            """,
            expandedSource: """
            var greetings: VariantCollection<String> = []
            
            func _mproxy_get_greetings(args: borrowing Arguments) -> Variant? {
                return Variant(greetings.array)
            }

            func _mproxy_set_greetings(args: borrowing Arguments) -> Variant? {
                guard let arg = args.first else {
                    GD.printErr("Unable to set `greetings`, no arguments")
                    return nil
                }

                guard let variant = arg else {
                    GD.printErr("Unable to set `greetings`, argument is `nil`")
                    return nil
                }
                guard let gArray = GArray(variant),
                      gArray.isTyped(),
                      gArray.isSameTyped(array: GArray(String.self)) else {
                    return nil
                }
                greetings.array = gArray
                return nil
            }
            """,
            macros: Self.macros
        )
    }
    
    func testExportConstantGenericArrayStringMacro() {
        assertExpansion(
            of: """
            @Export let greetings: VariantCollection<String> = []
            """,
            into: """
            let greetings: VariantCollection<String> = []

            func _mproxy_get_greetings(args: borrowing Arguments) -> Variant? {
                return Variant(greetings.array)
            }

            func _mproxy_set_greetings(args: borrowing Arguments) -> Variant? {
                guard let arg = args.first else {
                    GD.printErr("Unable to set `greetings`, no arguments")
                    return nil
                }

                guard let variant = arg else {
                    GD.printErr("Unable to set `greetings`, argument is `nil`")
                    return nil
                }
                guard let gArray = GArray(variant),
                      gArray.isTyped(),
                      gArray.isSameTyped(array: GArray(String.self)) else {
                    return nil
                }
                greetings.array = gArray
                return nil
            }
            """
        )
    }
    
    func testExportOptionalGenericArrayStringMacro() {
        assertMacroExpansion(
            "@Export var greetings: VariantCollection<String>? = []",
            expandedSource: "var greetings: VariantCollection<String>? = []",
            diagnostics: [
                .init(message: "@Export optional Collections are not supported", line: 1, column: 1)
            ],
            macros: Self.macros
        )
    }
    
    func testExportGArray() {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Export var someArray: GArray = GArray()
            }
            """,
            into: """
            
            class SomeNode: Node {
                var someArray: GArray = GArray()
            
                func _mproxy_set_someArray(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `someArray`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `someArray`, argument is nil")
                        return nil
                    }
            
                    guard let newValue = GArray(variant) else {
                        GD.printErr("Unable to set `someArray`, argument is not GArray")
                        return nil
                    }
            
                    someArray = newValue
                    return nil
                }
            
                func _mproxy_get_someArray (args: borrowing Arguments) -> Variant? {
                    return Variant (someArray)
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static let _initializeClass: Void = {
                    let className = StringName("SomeNode")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<SomeNode> (name: className)
                    let _psomeArray = PropInfo (
                        propertyType: .array,
                        propertyName: "someArray",
                        className: className,
                        hint: .none,
                        hintStr: "",
                        usage: .default)
                    classInfo.registerMethod (name: "_mproxy_get_someArray", flags: .default, returnValue: _psomeArray, arguments: [], function: SomeNode._mproxy_get_someArray)
                    classInfo.registerMethod (name: "_mproxy_set_someArray", flags: .default, returnValue: nil, arguments: [_psomeArray], function: SomeNode._mproxy_set_someArray)
                    classInfo.registerProperty (_psomeArray, getter: "_mproxy_get_someArray", setter: "_mproxy_set_someArray")
                } ()
            }
            """
        )
    }
    
    func testExportArrayIntGodotMacro() {
        assertExpansion(of: """
            @Godot
            class SomeNode: Node {
                @Export var someNumbers: VariantCollection<Int> = []
            }
            """,
            into: """
            class SomeNode: Node {
                var someNumbers: VariantCollection<Int> = []
            
                func _mproxy_get_someNumbers(args: borrowing Arguments) -> Variant? {
                    return Variant(someNumbers.array)
                }

                func _mproxy_set_someNumbers(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `someNumbers`, no arguments")
                        return nil
                    }

                    guard let variant = arg else {
                        GD.printErr("Unable to set `someNumbers`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Int.self)) else {
                        return nil
                    }
                    someNumbers.array = gArray
                    return nil
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static let _initializeClass: Void = {
                    let className = StringName("SomeNode")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<SomeNode> (name: className)
                    let _psomeNumbers = PropInfo (
                        propertyType: .array,
                        propertyName: "some_numbers",
                        className: StringName("Array[int]"),
                        hint: .arrayType,
                        hintStr: "int",
                        usage: .default)
                    classInfo.registerMethod (name: "get_some_numbers", flags: .default, returnValue: _psomeNumbers, arguments: [], function: SomeNode._mproxy_get_someNumbers)
                    classInfo.registerMethod (name: "set_some_numbers", flags: .default, returnValue: nil, arguments: [_psomeNumbers], function: SomeNode._mproxy_set_someNumbers)
                    classInfo.registerProperty (_psomeNumbers, getter: "get_some_numbers", setter: "set_some_numbers")
                } ()
            }
            """
        )
    }

    func testExportArraysIntGodotMacro() throws {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Export var someNumbers: VariantCollection<Int> = []
                @Export var someOtherNumbers: VariantCollection<Int> = []
            }
            """,
            into: """
            class SomeNode: Node {
                var someNumbers: VariantCollection<Int> = []

                func _mproxy_get_someNumbers(args: borrowing Arguments) -> Variant? {
                    return Variant(someNumbers.array)
                }

                func _mproxy_set_someNumbers(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `someNumbers`, no arguments")
                        return nil
                    }

                    guard let variant = arg else {
                        GD.printErr("Unable to set `someNumbers`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Int.self)) else {
                        return nil
                    }
                    someNumbers.array = gArray
                    return nil
                }
                var someOtherNumbers: VariantCollection<Int> = []

                func _mproxy_get_someOtherNumbers(args: borrowing Arguments) -> Variant? {
                    return Variant(someOtherNumbers.array)
                }

                func _mproxy_set_someOtherNumbers(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `someOtherNumbers`, no arguments")
                        return nil
                    }

                    guard let variant = arg else {
                        GD.printErr("Unable to set `someOtherNumbers`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Int.self)) else {
                        return nil
                    }
                    someOtherNumbers.array = gArray
                    return nil
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static let _initializeClass: Void = {
                    let className = StringName("SomeNode")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<SomeNode> (name: className)
                    let _psomeNumbers = PropInfo (
                        propertyType: .array,
                        propertyName: "some_numbers",
                        className: StringName("Array[int]"),
                        hint: .arrayType,
                        hintStr: "int",
                        usage: .default)
                    classInfo.registerMethod (name: "get_some_numbers", flags: .default, returnValue: _psomeNumbers, arguments: [], function: SomeNode._mproxy_get_someNumbers)
                    classInfo.registerMethod (name: "set_some_numbers", flags: .default, returnValue: nil, arguments: [_psomeNumbers], function: SomeNode._mproxy_set_someNumbers)
                    classInfo.registerProperty (_psomeNumbers, getter: "get_some_numbers", setter: "set_some_numbers")
                    let _psomeOtherNumbers = PropInfo (
                        propertyType: .array,
                        propertyName: "some_other_numbers",
                        className: StringName("Array[int]"),
                        hint: .arrayType,
                        hintStr: "int",
                        usage: .default)
                    classInfo.registerMethod (name: "get_some_other_numbers", flags: .default, returnValue: _psomeOtherNumbers, arguments: [], function: SomeNode._mproxy_get_someOtherNumbers)
                    classInfo.registerMethod (name: "set_some_other_numbers", flags: .default, returnValue: nil, arguments: [_psomeOtherNumbers], function: SomeNode._mproxy_set_someOtherNumbers)
                    classInfo.registerProperty (_psomeOtherNumbers, getter: "get_some_other_numbers", setter: "set_some_other_numbers")
                } ()
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
               @Export var firstNames: VariantCollection<String> = ["Thelonius"]
               @Export var lastNames: VariantCollection<String> = ["Monk"]
            }
            """,
            into: """
            import SwiftGodot
            class ArrayTest: Node {
               var firstNames: VariantCollection<String> = ["Thelonius"]

               func _mproxy_get_firstNames(args: borrowing Arguments) -> Variant? {
                   return Variant(firstNames.array)
               }

               func _mproxy_set_firstNames(args: borrowing Arguments) -> Variant? {
                   guard let arg = args.first else {
                       GD.printErr("Unable to set `firstNames`, no arguments")
                       return nil
                   }

                   guard let variant = arg else {
                       GD.printErr("Unable to set `firstNames`, argument is `nil`")
                       return nil
                   }
                   guard let gArray = GArray(variant),
                         gArray.isTyped(),
                         gArray.isSameTyped(array: GArray(String.self)) else {
                       return nil
                   }
                   firstNames.array = gArray
                   return nil
               }
               var lastNames: VariantCollection<String> = ["Monk"]

               func _mproxy_get_lastNames(args: borrowing Arguments) -> Variant? {
                   return Variant(lastNames.array)
               }

               func _mproxy_set_lastNames(args: borrowing Arguments) -> Variant? {
                   guard let arg = args.first else {
                       GD.printErr("Unable to set `lastNames`, no arguments")
                       return nil
                   }

                   guard let variant = arg else {
                       GD.printErr("Unable to set `lastNames`, argument is `nil`")
                       return nil
                   }
                   guard let gArray = GArray(variant),
                         gArray.isTyped(),
                         gArray.isSameTyped(array: GArray(String.self)) else {
                       return nil
                   }
                   lastNames.array = gArray
                   return nil
               }

                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static let _initializeClass: Void = {
                    let className = StringName("ArrayTest")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<ArrayTest> (name: className)
                    let _pfirstNames = PropInfo (
                        propertyType: .array,
                        propertyName: "first_names",
                        className: StringName("Array[String]"),
                        hint: .arrayType,
                        hintStr: "String",
                        usage: .default)
                    classInfo.registerMethod (name: "get_first_names", flags: .default, returnValue: _pfirstNames, arguments: [], function: ArrayTest._mproxy_get_firstNames)
                    classInfo.registerMethod (name: "set_first_names", flags: .default, returnValue: nil, arguments: [_pfirstNames], function: ArrayTest._mproxy_set_firstNames)
                    classInfo.registerProperty (_pfirstNames, getter: "get_first_names", setter: "set_first_names")
                    let _plastNames = PropInfo (
                        propertyType: .array,
                        propertyName: "last_names",
                        className: StringName("Array[String]"),
                        hint: .arrayType,
                        hintStr: "String",
                        usage: .default)
                    classInfo.registerMethod (name: "get_last_names", flags: .default, returnValue: _plastNames, arguments: [], function: ArrayTest._mproxy_get_lastNames)
                    classInfo.registerMethod (name: "set_last_names", flags: .default, returnValue: nil, arguments: [_plastNames], function: ArrayTest._mproxy_set_lastNames)
                    classInfo.registerProperty (_plastNames, getter: "get_last_names", setter: "set_last_names")
                } ()
            }
            """
        )
    }
    
    func testExportObjectCollection() throws {
        assertExpansion(
            of: """
            @Export var greetings: ObjectCollection<Node3D> = []
            """,
            into: """
            var greetings: ObjectCollection<Node3D> = []

            func _mproxy_get_greetings(args: borrowing Arguments) -> Variant? {
                return Variant(greetings.array)
            }

            func _mproxy_set_greetings(args: borrowing Arguments) -> Variant? {
                guard let arg = args.first else {
                    GD.printErr("Unable to set `greetings`, no arguments")
                    return nil
                }

                guard let variant = arg else {
                    GD.printErr("Unable to set `greetings`, argument is `nil`")
                    return nil
                }
                guard let gArray = GArray(variant),
                      gArray.isTyped(),
                      gArray.isSameTyped(array: GArray(Node3D.self)) else {
                    return nil
                }
                greetings.array = gArray
                return nil
            }
            """
        )
    }
    
    func testGodotExportObjectCollection() throws {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Export var greetings: ObjectCollection<Node3D> = []
            }
            """,
            into: """
            class SomeNode: Node {
                var greetings: ObjectCollection<Node3D> = []

                func _mproxy_get_greetings(args: borrowing Arguments) -> Variant? {
                    return Variant(greetings.array)
                }

                func _mproxy_set_greetings(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `greetings`, no arguments")
                        return nil
                    }

                    guard let variant = arg else {
                        GD.printErr("Unable to set `greetings`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Node3D.self)) else {
                        return nil
                    }
                    greetings.array = gArray
                    return nil
                }

                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static let _initializeClass: Void = {
                    let className = StringName("SomeNode")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<SomeNode> (name: className)
                    let _pgreetings = PropInfo (
                        propertyType: .array,
                        propertyName: "greetings",
                        className: StringName("Array[Node3D]"),
                        hint: .arrayType,
                        hintStr: "Node3D",
                        usage: .default)
                    classInfo.registerMethod (name: "get_greetings", flags: .default, returnValue: _pgreetings, arguments: [], function: SomeNode._mproxy_get_greetings)
                    classInfo.registerMethod (name: "set_greetings", flags: .default, returnValue: nil, arguments: [_pgreetings], function: SomeNode._mproxy_set_greetings)
                    classInfo.registerProperty (_pgreetings, getter: "get_greetings", setter: "set_greetings")
                } ()
            }
            """
        )
    }
}
