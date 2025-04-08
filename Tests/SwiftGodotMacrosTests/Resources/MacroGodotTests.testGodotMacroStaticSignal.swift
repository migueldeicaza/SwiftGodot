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
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Hi> (name: className)
        classInfo.registerSignal(name: Hi.pickedUpItem.name, arguments: Hi.pickedUpItem.arguments)
        classInfo.registerSignal(name: Hi.scored.name, arguments: Hi.scored.arguments)
        classInfo.registerSignal(name: Hi.differentInit.name, arguments: Hi.differentInit.arguments)
        classInfo.registerSignal(name: Hi.differentInit2.name, arguments: Hi.differentInit2.arguments)
    } ()
}