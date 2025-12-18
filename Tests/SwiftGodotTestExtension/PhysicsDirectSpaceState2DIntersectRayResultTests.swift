//
//  PhysicsDirectSpaceState2DIntersectRayResultTests.swift
//  SwiftGodotTests
//
//  Created by Estevan Hernandez on 06/24/24.
//



@testable import SwiftGodot

public final class PhysicsDirectSpaceState2DIntersectRayResultTests: GodotTestCase {
    public override class var allTests: [GodotTest] {
        [
            GodotTest(name: "testIntersectRayResultPropertiesMatchDictionary_whenAllPropertiesPresent", method: testIntersectRayResultPropertiesMatchDictionary_whenAllPropertiesPresent),
            GodotTest(name: "testIntersectRayResultIsNil_whenColliderPropertyIsMissing", method: testIntersectRayResultIsNil_whenColliderPropertyIsMissing),
        ]
    }

    public required init() {}

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
            XCTFail("Expected non-nil result")
            return
        }

        XCTAssertEqual(result.position, Vector2(x: 1, y: 2))
        XCTAssertEqual(result.normal, Vector2(x: 4, y: 5))
        XCTAssertEqual(result.collider, collider)
        XCTAssertEqual(result.colliderId, collider.id)
        XCTAssertEqual(result.rid, RID())
        XCTAssertEqual(result.shape, 22)
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
        
        XCTAssertNil(result)
    }
}
