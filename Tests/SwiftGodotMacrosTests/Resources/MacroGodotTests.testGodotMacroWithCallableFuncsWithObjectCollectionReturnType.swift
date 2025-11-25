
class SomeNode: Node {
    func getNodeCollection() -> TypedArray<Node> {
        let result: TypedArray<Node> = [Node(), Node()]
        return result
    }

    static func _mproxy_getNodeCollection(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling `getNodeCollection`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodotRuntime._wrapCallableResult(object.getNodeCollection())

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
            name: "getNodeCollection",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(TypedArray<Node>.self),
            arguments: [

            ],
            function: SomeNode._mproxy_getNodeCollection
        )
    } ()
}
