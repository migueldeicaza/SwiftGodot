
class Car: Node {
    var vin: String = ""

    func _mproxy_set_vin(args: borrowing Arguments) -> Variant? {
        _macroEnsureVariantConvertible(String.self)
        String._macroExportSetter(args, "vin", property: &vin)
        return nil
    }

    func _mproxy_get_vin (args: borrowing Arguments) -> Variant? {
        _macroEnsureVariantConvertible(String.self)
        return vin.toVariant()
    }
    var year: Int = 1997

    func _mproxy_set_year(args: borrowing Arguments) -> Variant? {
        _macroEnsureVariantConvertible(Int.self)
        Int._macroExportSetter(args, "year", property: &year)
        return nil
    }

    func _mproxy_get_year (args: borrowing Arguments) -> Variant? {
        _macroEnsureVariantConvertible(Int.self)
        return year.toVariant()
    }
    var make: String = "HONDA"

    func _mproxy_set_make(args: borrowing Arguments) -> Variant? {
        _macroEnsureVariantConvertible(String.self)
        String._macroExportSetter(args, "make", property: &make)
        return nil
    }

    func _mproxy_get_make (args: borrowing Arguments) -> Variant? {
        _macroEnsureVariantConvertible(String.self)
        return make.toVariant()
    }
    var model: String = "ACCORD"

    func _mproxy_set_model(args: borrowing Arguments) -> Variant? {
        _macroEnsureVariantConvertible(String.self)
        String._macroExportSetter(args, "model", property: &model)
        return nil
    }

    func _mproxy_get_model (args: borrowing Arguments) -> Variant? {
        _macroEnsureVariantConvertible(String.self)
        return model.toVariant()
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
        classInfo.addPropertyGroup(name: "YMM", prefix: "")
        let _pyear = PropInfo (
            propertyType: .int,
            propertyName: "year",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_year", flags: .default, returnValue: _pyear, arguments: [], function: Car._mproxy_get_year)
        classInfo.registerMethod (name: "_mproxy_set_year", flags: .default, returnValue: nil, arguments: [_pyear], function: Car._mproxy_set_year)
        classInfo.registerProperty (_pyear, getter: "_mproxy_get_year", setter: "_mproxy_set_year")
        let _pmake = PropInfo (
            propertyType: .string,
            propertyName: "make",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_make", flags: .default, returnValue: _pmake, arguments: [], function: Car._mproxy_get_make)
        classInfo.registerMethod (name: "_mproxy_set_make", flags: .default, returnValue: nil, arguments: [_pmake], function: Car._mproxy_set_make)
        classInfo.registerProperty (_pmake, getter: "_mproxy_get_make", setter: "_mproxy_set_make")
        let _pmodel = PropInfo (
            propertyType: .string,
            propertyName: "model",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_model", flags: .default, returnValue: _pmodel, arguments: [], function: Car._mproxy_get_model)
        classInfo.registerMethod (name: "_mproxy_set_model", flags: .default, returnValue: nil, arguments: [_pmodel], function: Car._mproxy_set_model)
        classInfo.registerProperty (_pmodel, getter: "_mproxy_get_model", setter: "_mproxy_set_model")
    } ()
    
}