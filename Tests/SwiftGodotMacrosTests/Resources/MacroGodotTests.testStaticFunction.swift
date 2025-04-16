class Hi: Node {
    static func get_some() -> Int64 { 10 }

    static func _mproxy_get_some(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        return SwiftGodot._wrapCallableResult(self.get_some())

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Hi")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Hi> (name: className)
        SwiftGodot._registerMethod(
            className: className,
            name: "get_some",
            flags: .static,
            returnValue: SwiftGodot._returnValuePropInfo(Int64.self),
            arguments: [

            ],
            function: Hi._mproxy_get_some
        )
    } ()
}