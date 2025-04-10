
class Garage: Node {
    var bar: VariantCollection<Bool> = [false]

    func _mproxy_set_bar(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "bar", bar) {
            bar = $0
        }
    }

    func _mproxy_get_bar(args: borrowing Arguments) -> Variant? {
        _macroExportGet(bar)
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
        let _pbar = PropInfo (
            propertyType: .array,
            propertyName: "bar",
            className: StringName("Array[bool]"),
            hint: .arrayType,
            hintStr: "bool",
            usage: .default)
        classInfo.registerMethod (name: "get_bar", flags: .default, returnValue: _pbar, arguments: [], function: Garage._mproxy_get_bar)
        classInfo.registerMethod (name: "set_bar", flags: .default, returnValue: nil, arguments: [_pbar], function: Garage._mproxy_set_bar)
        classInfo.registerProperty (_pbar, getter: "get_bar", setter: "set_bar")
    } ()
}