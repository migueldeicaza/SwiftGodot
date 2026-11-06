class Hi: Node {
    var camera3DAmount: Double = 0

    static func _mproxy_set_camera3DAmount(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for camera3DAmount: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "camera3DAmount", object.camera3DAmount) {
            object.camera3DAmount = $0
        }
        return nil
    }

    static func _mproxy_get_camera3DAmount(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for camera3DAmount: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.camera3DAmount)
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
                at: \Hi.camera3DAmount,
                name: "camera_3d_amount",
                userHint: .range,
                userHintStr: "0,1",
                userUsage: nil
            ),
            getterName: "get_camera3_d_amount",
            setterName: "set_camera3_d_amount",
            getterFunction: Hi._mproxy_get_camera3DAmount,
            setterFunction: Hi._mproxy_set_camera3DAmount
        )
    }
}
