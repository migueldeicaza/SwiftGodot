final class Hi: Node {
    override func _hasPoint(_ point: Vector2) -> Bool { false }

    private static let _initializeClass: Void = {
        let className = StringName(takingOver: getActualClassName())
        assert(ClassDB.classExists(class: className))
    }()

    override public class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static func getActualClassName() -> FastStringName {
        FastStringName("Hi")
    }

    public override func getActualClassName() -> FastStringName {
        Self.getActualClassName()
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