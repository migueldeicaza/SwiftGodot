
class Car: Node {
    var vin: String = "00000000000000000"

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

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Car")
        assert(ClassDB.classExists(class: className))
        let _pvin = PropInfo (
            propertyType: .string,
            propertyName: "vin",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        let classInfo = ClassInfo<Car> (name: className)
        classInfo.registerMethod (name: "_mproxy_get_vin", flags: .default, returnValue: _pvin, arguments: [], function: Car._mproxy_get_vin)
        classInfo.registerMethod (name: "_mproxy_set_vin", flags: .default, returnValue: nil, arguments: [_pvin], function: Car._mproxy_set_vin)
        classInfo.registerProperty (_pvin, getter: "_mproxy_get_vin", setter: "_mproxy_set_vin")
        classInfo.addPropertyGroup(name: "YMMS", prefix: "")
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
    } ()
}