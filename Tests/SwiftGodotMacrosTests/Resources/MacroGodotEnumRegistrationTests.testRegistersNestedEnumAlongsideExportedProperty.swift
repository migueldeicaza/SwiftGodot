class Player: Node {
    enum State: Int, CaseIterable {
        case idle
        case running
    }
    var state: State = .idle

    static func _mproxy_set_state(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for state: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "state", object.state) {
            object.state = $0
        }
        return nil
    }

    static func _mproxy_get_state(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for state: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.state)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: Player.self) else {
            return
        }
        let className = StringName("Player")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerEnumIfPossible(Player.State.self)
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Player.state,
                name: SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("state"),
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: StringName("get_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("state")),
            setterName: StringName("set_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("state")),
            getterFunction: Player._mproxy_get_state,
            setterFunction: Player._mproxy_set_state
        )
    }
}
