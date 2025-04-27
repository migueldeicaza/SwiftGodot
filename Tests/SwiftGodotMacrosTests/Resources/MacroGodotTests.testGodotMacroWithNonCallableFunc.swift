class Hi: Node {
    func hi() {
    }

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
}