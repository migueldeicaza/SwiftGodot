
class Car: Node {
    var vin: String = "00000000000000000"

    func _mproxy_set_vin(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "vin", vin) {
            vin = $0
        }
    }

    func _mproxy_get_vin(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(vin)
    }
    var year: Int = 1997

    func _mproxy_set_year(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "year", year) {
            year = $0
        }
    }

    func _mproxy_get_year(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(year)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Car")
        assert(ClassDB.classExists(class: className))
        let _pvin = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Car.vin,
            name: "vin",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        let classInfo = ClassInfo<Car> (name: className)
        classInfo.registerMethod (name: "get_vin", flags: .default, returnValue: _pvin, arguments: [], function: Car._mproxy_get_vin)
        classInfo.registerMethod (name: "set_vin", flags: .default, returnValue: nil, arguments: [_pvin], function: Car._mproxy_set_vin)
        classInfo.registerProperty (_pvin, getter: "get_vin", setter: "set_vin")
        classInfo.addPropertyGroup(name: "YMMS", prefix: "")
        let _pyear = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Car.year,
            name: "year",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_year", flags: .default, returnValue: _pyear, arguments: [], function: Car._mproxy_get_year)
        classInfo.registerMethod (name: "set_year", flags: .default, returnValue: nil, arguments: [_pyear], function: Car._mproxy_set_year)
        classInfo.registerProperty (_pyear, getter: "get_year", setter: "set_year")
    } ()
}