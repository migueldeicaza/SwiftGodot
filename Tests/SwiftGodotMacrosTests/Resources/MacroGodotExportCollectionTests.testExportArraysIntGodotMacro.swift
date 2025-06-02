
class SomeNode: Node {
    var someNumbers: TypedArray<Int> = []

    static func _mproxy_set_someNumbers(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for someNumbers: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "someNumbers", object.someNumbers) {
            object.someNumbers = $0
        }
        return nil
    }

    static func _mproxy_get_someNumbers(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for someNumbers: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.someNumbers)
    }
    var someOtherNumbers: TypedArray<Int> = []

    static func _mproxy_set_someOtherNumbers(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for someOtherNumbers: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "someOtherNumbers", object.someOtherNumbers) {
            object.someOtherNumbers = $0
        }
        return nil
    }

    static func _mproxy_get_someOtherNumbers(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for someOtherNumbers: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.someOtherNumbers)
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
                at: \SomeNode.someNumbers,
                name: "some_numbers",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_some_numbers",
            setterName: "set_some_numbers",
            getterFunction: SomeNode._mproxy_get_someNumbers,
            setterFunction: SomeNode._mproxy_set_someNumbers
        )
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \SomeNode.someOtherNumbers,
                name: "some_other_numbers",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_some_other_numbers",
            setterName: "set_some_other_numbers",
            getterFunction: SomeNode._mproxy_get_someOtherNumbers,
            setterFunction: SomeNode._mproxy_set_someOtherNumbers
        )
    }()
}