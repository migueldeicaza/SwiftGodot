class Car: Node {
    var vin: String = "00000000000000000"

    static func _mproxy_set_vin(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for vin: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "vin", object.vin) {
            object.vin = $0
        }
        return nil
    }

    static func _mproxy_get_vin(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for vin: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.vin)
    }
    var year: Int = 1997

    static func _mproxy_set_year(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for year: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "year", object.year) {
            object.year = $0
        }
        return nil
    }

    static func _mproxy_get_year(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for year: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.year)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: Car.self) else {
            return
        }
        let className = StringName("Car")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Car.vin,
                name: SwiftGodotRuntime._translateMemberIdentifier("vin"),
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: StringName("get_" + SwiftGodotRuntime._translateMemberIdentifier("vin")),
            setterName: StringName("set_" + SwiftGodotRuntime._translateMemberIdentifier("vin")),
            getterFunction: Car._mproxy_get_vin,
            setterFunction: Car._mproxy_set_vin
        )
        SwiftGodotRuntime._addPropertyGroup(className: className, name: "YMMS", prefix: "")
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Car.year,
                name: SwiftGodotRuntime._translateMemberIdentifier("year"),
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: StringName("get_" + SwiftGodotRuntime._translateMemberIdentifier("year")),
            setterName: StringName("set_" + SwiftGodotRuntime._translateMemberIdentifier("year")),
            getterFunction: Car._mproxy_get_year,
            setterFunction: Car._mproxy_set_year
        )
    }
}
