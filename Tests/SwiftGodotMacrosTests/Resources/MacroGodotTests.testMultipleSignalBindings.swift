class OtherThing: SwiftGodot.Node {            
    var signal0: SimpleSignal, signal1: SimpleSignal

    private static let _initializeClass: Void = {
        let className = StringName(takingOver: getActualClassName())
        assert(ClassDB.classExists(class: className))
        SimpleSignal.register(as: "signal0", in: className)
        SimpleSignal.register(as: "signal1", in: className)
    }()

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static func getActualClassName() -> FastStringName {
        FastStringName("OtherThing")
    }

    open override func getActualClassName() -> FastStringName {
        Self.getActualClassName()
    }
}