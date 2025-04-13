
class Thing: SwiftGodot.Object {
    var value: Int64 = 0

    func _mproxy_set_value(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "value", value) {
            value = $0
        }
    }

    func _mproxy_get_value(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._wrapGetterResult(value)
    }

    func get_some() -> Int64 { 10 }

    func _mproxy_get_some(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        return SwiftGodot._wrapCallableResult(get_some())

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
            SwiftGodot._propInfo(
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
        classInfo.registerMethod(
            name: "get_some",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Int64.self),
            arguments: [

            ],
            function: Thing._mproxy_get_some
        )
    } ()
}