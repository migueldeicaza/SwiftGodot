
class Garage: Node {
    var bar: Bool = false

    func _mproxy_set_bar(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "bar", &bar)
        return nil
    }

    func _mproxy_get_bar (args: borrowing Arguments) -> Variant? {
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
            propertyType: .bool,
            propertyName: "bar",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_bar", flags: .default, returnValue: _pbar, arguments: [], function: Garage._mproxy_get_bar)
        classInfo.registerMethod (name: "_mproxy_set_bar", flags: .default, returnValue: nil, arguments: [_pbar], function: Garage._mproxy_set_bar)
        classInfo.registerProperty (_pbar, getter: "_mproxy_get_bar", setter: "_mproxy_set_bar")
    } ()
}