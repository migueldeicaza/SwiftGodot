
class Car: Node {
    var vehicle_make: String = "Mazda"

    func _mproxy_set_vehicle_make(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "vehicle_make", vehicle_make) {
            vehicle_make = $0
        }
    }

    func _mproxy_get_vehicle_make(args: borrowing Arguments) -> Variant? {
        _macroExportGet(vehicle_make)
    }
    var vehicle_model: String = "RX7"

    func _mproxy_set_vehicle_model(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "vehicle_model", vehicle_model) {
            vehicle_model = $0
        }
    }

    func _mproxy_get_vehicle_model(args: borrowing Arguments) -> Variant? {
        _macroExportGet(vehicle_model)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Car")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Car> (name: className)
        classInfo.addPropertyGroup(name: "Vehicle", prefix: "vehicle_")
        let _pvehicle_make = PropInfo (
            propertyType: .string,
            propertyName: "vehicle_make",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_make", flags: .default, returnValue: _pvehicle_make, arguments: [], function: Car._mproxy_get_vehicle_make)
        classInfo.registerMethod (name: "_mproxy_set_make", flags: .default, returnValue: nil, arguments: [_pvehicle_make], function: Car._mproxy_set_vehicle_make)
        classInfo.registerProperty (_pvehicle_make, getter: "_mproxy_get_make", setter: "_mproxy_set_make")
        let _pvehicle_model = PropInfo (
            propertyType: .string,
            propertyName: "vehicle_model",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_model", flags: .default, returnValue: _pvehicle_model, arguments: [], function: Car._mproxy_get_vehicle_model)
        classInfo.registerMethod (name: "_mproxy_set_model", flags: .default, returnValue: nil, arguments: [_pvehicle_model], function: Car._mproxy_set_vehicle_model)
        classInfo.registerProperty (_pvehicle_model, getter: "_mproxy_get_model", setter: "_mproxy_set_model")
    } ()
}