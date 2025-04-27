final class Hi: Node {
    override func _hasPoint(_ point: Vector2) -> Bool { false }

    private static let _initializeClass: Void = {
        let className = actualClassName
        assert(ClassDB.classExists(class: className))
    }()

    override public class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let actualClassName: StringName = "Hi"

    public override var actualClassName: StringName {
        Self.actualClassName
    }

    override public class func implementedOverrides () -> [StringName] {
        guard !Engine.isEditorHint () else {
            return []
        }
        return super.implementedOverrides () + [
            StringName("_has_point"),
        ]
    }
}