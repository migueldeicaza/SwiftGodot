class Car: Node {
    var vin: String = ""

    static func _mproxy_set_vin(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for vin: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "vin", object.vin) {
            object.vin = $0
        }
        return nil
    }

    static func _mproxy_get_vin(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for vin: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.vin)
    }
    var ymms_year: Int = 1998

    static func _mproxy_set_ymms_year(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for ymms_year: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "ymms_year", object.ymms_year) {
            object.ymms_year = $0
        }
        return nil
    }

    static func _mproxy_get_ymms_year(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for ymms_year: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.ymms_year)
    }
    var ymms_make: String = "Honda"

    static func _mproxy_set_ymms_make(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for ymms_make: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "ymms_make", object.ymms_make) {
            object.ymms_make = $0
        }
        return nil
    }

    static func _mproxy_get_ymms_make(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for ymms_make: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.ymms_make)
    }
    var ymms_model: String = "Odyssey"

    static func _mproxy_set_ymms_model(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for ymms_model: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "ymms_model", object.ymms_model) {
            object.ymms_model = $0
        }
        return nil
    }

    static func _mproxy_get_ymms_model(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for ymms_model: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.ymms_model)
    }
    var ymms_series: String = "LX"

    static func _mproxy_set_ymms_series(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for ymms_series: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "ymms_series", object.ymms_series) {
            object.ymms_series = $0
        }
        return nil
    }

    static func _mproxy_get_ymms_series(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for ymms_series: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.ymms_series)
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
        SwiftGodot._addPropertyGroup(className: className, name: "Vehicle", prefix: "")
        SwiftGodot._addPropertySubgroup(className: className, name: "VIN", prefix: "")
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \Car.vin,
                name: "vin",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_vin",
            setterName: "set_vin",
            getterFunction: Car._mproxy_get_vin,
            setterFunction: Car._mproxy_set_vin
        )
        SwiftGodot._addPropertySubgroup(className: className, name: "YMMS", prefix: "ymms_")
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \Car.ymms_year,
                name: "ymms_year",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_year",
            setterName: "set_year",
            getterFunction: Car._mproxy_get_ymms_year,
            setterFunction: Car._mproxy_set_ymms_year
        )
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \Car.ymms_make,
                name: "ymms_make",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_make",
            setterName: "set_make",
            getterFunction: Car._mproxy_get_ymms_make,
            setterFunction: Car._mproxy_set_ymms_make
        )
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \Car.ymms_model,
                name: "ymms_model",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_model",
            setterName: "set_model",
            getterFunction: Car._mproxy_get_ymms_model,
            setterFunction: Car._mproxy_set_ymms_model
        )
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \Car.ymms_series,
                name: "ymms_series",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_series",
            setterName: "set_series",
            getterFunction: Car._mproxy_get_ymms_series,
            setterFunction: Car._mproxy_set_ymms_series
        )
    }()
}