class SomeNode: Node {
    var greetings: TypedArray<String> = []

    static func _mproxy_set_greetings(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for greetings: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "greetings", object.greetings) {
            object.greetings = $0
        }
        return nil
    }

    static func _mproxy_get_greetings(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for greetings: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.greetings)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \SomeNode.greetings,
                name: "greetings",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_greetings",
            setterName: "set_greetings",
            getterFunction: SomeNode._mproxy_get_greetings,
            setterFunction: SomeNode._mproxy_set_greetings
        )
    }()
}
