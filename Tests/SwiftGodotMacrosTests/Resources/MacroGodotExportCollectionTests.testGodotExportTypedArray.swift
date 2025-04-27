
class SomeNode: Node {
    var greetings: TypedArray<Node3D> = []

    static func _mproxy_set_greetings(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling setter for greetings: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "greetings", object.greetings) {
            object.greetings = $0
        }
        return nil
    }

    static func _mproxy_get_greetings(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for greetings: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.greetings)
    }

    private static let _initializeClass: Void = {
        let className = StringName(takingOver: getActualClassName())
        assert(ClassDB.classExists(class: className))
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \SomeNode.greetings,
                name: "greetings",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_greetings",
            setterName: "set_greetings",
            getterFunction: SomeNode._mproxy_get_greetings,
            setterFunction: SomeNode._mproxy_set_greetings
        )
    }()

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static func getActualClassName() -> FastStringName {
        FastStringName("SomeNode")
    }

    open override func getActualClassName() -> FastStringName {
        Self.getActualClassName()
    }
}