
class SomeNode: Node {
    var someArray: GArray = GArray()

    static func _mproxy_set_someArray(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for someArray: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "someArray", object.someArray) {
            object.someArray = $0
        }
        return nil
    }

    static func _mproxy_get_someArray(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for someArray: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.someArray)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<SomeNode> (name: className)
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \SomeNode.someArray,
                name: "some_array",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_some_array",
            setterName: "set_some_array",
            getterFunction: SomeNode._mproxy_get_someArray,
            setterFunction: SomeNode._mproxy_set_someArray
        )
    } ()
}