
class Thing: SwiftGodot.Object {
    var value: Int64 = 0

    static func _mproxy_set_value(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for value: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "value", object.value) {
            object.value = $0
        }
        return nil
    }

    static func _mproxy_get_value(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for value: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.value)
    }

    func get_some() -> Int64 { 10 }

    static func _mproxy_get_some(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling `get_some`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodot._wrapCallableResult(object.get_some())

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Thing")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \Thing.value,
                name: "value",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_value",
            setterName: "set_value",
            getterFunction: Thing._mproxy_get_value,
            setterFunction: Thing._mproxy_set_value
        )
        SwiftGodot._registerMethod(
            className: className,
            name: "get_some",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Int64.self),
            arguments: [

            ],
            function: Thing._mproxy_get_some
        )
    }()
}