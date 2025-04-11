
class Thing: SwiftGodot.Object {
    var value: Int64 = 0

    func _mproxy_set_value(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "value", value) {
            value = $0
        }
    }

    func _mproxy_get_value(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(value)
    }

    func get_some() -> Int64 { 10 }

    func _mproxy_get_some(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        return SwiftGodot._macroCallableToVariant(get_some())

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Thing")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Thing> (name: className)
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetVariablePropInfo(
                at: \Thing.value,
                name: "value",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_value",
            setterName: "set_value",
            getterFunction: Thing._mproxy_get_value,
            setterFunction: Thing._mproxy_set_value
        )
        let prop_0 = PropInfo (propertyType: .int, propertyName: "", className: StringName(""), hint: .none, hintStr: "", usage: .default)
        classInfo.registerMethod(name: StringName("get_some"), flags: .default, returnValue: prop_0, arguments: [], function: Thing._mproxy_get_some)
    } ()
}