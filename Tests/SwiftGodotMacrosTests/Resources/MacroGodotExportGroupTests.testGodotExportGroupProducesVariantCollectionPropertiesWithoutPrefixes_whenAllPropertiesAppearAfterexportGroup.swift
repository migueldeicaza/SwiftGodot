
class Car: Node {
    var vins: VariantCollection<String> = ["00000000000000000"]

    func _mproxy_set_vins(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "vins", vins) {
            vins = $0
        }
    }

    func _mproxy_get_vins(args: borrowing Arguments) -> Variant? {
        _macroExportGet(vins)
    }
    var years: VariantCollection<Int> = [1997]

    func _mproxy_set_years(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "years", years) {
            years = $0
        }
    }

    func _mproxy_get_years(args: borrowing Arguments) -> Variant? {
        _macroExportGet(years)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Car")
        assert(ClassDB.classExists(class: className))
        let _pvins = PropInfo (
            propertyType: .array,
            propertyName: "vins",
            className: StringName("Array[String]"),
            hint: .arrayType,
            hintStr: "String",
            usage: .default)
        let classInfo = ClassInfo<Car> (name: className)
        classInfo.registerMethod (name: "get_vins", flags: .default, returnValue: _pvins, arguments: [], function: Car._mproxy_get_vins)
        classInfo.registerMethod (name: "set_vins", flags: .default, returnValue: nil, arguments: [_pvins], function: Car._mproxy_set_vins)
        classInfo.registerProperty (_pvins, getter: "get_vins", setter: "set_vins")
        let _pyears = PropInfo (
            propertyType: .array,
            propertyName: "years",
            className: StringName("Array[int]"),
            hint: .arrayType,
            hintStr: "int",
            usage: .default)
        classInfo.registerMethod (name: "get_years", flags: .default, returnValue: _pyears, arguments: [], function: Car._mproxy_get_years)
        classInfo.registerMethod (name: "set_years", flags: .default, returnValue: nil, arguments: [_pyears], function: Car._mproxy_set_years)
        classInfo.registerProperty (_pyears, getter: "get_years", setter: "set_years")
        classInfo.addPropertyGroup(name: "Pointless", prefix: "")
    } ()
}