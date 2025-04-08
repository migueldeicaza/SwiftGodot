
class Car: Node {
    var vins: ObjectCollection<Node> = []

    func _mproxy_get_vins(args: borrowing Arguments) -> Variant? {
        return Variant(vins.array)
    }

    func _mproxy_set_vins(args: borrowing Arguments) -> Variant? {
        guard let arg = args.first else {
            GD.printErr("Unable to set `vins`, no arguments")
            return nil
        }

        guard let variant = arg else {
            GD.printErr("Unable to set `vins`, argument is `nil`")
            return nil
        }
        guard let gArray = GArray(variant),
              gArray.isTyped(),
              gArray.isSameTyped(array: GArray(Node.self)) else {
            return nil
        }
        vins.array = gArray
        return nil
    }
    var years: ObjectCollection<Node> = []

    func _mproxy_get_years(args: borrowing Arguments) -> Variant? {
        return Variant(years.array)
    }

    func _mproxy_set_years(args: borrowing Arguments) -> Variant? {
        guard let arg = args.first else {
            GD.printErr("Unable to set `years`, no arguments")
            return nil
        }

        guard let variant = arg else {
            GD.printErr("Unable to set `years`, argument is `nil`")
            return nil
        }
        guard let gArray = GArray(variant),
              gArray.isTyped(),
              gArray.isSameTyped(array: GArray(Node.self)) else {
            return nil
        }
        years.array = gArray
        return nil
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
            className: StringName("Array[Node]"),
            hint: .arrayType,
            hintStr: "Node",
            usage: .default)
        let classInfo = ClassInfo<Car> (name: className)
        classInfo.registerMethod (name: "get_vins", flags: .default, returnValue: _pvins, arguments: [], function: Car._mproxy_get_vins)
        classInfo.registerMethod (name: "set_vins", flags: .default, returnValue: nil, arguments: [_pvins], function: Car._mproxy_set_vins)
        classInfo.registerProperty (_pvins, getter: "get_vins", setter: "set_vins")
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
        classInfo.addPropertyGroup(name: "Pointless", prefix: "")
    } ()
}