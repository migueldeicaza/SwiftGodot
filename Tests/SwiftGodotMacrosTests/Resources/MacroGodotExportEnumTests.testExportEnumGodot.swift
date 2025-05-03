enum Demo: Int, CaseIterable {
    case first
}
enum Demo64: Int64, CaseIterable {
    case first
}
class SomeNode: Node {
    var demo: Demo

    static func _mproxy_set_demo(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for demo: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "demo", object.demo) {
            object.demo = $0
        }
        return nil
    }

    static func _mproxy_get_demo(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for demo: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.demo)
    }
    var demo64: Demo64

    static func _mproxy_set_demo64(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for demo64: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "demo64", object.demo64) {
            object.demo64 = $0
        }
        return nil
    }

    static func _mproxy_get_demo64(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for demo64: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.demo64)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \SomeNode.demo,
                name: "demo",
                userHint: .enum,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_demo",
            setterName: "set_demo",
            getterFunction: SomeNode._mproxy_get_demo,
            setterFunction: SomeNode._mproxy_set_demo
        )
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \SomeNode.demo64,
                name: "demo64",
                userHint: .enum,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_demo64",
            setterName: "set_demo64",
            getterFunction: SomeNode._mproxy_get_demo64,
            setterFunction: SomeNode._mproxy_set_demo64
        )
    }()
}