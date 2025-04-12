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
        classInfo.addPropertySubgroup(name: "YMMS", prefix: "ymms_")
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
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
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
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
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
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
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
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
    } ()
}
