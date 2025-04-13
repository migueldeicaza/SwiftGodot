
class Car: Node {
    var vins: VariantCollection<String> = [""]

    func _mproxy_set_vins(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._invokeSetter(args, "vins", vins) {
            vins = $0
        }
    }

    func _mproxy_get_vins(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._invokeGetter(vins)
    }
    var years: VariantCollection<Int> = [1997]

    func _mproxy_set_years(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._invokeSetter(args, "years", years) {
            years = $0
        }
    }

    func _mproxy_get_years(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._invokeGetter(years)
    }
    var makes: VariantCollection<String> = ["HONDA"]

    func _mproxy_set_makes(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._invokeSetter(args, "makes", makes) {
            makes = $0
        }
    }

    func _mproxy_get_makes(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._invokeGetter(makes)
    }
    var models: VariantCollection<String> = ["ACCORD"]

    func _mproxy_set_models(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._invokeSetter(args, "models", models) {
            models = $0
        }
    }

    func _mproxy_get_models(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._invokeGetter(models)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Car")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Car> (name: className)
        classInfo.addPropertyGroup(name: "VIN", prefix: "")
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
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
        classInfo.addPropertyGroup(name: "YMM", prefix: "")
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
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
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
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
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
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
    } ()
    
}
