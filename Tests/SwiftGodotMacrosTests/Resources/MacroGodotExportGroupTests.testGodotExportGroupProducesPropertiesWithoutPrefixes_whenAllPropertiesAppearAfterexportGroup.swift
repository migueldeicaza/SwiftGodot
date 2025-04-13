
class Car: Node {
    var vin: String = "00000000000000000"

    func _mproxy_set_vin(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "vin", vin) {
            vin = $0
        }
    }

    func _mproxy_get_vin(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._wrapGetterResult(vin)
    }
    var year: Int = 1997

    func _mproxy_set_year(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "year", year) {
            year = $0
        }
    }

    func _mproxy_get_year(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._wrapGetterResult(year)
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
            SwiftGodot._propInfo(
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
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \Car.year,
                name: "year",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_year",
            setterName: "set_year",
            getterFunction: Car._mproxy_get_year,
            setterFunction: Car._mproxy_set_year
        )
        classInfo.addPropertyGroup(name: "Pointless", prefix: "")
    } ()
}