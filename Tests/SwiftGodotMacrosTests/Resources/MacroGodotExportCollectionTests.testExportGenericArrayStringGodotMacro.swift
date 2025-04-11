
class SomeNode: Node {
    var greetings: VariantCollection<String> = []

    func _mproxy_set_greetings(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "greetings", greetings) {
            greetings = $0
        }
    }

    func _mproxy_get_greetings(args: borrowing Arguments) -> Variant? {
        _macroExportGet(greetings)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let _pgreetings = PropInfo (
            propertyType: .array,
            propertyName: "greetings",
            className: StringName("Array[String]"),
            hint: .arrayType,
            hintStr: "String",
            usage: .default)
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerMethod (name: "get_greetings", flags: .default, returnValue: _pgreetings, arguments: [], function: SomeNode._mproxy_get_greetings)
        classInfo.registerMethod (name: "set_greetings", flags: .default, returnValue: nil, arguments: [_pgreetings], function: SomeNode._mproxy_set_greetings)
        classInfo.registerProperty (_pgreetings, getter: "get_greetings", setter: "set_greetings")
    } ()
}