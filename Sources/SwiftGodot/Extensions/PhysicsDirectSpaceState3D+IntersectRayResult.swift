//
//  PhysicsDirectSpaceState3D+IntersectRayResult
//
//
//  Created by Estevan Hernandez on 12/24/23.
//

private extension GDictionary {
    func makeOrUnwrap<T: VariantStorable>(key: String) -> T? {
        guard let variant = self[key] else {
            GD.pushWarning("There was no Variant for key: \(key)")
            return nil
        }
        guard let result = T.makeOrUnwrap(variant) else {
            GD.pushWarning("\(T.self).makeOrUnwrap(\(variant)) was nil")
            return nil
        }

        return result
    }
}

extension PhysicsDirectSpaceState3D {
    /// Result from intersecting a ray
    public struct IntersectRayResult<T: Object> {
        /// The intersection point
        public let position: Vector3
        /// The object's surface normal at the intersection point, or `Vector3(x: 0, y: 0, z: 0)` if the ray starts inside the shape and `PhysicsRayQueryParameters3D.hitFromInside` is true.
        public let normal: Vector3
        /// The colliding object
        public let collider: T
        /// The colliding object's ID.
        public let colliderId: Int
        /// The The intersecting object's ``RID``.
        public let rid: RID
        /// The shape index of the colliding shape.
        public let shape: Int
        /// The metadata value from the dictionary.
        public let metadata: Variant?
        /// The face index at the intersection point.
        public let faceIndex: Int

        init?(_ dictionary: GDictionary) {
            guard dictionary.isEmpty() == false,
                  let position: Vector3 = dictionary.makeOrUnwrap(key: "position"),
                  let normal: Vector3 = dictionary.makeOrUnwrap(key: "normal"),
                  let colliderVariant = dictionary["collider"],
                  let collider = T.makeOrUnwrap(colliderVariant),
                  let colliderId: Int = dictionary.makeOrUnwrap(key: "collider_id"),
                  let rid: RID = dictionary.makeOrUnwrap(key: "rid"),
                  let shape: Int = dictionary.makeOrUnwrap(key: "shape"),
                  let faceIndex: Int = dictionary.makeOrUnwrap(key: "face_index") else {
                    return nil
                  }
            self.position = position
            self.normal = normal
            self.collider = collider
            self.colliderId = colliderId
            self.rid = rid
            self.shape = shape
            self.faceIndex = faceIndex
            self.metadata = dictionary["metadata"]
        }
    }
}

extension PhysicsDirectSpaceState3D {
    /// Intersects a ray in a given space. Ray position and other parameters are defined through `PhysicsRayQueryParameters3D` The return value is an `IntersectRayResult<T>?` where `T` is any Godot `Object`, however if the ray did not intersect anything, or the intersecting collider was not of type `T` then a nil object is returned instead. Usually `T` is a physics object such as `StaticBody` for example but it could also be a `GridMap` if the `mesh_library` has collisions.
    public func intersectRay<T: Object>(_ type: T.Type = T.self, parameters: PhysicsRayQueryParameters3D) -> IntersectRayResult<T>? {
        let dictionary: GDictionary = intersectRay(parameters: parameters)
        return IntersectRayResult<T>(dictionary)
    }
}
