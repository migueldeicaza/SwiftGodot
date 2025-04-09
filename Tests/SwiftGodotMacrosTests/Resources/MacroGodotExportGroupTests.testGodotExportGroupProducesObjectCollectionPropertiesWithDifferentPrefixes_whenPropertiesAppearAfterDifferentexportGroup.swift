
class Car: Node {
    var vins: ObjectCollection<Node> = []

    func _mproxy_set_vins(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "vins", vins) {
            vins = $0
        }
    }

    func _mproxy_get_vins(args: borrowing Arguments) -> Variant? {
        _macroExportGet(vins)
    }
    var years: ObjectCollection<Node> = []

    func _mproxy_set_years(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "years", years) {
            years = $0
        }
    }

    func _mproxy_get_years(args: borrowing Arguments) -> Variant? {
        _macroExportGet(years)
    }
    var makes: ObjectCollection<Node> = []

    func _mproxy_set_makes(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "makes", makes) {
            makes = $0
        }
    }

    func _mproxy_get_makes(args: borrowing Arguments) -> Variant? {
        _macroExportGet(makes)
    }
    var models: ObjectCollection<Node> = []

    func _mproxy_set_models(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "models", models) {
            models = $0
        }
    }

    func _mproxy_get_models(args: borrowing Arguments) -> Variant? {
        _macroExportGet(models)
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
        let _pvins = PropInfo (
            propertyType: .array,
            propertyName: "vins",
            className: StringName("Array[Node]"),
            hint: .arrayType,
            hintStr: "Node",
            usage: .default)
        classInfo.registerMethod (name: "get_vins", flags: .default, returnValue: _pvins, arguments: [], function: Car._mproxy_get_vins)
        classInfo.registerMethod (name: "set_vins", flags: .default, returnValue: nil, arguments: [_pvins], function: Car._mproxy_set_vins)
        classInfo.registerProperty (_pvins, getter: "get_vins", setter: "set_vins")
        classInfo.addPropertyGroup(name: "YMM", prefix: "")
        let _pyears = PropInfo (
            propertyType: .array,
            propertyName: "years",
            className: StringName("Array[Node]"),
            hint: .arrayType,
            hintStr: "Node",
            usage: .default)
        classInfo.registerMethod (name: "get_years", flags: .default, returnValue: _pyears, arguments: [], function: Car._mproxy_get_years)
        classInfo.registerMethod (name: "set_years", flags: .default, returnValue: nil, arguments: [_pyears], function: Car._mproxy_set_years)
        classInfo.registerProperty (_pyears, getter: "get_years", setter: "set_years")
        let _pmakes = PropInfo (
            propertyType: .array,
            propertyName: "makes",
            className: StringName("Array[Node]"),
            hint: .arrayType,
            hintStr: "Node",
            usage: .default)
        classInfo.registerMethod (name: "get_makes", flags: .default, returnValue: _pmakes, arguments: [], function: Car._mproxy_get_makes)
        classInfo.registerMethod (name: "set_makes", flags: .default, returnValue: nil, arguments: [_pmakes], function: Car._mproxy_set_makes)
        classInfo.registerProperty (_pmakes, getter: "get_makes", setter: "set_makes")
        let _pmodels = PropInfo (
            propertyType: .array,
            propertyName: "models",
            className: StringName("Array[Node]"),
            hint: .arrayType,
            hintStr: "Node",
            usage: .default)
        classInfo.registerMethod (name: "get_models", flags: .default, returnValue: _pmodels, arguments: [], function: Car._mproxy_get_models)
        classInfo.registerMethod (name: "set_models", flags: .default, returnValue: nil, arguments: [_pmodels], function: Car._mproxy_set_models)
        classInfo.registerProperty (_pmodels, getter: "get_models", setter: "set_models")
    } ()
    
}