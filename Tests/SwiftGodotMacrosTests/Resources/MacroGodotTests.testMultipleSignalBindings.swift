class OtherThing: SwiftGodot.Node {            
    var signal0: SimpleSignal, signal1: SimpleSignal

    private static let _initializeClass: Void = {
        let className = actualClassName
        assert(ClassDB.classExists(class: className))
        SimpleSignal.register(as: "signal0", in: className)
        SimpleSignal.register(as: "signal1", in: className)
    }()

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let actualClassName: StringName = "OtherThing"

    open override var actualClassName: StringName {
        Self.actualClassName
    }
}