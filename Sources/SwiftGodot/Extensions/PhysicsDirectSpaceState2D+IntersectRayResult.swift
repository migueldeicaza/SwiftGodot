//
//  PhysicsDirectSpaceState2D+IntersectRayResult.swift
//
//
//  Created by Estevan Hernandez on 06/24/24.
//

private extension VariantDictionary {
    func unwrap<T: VariantConvertible>(key: String) -> T? {
        guard let variant = self[key] else {
            GD.pushWarning("There was no Variant for key: \(key)")
            return nil
        }
        guard let result = T.fromVariant(variant) else {
            GD.pushWarning("\(T.self).unwrap(from: \(variant)) was nil")
            return nil
        }

        return result
    }
}

extension PhysicsDirectSpaceState2D {
    /// Result from intersecting a ray
    public struct IntersectRayResult<T: Object> {
        /// The intersection point
        public let position: Vector2
        /// The object's surface normal at the intersection point, or `Vector2(x: 0, y: 0)` if the ray starts inside the shape and `PhysicsRayQueryParameters2D.hitFromInside` is true.
        public let normal: Vector2
        /// The colliding object
        public let collider: T
        /// The colliding object's ID.
        public let colliderId: UInt
        /// The The intersecting object's ``RID``.
        public let rid: RID
        /// The shape index of the colliding shape.
        public let shape: Int
        /// The metadata value from the dictionary.
        public let metadata: Variant?

        init?(_ dictionary: VariantDictionary) {
            guard dictionary.isEmpty() == false,
                  let position: Vector2 = dictionary.unwrap(key: "position"),
                  let normal: Vector2 = dictionary.unwrap(key: "normal"),
                  let colliderVariant = dictionary["collider"],
                  let collider = T.fromVariant(colliderVariant),
                  let colliderId: UInt = dictionary.unwrap(key: "collider_id"),
                  let rid: RID = dictionary.unwrap(key: "rid"),
                  let shape: Int = dictionary.unwrap(key: "shape") else {
                    return nil
                  }
            self.position = position
            self.normal = normal
            self.collider = collider
            self.colliderId = colliderId
            self.rid = rid
            self.shape = shape
            self.metadata = dictionary["metadata"]
        }
    }
}

extension PhysicsDirectSpaceState2D {
    /// Intersects a ray in a given space. Ray position and other parameters are defined through `PhysicsRayQueryParameters2D` The return value is an `IntersectRayResult<T>?` where `T` is any Godot `Object`, however if the ray did not intersect anything, or the intersecting collider was not of type `T` then a nil object is returned instead. Usually `T` is a physics object such as `StaticBody` for example but it could also be a `GridMap` if the `mesh_library` has collisions.
    public func intersectRay<T: Object>(_ type: T.Type = T.self, parameters: PhysicsRayQueryParameters2D) -> IntersectRayResult<T>? {
        let dictionary: VariantDictionary = intersectRay(parameters: parameters)
        return IntersectRayResult<T>(dictionary)
    }
}
