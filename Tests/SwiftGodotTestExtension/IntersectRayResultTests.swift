//
//  IntersectRayResultTests.swift
//  SwiftGodotTests
//
//  Created by Estevan Hernandez on 12/24/23.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class IntersectRayResultTests {
    public func testIntersectRayResultPropertiesMatchDictionary_whenAllPropertiesPresent() {
        let collider: Object = GridMap()

        let dictionary: VariantDictionary = {
            let dictionary = VariantDictionary()
            dictionary["position"] = Variant(Vector3(x: 1, y: 2, z: 3))
            dictionary["normal"] = Variant(Vector3(x: 4, y: 5, z: 6))
            dictionary["collider"] = Variant(collider)
            dictionary["collider_id"] = Variant(collider.id)
            dictionary["rid"] = Variant(RID())
            dictionary["shape"] = Variant(22)
            dictionary["face_index"] = Variant(44)
            return dictionary
        }()

        guard let result = PhysicsDirectSpaceState3D.IntersectRayResult<GridMap>(dictionary) else {
            fail("Expected non-nil result")
            return
        }

        assertEqual(result.position, Vector3(x: 1, y: 2, z: 3))
        assertEqual(result.normal, Vector3(x: 4, y: 5, z: 6))
        assertEqual(result.collider, collider)
        assertEqual(result.colliderId, collider.id)
        assertEqual(result.rid, RID())
        assertEqual(result.shape, 22)
        assertEqual(result.faceIndex, 44)

        (collider as? Node)?.queueFree()
    }

    public func testIntersectRayResultIsNil_whenColliderPropertyIsMissing() {
        let collider: Object = GridMap()
        
        let dictionary: VariantDictionary = {
            let dictionary = VariantDictionary()
            dictionary["position"] = Variant(Vector3(x: 1, y: 2, z: 3))
            dictionary["normal"] = Variant(Vector3(x: 4, y: 5, z: 6))
//            dictionary["collider"] = Variant(collider)
            dictionary["collider_id"] = Variant(collider.id)
            dictionary["rid"] = Variant(RID())
            dictionary["shape"] = Variant(22)
            dictionary["face_index"] = Variant(44)
            return dictionary
        }()
        
        let result = PhysicsDirectSpaceState3D.IntersectRayResult<GridMap>(dictionary)

        assertNil(result)

        (collider as? Node)?.queueFree()
    }
}
