class Hi: Control {
    override func _hasPoint(_ point: Vector2) -> Bool { false }

    private static let _initializeClass: Void = {
        let className = StringName(takingOver: getActualClassName())
        assert(ClassDB.classExists(class: className))
    }()

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static func getActualClassName() -> FastStringName {
        FastStringName("Hi")
    }

    open override func getActualClassName() -> FastStringName {
        Self.getActualClassName()
    }

    override open class func implementedOverrides () -> [StringName] {
        return super.implementedOverrides () + [
            StringName("_has_point"),
        ]
    }
}