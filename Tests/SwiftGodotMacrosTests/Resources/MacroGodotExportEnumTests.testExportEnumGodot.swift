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
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \SomeNode.demo,
                name: "demo",
                userHint: .enum,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_demo",
            setterName: "set_demo",
            getterFunction: SomeNode._mproxy_get_demo,
            setterFunction: SomeNode._mproxy_set_demo
        )
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \SomeNode.demo64,
                name: "demo64",
                userHint: .enum,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_demo64",
            setterName: "set_demo64",
            getterFunction: SomeNode._mproxy_get_demo64,
            setterFunction: SomeNode._mproxy_set_demo64
        )
    } ()
}
