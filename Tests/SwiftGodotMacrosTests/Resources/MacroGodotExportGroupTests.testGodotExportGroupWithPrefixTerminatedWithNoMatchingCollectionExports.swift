class Garage: Node {
    var bar: TypedArray<Bool> = [false]

    static func _mproxy_set_bar(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for bar: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "bar", object.bar) {
            object.bar = $0
        }
        return nil
    }

    static func _mproxy_get_bar(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for bar: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.bar)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: Garage.self) else {
            return
        }
        let className = StringName("Garage")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._addPropertyGroup(className: className, name: "Example", prefix: "example")
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Garage.bar,
                name: SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("bar"),
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: StringName("get_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("bar")),
            setterName: StringName("set_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("bar")),
            getterFunction: Garage._mproxy_get_bar,
            setterFunction: Garage._mproxy_set_bar
        )
    }
}
