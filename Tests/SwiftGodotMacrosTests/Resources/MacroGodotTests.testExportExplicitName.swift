class TestClass: Node {
    var originalName: Node? = nil

    static func _mproxy_set_originalName(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for originalName: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "originalName", object.originalName) {
            object.originalName = $0
        }
        return nil
    }

    static func _mproxy_get_originalName(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for originalName: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.originalName)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: TestClass.self) else {
            return
        }
        let className = StringName("TestClass")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \TestClass.testExplicitName,
                name: "testExplicitName",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_test_explicit_name",
            setterName: "set_test_explicit_name",
            getterFunction: TestClass._mproxy_get_testExplicitName,
            setterFunction: TestClass._mproxy_set_testExplicitName
        )
    }
}
