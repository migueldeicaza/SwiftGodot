//
//  PropertyListTests.swift
//  SwiftGodot
//
//  Created by Chris Backas on 6/21/26.
//

@testable import SwiftGodot

@Godot
class TestPropList: Node {
    @Export
    var standardVariable: Int = 1

    private var specialVar: Int = 1

    override func _get(property: StringName) -> GetPropertyResult {
        if property == "Special" {
            return .from(specialVar)
        }
        return .unhandledProperty
    }

    override func _set(property: StringName, value: consuming Variant?) -> Bool {
        if property == "Special" {
            specialVar = Int.fromVariant(value) ?? 0
            return true
        }
        return false
    }

    override func _propertyGetRevert(property: StringName) -> GetPropertyResult {
        if property == "Special" {
            return .from(1)
        }
        return .unhandledProperty
    }

    override func _propertyCanRevert(property: StringName) -> PropertyCanRevertResult {
		guard property == "Special" else { return .unhandledProperty }
		return .handledProperty(true)
    }

    override func _getPropertyList() -> [PropInfo]? {
        return [PropInfo(propertyType: .int,
                         propertyName: "Special",
                         className: "TestPropList",
                         hint: .none,
                         hintStr: "",
                         usage: .default)]
    }
}

@SwiftGodotTestSuite
final class PropertyListTests {
    public static var registeredTypes: [Object.Type] {
        return [TestPropList.self]
    }

    public func testSpecialHandled() {
        let node = TestPropList()
        var foundSpecial = false
        for prop in node.getPropertyList() {
            if let name =  prop["name"],
               String.fromVariant(name) == "Special" {
                foundSpecial = true
                break
            }
        }
        assertTrue(foundSpecial, "Did not find the 'Special' property in node's property list")
        
        assertTrue(node.propertyCanRevert(property: "Special"), "`Special` property should be revertable")
        let revertValue = node.propertyGetRevert(property: "Special")
        let revertValueInt = Int.fromVariant(revertValue)
        assertEqual(revertValueInt, 1, "Revert value should be 1, was \(revertValueInt.debugDescription)")
        
        let originalValue = node.get(property: "Special")
        node.set(property: "Special", value: Variant(12))
        let newValue = node.get(property: "Special")
        assertNotEqual(Int.fromVariant(originalValue), Int.fromVariant(newValue), "Setting 'Special` value on Node did not change the value")
        assertEqual(Int.fromVariant(newValue), 12, "Did not receive same value back after setting `Special` value on node")
        node.queueFree()
    }
    
    public func testStandardExportNotBroken() {
        let node = TestPropList()
        var foundStandard = false
        for prop in node.getPropertyList() {
            if let name =  prop["name"],
               String.fromVariant(name) == "standard_variable" {
                foundStandard = true
                break
            }
        }
        assertTrue(foundStandard, "Did not find the 'standard_variable' property in node's property list.")
        
        let originalValue = node.get(property: "standard_variable")
        node.set(property: "standard_variable", value: Variant(12))
        let newValue = node.get(property: "standard_variable")
        assertNotEqual(Int.fromVariant(originalValue), Int.fromVariant(newValue), "Setting 'standard_variable` value on Node did not change the value")
        assertEqual(Int.fromVariant(newValue), 12, "Did not receive same value back after setting `standard_variable` value on node")
        
        node.queueFree()
    }
    
}
