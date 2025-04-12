
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
    var year: Int = 1997

    func _mproxy_set_year(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "year", year) {
            year = $0
        }
    }

    func _mproxy_get_year(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(year)
    }
    var make: String = "HONDA"

    func _mproxy_set_make(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "make", make) {
            make = $0
        }
    }

    func _mproxy_get_make(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(make)
    }
    var model: String = "ACCORD"

    func _mproxy_set_model(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "model", model) {
            model = $0
        }
    }

    func _mproxy_get_model(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(model)
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
        classInfo.addPropertyGroup(name: "YMM", prefix: "")
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \Car.year,
                name: "year",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_year",
            setterName: "set_year",
            getterFunction: Car._mproxy_get_year,
            setterFunction: Car._mproxy_set_year
        )
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \Car.make,
                name: "make",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_make",
            setterName: "set_make",
            getterFunction: Car._mproxy_get_make,
            setterFunction: Car._mproxy_set_make
        )
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \Car.model,
                name: "model",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_model",
            setterName: "set_model",
            getterFunction: Car._mproxy_get_model,
            setterFunction: Car._mproxy_set_model
        )
    } ()
    
}
