
class Thing: SwiftGodot.Object {
    var value: Int64 = 0

    func _mproxy_set_value(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "value", value) {
            value = $0
        }
    }

    func _mproxy_get_value(args: borrowing Arguments) -> Variant? {
        _macroExportGet(value)
    }

    func get_some() -> Int64 { 10 }

    func _mproxy_get_some(arguments: borrowing Arguments) -> Variant? {
        let result = get_some()
        return Variant(result)

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Thing")
        assert(ClassDB.classExists(class: className))
        let _pvalue = PropInfo (
            propertyType: .int,
            propertyName: "value",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        let classInfo = ClassInfo<Thing> (name: className)
        classInfo.registerMethod (name: "_mproxy_get_value", flags: .default, returnValue: _pvalue, arguments: [], function: Thing._mproxy_get_value)
        classInfo.registerMethod (name: "_mproxy_set_value", flags: .default, returnValue: nil, arguments: [_pvalue], function: Thing._mproxy_set_value)
        classInfo.registerProperty (_pvalue, getter: "_mproxy_get_value", setter: "_mproxy_set_value")
        let prop_0 = PropInfo (propertyType: .int, propertyName: "", className: StringName(""), hint: .none, hintStr: "", usage: .default)
        classInfo.registerMethod(name: StringName("get_some"), flags: .default, returnValue: prop_0, arguments: [], function: Thing._mproxy_get_some)
    } ()
}