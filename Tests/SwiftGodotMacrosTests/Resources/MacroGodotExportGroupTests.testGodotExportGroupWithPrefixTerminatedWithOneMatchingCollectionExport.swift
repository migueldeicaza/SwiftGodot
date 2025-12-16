
public class Issue353: Node {
    var prefix1_prefixed_bool: TypedArray<Bool> = [false]

    static func _mproxy_set_prefix1_prefixed_bool(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for prefix1_prefixed_bool: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "prefix1_prefixed_bool", object.prefix1_prefixed_bool) {
            object.prefix1_prefixed_bool = $0
        }
        return nil
    }

    static func _mproxy_get_prefix1_prefixed_bool(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for prefix1_prefixed_bool: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.prefix1_prefixed_bool)
    }
    var non_prefixed_bool: TypedArray<Bool> = [false]

    static func _mproxy_set_non_prefixed_bool(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for non_prefixed_bool: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "non_prefixed_bool", object.non_prefixed_bool) {
            object.non_prefixed_bool = $0
        }
        return nil
    }

    static func _mproxy_get_non_prefixed_bool(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for non_prefixed_bool: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.non_prefixed_bool)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Issue353")
        assert(ClassDB.classExists(class: className))
        SwiftGodotRuntime._addPropertyGroup(className: className, name: "Group With a Prefix", prefix: "prefix1")
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
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
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
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
    }()
}