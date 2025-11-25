class Hi: Node {
    var goodName: String = "Supertop"

    static func _mproxy_set_goodName(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for goodName: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "goodName", object.goodName) {
            object.goodName = $0
        }
        return nil
    }

    static func _mproxy_get_goodName(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for goodName: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.goodName)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Hi")
        assert(ClassDB.classExists(class: className))
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Hi.goodName,
                name: "good_name",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_good_name",
            setterName: "set_good_name",
            getterFunction: Hi._mproxy_get_goodName,
            setterFunction: Hi._mproxy_set_goodName
        )
    }()
}