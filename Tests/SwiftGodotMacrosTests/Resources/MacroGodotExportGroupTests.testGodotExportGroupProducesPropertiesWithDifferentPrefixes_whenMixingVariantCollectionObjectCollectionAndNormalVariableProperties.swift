
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
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetPropInfo(
                at: \Garage.name,
                name: "name",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_name",
            setterName: "set_name",
            getterFunction: Garage._mproxy_get_name,
            setterFunction: Garage._mproxy_set_name
        )
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetPropInfo(
                at: \Garage.rating,
                name: "rating",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_rating",
            setterName: "set_rating",
            getterFunction: Garage._mproxy_get_rating,
            setterFunction: Garage._mproxy_set_rating
        )
        classInfo.addPropertyGroup(name: "More Details", prefix: "")
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetPropInfo(
                at: \Garage.reviews,
                name: "reviews",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_reviews",
            setterName: "set_reviews",
            getterFunction: Garage._mproxy_get_reviews,
            setterFunction: Garage._mproxy_set_reviews
        )
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetPropInfo(
                at: \Garage.checkIns,
                name: "check_ins",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_check_ins",
            setterName: "set_check_ins",
            getterFunction: Garage._mproxy_get_checkIns,
            setterFunction: Garage._mproxy_set_checkIns
        )
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetPropInfo(
                at: \Garage.address,
                name: "address",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_address",
            setterName: "set_address",
            getterFunction: Garage._mproxy_get_address,
            setterFunction: Garage._mproxy_set_address
        )
        classInfo.addPropertyGroup(name: "Hours and Insurance", prefix: "")
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetPropInfo(
                at: \Garage.daysOfOperation,
                name: "days_of_operation",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_days_of_operation",
            setterName: "set_days_of_operation",
            getterFunction: Garage._mproxy_get_daysOfOperation,
            setterFunction: Garage._mproxy_set_daysOfOperation
        )
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetPropInfo(
                at: \Garage.hours,
                name: "hours",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_hours",
            setterName: "set_hours",
            getterFunction: Garage._mproxy_get_hours,
            setterFunction: Garage._mproxy_set_hours
        )
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetPropInfo(
                at: \Garage.insuranceProvidersAccepted,
                name: "insurance_providers_accepted",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_insurance_providers_accepted",
            setterName: "set_insurance_providers_accepted",
            getterFunction: Garage._mproxy_get_insuranceProvidersAccepted,
            setterFunction: Garage._mproxy_set_insuranceProvidersAccepted
        )
    } ()
}