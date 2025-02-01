public extension Wrapped {
    struct Testing {
        /// Public API for tracking live objects
        public struct LiveObjects {
            /// All framework objects.
            /// For Testing purposes only.
            public static var framework: [Wrapped] { Array(liveFrameworkObjects.values) }

            /// All user-defined objects
            /// For Testing purposes only.
            public static var subtyped: [Wrapped] { Array(liveSubtypedObjects.values) }

            /// All objects
            /// For Testing purposes only.
            public static var all: [Wrapped] { framework + subtyped }

            /// Reset all existing tracked objects
            /// For Testing purposes only.
            public static func reset() {
                liveFrameworkObjects.removeAll()
                liveSubtypedObjects.removeAll()
            }
        }
        
        /// Public API for monitoring class names.
        public struct ClassNames {
            /// Set a callback to be called when a duplicate class name is detected.
            /// For Testing purposes only.
            public static func setDuplicateNameCallback(_ callback: @escaping DuplicateNameCallback) -> DuplicateNameCallback {
                let old = duplicateClassCallback
                duplicateClassCallback = callback
                return old
            }
        }
    }
}


