class Car: Node {
    var vins: TypedArray<String> = [""]

    static func _mproxy_set_vins(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for vins: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "vins", object.vins) {
            object.vins = $0
        }
        return nil
    }

    static func _mproxy_get_vins(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for vins: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.vins)
    }
    var years: TypedArray<Int> = [1997]

    static func _mproxy_set_years(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for years: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "years", object.years) {
            object.years = $0
        }
        return nil
    }

    static func _mproxy_get_years(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for years: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.years)
    }
    var makes: TypedArray<String> = ["HONDA"]

    static func _mproxy_set_makes(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for makes: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "makes", object.makes) {
            object.makes = $0
        }
        return nil
    }

    static func _mproxy_get_makes(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for makes: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.makes)
    }
    var models: TypedArray<String> = ["ACCORD"]

    static func _mproxy_set_models(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for models: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "models", object.models) {
            object.models = $0
        }
        return nil
    }

    static func _mproxy_get_models(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for models: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.models)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Car")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._addPropertyGroup(className: className, name: "VIN", prefix: "")
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
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
        SwiftGodotRuntime._addPropertyGroup(className: className, name: "YMM", prefix: "")
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
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
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Car.makes,
                name: "makes",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_makes",
            setterName: "set_makes",
            getterFunction: Car._mproxy_get_makes,
            setterFunction: Car._mproxy_set_makes
        )
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Car.models,
                name: "models",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_models",
            setterName: "set_models",
            getterFunction: Car._mproxy_get_models,
            setterFunction: Car._mproxy_set_models
        )
    }()
    
}
