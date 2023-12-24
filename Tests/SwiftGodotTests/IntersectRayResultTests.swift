//
//  IntersectRayResultTests.swift
//  SwiftGodotTests
//
//  Created by Estevan Hernandez on 12/24/23.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class IntersectRayResultTests: GodotTestCase {
    func testIntersectRayResultPropertiesMatchDictionary_whenAllPropertiesPresent() throws {
        let collider: Object = GridMap()
        
        let dictionary: GDictionary = {
            let dictionary = GDictionary()
            dictionary["position"] = Variant(Vector3(x: 1, y: 2, z: 3))
            dictionary["normal"] = Variant(Vector3(x: 4, y: 5, z: 6))
            dictionary["collider"] = Variant(collider)
            dictionary["collider_id"] = Variant(collider.id)
            dictionary["rid"] = Variant(RID())
            dictionary["shape"] = Variant(22)
            dictionary["face_index"] = Variant(44)
            return dictionary
        }()
        
        let result = try XCTUnwrap(PhysicsDirectSpaceState3D.IntersectRayResult<GridMap>(dictionary))
        
        XCTAssertEqual(result.position, Vector3(x: 1, y: 2, z: 3))
        XCTAssertEqual(result.normal, Vector3(x: 4, y: 5, z: 6))
        XCTAssertEqual(result.collider, collider)
        XCTAssertEqual(result.colliderId, collider.id)
        XCTAssertEqual(result.rid, RID())
        XCTAssertEqual(result.shape, 22)
        XCTAssertEqual(result.faceIndex, 44)
    }
    
    func testIntersectRayResultIsNil_whenColliderPropertyIsMissing() {
        let collider: Object = GridMap()
        
        let dictionary: GDictionary = {
            let dictionary = GDictionary()
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
        
        XCTAssertNil(result)
    }
}
