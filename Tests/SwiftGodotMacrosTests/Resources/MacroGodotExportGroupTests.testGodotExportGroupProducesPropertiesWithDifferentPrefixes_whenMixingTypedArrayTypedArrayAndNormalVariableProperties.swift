class Garage: Node {
    var name: String = ""

    static func _mproxy_set_name(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for name: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "name", object.name) {
            object.name = $0
        }
        return nil
    }

    static func _mproxy_get_name(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for name: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.name)
    }
    var rating: Float = 0.0

    static func _mproxy_set_rating(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for rating: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "rating", object.rating) {
            object.rating = $0
        }
        return nil
    }

    static func _mproxy_get_rating(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for rating: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.rating)
    }
    var reviews: TypedArray<String> = []

    static func _mproxy_set_reviews(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for reviews: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "reviews", object.reviews) {
            object.reviews = $0
        }
        return nil
    }

    static func _mproxy_get_reviews(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for reviews: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.reviews)
    }
    var checkIns: TypedArray<CheckIn> = []

    static func _mproxy_set_checkIns(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for checkIns: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "checkIns", object.checkIns) {
            object.checkIns = $0
        }
        return nil
    }

    static func _mproxy_get_checkIns(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for checkIns: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.checkIns)
    }
    var address: String = ""

    static func _mproxy_set_address(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for address: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "address", object.address) {
            object.address = $0
        }
        return nil
    }

    static func _mproxy_get_address(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for address: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.address)
    }
    var daysOfOperation: TypedArray<String> = []

    static func _mproxy_set_daysOfOperation(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for daysOfOperation: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "daysOfOperation", object.daysOfOperation) {
            object.daysOfOperation = $0
        }
        return nil
    }

    static func _mproxy_get_daysOfOperation(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for daysOfOperation: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.daysOfOperation)
    }
    var hours: TypedArray<String> = []

    static func _mproxy_set_hours(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for hours: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "hours", object.hours) {
            object.hours = $0
        }
        return nil
    }

    static func _mproxy_get_hours(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for hours: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.hours)
    }
    var insuranceProvidersAccepted: TypedArray<InsuranceProvider> = []

    static func _mproxy_set_insuranceProvidersAccepted(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for insuranceProvidersAccepted: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "insuranceProvidersAccepted", object.insuranceProvidersAccepted) {
            object.insuranceProvidersAccepted = $0
        }
        return nil
    }

    static func _mproxy_get_insuranceProvidersAccepted(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for insuranceProvidersAccepted: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.insuranceProvidersAccepted)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: Garage.self) else {
            return
        }
        let className = StringName("Garage")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._addPropertyGroup(className: className, name: "Front Page", prefix: "")
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Garage.name,
                name: SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("name"),
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: StringName("get_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("name")),
            setterName: StringName("set_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("name")),
            getterFunction: Garage._mproxy_get_name,
            setterFunction: Garage._mproxy_set_name
        )
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Garage.rating,
                name: SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("rating"),
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: StringName("get_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("rating")),
            setterName: StringName("set_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("rating")),
            getterFunction: Garage._mproxy_get_rating,
            setterFunction: Garage._mproxy_set_rating
        )
        SwiftGodotRuntime._addPropertyGroup(className: className, name: "More Details", prefix: "")
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Garage.reviews,
                name: SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("reviews"),
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: StringName("get_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("reviews")),
            setterName: StringName("set_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("reviews")),
            getterFunction: Garage._mproxy_get_reviews,
            setterFunction: Garage._mproxy_set_reviews
        )
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Garage.checkIns,
                name: SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("checkIns"),
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: StringName("get_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("checkIns")),
            setterName: StringName("set_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("checkIns")),
            getterFunction: Garage._mproxy_get_checkIns,
            setterFunction: Garage._mproxy_set_checkIns
        )
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Garage.address,
                name: SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("address"),
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: StringName("get_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("address")),
            setterName: StringName("set_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("address")),
            getterFunction: Garage._mproxy_get_address,
            setterFunction: Garage._mproxy_set_address
        )
        SwiftGodotRuntime._addPropertyGroup(className: className, name: "Hours and Insurance", prefix: "")
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Garage.daysOfOperation,
                name: SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("daysOfOperation"),
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: StringName("get_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("daysOfOperation")),
            setterName: StringName("set_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("daysOfOperation")),
            getterFunction: Garage._mproxy_get_daysOfOperation,
            setterFunction: Garage._mproxy_set_daysOfOperation
        )
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Garage.hours,
                name: SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("hours"),
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: StringName("get_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("hours")),
            setterName: StringName("set_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("hours")),
            getterFunction: Garage._mproxy_get_hours,
            setterFunction: Garage._mproxy_set_hours
        )
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Garage.insuranceProvidersAccepted,
                name: SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("insuranceProvidersAccepted"),
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: StringName("get_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("insuranceProvidersAccepted")),
            setterName: StringName("set_" + SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("insuranceProvidersAccepted")),
            getterFunction: Garage._mproxy_get_insuranceProvidersAccepted,
            setterFunction: Garage._mproxy_set_insuranceProvidersAccepted
        )
    }
}
