
class Garage: Node {
    var name: String = ""

    func _mproxy_set_name(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "name", &name)
        return nil
    }

    func _mproxy_get_name (args: borrowing Arguments) -> Variant? {
        _macroExportGet(name)
    }
    var rating: Float = 0.0

    func _mproxy_set_rating(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "rating", &rating)
        return nil
    }

    func _mproxy_get_rating (args: borrowing Arguments) -> Variant? {
        _macroExportGet(rating)
    }
    var reviews: VariantCollection<String> = []

    func _mproxy_get_reviews(args: borrowing Arguments) -> Variant? {
        return Variant(reviews.array)
    }

    func _mproxy_set_reviews(args: borrowing Arguments) -> Variant? {
        guard let arg = args.first else {
            GD.printErr("Unable to set `reviews`, no arguments")
            return nil
        }

        guard let variant = arg else {
            GD.printErr("Unable to set `reviews`, argument is `nil`")
            return nil
        }
        guard let gArray = GArray(variant),
              gArray.isTyped(),
              gArray.isSameTyped(array: GArray(String.self)) else {
            return nil
        }
        reviews.array = gArray
        return nil
    }
    var checkIns: ObjectCollection<CheckIn> = []

    func _mproxy_get_checkIns(args: borrowing Arguments) -> Variant? {
        return Variant(checkIns.array)
    }

    func _mproxy_set_checkIns(args: borrowing Arguments) -> Variant? {
        guard let arg = args.first else {
            GD.printErr("Unable to set `checkIns`, no arguments")
            return nil
        }

        guard let variant = arg else {
            GD.printErr("Unable to set `checkIns`, argument is `nil`")
            return nil
        }
        guard let gArray = GArray(variant),
              gArray.isTyped(),
              gArray.isSameTyped(array: GArray(CheckIn.self)) else {
            return nil
        }
        checkIns.array = gArray
        return nil
    }
    var address: String = ""

    func _mproxy_set_address(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "address", &address)
        return nil
    }

    func _mproxy_get_address (args: borrowing Arguments) -> Variant? {
        _macroExportGet(address)
    }
    var daysOfOperation: VariantCollection<String> = []

    func _mproxy_get_daysOfOperation(args: borrowing Arguments) -> Variant? {
        return Variant(daysOfOperation.array)
    }

    func _mproxy_set_daysOfOperation(args: borrowing Arguments) -> Variant? {
        guard let arg = args.first else {
            GD.printErr("Unable to set `daysOfOperation`, no arguments")
            return nil
        }

        guard let variant = arg else {
            GD.printErr("Unable to set `daysOfOperation`, argument is `nil`")
            return nil
        }
        guard let gArray = GArray(variant),
              gArray.isTyped(),
              gArray.isSameTyped(array: GArray(String.self)) else {
            return nil
        }
        daysOfOperation.array = gArray
        return nil
    }
    var hours: VariantCollection<String> = []

    func _mproxy_get_hours(args: borrowing Arguments) -> Variant? {
        return Variant(hours.array)
    }

    func _mproxy_set_hours(args: borrowing Arguments) -> Variant? {
        guard let arg = args.first else {
            GD.printErr("Unable to set `hours`, no arguments")
            return nil
        }

        guard let variant = arg else {
            GD.printErr("Unable to set `hours`, argument is `nil`")
            return nil
        }
        guard let gArray = GArray(variant),
              gArray.isTyped(),
              gArray.isSameTyped(array: GArray(String.self)) else {
            return nil
        }
        hours.array = gArray
        return nil
    }
    var insuranceProvidersAccepted: ObjectCollection<InsuranceProvider> = []

    func _mproxy_get_insuranceProvidersAccepted(args: borrowing Arguments) -> Variant? {
        return Variant(insuranceProvidersAccepted.array)
    }

    func _mproxy_set_insuranceProvidersAccepted(args: borrowing Arguments) -> Variant? {
        guard let arg = args.first else {
            GD.printErr("Unable to set `insuranceProvidersAccepted`, no arguments")
            return nil
        }

        guard let variant = arg else {
            GD.printErr("Unable to set `insuranceProvidersAccepted`, argument is `nil`")
            return nil
        }
        guard let gArray = GArray(variant),
              gArray.isTyped(),
              gArray.isSameTyped(array: GArray(InsuranceProvider.self)) else {
            return nil
        }
        insuranceProvidersAccepted.array = gArray
        return nil
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Garage")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Garage> (name: className)
        classInfo.addPropertyGroup(name: "Front Page", prefix: "")
        let _pname = PropInfo (
            propertyType: .string,
            propertyName: "name",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_name", flags: .default, returnValue: _pname, arguments: [], function: Garage._mproxy_get_name)
        classInfo.registerMethod (name: "_mproxy_set_name", flags: .default, returnValue: nil, arguments: [_pname], function: Garage._mproxy_set_name)
        classInfo.registerProperty (_pname, getter: "_mproxy_get_name", setter: "_mproxy_set_name")
        let _prating = PropInfo (
            propertyType: .float,
            propertyName: "rating",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_rating", flags: .default, returnValue: _prating, arguments: [], function: Garage._mproxy_get_rating)
        classInfo.registerMethod (name: "_mproxy_set_rating", flags: .default, returnValue: nil, arguments: [_prating], function: Garage._mproxy_set_rating)
        classInfo.registerProperty (_prating, getter: "_mproxy_get_rating", setter: "_mproxy_set_rating")
        classInfo.addPropertyGroup(name: "More Details", prefix: "")
        let _previews = PropInfo (
            propertyType: .array,
            propertyName: "reviews",
            className: StringName("Array[String]"),
            hint: .arrayType,
            hintStr: "String",
            usage: .default)
        classInfo.registerMethod (name: "get_reviews", flags: .default, returnValue: _previews, arguments: [], function: Garage._mproxy_get_reviews)
        classInfo.registerMethod (name: "set_reviews", flags: .default, returnValue: nil, arguments: [_previews], function: Garage._mproxy_set_reviews)
        classInfo.registerProperty (_previews, getter: "get_reviews", setter: "set_reviews")
        let _pcheckIns = PropInfo (
            propertyType: .array,
            propertyName: "check_ins",
            className: StringName("Array[CheckIn]"),
            hint: .arrayType,
            hintStr: "CheckIn",
            usage: .default)
        classInfo.registerMethod (name: "get_check_ins", flags: .default, returnValue: _pcheckIns, arguments: [], function: Garage._mproxy_get_checkIns)
        classInfo.registerMethod (name: "set_check_ins", flags: .default, returnValue: nil, arguments: [_pcheckIns], function: Garage._mproxy_set_checkIns)
        classInfo.registerProperty (_pcheckIns, getter: "get_check_ins", setter: "set_check_ins")
        let _paddress = PropInfo (
            propertyType: .string,
            propertyName: "address",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_address", flags: .default, returnValue: _paddress, arguments: [], function: Garage._mproxy_get_address)
        classInfo.registerMethod (name: "_mproxy_set_address", flags: .default, returnValue: nil, arguments: [_paddress], function: Garage._mproxy_set_address)
        classInfo.registerProperty (_paddress, getter: "_mproxy_get_address", setter: "_mproxy_set_address")
        classInfo.addPropertyGroup(name: "Hours and Insurance", prefix: "")
        let _pdaysOfOperation = PropInfo (
            propertyType: .array,
            propertyName: "days_of_operation",
            className: StringName("Array[String]"),
            hint: .arrayType,
            hintStr: "String",
            usage: .default)
        classInfo.registerMethod (name: "get_days_of_operation", flags: .default, returnValue: _pdaysOfOperation, arguments: [], function: Garage._mproxy_get_daysOfOperation)
        classInfo.registerMethod (name: "set_days_of_operation", flags: .default, returnValue: nil, arguments: [_pdaysOfOperation], function: Garage._mproxy_set_daysOfOperation)
        classInfo.registerProperty (_pdaysOfOperation, getter: "get_days_of_operation", setter: "set_days_of_operation")
        let _phours = PropInfo (
            propertyType: .array,
            propertyName: "hours",
            className: StringName("Array[String]"),
            hint: .arrayType,
            hintStr: "String",
            usage: .default)
        classInfo.registerMethod (name: "get_hours", flags: .default, returnValue: _phours, arguments: [], function: Garage._mproxy_get_hours)
        classInfo.registerMethod (name: "set_hours", flags: .default, returnValue: nil, arguments: [_phours], function: Garage._mproxy_set_hours)
        classInfo.registerProperty (_phours, getter: "get_hours", setter: "set_hours")
        let _pinsuranceProvidersAccepted = PropInfo (
            propertyType: .array,
            propertyName: "insurance_providers_accepted",
            className: StringName("Array[InsuranceProvider]"),
            hint: .arrayType,
            hintStr: "InsuranceProvider",
            usage: .default)
        classInfo.registerMethod (name: "get_insurance_providers_accepted", flags: .default, returnValue: _pinsuranceProvidersAccepted, arguments: [], function: Garage._mproxy_get_insuranceProvidersAccepted)
        classInfo.registerMethod (name: "set_insurance_providers_accepted", flags: .default, returnValue: nil, arguments: [_pinsuranceProvidersAccepted], function: Garage._mproxy_set_insuranceProvidersAccepted)
        classInfo.registerProperty (_pinsuranceProvidersAccepted, getter: "get_insurance_providers_accepted", setter: "set_insurance_providers_accepted")
    } ()
}