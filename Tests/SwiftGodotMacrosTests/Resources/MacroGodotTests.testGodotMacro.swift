class Hi: Node {

    private static let _initializeClass: Void = {
        let className = StringName(content: actualClassName.content)
        assert(ClassDB.classExists(class: className))
        className.content = .zero
    }()

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static var actualClassName: UnsafeStringName {
        UnsafeStringName("Hi")
    }

    open override var actualClassName: UnsafeStringName {
        Self.actualClassName
    }
}