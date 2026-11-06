class Hi: Node {
    var doItButton: Callable = Callable()

    static func _mproxy_set_doItButton(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for doItButton: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "doItButton", object.doItButton) {
            object.doItButton = $0
        }
        return nil
    }

    static func _mproxy_get_doItButton(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for doItButton: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.doItButton)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: Hi.self) else {
            return
        }
        let className = StringName("Hi")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Hi.doItButton,
                name: "do_it_button",
                userHint: .toolButton,
                userHintStr: "Do It,Add",
                userUsage: .editor
            ),
            getterName: "get_do_it_button",
            setterName: "set_do_it_button",
            getterFunction: Hi._mproxy_get_doItButton,
            setterFunction: Hi._mproxy_set_doItButton
        )
    }
}
