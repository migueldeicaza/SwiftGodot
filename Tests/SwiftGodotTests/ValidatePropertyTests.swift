//
//  ValidatePropertyTests.swift
//  SwiftGodot
//
//  Created by Miguel de Icaza on 3/29/25.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

@Godot
private class TestProp: Node {
    @Export
    var changeThisVariable: Int = 1

    override func _validateProperty(_ prop: inout PropInfo) -> Bool {
        if prop.propertyName == "change_this_variable" {
            prop.usage.insert(.group)
            return true
        }
        return false
    }
}

final class TestProperty: GodotTestCase {
    override static var godotSubclasses: [Wrapped.Type] {
        return [TestProp.self]
    }

    func testThing() {
        var found = false
        let node = TestProp()
        for prop in node.getPropertyList() {
            //print("PROP: \(prop)")
            guard let nameV = prop["name"] else { continue }
            guard let name = String(nameV) else { continue }
            guard let flagsV = prop["usage"], let iflags = Int(flagsV) else { continue }
            let flags = PropertyUsageFlags(rawValue: iflags)

            if name == "change_this_variable", flags.contains(.group) {
                found = true
            }
        }
        XCTAssertTrue(found, "Should have found a property named hideThisVariable with the usage set to 'readOnly'")
    }
}
