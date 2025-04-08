
class Car: Node {
    var makes: ObjectCollection<Node> = []

    func _mproxy_get_makes(args: borrowing Arguments) -> Variant? {
        return Variant(makes.array)
    }

    func _mproxy_set_makes(args: borrowing Arguments) -> Variant? {
        guard let arg = args.first else {
            GD.printErr("Unable to set `makes`, no arguments")
            return nil
        }

        guard let variant = arg else {
            GD.printErr("Unable to set `makes`, argument is `nil`")
            return nil
        }
        guard let gArray = GArray(variant),
              gArray.isTyped(),
              gArray.isSameTyped(array: GArray(Node.self)) else {
            return nil
        }
        makes.array = gArray
        return nil
    }
    var model: ObjectCollection<Node> = []

    func _mproxy_get_model(args: borrowing Arguments) -> Variant? {
        return Variant(model.array)
    }

    func _mproxy_set_model(args: borrowing Arguments) -> Variant? {
        guard let arg = args.first else {
            GD.printErr("Unable to set `model`, no arguments")
            return nil
        }

        guard let variant = arg else {
            GD.printErr("Unable to set `model`, argument is `nil`")
            return nil
        }
        guard let gArray = GArray(variant),
              gArray.isTyped(),
              gArray.isSameTyped(array: GArray(Node.self)) else {
            return nil
        }
        model.array = gArray
        return nil
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
        let _pmodel = PropInfo (
            propertyType: .array,
            propertyName: "model",
            className: StringName("Array[Node]"),
            hint: .arrayType,
            hintStr: "Node",
            usage: .default)
        classInfo.registerMethod (name: "get_model", flags: .default, returnValue: _pmodel, arguments: [], function: Car._mproxy_get_model)
        classInfo.registerMethod (name: "set_model", flags: .default, returnValue: nil, arguments: [_pmodel], function: Car._mproxy_set_model)
        classInfo.registerProperty (_pmodel, getter: "get_model", setter: "set_model")
    } ()
}