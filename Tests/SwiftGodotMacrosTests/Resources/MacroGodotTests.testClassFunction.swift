class Hi: Node {
    class func get_some() -> Int64 { 10 }

    static func _mproxy_get_some(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        return SwiftGodotRuntime._wrapCallableResult(self.get_some())

    }
    static func _pproxy_get_some(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {

        RawReturnWriter.writeResult(returnValue, self.get_some()) 

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Hi")
        assert(ClassDB.classExists(class: className))
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "get_some",
            flags: .static,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Int64.self),
            arguments: [

            ],
            function: Hi._mproxy_get_some,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                Hi._pproxy_get_some (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }()
}