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
    var ymms_year: Int = 1998

    func _mproxy_set_ymms_year(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "ymms_year", ymms_year) {
            ymms_year = $0
        }
    }

    func _mproxy_get_ymms_year(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(ymms_year)
    }
    var ymms_make: String = "Honda"

    func _mproxy_set_ymms_make(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "ymms_make", ymms_make) {
            ymms_make = $0
        }
    }

    func _mproxy_get_ymms_make(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(ymms_make)
    }
    var ymms_model: String = "Odyssey"

    func _mproxy_set_ymms_model(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "ymms_model", ymms_model) {
            ymms_model = $0
        }
    }

    func _mproxy_get_ymms_model(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(ymms_model)
    }
    var ymms_series: String = "LX"

    func _mproxy_set_ymms_series(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "ymms_series", ymms_series) {
            ymms_series = $0
        }
    }

    func _mproxy_get_ymms_series(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(ymms_series)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Car")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Car> (name: className)
        classInfo.addPropertyGroup(name: "Vehicle", prefix: "")
        classInfo.addPropertySubgroup(name: "VIN", prefix: "")
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
        classInfo.addPropertySubgroup(name: "YMMS", prefix: "ymms_")
        let _pymms_year = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Car.ymms_year,
            name: "ymms_year",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_year", flags: .default, returnValue: _pymms_year, arguments: [], function: Car._mproxy_get_ymms_year)
        classInfo.registerMethod (name: "set_year", flags: .default, returnValue: nil, arguments: [_pymms_year], function: Car._mproxy_set_ymms_year)
        classInfo.registerProperty (_pymms_year, getter: "get_year", setter: "set_year")
        let _pymms_make = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Car.ymms_make,
            name: "ymms_make",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_make", flags: .default, returnValue: _pymms_make, arguments: [], function: Car._mproxy_get_ymms_make)
        classInfo.registerMethod (name: "set_make", flags: .default, returnValue: nil, arguments: [_pymms_make], function: Car._mproxy_set_ymms_make)
        classInfo.registerProperty (_pymms_make, getter: "get_make", setter: "set_make")
        let _pymms_model = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Car.ymms_model,
            name: "ymms_model",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_model", flags: .default, returnValue: _pymms_model, arguments: [], function: Car._mproxy_get_ymms_model)
        classInfo.registerMethod (name: "set_model", flags: .default, returnValue: nil, arguments: [_pymms_model], function: Car._mproxy_set_ymms_model)
        classInfo.registerProperty (_pymms_model, getter: "get_model", setter: "set_model")
        let _pymms_series = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Car.ymms_series,
            name: "ymms_series",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_series", flags: .default, returnValue: _pymms_series, arguments: [], function: Car._mproxy_get_ymms_series)
        classInfo.registerMethod (name: "set_series", flags: .default, returnValue: nil, arguments: [_pymms_series], function: Car._mproxy_set_ymms_series)
        classInfo.registerProperty (_pymms_series, getter: "get_series", setter: "set_series")
    } ()
}