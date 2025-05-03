class TestClass: Node {
    func noNeedToSnakeCaseFunctionsNow() {}

    static func _mproxy_noNeedToSnakeCaseFunctionsNow(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling `noNeedToSnakeCaseFunctionsNow`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodot._wrapCallableResult(object.noNeedToSnakeCaseFunctionsNow())

    }
    func or_is_there() {}

    static func _mproxy_or_is_there(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling `or_is_there`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodot._wrapCallableResult(object.or_is_there())

    }
    func thatIsHideous() {}

    static func _mproxy_thatIsHideous(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling `thatIsHideous`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodot._wrapCallableResult(object.thatIsHideous())

    }
    func defaultIsLegacyCompatible() {}

    static func _mproxy_defaultIsLegacyCompatible(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling `defaultIsLegacyCompatible`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodot._wrapCallableResult(object.defaultIsLegacyCompatible())

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("TestClass")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodot._registerMethod(
            className: className,
            name: "no_need_to_snake_case_functions_now",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Swift.Void.self),
            arguments: [

            ],
            function: TestClass._mproxy_noNeedToSnakeCaseFunctionsNow
        )
        SwiftGodot._registerMethod(
            className: className,
            name: "or_is_there",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Swift.Void.self),
            arguments: [

            ],
            function: TestClass._mproxy_or_is_there
        )
        SwiftGodot._registerMethod(
            className: className,
            name: "thatIsHideous",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Swift.Void.self),
            arguments: [

            ],
            function: TestClass._mproxy_thatIsHideous
        )
        SwiftGodot._registerMethod(
            className: className,
            name: "defaultIsLegacyCompatible",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Swift.Void.self),
            arguments: [

            ],
            function: TestClass._mproxy_defaultIsLegacyCompatible
        )
    }()
}