
class Car: Node {
    var vins: TypedArray<String> = ["00000000000000000"]

    static func _mproxy_set_vins(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for vins: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "vins", object.vins) {
            object.vins = $0
        }
        return nil
    }

    static func _mproxy_get_vins(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for vins: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.vins)
    }
    var years: TypedArray<Int> = [1997]

    static func _mproxy_set_years(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for years: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "years", object.years) {
            object.years = $0
        }
        return nil
    }

    static func _mproxy_get_years(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for years: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.years)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Car")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \Car.vins,
                name: "vins",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_vins",
            setterName: "set_vins",
            getterFunction: Car._mproxy_get_vins,
            setterFunction: Car._mproxy_set_vins
        )
        SwiftGodot._addPropertyGroup(className: className, name: "YMMS", prefix: "")
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \Car.years,
                name: "years",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_years",
            setterName: "set_years",
            getterFunction: Car._mproxy_get_years,
            setterFunction: Car._mproxy_set_years
        )
    }()
}