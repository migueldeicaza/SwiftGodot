
class Garage: Node {
    var name: String = ""

    static func _mproxy_set_name(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for name: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "name", object.name) {
            object.name = $0
        }
        return nil
    }

    static func _mproxy_get_name(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for name: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.name)
    }
    var rating: Float = 0.0

    static func _mproxy_set_rating(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for rating: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "rating", object.rating) {
            object.rating = $0
        }
        return nil
    }

    static func _mproxy_get_rating(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for rating: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.rating)
    }
    var reviews: TypedArray<String> = []

    static func _mproxy_set_reviews(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for reviews: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "reviews", object.reviews) {
            object.reviews = $0
        }
        return nil
    }

    static func _mproxy_get_reviews(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for reviews: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.reviews)
    }
    var checkIns: TypedArray<CheckIn> = []

    static func _mproxy_set_checkIns(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for checkIns: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "checkIns", object.checkIns) {
            object.checkIns = $0
        }
        return nil
    }

    static func _mproxy_get_checkIns(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for checkIns: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.checkIns)
    }
    var address: String = ""

    static func _mproxy_set_address(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for address: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "address", object.address) {
            object.address = $0
        }
        return nil
    }

    static func _mproxy_get_address(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for address: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.address)
    }
    var daysOfOperation: TypedArray<String> = []

    static func _mproxy_set_daysOfOperation(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for daysOfOperation: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "daysOfOperation", object.daysOfOperation) {
            object.daysOfOperation = $0
        }
        return nil
    }

    static func _mproxy_get_daysOfOperation(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for daysOfOperation: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.daysOfOperation)
    }
    var hours: TypedArray<String> = []

    static func _mproxy_set_hours(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for hours: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "hours", object.hours) {
            object.hours = $0
        }
        return nil
    }

    static func _mproxy_get_hours(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for hours: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.hours)
    }
    var insuranceProvidersAccepted: TypedArray<InsuranceProvider> = []

    static func _mproxy_set_insuranceProvidersAccepted(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for insuranceProvidersAccepted: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "insuranceProvidersAccepted", object.insuranceProvidersAccepted) {
            object.insuranceProvidersAccepted = $0
        }
        return nil
    }

    static func _mproxy_get_insuranceProvidersAccepted(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for insuranceProvidersAccepted: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.insuranceProvidersAccepted)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Garage")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodot._addPropertyGroup(className: className, name: "Front Page", prefix: "")
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
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
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
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
        SwiftGodot._addPropertyGroup(className: className, name: "More Details", prefix: "")
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
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
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
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
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
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
        SwiftGodot._addPropertyGroup(className: className, name: "Hours and Insurance", prefix: "")
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
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
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
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
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
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
    }()
}