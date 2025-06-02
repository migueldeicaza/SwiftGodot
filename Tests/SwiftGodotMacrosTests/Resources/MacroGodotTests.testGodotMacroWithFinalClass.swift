final class Hi: Node {
    override func _hasPoint(_ point: Vector2) -> Bool { false }

    override public class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Hi")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
    }()

    override public class func implementedOverrides () -> [StringName] {
        guard !Engine.isEditorHint () else {
            return []
        }
        return super.implementedOverrides () + [
            StringName("_has_point"),
        ]
    }
}