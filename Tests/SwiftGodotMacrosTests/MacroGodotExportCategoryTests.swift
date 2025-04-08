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
            """,
            into: """
            
            class Car: Node {
                var vins: VariantCollection<String> = ["00000000000000000"]
            
                func _mproxy_get_vins(args: borrowing Arguments) -> Variant? {
                    return Variant(vins.array)
                }
            
                func _mproxy_set_vins(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `vins`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `vins`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(String.self)) else {
                        return nil
                    }
                    vins.array = gArray
                    return nil
                }
                var years: VariantCollection<Int> = [1997]
            
                func _mproxy_get_years(args: borrowing Arguments) -> Variant? {
                    return Variant(years.array)
                }
            
                func _mproxy_set_years(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `years`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `years`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Int.self)) else {
                        return nil
                    }
                    years.array = gArray
                    return nil
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static let _initializeClass: Void = {
                    let className = StringName("Car")
                    assert(ClassDB.classExists(class: className))
                    let _pvins = PropInfo (
                        propertyType: .array,
                        propertyName: "vins",
                        className: StringName("Array[String]"),
                        hint: .arrayType,
                        hintStr: "String",
                        usage: .default)
                    let classInfo = ClassInfo<Car> (name: className)
                    classInfo.registerMethod (name: "get_vins", flags: .default, returnValue: _pvins, arguments: [], function: Car._mproxy_get_vins)
                    classInfo.registerMethod (name: "set_vins", flags: .default, returnValue: nil, arguments: [_pvins], function: Car._mproxy_set_vins)
                    classInfo.registerProperty (_pvins, getter: "get_vins", setter: "set_vins")
                    classInfo.addPropertyGroup(name: "YMMS", prefix: "")
                    let _pyears = PropInfo (
                        propertyType: .array,
                        propertyName: "years",
                        className: StringName("Array[int]"),
                        hint: .arrayType,
                        hintStr: "int",
                        usage: .default)
                    classInfo.registerMethod (name: "get_years", flags: .default, returnValue: _pyears, arguments: [], function: Car._mproxy_get_years)
                    classInfo.registerMethod (name: "set_years", flags: .default, returnValue: nil, arguments: [_pyears], function: Car._mproxy_set_years)
                    classInfo.registerProperty (_pyears, getter: "get_years", setter: "set_years")
                } ()
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
            """,
            into: """
            
            class Car: Node {
                var vins: VariantCollection<String> = ["00000000000000000"]
            
                func _mproxy_get_vins(args: borrowing Arguments) -> Variant? {
                    return Variant(vins.array)
                }
            
                func _mproxy_set_vins(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `vins`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `vins`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(String.self)) else {
                        return nil
                    }
                    vins.array = gArray
                    return nil
                }
                var years: VariantCollection<Int> = [1997]
            
                func _mproxy_get_years(args: borrowing Arguments) -> Variant? {
                    return Variant(years.array)
                }
            
                func _mproxy_set_years(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `years`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `years`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Int.self)) else {
                        return nil
                    }
                    years.array = gArray
                    return nil
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static let _initializeClass: Void = {
                    let className = StringName("Car")
                    assert(ClassDB.classExists(class: className))
                    let _pvins = PropInfo (
                        propertyType: .array,
                        propertyName: "vins",
                        className: StringName("Array[String]"),
                        hint: .arrayType,
                        hintStr: "String",
                        usage: .default)
                    let classInfo = ClassInfo<Car> (name: className)
                    classInfo.registerMethod (name: "get_vins", flags: .default, returnValue: _pvins, arguments: [], function: Car._mproxy_get_vins)
                    classInfo.registerMethod (name: "set_vins", flags: .default, returnValue: nil, arguments: [_pvins], function: Car._mproxy_set_vins)
                    classInfo.registerProperty (_pvins, getter: "get_vins", setter: "set_vins")
                    let _pyears = PropInfo (
                        propertyType: .array,
                        propertyName: "years",
                        className: StringName("Array[int]"),
                        hint: .arrayType,
                        hintStr: "int",
                        usage: .default)
                    classInfo.registerMethod (name: "get_years", flags: .default, returnValue: _pyears, arguments: [], function: Car._mproxy_get_years)
                    classInfo.registerMethod (name: "set_years", flags: .default, returnValue: nil, arguments: [_pyears], function: Car._mproxy_set_years)
                    classInfo.registerProperty (_pyears, getter: "get_years", setter: "set_years")
                    classInfo.addPropertyGroup(name: "Pointless", prefix: "")
                } ()
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
            """,
            into: """
            
            class Car: Node {
                var vins: VariantCollection<String> = [""]
            
                func _mproxy_get_vins(args: borrowing Arguments) -> Variant? {
                    return Variant(vins.array)
                }
            
                func _mproxy_set_vins(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `vins`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `vins`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(String.self)) else {
                        return nil
                    }
                    vins.array = gArray
                    return nil
                }
                var years: VariantCollection<Int> = [1997]
            
                func _mproxy_get_years(args: borrowing Arguments) -> Variant? {
                    return Variant(years.array)
                }
            
                func _mproxy_set_years(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `years`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `years`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Int.self)) else {
                        return nil
                    }
                    years.array = gArray
                    return nil
                }
                var makes: VariantCollection<String> = ["HONDA"]
            
                func _mproxy_get_makes(args: borrowing Arguments) -> Variant? {
                    return Variant(makes.array)
                }
            
                func _mproxy_set_makes(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `makes`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `makes`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(String.self)) else {
                        return nil
                    }
                    makes.array = gArray
                    return nil
                }
                var models: VariantCollection<String> = ["ACCORD"]
            
                func _mproxy_get_models(args: borrowing Arguments) -> Variant? {
                    return Variant(models.array)
                }
            
                func _mproxy_set_models(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `models`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `models`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(String.self)) else {
                        return nil
                    }
                    models.array = gArray
                    return nil
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static let _initializeClass: Void = {
                    let className = StringName("Car")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<Car> (name: className)
                    classInfo.addPropertyGroup(name: "VIN", prefix: "")
                    let _pvins = PropInfo (
                        propertyType: .array,
                        propertyName: "vins",
                        className: StringName("Array[String]"),
                        hint: .arrayType,
                        hintStr: "String",
                        usage: .default)
                    classInfo.registerMethod (name: "get_vins", flags: .default, returnValue: _pvins, arguments: [], function: Car._mproxy_get_vins)
                    classInfo.registerMethod (name: "set_vins", flags: .default, returnValue: nil, arguments: [_pvins], function: Car._mproxy_set_vins)
                    classInfo.registerProperty (_pvins, getter: "get_vins", setter: "set_vins")
                    classInfo.addPropertyGroup(name: "YMM", prefix: "")
                    let _pyears = PropInfo (
                        propertyType: .array,
                        propertyName: "years",
                        className: StringName("Array[int]"),
                        hint: .arrayType,
                        hintStr: "int",
                        usage: .default)
                    classInfo.registerMethod (name: "get_years", flags: .default, returnValue: _pyears, arguments: [], function: Car._mproxy_get_years)
                    classInfo.registerMethod (name: "set_years", flags: .default, returnValue: nil, arguments: [_pyears], function: Car._mproxy_set_years)
                    classInfo.registerProperty (_pyears, getter: "get_years", setter: "set_years")
                    let _pmakes = PropInfo (
                        propertyType: .array,
                        propertyName: "makes",
                        className: StringName("Array[String]"),
                        hint: .arrayType,
                        hintStr: "String",
                        usage: .default)
                    classInfo.registerMethod (name: "get_makes", flags: .default, returnValue: _pmakes, arguments: [], function: Car._mproxy_get_makes)
                    classInfo.registerMethod (name: "set_makes", flags: .default, returnValue: nil, arguments: [_pmakes], function: Car._mproxy_set_makes)
                    classInfo.registerProperty (_pmakes, getter: "get_makes", setter: "set_makes")
                    let _pmodels = PropInfo (
                        propertyType: .array,
                        propertyName: "models",
                        className: StringName("Array[String]"),
                        hint: .arrayType,
                        hintStr: "String",
                        usage: .default)
                    classInfo.registerMethod (name: "get_models", flags: .default, returnValue: _pmodels, arguments: [], function: Car._mproxy_get_models)
                    classInfo.registerMethod (name: "set_models", flags: .default, returnValue: nil, arguments: [_pmodels], function: Car._mproxy_set_models)
                    classInfo.registerProperty (_pmodels, getter: "get_models", setter: "set_models")
                } ()
                
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
            """,
            into: """
            
            class Car: Node {
                var makes: ObjectCollection<Node> = []
            
                func _mproxy_get_makes(args: borrowing Arguments) -> Variant? {
                    return Variant(makes.array)
                }
            
                func _mproxy_set_makes(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `makes`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `makes`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Node.self)) else {
                        return nil
                    }
                    makes.array = gArray
                    return nil
                }
                var model: ObjectCollection<Node> = []
            
                func _mproxy_get_model(args: borrowing Arguments) -> Variant? {
                    return Variant(model.array)
                }
            
                func _mproxy_set_model(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `model`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `model`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Node.self)) else {
                        return nil
                    }
                    model.array = gArray
                    return nil
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static let _initializeClass: Void = {
                    let className = StringName("Car")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<Car> (name: className)
                    classInfo.addPropertyGroup(name: "Vehicle", prefix: "")
                    let _pmakes = PropInfo (
                        propertyType: .array,
                        propertyName: "makes",
                        className: StringName("Array[Node]"),
                        hint: .arrayType,
                        hintStr: "Node",
                        usage: .default)
                    classInfo.registerMethod (name: "get_makes", flags: .default, returnValue: _pmakes, arguments: [], function: Car._mproxy_get_makes)
                    classInfo.registerMethod (name: "set_makes", flags: .default, returnValue: nil, arguments: [_pmakes], function: Car._mproxy_set_makes)
                    classInfo.registerProperty (_pmakes, getter: "get_makes", setter: "set_makes")
                    let _pmodel = PropInfo (
                        propertyType: .array,
                        propertyName: "model",
                        className: StringName("Array[Node]"),
                        hint: .arrayType,
                        hintStr: "Node",
                        usage: .default)
                    classInfo.registerMethod (name: "get_model", flags: .default, returnValue: _pmodel, arguments: [], function: Car._mproxy_get_model)
                    classInfo.registerMethod (name: "set_model", flags: .default, returnValue: nil, arguments: [_pmodel], function: Car._mproxy_set_model)
                    classInfo.registerProperty (_pmodel, getter: "get_model", setter: "set_model")
                } ()
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
            """,
            into: """
            
            class Car: Node {
                var vins: ObjectCollection<Node> = []
            
                func _mproxy_get_vins(args: borrowing Arguments) -> Variant? {
                    return Variant(vins.array)
                }
            
                func _mproxy_set_vins(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `vins`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `vins`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Node.self)) else {
                        return nil
                    }
                    vins.array = gArray
                    return nil
                }
                var years: ObjectCollection<Node> = []
            
                func _mproxy_get_years(args: borrowing Arguments) -> Variant? {
                    return Variant(years.array)
                }
            
                func _mproxy_set_years(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `years`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `years`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Node.self)) else {
                        return nil
                    }
                    years.array = gArray
                    return nil
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static let _initializeClass: Void = {
                    let className = StringName("Car")
                    assert(ClassDB.classExists(class: className))
                    let _pvins = PropInfo (
                        propertyType: .array,
                        propertyName: "vins",
                        className: StringName("Array[Node]"),
                        hint: .arrayType,
                        hintStr: "Node",
                        usage: .default)
                    let classInfo = ClassInfo<Car> (name: className)
                    classInfo.registerMethod (name: "get_vins", flags: .default, returnValue: _pvins, arguments: [], function: Car._mproxy_get_vins)
                    classInfo.registerMethod (name: "set_vins", flags: .default, returnValue: nil, arguments: [_pvins], function: Car._mproxy_set_vins)
                    classInfo.registerProperty (_pvins, getter: "get_vins", setter: "set_vins")
                    classInfo.addPropertyGroup(name: "YMMS", prefix: "")
                    let _pyears = PropInfo (
                        propertyType: .array,
                        propertyName: "years",
                        className: StringName("Array[Node]"),
                        hint: .arrayType,
                        hintStr: "Node",
                        usage: .default)
                    classInfo.registerMethod (name: "get_years", flags: .default, returnValue: _pyears, arguments: [], function: Car._mproxy_get_years)
                    classInfo.registerMethod (name: "set_years", flags: .default, returnValue: nil, arguments: [_pyears], function: Car._mproxy_set_years)
                    classInfo.registerProperty (_pyears, getter: "get_years", setter: "set_years")
                } ()
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
            """,
            into: """
            
            class Car: Node {
                var vins: ObjectCollection<Node> = []
            
                func _mproxy_get_vins(args: borrowing Arguments) -> Variant? {
                    return Variant(vins.array)
                }
            
                func _mproxy_set_vins(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `vins`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `vins`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Node.self)) else {
                        return nil
                    }
                    vins.array = gArray
                    return nil
                }
                var years: ObjectCollection<Node> = []
            
                func _mproxy_get_years(args: borrowing Arguments) -> Variant? {
                    return Variant(years.array)
                }
            
                func _mproxy_set_years(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `years`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `years`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Node.self)) else {
                        return nil
                    }
                    years.array = gArray
                    return nil
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static let _initializeClass: Void = {
                    let className = StringName("Car")
                    assert(ClassDB.classExists(class: className))
                    let _pvins = PropInfo (
                        propertyType: .array,
                        propertyName: "vins",
                        className: StringName("Array[Node]"),
                        hint: .arrayType,
                        hintStr: "Node",
                        usage: .default)
                    let classInfo = ClassInfo<Car> (name: className)
                    classInfo.registerMethod (name: "get_vins", flags: .default, returnValue: _pvins, arguments: [], function: Car._mproxy_get_vins)
                    classInfo.registerMethod (name: "set_vins", flags: .default, returnValue: nil, arguments: [_pvins], function: Car._mproxy_set_vins)
                    classInfo.registerProperty (_pvins, getter: "get_vins", setter: "set_vins")
                    let _pyears = PropInfo (
                        propertyType: .array,
                        propertyName: "years",
                        className: StringName("Array[Node]"),
                        hint: .arrayType,
                        hintStr: "Node",
                        usage: .default)
                    classInfo.registerMethod (name: "get_years", flags: .default, returnValue: _pyears, arguments: [], function: Car._mproxy_get_years)
                    classInfo.registerMethod (name: "set_years", flags: .default, returnValue: nil, arguments: [_pyears], function: Car._mproxy_set_years)
                    classInfo.registerProperty (_pyears, getter: "get_years", setter: "set_years")
                    classInfo.addPropertyGroup(name: "Pointless", prefix: "")
                } ()
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
            """,
            into: """
            
            class Car: Node {
                var vins: ObjectCollection<Node> = []
            
                func _mproxy_get_vins(args: borrowing Arguments) -> Variant? {
                    return Variant(vins.array)
                }
            
                func _mproxy_set_vins(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `vins`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `vins`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Node.self)) else {
                        return nil
                    }
                    vins.array = gArray
                    return nil
                }
                var years: ObjectCollection<Node> = []
            
                func _mproxy_get_years(args: borrowing Arguments) -> Variant? {
                    return Variant(years.array)
                }
            
                func _mproxy_set_years(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `years`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `years`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Node.self)) else {
                        return nil
                    }
                    years.array = gArray
                    return nil
                }
                var makes: ObjectCollection<Node> = []
            
                func _mproxy_get_makes(args: borrowing Arguments) -> Variant? {
                    return Variant(makes.array)
                }
            
                func _mproxy_set_makes(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `makes`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `makes`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Node.self)) else {
                        return nil
                    }
                    makes.array = gArray
                    return nil
                }
                var models: ObjectCollection<Node> = []
            
                func _mproxy_get_models(args: borrowing Arguments) -> Variant? {
                    return Variant(models.array)
                }
            
                func _mproxy_set_models(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `models`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `models`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Node.self)) else {
                        return nil
                    }
                    models.array = gArray
                    return nil
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static let _initializeClass: Void = {
                    let className = StringName("Car")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<Car> (name: className)
                    classInfo.addPropertyGroup(name: "VIN", prefix: "")
                    let _pvins = PropInfo (
                        propertyType: .array,
                        propertyName: "vins",
                        className: StringName("Array[Node]"),
                        hint: .arrayType,
                        hintStr: "Node",
                        usage: .default)
                    classInfo.registerMethod (name: "get_vins", flags: .default, returnValue: _pvins, arguments: [], function: Car._mproxy_get_vins)
                    classInfo.registerMethod (name: "set_vins", flags: .default, returnValue: nil, arguments: [_pvins], function: Car._mproxy_set_vins)
                    classInfo.registerProperty (_pvins, getter: "get_vins", setter: "set_vins")
                    classInfo.addPropertyGroup(name: "YMM", prefix: "")
                    let _pyears = PropInfo (
                        propertyType: .array,
                        propertyName: "years",
                        className: StringName("Array[Node]"),
                        hint: .arrayType,
                        hintStr: "Node",
                        usage: .default)
                    classInfo.registerMethod (name: "get_years", flags: .default, returnValue: _pyears, arguments: [], function: Car._mproxy_get_years)
                    classInfo.registerMethod (name: "set_years", flags: .default, returnValue: nil, arguments: [_pyears], function: Car._mproxy_set_years)
                    classInfo.registerProperty (_pyears, getter: "get_years", setter: "set_years")
                    let _pmakes = PropInfo (
                        propertyType: .array,
                        propertyName: "makes",
                        className: StringName("Array[Node]"),
                        hint: .arrayType,
                        hintStr: "Node",
                        usage: .default)
                    classInfo.registerMethod (name: "get_makes", flags: .default, returnValue: _pmakes, arguments: [], function: Car._mproxy_get_makes)
                    classInfo.registerMethod (name: "set_makes", flags: .default, returnValue: nil, arguments: [_pmakes], function: Car._mproxy_set_makes)
                    classInfo.registerProperty (_pmakes, getter: "get_makes", setter: "set_makes")
                    let _pmodels = PropInfo (
                        propertyType: .array,
                        propertyName: "models",
                        className: StringName("Array[Node]"),
                        hint: .arrayType,
                        hintStr: "Node",
                        usage: .default)
                    classInfo.registerMethod (name: "get_models", flags: .default, returnValue: _pmodels, arguments: [], function: Car._mproxy_get_models)
                    classInfo.registerMethod (name: "set_models", flags: .default, returnValue: nil, arguments: [_pmodels], function: Car._mproxy_set_models)
                    classInfo.registerProperty (_pmodels, getter: "get_models", setter: "set_models")
                } ()
                
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
            """,
            into: """
            
            class Garage: Node {
                var bar: VariantCollection<Bool> = [false]
            
                func _mproxy_get_bar(args: borrowing Arguments) -> Variant? {
                    return Variant(bar.array)
                }
            
                func _mproxy_set_bar(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `bar`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `bar`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Bool.self)) else {
                        return nil
                    }
                    bar.array = gArray
                    return nil
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static let _initializeClass: Void = {
                    let className = StringName("Garage")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<Garage> (name: className)
                    classInfo.addPropertyGroup(name: "Example", prefix: "example")
                    let _pbar = PropInfo (
                        propertyType: .array,
                        propertyName: "bar",
                        className: StringName("Array[bool]"),
                        hint: .arrayType,
                        hintStr: "bool",
                        usage: .default)
                    classInfo.registerMethod (name: "get_bar", flags: .default, returnValue: _pbar, arguments: [], function: Garage._mproxy_get_bar)
                    classInfo.registerMethod (name: "set_bar", flags: .default, returnValue: nil, arguments: [_pbar], function: Garage._mproxy_set_bar)
                    classInfo.registerProperty (_pbar, getter: "get_bar", setter: "set_bar")
                } ()
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
            """,
            into: """
            
            public class Issue353: Node {
                var prefix1_prefixed_bool: VariantCollection<Bool> = [false]
            
                func _mproxy_get_prefix1_prefixed_bool(args: borrowing Arguments) -> Variant? {
                    return Variant(prefix1_prefixed_bool.array)
                }
            
                func _mproxy_set_prefix1_prefixed_bool(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `prefix1_prefixed_bool`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `prefix1_prefixed_bool`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Bool.self)) else {
                        return nil
                    }
                    prefix1_prefixed_bool.array = gArray
                    return nil
                }
                var non_prefixed_bool: VariantCollection<Bool> = [false]
            
                func _mproxy_get_non_prefixed_bool(args: borrowing Arguments) -> Variant? {
                    return Variant(non_prefixed_bool.array)
                }
            
                func _mproxy_set_non_prefixed_bool(args: borrowing Arguments) -> Variant? {
                    guard let arg = args.first else {
                        GD.printErr("Unable to set `non_prefixed_bool`, no arguments")
                        return nil
                    }
            
                    guard let variant = arg else {
                        GD.printErr("Unable to set `non_prefixed_bool`, argument is `nil`")
                        return nil
                    }
                    guard let gArray = GArray(variant),
                          gArray.isTyped(),
                          gArray.isSameTyped(array: GArray(Bool.self)) else {
                        return nil
                    }
                    non_prefixed_bool.array = gArray
                    return nil
                }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static let _initializeClass: Void = {
                    let className = StringName("Issue353")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<Issue353> (name: className)
                    classInfo.addPropertyGroup(name: "Group With a Prefix", prefix: "prefix1")
                    let _pprefix1_prefixed_bool = PropInfo (
                        propertyType: .array,
                        propertyName: "prefix1_prefixed_bool",
                        className: StringName("Array[bool]"),
                        hint: .arrayType,
                        hintStr: "bool",
                        usage: .default)
                    classInfo.registerMethod (name: "get__prefixed_bool", flags: .default, returnValue: _pprefix1_prefixed_bool, arguments: [], function: Issue353._mproxy_get_prefix1_prefixed_bool)
                    classInfo.registerMethod (name: "set__prefixed_bool", flags: .default, returnValue: nil, arguments: [_pprefix1_prefixed_bool], function: Issue353._mproxy_set_prefix1_prefixed_bool)
                    classInfo.registerProperty (_pprefix1_prefixed_bool, getter: "get__prefixed_bool", setter: "set__prefixed_bool")
                    let _pnon_prefixed_bool = PropInfo (
                        propertyType: .array,
                        propertyName: "non_prefixed_bool",
                        className: StringName("Array[bool]"),
                        hint: .arrayType,
                        hintStr: "bool",
                        usage: .default)
                    classInfo.registerMethod (name: "get_non_prefixed_bool", flags: .default, returnValue: _pnon_prefixed_bool, arguments: [], function: Issue353._mproxy_get_non_prefixed_bool)
                    classInfo.registerMethod (name: "set_non_prefixed_bool", flags: .default, returnValue: nil, arguments: [_pnon_prefixed_bool], function: Issue353._mproxy_set_non_prefixed_bool)
                    classInfo.registerProperty (_pnon_prefixed_bool, getter: "get_non_prefixed_bool", setter: "set_non_prefixed_bool")
                } ()
            }
            """
        )
    }
}
