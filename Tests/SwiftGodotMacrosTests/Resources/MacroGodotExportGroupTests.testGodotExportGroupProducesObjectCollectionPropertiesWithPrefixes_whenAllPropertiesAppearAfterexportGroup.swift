
class Car: Node {
    var makes: ObjectCollection<Node> = []

    func _mproxy_set_makes(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "makes", makes) {
            makes = $0
        }
    }

    func _mproxy_get_makes(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(makes)
    }
    var model: ObjectCollection<Node> = []

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
        classInfo.addPropertyGroup(name: "Vehicle", prefix: "")
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \Car.makes,
                name: "makes",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_makes",
            setterName: "set_makes",
            getterFunction: Car._mproxy_get_makes,
            setterFunction: Car._mproxy_set_makes
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
