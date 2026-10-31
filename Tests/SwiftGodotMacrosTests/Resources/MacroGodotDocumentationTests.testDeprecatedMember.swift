class Legacy: Node {
    @available(*, deprecated, message: "Use speed instead.")
    var velocity: Double = 0

    static func _mproxy_set_velocity(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for velocity: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "velocity", object.velocity) {
            object.velocity = $0
        }
        return nil
    }

    static func _mproxy_get_velocity(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for velocity: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.velocity)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: Legacy.self) else {
            return
        }
        let className = StringName("Legacy")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Legacy.velocity,
                name: "velocity",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_velocity",
            setterName: "set_velocity",
            getterFunction: Legacy._mproxy_get_velocity,
            setterFunction: Legacy._mproxy_set_velocity
        )
    }

    override open class var _editorDocumentation: String? {
        #if SWIFTGODOT_INCLUDE_EDITOR_DOCUMENTATION
        return "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<class name=\"Legacy\">\n<brief_description></brief_description>\n<description></description>\n<members>\n<member name=\"velocity\" type=\"\" deprecated=\"Use speed instead.\"></member>\n</members>\n</class>\n"
        #else
        return nil
        #endif
    }
}
