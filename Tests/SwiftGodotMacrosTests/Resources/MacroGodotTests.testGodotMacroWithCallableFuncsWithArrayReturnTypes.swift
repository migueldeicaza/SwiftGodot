class CallableCollectionsNode: Node {
    func get_ages() -> [Int] {
        [1, 2, 3, 4]
    }

    static func _mproxy_get_ages(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling `get_ages`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodotRuntime._wrapCallableResult(object.get_ages())

    }
    static func _pproxy_get_ages(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling `get_ages`: failed to unwrap instance \(String(describing: pInstance))")
            return
        }
        SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.get_ages()) 

    }
    func get_markers() -> [Marker3D] {
        [.init(), .init(), .init()]
    }

    static func _mproxy_get_markers(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling `get_markers`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodotRuntime._wrapCallableResult(object.get_markers())

    }
    static func _pproxy_get_markers(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling `get_markers`: failed to unwrap instance \(String(describing: pInstance))")
            return
        }
        SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.get_markers()) 

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("CallableCollectionsNode")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "get_ages",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo([Int].self),
            arguments: [

            ],
            function: CallableCollectionsNode._mproxy_get_ages,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                CallableCollectionsNode._pproxy_get_ages (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "get_markers",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo([Marker3D].self),
            arguments: [

            ],
            function: CallableCollectionsNode._mproxy_get_markers,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                CallableCollectionsNode._pproxy_get_markers (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }()
}
