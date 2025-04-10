
class Garage: Node {
    var name: String = ""

    func _mproxy_set_name(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "name", name) {
            name = $0
        }
    }

    func _mproxy_get_name(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(name)
    }
    var rating: Float = 0.0

    func _mproxy_set_rating(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "rating", rating) {
            rating = $0
        }
    }

    func _mproxy_get_rating(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(rating)
    }
    var reviews: VariantCollection<String> = []

    func _mproxy_set_reviews(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "reviews", reviews) {
            reviews = $0
        }
    }

    func _mproxy_get_reviews(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(reviews)
    }
    var checkIns: ObjectCollection<CheckIn> = []

    func _mproxy_set_checkIns(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "checkIns", checkIns) {
            checkIns = $0
        }
    }

    func _mproxy_get_checkIns(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(checkIns)
    }
    var address: String = ""

    func _mproxy_set_address(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "address", address) {
            address = $0
        }
    }

    func _mproxy_get_address(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(address)
    }
    var daysOfOperation: VariantCollection<String> = []

    func _mproxy_set_daysOfOperation(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "daysOfOperation", daysOfOperation) {
            daysOfOperation = $0
        }
    }

    func _mproxy_get_daysOfOperation(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(daysOfOperation)
    }
    var hours: VariantCollection<String> = []

    func _mproxy_set_hours(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "hours", hours) {
            hours = $0
        }
    }

    func _mproxy_get_hours(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(hours)
    }
    var insuranceProvidersAccepted: ObjectCollection<InsuranceProvider> = []

    func _mproxy_set_insuranceProvidersAccepted(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "insuranceProvidersAccepted", insuranceProvidersAccepted) {
            insuranceProvidersAccepted = $0
        }
    }

    func _mproxy_get_insuranceProvidersAccepted(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(insuranceProvidersAccepted)
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
        let _pname = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Garage.name,
            name: "name",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_name", flags: .default, returnValue: _pname, arguments: [], function: Garage._mproxy_get_name)
        classInfo.registerMethod (name: "set_name", flags: .default, returnValue: nil, arguments: [_pname], function: Garage._mproxy_set_name)
        classInfo.registerProperty (_pname, getter: "get_name", setter: "set_name")
        let _prating = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Garage.rating,
            name: "rating",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_rating", flags: .default, returnValue: _prating, arguments: [], function: Garage._mproxy_get_rating)
        classInfo.registerMethod (name: "set_rating", flags: .default, returnValue: nil, arguments: [_prating], function: Garage._mproxy_set_rating)
        classInfo.registerProperty (_prating, getter: "get_rating", setter: "set_rating")
        classInfo.addPropertyGroup(name: "More Details", prefix: "")
        let _previews = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Garage.reviews,
            name: "reviews",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_reviews", flags: .default, returnValue: _previews, arguments: [], function: Garage._mproxy_get_reviews)
        classInfo.registerMethod (name: "set_reviews", flags: .default, returnValue: nil, arguments: [_previews], function: Garage._mproxy_set_reviews)
        classInfo.registerProperty (_previews, getter: "get_reviews", setter: "set_reviews")
        let _pcheckIns = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Garage.checkIns,
            name: "check_ins",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_check_ins", flags: .default, returnValue: _pcheckIns, arguments: [], function: Garage._mproxy_get_checkIns)
        classInfo.registerMethod (name: "set_check_ins", flags: .default, returnValue: nil, arguments: [_pcheckIns], function: Garage._mproxy_set_checkIns)
        classInfo.registerProperty (_pcheckIns, getter: "get_check_ins", setter: "set_check_ins")
        let _paddress = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Garage.address,
            name: "address",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_address", flags: .default, returnValue: _paddress, arguments: [], function: Garage._mproxy_get_address)
        classInfo.registerMethod (name: "set_address", flags: .default, returnValue: nil, arguments: [_paddress], function: Garage._mproxy_set_address)
        classInfo.registerProperty (_paddress, getter: "get_address", setter: "set_address")
        classInfo.addPropertyGroup(name: "Hours and Insurance", prefix: "")
        let _pdaysOfOperation = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Garage.daysOfOperation,
            name: "days_of_operation",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_days_of_operation", flags: .default, returnValue: _pdaysOfOperation, arguments: [], function: Garage._mproxy_get_daysOfOperation)
        classInfo.registerMethod (name: "set_days_of_operation", flags: .default, returnValue: nil, arguments: [_pdaysOfOperation], function: Garage._mproxy_set_daysOfOperation)
        classInfo.registerProperty (_pdaysOfOperation, getter: "get_days_of_operation", setter: "set_days_of_operation")
        let _phours = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Garage.hours,
            name: "hours",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_hours", flags: .default, returnValue: _phours, arguments: [], function: Garage._mproxy_get_hours)
        classInfo.registerMethod (name: "set_hours", flags: .default, returnValue: nil, arguments: [_phours], function: Garage._mproxy_set_hours)
        classInfo.registerProperty (_phours, getter: "get_hours", setter: "set_hours")
        let _pinsuranceProvidersAccepted = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \Garage.insuranceProvidersAccepted,
            name: "insurance_providers_accepted",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_insurance_providers_accepted", flags: .default, returnValue: _pinsuranceProvidersAccepted, arguments: [], function: Garage._mproxy_get_insuranceProvidersAccepted)
        classInfo.registerMethod (name: "set_insurance_providers_accepted", flags: .default, returnValue: nil, arguments: [_pinsuranceProvidersAccepted], function: Garage._mproxy_set_insuranceProvidersAccepted)
        classInfo.registerProperty (_pinsuranceProvidersAccepted, getter: "get_insurance_providers_accepted", setter: "set_insurance_providers_accepted")
    } ()
}