class Hi: Control {
    override func _hasPoint(_ point: Vector2) -> Bool { false }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Hi")
        assert(ClassDB.classExists(class: className))
    }()

    override open class func implementedOverrides () -> [StringName] {
        return super.implementedOverrides () + [
            StringName("_has_point"),
        ]
    }
}
