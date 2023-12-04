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

final class MacroGodotExportCollectionTests: XCTestCase {
	let testMacros: [String: Macro.Type] = [
		"Godot": GodotMacro.self,
		"Export": GodotExport.self,
	]
	
	func testExportArrayStringGodotMacroFails() {
		assertMacroExpansion(
			"""
			@Godot
			class SomeNode: Node {
				@Export var greetings: [String]
			}
			""",
		expandedSource:
			"""

			class SomeNode: Node {
				var greetings: [String]
			}
			""",
			diagnostics: [
				.init(message: "@Export attribute can not be applied to Array types, use a VariantCollection, or an ObjectCollection instead", line: 3, column: 2),
				.init(message: "@Export attribute can not be applied to Array types, use a VariantCollection, or an ObjectCollection instead", line: 1, column: 1)
			],
			macros: testMacros
		)
	}
	
	func testExportArrayStringMacroFails() {
		assertMacroExpansion(
			"""
			@Export
			var greetings: [String]
			""",
		expandedSource:
			"""

			var greetings: [String]
			""",
			diagnostics: [
				.init(message: "@Export attribute can not be applied to Array types, use a VariantCollection, or an ObjectCollection instead", line: 1, column: 1)
			],
			macros: testMacros
		)
	}

	func testExportGenericArrayStringGodotMacro() {
		assertMacroExpansion(
"""
@Godot
class SomeNode: Node {
	@Export
	var greetings: VariantCollection<String> = []
}
""",
			expandedSource:
"""

class SomeNode: Node {
	var greetings: VariantCollection<String> = []

	func _mproxy_get_greetings(args: [Variant]) -> Variant? {
		return Variant(greetings.array)
	}

	func _mproxy_set_greetings(args: [Variant]) -> Variant? {
		guard let arg = args.first,
			  let gArray = GArray(arg),
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

    private static var _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<SomeNode> (name: className)
        let _pgreetings = PropInfo (
            propertyType: .array,
            propertyName: "greetings",
            className: StringName("Array[String]"),
            hint: .none,
            hintStr: "Array of String",
            usage: .default)
    	classInfo.registerMethod (name: "get_greetings", flags: .default, returnValue: _pgreetings, arguments: [], function: SomeNode._mproxy_get_greetings)
    	classInfo.registerMethod (name: "set_greetings", flags: .default, returnValue: nil, arguments: [_pgreetings], function: SomeNode._mproxy_set_greetings)
    	classInfo.registerProperty (_pgreetings, getter: "get_greetings", setter: "set_greetings")
    } ()
}
""",
			macros: testMacros
		)
	}
	
	func testExportArrayStringMacro() {
		assertMacroExpansion(
"""
@Export var greetings: VariantCollection<String> = []
""",
			expandedSource:
"""

var greetings: VariantCollection<String> = []

func _mproxy_get_greetings(args: [Variant]) -> Variant? {
	return Variant(greetings.array)
}

func _mproxy_set_greetings(args: [Variant]) -> Variant? {
	guard let arg = args.first,
		  let gArray = GArray(arg),
		  gArray.isTyped(),
		  gArray.isSameTyped(array: GArray(String.self)) else {
		return nil
	}
	greetings.array = gArray
	return nil
}
""",
			macros: testMacros
		)
	}
	
	func testExportGenericArrayStringMacro() {
		assertMacroExpansion(
"""
@Export var greetings: VariantCollection<String> = []
""",
			expandedSource:
"""

var greetings: VariantCollection<String> = []

func _mproxy_get_greetings(args: [Variant]) -> Variant? {
	return Variant(greetings.array)
}

func _mproxy_set_greetings(args: [Variant]) -> Variant? {
	guard let arg = args.first,
		  let gArray = GArray(arg),
		  gArray.isTyped(),
		  gArray.isSameTyped(array: GArray(String.self)) else {
		return nil
	}
	greetings.array = gArray
	return nil
}
""",
			macros: testMacros
		)
	}
	
	func testExportConstantGenericArrayStringMacro() {
		assertMacroExpansion(
"""
@Export let greetings: VariantCollection<String> = []
""",
			expandedSource:
"""

let greetings: VariantCollection<String> = []

func _mproxy_get_greetings(args: [Variant]) -> Variant? {
	return Variant(greetings.array)
}

func _mproxy_set_greetings(args: [Variant]) -> Variant? {
	guard let arg = args.first,
		  let gArray = GArray(arg),
		  gArray.isTyped(),
		  gArray.isSameTyped(array: GArray(String.self)) else {
		return nil
	}
	greetings.array = gArray
	return nil
}
""",
			macros: testMacros
		)
	}
	
