class Hi: Node {
    static let pickedUpItem = SignalWith1Argument<String>("picked_up_item", argument1Name: "kind")
    static let scored = SignalWithNoArguments("scored")
    static let differentInit = SignalWithNoArguments("different_init")
    static let differentInit2 = SignalWithNoArguments("different_init2")

    private static let _initializeClass: Void = {
        let className = actualClassName
        assert(ClassDB.classExists(class: className))
        SwiftGodot._registerSignal(
            Hi.pickedUpItem.name,
            in: className,
            arguments: Hi.pickedUpItem.arguments
        )
        SwiftGodot._registerSignal(
            Hi.scored.name,
            in: className,
            arguments: Hi.scored.arguments
        )
        SwiftGodot._registerSignal(
            Hi.differentInit.name,
            in: className,
            arguments: Hi.differentInit.arguments
        )
        SwiftGodot._registerSignal(
            Hi.differentInit2.name,
            in: className,
            arguments: Hi.differentInit2.arguments
        )
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