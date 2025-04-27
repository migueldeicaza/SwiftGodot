class Hi: Control {
    override func _hasPoint(_ point: Vector2) -> Bool { false }

    private static let _initializeClass: Void = {
        let className = actualClassName
        assert(ClassDB.classExists(class: className))
    }()

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let actualClassName: StringName = "Hi"

    open override var actualClassName: StringName {
        Self.actualClassName
    }

    override open class func implementedOverrides () -> [StringName] {
        return super.implementedOverrides () + [
            StringName("_has_point"),
        ]
    }
}