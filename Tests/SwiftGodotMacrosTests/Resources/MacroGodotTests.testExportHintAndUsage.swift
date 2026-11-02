class Hi: Node {
    var amount: Double = 0

    static func _mproxy_set_amount(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for amount: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "amount", object.amount) {
            object.amount = $0
        }
        return nil
    }

    static func _mproxy_get_amount(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for amount: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.amount)
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
                at: \Hi.amount,
                name: "amount",
                userHint: .range,
                userHintStr: nil,
                userUsage: .editor
            ),
            getterName: "get_amount",
            setterName: "set_amount",
            getterFunction: Hi._mproxy_get_amount,
            setterFunction: Hi._mproxy_set_amount
        )
    }
}
