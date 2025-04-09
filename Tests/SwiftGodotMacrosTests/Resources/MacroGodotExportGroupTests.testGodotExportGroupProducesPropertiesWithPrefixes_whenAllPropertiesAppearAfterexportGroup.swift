
class Car: Node {
    var make: String = "Mazda"

    func _mproxy_set_make(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "make", make) {
            make = $0
        }
    }

    func _mproxy_get_make(args: borrowing Arguments) -> Variant? {
        _macroExportGet(make)
    }
    var model: String = "RX7"

    func _mproxy_set_model(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "model", model) {
            model = $0
        }
    }

    func _mproxy_get_model(args: borrowing Arguments) -> Variant? {
        _macroExportGet(model)
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