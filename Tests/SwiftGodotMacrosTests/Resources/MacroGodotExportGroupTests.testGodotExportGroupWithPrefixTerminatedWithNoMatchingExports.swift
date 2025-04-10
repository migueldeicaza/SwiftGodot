
class Garage: Node {
    var bar: Bool = false

    func _mproxy_set_bar(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "bar", bar) {
            bar = $0
        }
    }

    func _mproxy_get_bar(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(bar)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Garage")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Garage> (name: className)
        classInfo.addPropertyGroup(name: "Example", prefix: "example")
        let _pbar = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Garage.bar,
            name: "bar",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_bar", flags: .default, returnValue: _pbar, arguments: [], function: Garage._mproxy_get_bar)
        classInfo.registerMethod (name: "set_bar", flags: .default, returnValue: nil, arguments: [_pbar], function: Garage._mproxy_set_bar)
        classInfo.registerProperty (_pbar, getter: "get_bar", setter: "set_bar")
    } ()
}