
class SomeNode: Node {
    func getIntegerCollection() -> TypedArray<Int> {
        let result: TypedArray<Int> = [0, 1, 1, 2, 3, 5, 8]
        return result
    }

    static func _mproxy_getIntegerCollection(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling `getIntegerCollection`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodotRuntime._wrapCallableResult(object.getIntegerCollection())

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<SomeNode> (name: className)
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "getIntegerCollection",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(TypedArray<Int>.self),
            arguments: [

            ],
            function: SomeNode._mproxy_getIntegerCollection
        )
    } ()
}
