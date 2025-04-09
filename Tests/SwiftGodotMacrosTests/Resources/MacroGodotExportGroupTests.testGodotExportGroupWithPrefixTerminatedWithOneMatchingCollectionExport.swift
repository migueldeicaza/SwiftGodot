
public class Issue353: Node {
    var prefix1_prefixed_bool: VariantCollection<Bool> = [false]

    func _mproxy_set_prefix1_prefixed_bool(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "prefix1_prefixed_bool", prefix1_prefixed_bool) {
            prefix1_prefixed_bool = $0
        }
    }

    func _mproxy_get_prefix1_prefixed_bool(args: borrowing Arguments) -> Variant? {
        _macroExportGet(prefix1_prefixed_bool)
    }
    var non_prefixed_bool: VariantCollection<Bool> = [false]

    func _mproxy_set_non_prefixed_bool(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "non_prefixed_bool", non_prefixed_bool) {
            non_prefixed_bool = $0
        }
    }

    func _mproxy_get_non_prefixed_bool(args: borrowing Arguments) -> Variant? {
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
            propertyType: .array,
            propertyName: "prefix1_prefixed_bool",
            className: StringName("Array[bool]"),
            hint: .arrayType,
            hintStr: "bool",
            usage: .default)
        classInfo.registerMethod (name: "get__prefixed_bool", flags: .default, returnValue: _pprefix1_prefixed_bool, arguments: [], function: Issue353._mproxy_get_prefix1_prefixed_bool)
        classInfo.registerMethod (name: "set__prefixed_bool", flags: .default, returnValue: nil, arguments: [_pprefix1_prefixed_bool], function: Issue353._mproxy_set_prefix1_prefixed_bool)
        classInfo.registerProperty (_pprefix1_prefixed_bool, getter: "get__prefixed_bool", setter: "set__prefixed_bool")
        let _pnon_prefixed_bool = PropInfo (
            propertyType: .array,
            propertyName: "non_prefixed_bool",
            className: StringName("Array[bool]"),
            hint: .arrayType,
            hintStr: "bool",
            usage: .default)
        classInfo.registerMethod (name: "get_non_prefixed_bool", flags: .default, returnValue: _pnon_prefixed_bool, arguments: [], function: Issue353._mproxy_get_non_prefixed_bool)
        classInfo.registerMethod (name: "set_non_prefixed_bool", flags: .default, returnValue: nil, arguments: [_pnon_prefixed_bool], function: Issue353._mproxy_set_non_prefixed_bool)
        classInfo.registerProperty (_pnon_prefixed_bool, getter: "get_non_prefixed_bool", setter: "set_non_prefixed_bool")
    } ()
}