class Hi: Node {
    var goodName: String = "Supertop"

    func _mproxy_set_goodName(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "goodName", goodName) {
            goodName = $0
        }
    }

    func _mproxy_get_goodName(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(goodName)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Hi")
        assert(ClassDB.classExists(class: className))
        let _pgoodName = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Hi.goodName,
            name: "good_name",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        let classInfo = ClassInfo<Hi> (name: className)
        classInfo.registerMethod (name: "get_good_name", flags: .default, returnValue: _pgoodName, arguments: [], function: Hi._mproxy_get_goodName)
        classInfo.registerMethod (name: "set_good_name", flags: .default, returnValue: nil, arguments: [_pgoodName], function: Hi._mproxy_set_goodName)
        classInfo.registerProperty (_pgoodName, getter: "get_good_name", setter: "set_good_name")
    } ()
}