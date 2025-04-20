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

    func testWrap() {
        let x: Node? = Node()
        let _ = Variant(x)
    }
    
    
    func testVariantCall() {
        let string = "Hello Hello Hello Hello"
        let variant = Variant(string)
        
        switch variant.call(method: "count", Variant("ello"), Variant(0), Variant(11)) {
        case .success(let value):
            guard let value else {
                XCTFail()
                return
            }
            
            guard let value = Int(value) else {
                XCTFail("Expected \(Variant.GType.int), got \(value.gtype) instead")
                return
            }
            XCTAssertEqual(value, 2, "ello appears twice in `\(string)` from index 0 to 11, got \(value) instead")
        case .failure(let error):
            XCTFail("\(error)")
            return
        }
        
        switch variant.call(method: "count", Variant("ello"), Variant(0), Variant(0)) {
        case .success(let value):
            guard let value else {
                XCTFail()
                return
            }
            
            guard let value = Int(value) else {
                XCTFail("Expected \(Variant.GType.int), got \(value.gtype) instead")
                return
            }
            XCTAssertEqual(value, 4, "ello appears twice in `\(string)`, got \(value) instead")
        case .failure(let error):
            XCTFail("\(error)")
            return
        }
                        
        // Check special treatment for a single argument case
        switch variant.call(method: "ends_with", Variant("llo")) {
        case .success(let value):
            guard let value else {
                XCTFail()
                return
            }
            
            guard let value = Bool(value) else {
                XCTFail("Expected \(Variant.GType.bool), got \(value.gtype) instead")
                return
            }
            XCTAssertTrue(value, "`\(string)` ends with `llo`, got `false` instead")
        case .failure(let error):
            XCTFail("\(error)")
            return
        }
        
        // Check special treatment for a zero arguments case
        switch variant.call(method: "is_empty") {
        case .success(let value):
            guard let value else {
                XCTFail()
                return
            }
            
            guard let value = Bool(value) else {
                XCTFail("Expected \(Variant.GType.bool), got \(value.gtype) instead")
                return
            }
            XCTAssertFalse(value, "`\(string)` is not empty, got `true` instead")
        case .failure(let error):
            XCTFail("\(error)")
            return
        }
                              
    }
    
    func tesetInitVariantConvertible() {
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
        let string = "VariantConvertible"
        variant = Variant (string)
        XCTAssertEqual (variant.description, "VariantConvertible")
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
        let node = Node()
        XCTAssertTrue (Variant (node) == Variant (node))
        XCTAssertFalse (Variant (node) == Variant (Node ()))
    }
    
    func testUnwrappingApi() {
        func someFunctionTakingBool(_ bool: Bool?, successCount: inout Int) {
            if let bool {
                successCount += 1
                
                print("\(bool) again!")
            }
        }

        func boolsUnwrapped(variant: Variant?) -> Int {
            var successCount = 0
            
            if let boolValue = Bool(variant) {
                print("I'm \(boolValue)!")
                successCount += 1
            }
            
            if let boolValue = Bool.fromVariant(variant) {
                print("Still \(boolValue)...")
                successCount += 1
            }
            
            if let boolValue = variant.to(Bool.self) {
                print("Nothing changed, it's \(boolValue)")
                successCount += 1
            }
            
            if let boolValue: Bool = variant.to() {
                print("Oh, I see you enjoy Swift type inferrence! I'm \(boolValue)")
                successCount += 1
            }                        
            
            someFunctionTakingBool(variant.to(), successCount: &successCount)

            return successCount
        }
        
        XCTAssertEqual(boolsUnwrapped(variant: true.toVariant()), 5)
        
        let variants = [
            Vector3.back.toVariant(),
            Vector3.right.toVariant(),
            Vector3.up.toVariant(),
        ]
                            
        do {
            var result = Vector3()
            for variant in variants {
                result += try Vector3.fromVariantOrThrow(variant)
            }
            // use result
            XCTAssertEqual(result.x, 1.0, accuracy: 0e-5)
            XCTAssertEqual(result.y, 1.0, accuracy: 0e-5)
            XCTAssertEqual(result.z, 1.0, accuracy: 0e-5)
        } catch {
            // error is guaranteed typed `VariantConversionError`
            XCTFail(error.description)
        }
    }
    
    func testNoMisconversions() {
        let variant = Vector2(x: 1, y: 2).toVariant()
        
        XCTAssertNil(variant.to(Bool.self))
        XCTAssertNil(variant.to(Int.self))
        XCTAssertNil(variant.to(Int32.self))
        XCTAssertNil(variant.to(UInt8.self)) // Still Int! We differentiate `Bool` and `BinaryInteger`.
        XCTAssertNil(variant.to(String.self))
        XCTAssertNil(variant.to(Float.self))
        XCTAssertNil(variant.to(Double.self))
    }
    
}
