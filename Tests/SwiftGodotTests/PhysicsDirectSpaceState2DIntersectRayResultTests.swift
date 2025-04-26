//
//  PhysicsDirectSpaceState2DIntersectRayResultTests.swift
//  SwiftGodotTests
//
//  Created by Estevan Hernandez on 06/24/24.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class PhysicsDirectSpaceState2DIntersectRayResultTests: GodotTestCase {
    func testIntersectRayResultPropertiesMatchDictionary_whenAllPropertiesPresent() throws {
        let collider: Object = GridMap()
        
        let dictionary: VariantDictionary = {
            let dictionary = VariantDictionary()
            dictionary["position"] = Variant(Vector2(x: 1, y: 2))
            dictionary["normal"] = Variant(Vector2(x: 4, y: 5))
            dictionary["collider"] = Variant(collider)
            dictionary["collider_id"] = Variant(collider.getInstanceId())
            dictionary["rid"] = Variant(RID())
            dictionary["shape"] = Variant(22)
            return dictionary
        }()
        
        let result = try XCTUnwrap(PhysicsDirectSpaceState2D.IntersectRayResult<GridMap>(dictionary))
        
        XCTAssertEqual(result.position, Vector2(x: 1, y: 2))
        XCTAssertEqual(result.normal, Vector2(x: 4, y: 5))
        XCTAssertEqual(result.collider, collider)
        XCTAssertEqual(result.colliderId, collider.getInstanceId())
        XCTAssertEqual(result.rid, RID())
        XCTAssertEqual(result.shape, 22)
    }
    
    func testIntersectRayResultIsNil_whenColliderPropertyIsMissing() {
        let collider: Object = GridMap()
        
        let dictionary: VariantDictionary = {
            let dictionary = VariantDictionary()
            dictionary["position"] = Variant(Vector2(x: 1, y: 2))
            dictionary["normal"] = Variant(Vector2(x: 4, y: 5))
//            dictionary["collider"] = Variant(collider)
            dictionary["collider_id"] = Variant(collider.getInstanceId())
            dictionary["rid"] = Variant(RID())
            dictionary["shape"] = Variant(22)
            return dictionary
        }()
        
        let result = PhysicsDirectSpaceState2D.IntersectRayResult<GridMap>(dictionary)
        
        XCTAssertNil(result)
    }
}
