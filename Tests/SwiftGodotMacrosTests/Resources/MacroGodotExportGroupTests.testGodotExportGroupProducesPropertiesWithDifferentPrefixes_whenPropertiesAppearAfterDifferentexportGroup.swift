
class Car: Node {
    var vin: String = ""

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
    var make: String = "HONDA"

    func _mproxy_set_make(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "make", make) {
            make = $0
        }
    }

    func _mproxy_get_make(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(make)
    }
    var model: String = "ACCORD"

    func _mproxy_set_model(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "model", model) {
            model = $0
        }
    }

    func _mproxy_get_model(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(model)
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
        let _pvin = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Car.vin,
            name: "vin",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_vin", flags: .default, returnValue: _pvin, arguments: [], function: Car._mproxy_get_vin)
        classInfo.registerMethod (name: "set_vin", flags: .default, returnValue: nil, arguments: [_pvin], function: Car._mproxy_set_vin)
        classInfo.registerProperty (_pvin, getter: "get_vin", setter: "set_vin")
        classInfo.addPropertyGroup(name: "YMM", prefix: "")
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
        let _pmake = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Car.make,
            name: "make",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_make", flags: .default, returnValue: _pmake, arguments: [], function: Car._mproxy_get_make)
        classInfo.registerMethod (name: "set_make", flags: .default, returnValue: nil, arguments: [_pmake], function: Car._mproxy_set_make)
        classInfo.registerProperty (_pmake, getter: "get_make", setter: "set_make")
        let _pmodel = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Car.model,
            name: "model",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_model", flags: .default, returnValue: _pmodel, arguments: [], function: Car._mproxy_get_model)
        classInfo.registerMethod (name: "set_model", flags: .default, returnValue: nil, arguments: [_pmodel], function: Car._mproxy_set_model)
        classInfo.registerProperty (_pmodel, getter: "get_model", setter: "set_model")
    } ()
    
}