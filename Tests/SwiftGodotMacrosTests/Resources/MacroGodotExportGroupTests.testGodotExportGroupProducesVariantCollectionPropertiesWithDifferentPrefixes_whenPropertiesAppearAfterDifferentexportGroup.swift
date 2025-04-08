
class Car: Node {
    var vins: VariantCollection<String> = [""]

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
              gArray.isSameTyped(array: GArray(String.self)) else {
            return nil
        }
        vins.array = gArray
        return nil
    }
    var years: VariantCollection<Int> = [1997]

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
              gArray.isSameTyped(array: GArray(Int.self)) else {
            return nil
        }
        years.array = gArray
        return nil
    }
    var makes: VariantCollection<String> = ["HONDA"]

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
              gArray.isSameTyped(array: GArray(String.self)) else {
            return nil
        }
        makes.array = gArray
        return nil
    }
    var models: VariantCollection<String> = ["ACCORD"]

    func _mproxy_get_models(args: borrowing Arguments) -> Variant? {
        return Variant(models.array)
    }

    func _mproxy_set_models(args: borrowing Arguments) -> Variant? {
        guard let arg = args.first else {
            GD.printErr("Unable to set `models`, no arguments")
            return nil
        }

        guard let variant = arg else {
            GD.printErr("Unable to set `models`, argument is `nil`")
            return nil
        }
        guard let gArray = GArray(variant),
              gArray.isTyped(),
              gArray.isSameTyped(array: GArray(String.self)) else {
            return nil
        }
        models.array = gArray
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
        classInfo.addPropertyGroup(name: "VIN", prefix: "")
        let _pvins = PropInfo (
            propertyType: .array,
            propertyName: "vins",
            className: StringName("Array[String]"),
            hint: .arrayType,
            hintStr: "String",
            usage: .default)
        classInfo.registerMethod (name: "get_vins", flags: .default, returnValue: _pvins, arguments: [], function: Car._mproxy_get_vins)
        classInfo.registerMethod (name: "set_vins", flags: .default, returnValue: nil, arguments: [_pvins], function: Car._mproxy_set_vins)
        classInfo.registerProperty (_pvins, getter: "get_vins", setter: "set_vins")
        classInfo.addPropertyGroup(name: "YMM", prefix: "")
        let _pyears = PropInfo (
            propertyType: .array,
            propertyName: "years",
            className: StringName("Array[int]"),
            hint: .arrayType,
            hintStr: "int",
            usage: .default)
        classInfo.registerMethod (name: "get_years", flags: .default, returnValue: _pyears, arguments: [], function: Car._mproxy_get_years)
        classInfo.registerMethod (name: "set_years", flags: .default, returnValue: nil, arguments: [_pyears], function: Car._mproxy_set_years)
        classInfo.registerProperty (_pyears, getter: "get_years", setter: "set_years")
        let _pmakes = PropInfo (
            propertyType: .array,
            propertyName: "makes",
            className: StringName("Array[String]"),
            hint: .arrayType,
            hintStr: "String",
            usage: .default)
        classInfo.registerMethod (name: "get_makes", flags: .default, returnValue: _pmakes, arguments: [], function: Car._mproxy_get_makes)
        classInfo.registerMethod (name: "set_makes", flags: .default, returnValue: nil, arguments: [_pmakes], function: Car._mproxy_set_makes)
        classInfo.registerProperty (_pmakes, getter: "get_makes", setter: "set_makes")
        let _pmodels = PropInfo (
            propertyType: .array,
            propertyName: "models",
            className: StringName("Array[String]"),
            hint: .arrayType,
            hintStr: "String",
            usage: .default)
        classInfo.registerMethod (name: "get_models", flags: .default, returnValue: _pmodels, arguments: [], function: Car._mproxy_get_models)
        classInfo.registerMethod (name: "set_models", flags: .default, returnValue: nil, arguments: [_pmodels], function: Car._mproxy_set_models)
        classInfo.registerProperty (_pmodels, getter: "get_models", setter: "set_models")
    } ()
    
}