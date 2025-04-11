
class Car: Node {
    var vins: VariantCollection<String> = ["00000000000000000"]

    func _mproxy_set_vins(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "vins", vins) {
            vins = $0
        }
    }

    func _mproxy_get_vins(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(vins)
    }
    var years: VariantCollection<Int> = [1997]

    func _mproxy_set_years(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "years", years) {
            years = $0
        }
    }

    func _mproxy_get_years(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(years)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Car")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Car> (name: className)
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetVariablePropInfo(
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
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetVariablePropInfo(
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
        classInfo.addPropertyGroup(name: "Pointless", prefix: "")
    } ()
}