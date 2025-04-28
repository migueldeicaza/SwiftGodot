class MyThing: SwiftGodot.RefCounted {

    private static let _initializeClass: Void = {
        let className = StringName(content: actualClassName.content)
        assert(ClassDB.classExists(class: className))
        className.content = .zero
    }()

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static var actualClassName: UnsafeStringName {
        UnsafeStringName("MyThing")
    }

    open override var actualClassName: UnsafeStringName {
        Self.actualClassName
    }

}

class OtherThing: SwiftGodot.Node {
    func get_thing() -> MyThing? {
        return nil
    }

    static func _mproxy_get_thing(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling `get_thing`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodot._wrapCallableResult(object.get_thing())

    }

    private static let _initializeClass: Void = {
        let className = StringName(content: actualClassName.content)
        assert(ClassDB.classExists(class: className))
        SwiftGodot._registerMethod(
            className: className,
            name: "get_thing",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(MyThing?.self),
            arguments: [

            ],
            function: OtherThing._mproxy_get_thing
        )
        className.content = .zero
    }()

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static var actualClassName: UnsafeStringName {
        UnsafeStringName("OtherThing")
    }

    open override var actualClassName: UnsafeStringName {
        Self.actualClassName
    }
}