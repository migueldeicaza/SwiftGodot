class Hi: Node {
    static let pickedUpItem = SignalWith1Argument<String>("picked_up_item", argument1Name: "kind")
    static let scored = SignalWithNoArguments("scored")
    static let differentInit = SignalWithNoArguments("different_init")
    static let differentInit2 = SignalWithNoArguments("different_init2")

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Hi")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerSignal(
            Hi.pickedUpItem.name,
            in: className,
            arguments: Hi.pickedUpItem.arguments
        )
        SwiftGodotRuntime._registerSignal(
            Hi.scored.name,
            in: className,
            arguments: Hi.scored.arguments
        )
        SwiftGodotRuntime._registerSignal(
            Hi.differentInit.name,
            in: className,
            arguments: Hi.differentInit.arguments
        )
        SwiftGodotRuntime._registerSignal(
            Hi.differentInit2.name,
            in: className,
            arguments: Hi.differentInit2.arguments
        )
    }()
}
