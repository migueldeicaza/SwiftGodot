class Hi: Node {

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
}