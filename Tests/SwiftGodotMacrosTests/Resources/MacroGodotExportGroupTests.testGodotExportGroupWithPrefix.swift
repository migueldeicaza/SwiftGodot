
class Car: Node {
    var vehicle_make: String = "Mazda"

    func _mproxy_set_vehicle_make(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "vehicle_make", vehicle_make) {
            vehicle_make = $0
        }
    }

    func _mproxy_get_vehicle_make(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(vehicle_make)
    }
    var vehicle_model: String = "RX7"

    func _mproxy_set_vehicle_model(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "vehicle_model", vehicle_model) {
            vehicle_model = $0
        }
    }

    func _mproxy_get_vehicle_model(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(vehicle_model)
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
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \Car.vehicle_make,
                name: "vehicle_make",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_make",
            setterName: "set_make",
            getterFunction: Car._mproxy_get_vehicle_make,
            setterFunction: Car._mproxy_set_vehicle_make
        )
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \Car.vehicle_model,
                name: "vehicle_model",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_model",
            setterName: "set_model",
            getterFunction: Car._mproxy_get_vehicle_model,
            setterFunction: Car._mproxy_set_vehicle_model
        )
    } ()
}
