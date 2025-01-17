public struct Testing {
    /// Public API for tracking live objects
    public struct LiveObjects {
        /// All framework objects
        public static var framework: [Wrapped] { Array(liveFrameworkObjects.values) }

        /// All user-defined objects
        public static var subtyped: [Wrapped] { Array(liveSubtypedObjects.values) }

        /// All objects
        public static var all: [Wrapped] { framework + subtyped }

        /// Reset all existing tracked objects
        public static func reset() {
            liveFrameworkObjects.removeAll()
            liveSubtypedObjects.removeAll()
        }
    }
    
    public struct ClassNames {
        public static func setDuplicateNameCallback(_ callback: @escaping (_ name: StringName, _ type: Wrapped.Type) -> Void) -> DuplicateNameCallback {
            let old = duplicateClassNameDetected
            duplicateClassNameDetected = callback
            return old
        }
    }
}

/// Currently contains all instantiated objects, but might want to separate those
/// (or find a way of easily telling appart) framework objects from user subtypes
internal var liveFrameworkObjects: [UnsafeRawPointer: Wrapped] = [:]
internal var liveSubtypedObjects: [UnsafeRawPointer: Wrapped] = [:]

public typealias DuplicateNameCallback = (StringName, Wrapped.Type) -> Void
var duplicateClassNameDetected: DuplicateNameCallback = { name, type in
    preconditionFailure(
                """
                Godot already has a class named \(name), so I cannot register \(type) using that name. This is a fatal error because the only way I can tell whether Godot is handing me a pointer to a class I'm responsible for is by checking the class name.
                """
    )
}

