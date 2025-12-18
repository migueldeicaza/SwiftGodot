//
//  TypedDictionaryTests.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 24/04/2025.
//



@testable import SwiftGodot

public final class TypedDictionaryTests: GodotTestCase {
    public override class var allTests: [GodotTest] {
        [
            GodotTest(name: "testSubscripts", method: testSubscripts),
        ]
    }

    public required init() {}

    public func testSubscripts() {
        // Till libgodot 4.4
//        var dictionary = TypedDictionary<String, RefCounted?>()
//        
//        let a = RefCounted()
//        let b = RefCounted()
//        
//        dictionary["A"] = a
//        dictionary["B"] = b
//        
//        XCTAssertTrue(dictionary["A"] === a)
//        XCTAssertTrue(dictionary["B"] === b)
    }
}
