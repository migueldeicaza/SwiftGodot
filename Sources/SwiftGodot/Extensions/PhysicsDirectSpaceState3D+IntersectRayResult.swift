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
    // https://docs.godotengine.org/en/stable/classes/class_physicsdirectspacestate3d.html#class-physicsdirectspacestate3d-method-intersect-ray
    public struct IntersectRayResult<T: Object> {
        public let position: Vector3
        public let normal: Vector3
        public let collider: T
        public let colliderId: Int
        public let rid: RID
        public let shape: Int
        public let metadata: Variant?
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
    /// Intersects a ray in a given space. Ray position and other parameters are defined through `PhysicsRayQueryParameters3D` The return value is an `IntersectRayResult<T>?` where `T` is any Godot `Object`, however if the ray did not intersect anything, or the intersecting collider was not of type `T` then a nil object is returned instead.
    public func intersectRay<T: Object>(_ type: T.Type = T.self, parameters: PhysicsRayQueryParameters3D) -> IntersectRayResult<T>? {
        let dictionary: GDictionary = intersectRay(parameters: parameters)
        return IntersectRayResult<T>(dictionary)
    }
}
