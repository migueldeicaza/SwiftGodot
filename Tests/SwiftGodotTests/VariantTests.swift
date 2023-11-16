//
//  VariantTests.swift
//
//
//  Created by Padraig O Cinneide on 2023-10-31.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class VariantTests: GodotTestCase {
    
    func testVariant () {
        let testString = "Hi"
        let variant = Variant (testString)
        let unwrapped = String (variant)
        
        XCTAssertEqual (unwrapped, testString)
    }
    
    func testInitVariantStorable () {
        var variant: Variant
        
        // Builtin struct
        let transform2d = Transform2D (xAxis: Vector2 (x: 1, y: 2), yAxis: Vector2 (x: 3, y: 4), origin: Vector2 (x: 10, y: 20))
        variant = Variant (transform2d)
        XCTAssertEqual (variant.description, "[X: (1, 2), Y: (3, 4), O: (10, 20)]")
        XCTAssertEqual (variant.gtype, Variant.GType.transform2d)
        let newTransform2d = Transform2D (variant)
        XCTAssertEqual (transform2d, newTransform2d)
        XCTAssertEqual (newTransform2d?.x.x, 1)
        XCTAssertEqual (newTransform2d?.x.y, 2)
        XCTAssertEqual (newTransform2d?.y.x, 3)
        XCTAssertEqual (newTransform2d?.y.y, 4)
        XCTAssertEqual (newTransform2d?.origin.x, 10)
        XCTAssertEqual (newTransform2d?.origin.y, 20)
        
        // Reference object
        let sprite = Sprite2D ()
        sprite.position = Vector2 (x: 1, y: 2)
        sprite.offset = Vector2 (x: 3, y: 4)
        variant = Variant (sprite)
        XCTAssertEqual (variant.gtype, Variant.GType.object)
        let unwrappedSprite: Sprite2D? = variant.asObject ()
        XCTAssertEqual (unwrappedSprite?.position.x, 1)
        XCTAssertEqual (unwrappedSprite?.position.y, 2)
        XCTAssertEqual (unwrappedSprite?.offset.x, 3)
        XCTAssertEqual (unwrappedSprite?.offset.y, 4)
        
        // Custom type
        let string = "VariantStorable"
        variant = Variant (string)
        XCTAssertEqual (variant.description, "VariantStorable")
        XCTAssertEqual (variant.gtype, Variant.GType.string)
        let newString = String (variant)
        XCTAssertEqual (string, newString)
    }
    
    func testOperatorEqualsEquals () {
        XCTAssertTrue (Variant (false) == Variant (false))
        XCTAssertTrue (Variant (true) == Variant (true))
        XCTAssertFalse (Variant (true) == Variant (false))
        XCTAssertFalse (Variant (false) == Variant (0))
        XCTAssertFalse (Variant (true) == Variant (1))
        XCTAssertTrue (Variant (1) == Variant (1))
        XCTAssertFalse (Variant (1) == Variant (2))
        XCTAssertTrue (Variant (Vector2 (x: 1, y: 2)) == Variant (Vector2 (x: 1, y: 2)))
        XCTAssertFalse (Variant (Vector2 (x: 1, y: 2)) == Variant (Vector2 (x: 1, y: 3)))
        let node = Node ()
        XCTAssertTrue (Variant (node) == Variant (node))
        XCTAssertFalse (Variant (node) == Variant (Node ()))
    }
    
}