	func testExportOptionalGenericArrayStringMacro() {
		assertMacroExpansion(
			"@Export var greetings: VariantCollection<String>? = []",
			expandedSource: "var greetings: VariantCollection<String>? = []",
			diagnostics: [
				.init(message: "@Export optional Collections are not supported", line: 1, column: 1)
			],
			macros: testMacros
		)
	}
	
	func testExportArrayIntGodotMacro() {
		assertMacroExpansion(
"""
@Godot
class SomeNode: Node {
	@Export var someNumbers: VariantCollection<Int> = []
}
""",
			expandedSource:
"""

class SomeNode: Node {
	var someNumbers: VariantCollection<Int> = []

	func _mproxy_get_someNumbers(args: [Variant]) -> Variant? {
		return Variant(someNumbers.array)
	}

	func _mproxy_set_someNumbers(args: [Variant]) -> Variant? {
		guard let arg = args.first,
			  let gArray = GArray(arg),
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

    private static var _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<SomeNode> (name: className)
        let _psomeNumbers = PropInfo (
            propertyType: .array,
            propertyName: "some_numbers",
            className: StringName("Array[int]"),
            hint: .none,
            hintStr: "Array of Int",
            usage: .default)
    	classInfo.registerMethod (name: "get_some_numbers", flags: .default, returnValue: _psomeNumbers, arguments: [], function: SomeNode._mproxy_get_someNumbers)
    	classInfo.registerMethod (name: "set_some_numbers", flags: .default, returnValue: nil, arguments: [_psomeNumbers], function: SomeNode._mproxy_set_someNumbers)
    	classInfo.registerProperty (_psomeNumbers, getter: "get_some_numbers", setter: "set_some_numbers")
    } ()
}
""",
			macros: testMacros
		)
	}

	func testExportArraysIntGodotMacro() throws {
		assertMacroExpansion(
"""
@Godot
class SomeNode: Node {
	@Export var someNumbers: VariantCollection<Int> = []
	@Export var someOtherNumbers: VariantCollection<Int> = []
}
""",
			expandedSource:
"""

class SomeNode: Node {
	var someNumbers: VariantCollection<Int> = []

	func _mproxy_get_someNumbers(args: [Variant]) -> Variant? {
		return Variant(someNumbers.array)
	}

	func _mproxy_set_someNumbers(args: [Variant]) -> Variant? {
		guard let arg = args.first,
			  let gArray = GArray(arg),
			  gArray.isTyped(),
			  gArray.isSameTyped(array: GArray(Int.self)) else {
			return nil
		}
		someNumbers.array = gArray
		return nil
	}
	var someOtherNumbers: VariantCollection<Int> = []

	func _mproxy_get_someOtherNumbers(args: [Variant]) -> Variant? {
		return Variant(someOtherNumbers.array)
	}

	func _mproxy_set_someOtherNumbers(args: [Variant]) -> Variant? {
		guard let arg = args.first,
			  let gArray = GArray(arg),
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

    private static var _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<SomeNode> (name: className)
        let _psomeNumbers = PropInfo (
            propertyType: .array,
            propertyName: "some_numbers",
            className: StringName("Array[int]"),
            hint: .none,
            hintStr: "Array of Int",
            usage: .default)
    	classInfo.registerMethod (name: "get_some_numbers", flags: .default, returnValue: _psomeNumbers, arguments: [], function: SomeNode._mproxy_get_someNumbers)
    	classInfo.registerMethod (name: "set_some_numbers", flags: .default, returnValue: nil, arguments: [_psomeNumbers], function: SomeNode._mproxy_set_someNumbers)
    	classInfo.registerProperty (_psomeNumbers, getter: "get_some_numbers", setter: "set_some_numbers")
        let _psomeOtherNumbers = PropInfo (
            propertyType: .array,
            propertyName: "some_other_numbers",
            className: StringName("Array[int]"),
            hint: .none,
            hintStr: "Array of Int",
            usage: .default)
    	classInfo.registerMethod (name: "get_some_other_numbers", flags: .default, returnValue: _psomeOtherNumbers, arguments: [], function: SomeNode._mproxy_get_someOtherNumbers)
    	classInfo.registerMethod (name: "set_some_other_numbers", flags: .default, returnValue: nil, arguments: [_psomeOtherNumbers], function: SomeNode._mproxy_set_someOtherNumbers)
    	classInfo.registerProperty (_psomeOtherNumbers, getter: "get_some_other_numbers", setter: "set_some_other_numbers")
    } ()
}
""",
			macros: testMacros
		)
	}
	
