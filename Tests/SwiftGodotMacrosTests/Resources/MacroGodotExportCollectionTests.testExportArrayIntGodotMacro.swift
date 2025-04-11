
class SomeNode: Node {
    var someNumbers: VariantCollection<Int> = []

    func _mproxy_set_someNumbers(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "someNumbers", someNumbers) {
            someNumbers = $0
        }
    }

    func _mproxy_get_someNumbers(args: borrowing Arguments) -> Variant? {
        _macroExportGet(someNumbers)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let _psomeNumbers = PropInfo (
            propertyType: .array,
            propertyName: "some_numbers",
            className: StringName("Array[int]"),
            hint: .arrayType,
            hintStr: "int",
            usage: .default)
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerMethod (name: "get_some_numbers", flags: .default, returnValue: _psomeNumbers, arguments: [], function: SomeNode._mproxy_get_someNumbers)
        classInfo.registerMethod (name: "set_some_numbers", flags: .default, returnValue: nil, arguments: [_psomeNumbers], function: SomeNode._mproxy_set_someNumbers)
        classInfo.registerProperty (_psomeNumbers, getter: "get_some_numbers", setter: "set_some_numbers")
    } ()
}