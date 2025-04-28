final class Hi: Node {
    override func _hasPoint(_ point: Vector2) -> Bool { false }

    private static let _initializeClass: Void = {
        let className = StringName(content: actualClassName.content)
        assert(ClassDB.classExists(class: className))
        className.content = .zero
    }()

    override public class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static var actualClassName: UnsafeStringName {
        UnsafeStringName("Hi")
    }

    public override var actualClassName: UnsafeStringName {
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