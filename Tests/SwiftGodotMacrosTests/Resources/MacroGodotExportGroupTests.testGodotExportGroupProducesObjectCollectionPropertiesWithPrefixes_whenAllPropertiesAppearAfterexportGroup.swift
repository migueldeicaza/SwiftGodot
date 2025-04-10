
class Car: Node {
    var makes: ObjectCollection<Node> = []

    func _mproxy_set_makes(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "makes", makes) {
            makes = $0
        }
    }

    func _mproxy_get_makes(args: borrowing Arguments) -> Variant? {
        _macroExportGet(makes)
    }
    var model: ObjectCollection<Node> = []

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