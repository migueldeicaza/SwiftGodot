enum Demo: Int, CaseIterable {
    case first
}
enum Demo64: Int64, CaseIterable {
    case first
}
class SomeNode: Node {
    var demo: Demo

    func _mproxy_set_demo(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "demo", demo) {
            demo = $0
        }
    }

    func _mproxy_get_demo(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(demo)
    }
    var demo64: Demo64

    func _mproxy_set_demo64(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "demo64", demo64) {
            demo64 = $0
        }
    }

    func _mproxy_get_demo64(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(demo64)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let _pdemo = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \SomeNode.demo,
            name: "demo",
            userHint: .enum,
            userHintStr: nil,
            userUsage: nil
        )
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerMethod (name: "get_demo", flags: .default, returnValue: _pdemo, arguments: [], function: SomeNode._mproxy_get_demo)
        classInfo.registerMethod (name: "set_demo", flags: .default, returnValue: nil, arguments: [_pdemo], function: SomeNode._mproxy_set_demo)
        classInfo.registerProperty (_pdemo, getter: "get_demo", setter: "set_demo")
        let _pdemo64 = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \SomeNode.demo64,
            name: "demo64",
            userHint: .enum,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_demo64", flags: .default, returnValue: _pdemo64, arguments: [], function: SomeNode._mproxy_get_demo64)
        classInfo.registerMethod (name: "set_demo64", flags: .default, returnValue: nil, arguments: [_pdemo64], function: SomeNode._mproxy_set_demo64)
        classInfo.registerProperty (_pdemo64, getter: "get_demo64", setter: "set_demo64")
    } ()
}