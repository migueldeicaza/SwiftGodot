
class Garage: Node {
    var bar: TypedArray<Bool> = [false]

    static func _mproxy_set_bar(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for bar: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "bar", object.bar) {
            object.bar = $0
        }
        return nil
    }

    static func _mproxy_get_bar(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for bar: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.bar)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Garage")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodot._addPropertyGroup(className: className, name: "Example", prefix: "example")
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \Garage.bar,
                name: "bar",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_bar",
            setterName: "set_bar",
            getterFunction: Garage._mproxy_get_bar,
            setterFunction: Garage._mproxy_set_bar
        )
    }()
}