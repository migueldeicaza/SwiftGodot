class Car: Node {
    var vin: String = ""

    func _mproxy_set_vin(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "vin", vin) {
            vin = $0
        }
    }

    func _mproxy_get_vin(args: borrowing Arguments) -> Variant? {
        _macroExportGet(vin)
    }
    var ymms_year: Int = 1998

    func _mproxy_set_ymms_year(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "ymms_year", ymms_year) {
            ymms_year = $0
        }
    }

    func _mproxy_get_ymms_year(args: borrowing Arguments) -> Variant? {
        _macroExportGet(ymms_year)
    }
    var ymms_make: String = "Honda"

    func _mproxy_set_ymms_make(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "ymms_make", ymms_make) {
            ymms_make = $0
        }
    }

    func _mproxy_get_ymms_make(args: borrowing Arguments) -> Variant? {
        _macroExportGet(ymms_make)
    }
    var ymms_model: String = "Odyssey"

    func _mproxy_set_ymms_model(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "ymms_model", ymms_model) {
            ymms_model = $0
        }
    }

    func _mproxy_get_ymms_model(args: borrowing Arguments) -> Variant? {
        _macroExportGet(ymms_model)
    }
    var ymms_series: String = "LX"

    func _mproxy_set_ymms_series(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "ymms_series", ymms_series) {
            ymms_series = $0
        }
    }

    func _mproxy_get_ymms_series(args: borrowing Arguments) -> Variant? {
        _macroExportGet(ymms_series)
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
        let _pvin = PropInfo (
            propertyType: .string,
            propertyName: "vin",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_vin", flags: .default, returnValue: _pvin, arguments: [], function: Car._mproxy_get_vin)
        classInfo.registerMethod (name: "_mproxy_set_vin", flags: .default, returnValue: nil, arguments: [_pvin], function: Car._mproxy_set_vin)
        classInfo.registerProperty (_pvin, getter: "_mproxy_get_vin", setter: "_mproxy_set_vin")
        classInfo.addPropertySubgroup(name: "YMMS", prefix: "ymms_")
        let _pymms_year = PropInfo (
            propertyType: .int,
            propertyName: "ymms_year",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_year", flags: .default, returnValue: _pymms_year, arguments: [], function: Car._mproxy_get_ymms_year)
        classInfo.registerMethod (name: "_mproxy_set_year", flags: .default, returnValue: nil, arguments: [_pymms_year], function: Car._mproxy_set_ymms_year)
        classInfo.registerProperty (_pymms_year, getter: "_mproxy_get_year", setter: "_mproxy_set_year")
        let _pymms_make = PropInfo (
            propertyType: .string,
            propertyName: "ymms_make",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_make", flags: .default, returnValue: _pymms_make, arguments: [], function: Car._mproxy_get_ymms_make)
        classInfo.registerMethod (name: "_mproxy_set_make", flags: .default, returnValue: nil, arguments: [_pymms_make], function: Car._mproxy_set_ymms_make)
        classInfo.registerProperty (_pymms_make, getter: "_mproxy_get_make", setter: "_mproxy_set_make")
        let _pymms_model = PropInfo (
            propertyType: .string,
            propertyName: "ymms_model",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_model", flags: .default, returnValue: _pymms_model, arguments: [], function: Car._mproxy_get_ymms_model)
        classInfo.registerMethod (name: "_mproxy_set_model", flags: .default, returnValue: nil, arguments: [_pymms_model], function: Car._mproxy_set_ymms_model)
        classInfo.registerProperty (_pymms_model, getter: "_mproxy_get_model", setter: "_mproxy_set_model")
        let _pymms_series = PropInfo (
            propertyType: .string,
            propertyName: "ymms_series",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_series", flags: .default, returnValue: _pymms_series, arguments: [], function: Car._mproxy_get_ymms_series)
        classInfo.registerMethod (name: "_mproxy_set_series", flags: .default, returnValue: nil, arguments: [_pymms_series], function: Car._mproxy_set_ymms_series)
        classInfo.registerProperty (_pymms_series, getter: "_mproxy_get_series", setter: "_mproxy_set_series")
    } ()
}