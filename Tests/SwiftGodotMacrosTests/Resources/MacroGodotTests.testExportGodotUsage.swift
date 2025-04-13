class Hi: Node {
    var goodName: String = "Supertop"

    func _mproxy_set_goodName(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._invokeSetter(args, "goodName", goodName) {
            goodName = $0
        }
    }

    func _mproxy_get_goodName(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._invokeGetter(goodName)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Hi")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Hi> (name: className)
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \Hi.goodName,
                name: "good_name",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_good_name",
            setterName: "set_good_name",
            getterFunction: Hi._mproxy_get_goodName,
            setterFunction: Hi._mproxy_set_goodName
        )
    } ()
}
