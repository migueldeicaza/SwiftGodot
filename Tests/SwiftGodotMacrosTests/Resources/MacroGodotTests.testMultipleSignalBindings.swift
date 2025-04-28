class OtherThing: SwiftGodot.Node {            
    var signal0: SimpleSignal, signal1: SimpleSignal

    private static let _initializeClass: Void = {
        let className = StringName(content: actualClassName.content)
        assert(ClassDB.classExists(class: className))
        SimpleSignal.register(as: "signal0", in: className)
        SimpleSignal.register(as: "signal1", in: className)
        className.content = .zero
    }()

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static var actualClassName: UnsafeStringName {
        UnsafeStringName("OtherThing")
    }

    open override var actualClassName: UnsafeStringName {
        Self.actualClassName
    }
}