	func testGodotExportTwoStringArrays() throws {
		assertMacroExpansion(
"""
import SwiftGodot

@Godot
class ArrayTest: Node {
   @Export var firstNames: VariantCollection<String> = ["Thelonius"]
   @Export var lastNames: VariantCollection<String> = ["Monk"]
}
"""
		, expandedSource:
"""
import SwiftGodot
class ArrayTest: Node {
   var firstNames: VariantCollection<String> = ["Thelonius"]

   func _mproxy_get_firstNames(args: [Variant]) -> Variant? {
   	return Variant(firstNames.array)
   }

   func _mproxy_set_firstNames(args: [Variant]) -> Variant? {
   	guard let arg = args.first,
   		  let gArray = GArray(arg),
   		  gArray.isTyped(),
   		  gArray.isSameTyped(array: GArray(String.self)) else {
   		return nil
   	}
   	firstNames.array = gArray
   	return nil
   }
   var lastNames: VariantCollection<String> = ["Monk"]

   func _mproxy_get_lastNames(args: [Variant]) -> Variant? {
   	return Variant(lastNames.array)
   }

   func _mproxy_set_lastNames(args: [Variant]) -> Variant? {
   	guard let arg = args.first,
   		  let gArray = GArray(arg),
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

    private static var _initializeClass: Void = {
        let className = StringName("ArrayTest")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<ArrayTest> (name: className)
        let _pfirstNames = PropInfo (
            propertyType: .array,
            propertyName: "first_names",
            className: StringName("Array[String]"),
            hint: .none,
            hintStr: "Array of String",
            usage: .default)
    	classInfo.registerMethod (name: "get_first_names", flags: .default, returnValue: _pfirstNames, arguments: [], function: ArrayTest._mproxy_get_firstNames)
    	classInfo.registerMethod (name: "set_first_names", flags: .default, returnValue: nil, arguments: [_pfirstNames], function: ArrayTest._mproxy_set_firstNames)
    	classInfo.registerProperty (_pfirstNames, getter: "get_first_names", setter: "set_first_names")
        let _plastNames = PropInfo (
            propertyType: .array,
            propertyName: "last_names",
            className: StringName("Array[String]"),
            hint: .none,
            hintStr: "Array of String",
            usage: .default)
    	classInfo.registerMethod (name: "get_last_names", flags: .default, returnValue: _plastNames, arguments: [], function: ArrayTest._mproxy_get_lastNames)
    	classInfo.registerMethod (name: "set_last_names", flags: .default, returnValue: nil, arguments: [_plastNames], function: ArrayTest._mproxy_set_lastNames)
    	classInfo.registerProperty (_plastNames, getter: "get_last_names", setter: "set_last_names")
    } ()
}
"""
		, macros: testMacros
		)
	}
	
	func testExportObjectCollection() throws {
		assertMacroExpansion(
"""
@Export var greetings: ObjectCollection<Node3D> = []
""",
			expandedSource:
"""
var greetings: ObjectCollection<Node3D> = []

func _mproxy_get_greetings(args: [Variant]) -> Variant? {
	return Variant(greetings.array)
}

func _mproxy_set_greetings(args: [Variant]) -> Variant? {
	guard let arg = args.first,
		  let gArray = GArray(arg),
		  gArray.isTyped(),
		  gArray.isSameTyped(array: GArray(Node3D.self)) else {
		return nil
	}
	greetings.array = gArray
	return nil
}
""",
			macros: testMacros
		)
	}
	
	func testGodotExportObjectCollection() throws {
		assertMacroExpansion(
"""
@Godot
class SomeNode: Node {
	@Export var greetings: ObjectCollection<Node3D> = []
}
""",
			expandedSource:
"""

class SomeNode: Node {
	var greetings: ObjectCollection<Node3D> = []

	func _mproxy_get_greetings(args: [Variant]) -> Variant? {
		return Variant(greetings.array)
	}

	func _mproxy_set_greetings(args: [Variant]) -> Variant? {
		guard let arg = args.first,
			  let gArray = GArray(arg),
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

    private static var _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<SomeNode> (name: className)
        let _pgreetings = PropInfo (
            propertyType: .array,
            propertyName: "greetings",
            className: StringName("Array[Node3D]"),
            hint: .none,
            hintStr: "Array of Node3D",
            usage: .default)
    	classInfo.registerMethod (name: "get_greetings", flags: .default, returnValue: _pgreetings, arguments: [], function: SomeNode._mproxy_get_greetings)
    	classInfo.registerMethod (name: "set_greetings", flags: .default, returnValue: nil, arguments: [_pgreetings], function: SomeNode._mproxy_set_greetings)
    	classInfo.registerProperty (_pgreetings, getter: "get_greetings", setter: "set_greetings")
    } ()
}
""",
			macros: testMacros
		)
	}
}
