//
//  PhysicsDirectSpaceState2DIntersectRayResultTests.swift
//  SwiftGodotTests
//
//  Created by Estevan Hernandez on 06/24/24.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class PhysicsDirectSpaceState2DIntersectRayResultTests {
    public func testIntersectRayResultPropertiesMatchDictionary_whenAllPropertiesPresent() {
        let collider: Object = GridMap()

        let dictionary: VariantDictionary = {
            let dictionary = VariantDictionary()
            dictionary["position"] = Variant(Vector2(x: 1, y: 2))
            dictionary["normal"] = Variant(Vector2(x: 4, y: 5))
            dictionary["collider"] = Variant(collider)
            dictionary["collider_id"] = Variant(collider.id)
            dictionary["rid"] = Variant(RID())
            dictionary["shape"] = Variant(22)
            return dictionary
        }()

        guard let result = PhysicsDirectSpaceState2D.IntersectRayResult<GridMap>(dictionary) else {
            fail("Expected non-nil result")
            return
        }

        assertEqual(result.position, Vector2(x: 1, y: 2))
        assertEqual(result.normal, Vector2(x: 4, y: 5))
        assertEqual(result.collider, collider)
        assertEqual(result.colliderId, collider.id)
        assertEqual(result.rid, RID())
        assertEqual(result.shape, 22)

        (collider as? Node)?.queueFree()
    }

    public func testIntersectRayResultIsNil_whenColliderPropertyIsMissing() {
        let collider: Object = GridMap()
        
        let dictionary: VariantDictionary = {
            let dictionary = VariantDictionary()
            dictionary["position"] = Variant(Vector2(x: 1, y: 2))
            dictionary["normal"] = Variant(Vector2(x: 4, y: 5))
//            dictionary["collider"] = Variant(collider)
            dictionary["collider_id"] = Variant(collider.id)
            dictionary["rid"] = Variant(RID())
            dictionary["shape"] = Variant(22)
            return dictionary
        }()
        
        let result = PhysicsDirectSpaceState2D.IntersectRayResult<GridMap>(dictionary)

        assertNil(result)

        (collider as? Node)?.queueFree()
    }
}
