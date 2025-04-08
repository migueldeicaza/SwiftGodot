
public class Issue353: Node {
    var prefix1_prefixed_bool: Bool = true

    func _mproxy_set_prefix1_prefixed_bool(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "prefix1_prefixed_bool", &prefix1_prefixed_bool)
        return nil
    }

    func _mproxy_get_prefix1_prefixed_bool (args: borrowing Arguments) -> Variant? {
        _macroExportGet(prefix1_prefixed_bool)
    }
    var non_prefixed_bool: Bool = true

    func _mproxy_set_non_prefixed_bool(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "non_prefixed_bool", &non_prefixed_bool)
        return nil
    }

    func _mproxy_get_non_prefixed_bool (args: borrowing Arguments) -> Variant? {
        _macroExportGet(non_prefixed_bool)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Issue353")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Issue353> (name: className)
        classInfo.addPropertyGroup(name: "Group With a Prefix", prefix: "prefix1")
        let _pprefix1_prefixed_bool = PropInfo (
            propertyType: .bool,
            propertyName: "prefix1_prefixed_bool",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get__prefixed_bool", flags: .default, returnValue: _pprefix1_prefixed_bool, arguments: [], function: Issue353._mproxy_get_prefix1_prefixed_bool)
        classInfo.registerMethod (name: "_mproxy_set__prefixed_bool", flags: .default, returnValue: nil, arguments: [_pprefix1_prefixed_bool], function: Issue353._mproxy_set_prefix1_prefixed_bool)
        classInfo.registerProperty (_pprefix1_prefixed_bool, getter: "_mproxy_get__prefixed_bool", setter: "_mproxy_set__prefixed_bool")
        let _pnon_prefixed_bool = PropInfo (
            propertyType: .bool,
            propertyName: "non_prefixed_bool",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_non_prefixed_bool", flags: .default, returnValue: _pnon_prefixed_bool, arguments: [], function: Issue353._mproxy_get_non_prefixed_bool)
        classInfo.registerMethod (name: "_mproxy_set_non_prefixed_bool", flags: .default, returnValue: nil, arguments: [_pnon_prefixed_bool], function: Issue353._mproxy_set_non_prefixed_bool)
        classInfo.registerProperty (_pnon_prefixed_bool, getter: "_mproxy_get_non_prefixed_bool", setter: "_mproxy_set_non_prefixed_bool")
    } ()
}