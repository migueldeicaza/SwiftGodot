class Hi: Node {
    var goodName: String = "Supertop"

    static func _mproxy_set_goodName(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for goodName: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "goodName", object.goodName) {
            object.goodName = $0
        }
        return nil
    }

    static func _mproxy_get_goodName(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for goodName: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.goodName)
    }

    private static let _initializeClass: Void = {
        let className = StringName(takingOver: getActualClassName())
        assert(ClassDB.classExists(class: className))
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \Hi.goodName,
                name: "good_name",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_good_name",
            setterName: "set_good_name",
            getterFunction: Hi._mproxy_get_goodName,
            setterFunction: Hi._mproxy_set_goodName
        )
    }()

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static func getActualClassName() -> FastStringName {
        FastStringName("Hi")
    }

    open override func getActualClassName() -> FastStringName {
        Self.getActualClassName()
    }
}