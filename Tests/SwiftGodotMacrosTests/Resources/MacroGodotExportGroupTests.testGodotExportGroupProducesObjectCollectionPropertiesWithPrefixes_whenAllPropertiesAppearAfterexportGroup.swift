
class Car: Node {
    var makes: ObjectCollection<Node> = []

    static func _mproxy_set_makes(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for makes: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "makes", object.makes) {
            object.makes = $0
        }
        return nil
    }

    static func _mproxy_get_makes(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for makes: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.makes)
    }
    var model: ObjectCollection<Node> = []

    static func _mproxy_set_model(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for model: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "model", object.model) {
            object.model = $0
        }
        return nil
    }

    static func _mproxy_get_model(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for model: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.model)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Car")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Car> (name: className)
        SwiftGodot._addPropertyGroup(className: className, name: "Vehicle", prefix: "")
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
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
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
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