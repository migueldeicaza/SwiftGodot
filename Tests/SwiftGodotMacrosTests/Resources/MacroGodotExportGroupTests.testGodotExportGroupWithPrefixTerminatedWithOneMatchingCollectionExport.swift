
public class Issue353: Node {
    var prefix1_prefixed_bool: VariantCollection<Bool> = [false]

    func _mproxy_set_prefix1_prefixed_bool(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "prefix1_prefixed_bool", prefix1_prefixed_bool) {
            prefix1_prefixed_bool = $0
        }
    }

    func _mproxy_get_prefix1_prefixed_bool(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._wrapGetterResult(prefix1_prefixed_bool)
    }
    var non_prefixed_bool: VariantCollection<Bool> = [false]

    func _mproxy_set_non_prefixed_bool(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "non_prefixed_bool", non_prefixed_bool) {
            non_prefixed_bool = $0
        }
    }

    func _mproxy_get_non_prefixed_bool(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._wrapGetterResult(non_prefixed_bool)
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
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \Issue353.prefix1_prefixed_bool,
                name: "prefix1_prefixed_bool",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get__prefixed_bool",
            setterName: "set__prefixed_bool",
            getterFunction: Issue353._mproxy_get_prefix1_prefixed_bool,
            setterFunction: Issue353._mproxy_set_prefix1_prefixed_bool
        )
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \Issue353.non_prefixed_bool,
                name: "non_prefixed_bool",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_non_prefixed_bool",
            setterName: "set_non_prefixed_bool",
            getterFunction: Issue353._mproxy_get_non_prefixed_bool,
            setterFunction: Issue353._mproxy_set_non_prefixed_bool
        )
    } ()
}