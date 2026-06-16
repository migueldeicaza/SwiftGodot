//
//  VariantTests.swift
//
//
//  Created by Padraig O Cinneide on 2023-10-31.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class VariantTests {
    public func testVariant () {
        let testString = "Hi"
        let variant = Variant (testString)
        let unwrapped = String (variant)
        
        assertEqual (unwrapped, testString)
    }

    public func testWrap() {
        let x: Node? = Node()
        let _ = Variant(x)
        x?.queueFree()
    }
    
    
    public func testVariantCall() {
        let string = "Hello Hello Hello Hello"
        let variant = Variant(string)
        
        switch variant.call(method: "count", Variant("ello"), Variant(0), Variant(11)) {
        case .success(let value):
            guard let value else {
                fail()
                return
            }
            
            guard let value = Int(value) else {
                fail("Expected \(Variant.GType.int), got \(value.gtype) instead")
                return
            }
            assertEqual(value, 2, "ello appears twice in `\(string)` from index 0 to 11, got \(value) instead")
        case .failure(let error):
            fail("\(error)")
            return
        }
        
        switch variant.call(method: "count", Variant("ello"), Variant(0), Variant(0)) {
        case .success(let value):
            guard let value else {
                fail()
                return
            }
            
            guard let value = Int(value) else {
                fail("Expected \(Variant.GType.int), got \(value.gtype) instead")
                return
            }
            assertEqual(value, 4, "ello appears twice in `\(string)`, got \(value) instead")
        case .failure(let error):
            fail("\(error)")
            return
        }
                        
        // Check special treatment for a single argument case
        switch variant.call(method: "ends_with", Variant("llo")) {
        case .success(let value):
            guard let value else {
                fail()
                return
            }
            
            guard let value = Bool(value) else {
                fail("Expected \(Variant.GType.bool), got \(value.gtype) instead")
                return
            }
            assertTrue(value, "`\(string)` ends with `llo`, got `false` instead")
        case .failure(let error):
            fail("\(error)")
            return
        }
        
        // Check special treatment for a zero arguments case
        switch variant.call(method: "is_empty") {
        case .success(let value):
            guard let value else {
                fail()
                return
            }
            
            guard let value = Bool(value) else {
                fail("Expected \(Variant.GType.bool), got \(value.gtype) instead")
                return
            }
            assertFalse(value, "`\(string)` is not empty, got `true` instead")
        case .failure(let error):
            fail("\(error)")
            return
        }
                              
    }
    
    public func testInitVariantConvertible() {
        var variant: Variant
        
        // Builtin struct
        let transform2d = Transform2D (xAxis: Vector2 (x: 1, y: 2), yAxis: Vector2 (x: 3, y: 4), origin: Vector2 (x: 10, y: 20))
        variant = Variant (transform2d)
        assertEqual (variant.description, "[X: (1.0, 2.0), Y: (3.0, 4.0), O: (10.0, 20.0)]")
        assertEqual (variant.gtype, Variant.GType.transform2d)
        let newTransform2d = Transform2D (variant)
        assertEqual (transform2d, newTransform2d)
        assertEqual (newTransform2d?.x.x, 1)
        assertEqual (newTransform2d?.x.y, 2)
        assertEqual (newTransform2d?.y.x, 3)
        assertEqual (newTransform2d?.y.y, 4)
        assertEqual (newTransform2d?.origin.x, 10)
        assertEqual (newTransform2d?.origin.y, 20)
        
        // Reference object
        let sprite = Sprite2D ()
        sprite.position = Vector2 (x: 1, y: 2)
        sprite.offset = Vector2 (x: 3, y: 4)
        variant = Variant (sprite)
        assertEqual (variant.gtype, Variant.GType.object)
        let unwrappedSprite: Sprite2D? = variant.asObject ()
        assertEqual (unwrappedSprite?.position.x, 1)
        assertEqual (unwrappedSprite?.position.y, 2)
        assertEqual (unwrappedSprite?.offset.x, 3)
        assertEqual (unwrappedSprite?.offset.y, 4)
        
        // Custom type
        let string = "VariantConvertible"
        variant = Variant (string)
        assertEqual (variant.description, "VariantConvertible")
        assertEqual (variant.gtype, Variant.GType.string)
        let newString = String (variant)
        assertEqual (string, newString)
        sprite.queueFree()
    }
    
    public func testOperatorEqualsEquals () {
        assertTrue (Variant (false) == Variant (false))
        assertTrue (Variant (true) == Variant (true))
        assertFalse (Variant (true) == Variant (false))
        assertFalse (Variant (false) == Variant (0))
        assertFalse (Variant (true) == Variant (1))
        assertTrue (Variant (1) == Variant (1))
        assertFalse (Variant (1) == Variant (2))
        assertTrue (Variant (Vector2 (x: 1, y: 2)) == Variant (Vector2 (x: 1, y: 2)))
        assertFalse (Variant (Vector2 (x: 1, y: 2)) == Variant (Vector2 (x: 1, y: 3)))
        let node = Node()
        let node2 = Node()
        assertTrue (Variant (node) == Variant (node))
        assertFalse (Variant (node) == Variant (node2))
        node.queueFree()
        node2.queueFree()
    }
    
    public func testUnwrappingApi() {
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
        
        assertEqual(boolsUnwrapped(variant: true.toVariant()), 5)
        
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
            assertEqual(result.x, 1.0, accuracy: 0e-5)
            assertEqual(result.y, 1.0, accuracy: 0e-5)
            assertEqual(result.z, 1.0, accuracy: 0e-5)
        } catch {
            // error is guaranteed typed `VariantConversionError`
            fail(error.description)
        }
    }
    
    public func testNoMisconversions() {
        let variant = Vector2(x: 1, y: 2).toVariant()
        
        assertNil(variant.to(Bool.self))
        assertNil(variant.to(Int.self))
        assertNil(variant.to(Int32.self))
        assertNil(variant.to(UInt8.self)) // Still Int! We differentiate `Bool` and `BinaryInteger`.
        assertNil(variant.to(String.self))
        assertNil(variant.to(Float.self))
        assertNil(variant.to(Double.self))
    }
    
}
