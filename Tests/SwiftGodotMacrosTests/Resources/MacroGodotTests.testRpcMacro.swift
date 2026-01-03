class MultiplayerNode: Node {

    func syncPosition(_ position: Vector3) {
    }

    static func _mproxy_syncPosition(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `syncPosition`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Vector3.self, at: 0)
            return SwiftGodotRuntime._wrapCallableResult(object.syncPosition(arg0))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `syncPosition`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_syncPosition(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `syncPosition`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Vector3 = try rargs.fetchArgument(at: 0)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.syncPosition(arg0)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `syncPosition`: \(String(describing: error))")                    
        }
    }


    func defaultRpc() {
    }

    static func _mproxy_defaultRpc(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling `defaultRpc`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodotRuntime._wrapCallableResult(object.defaultRpc())

    }
    static func _pproxy_defaultRpc(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling `defaultRpc`: failed to unwrap instance \(String(describing: pInstance))")
            return
        }
        SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.defaultRpc()) 

    }


    func fullConfig() {
    }

    static func _mproxy_fullConfig(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling `fullConfig`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodotRuntime._wrapCallableResult(object.fullConfig())

    }
    static func _pproxy_fullConfig(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling `fullConfig`: failed to unwrap instance \(String(describing: pInstance))")
            return
        }
        SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.fullConfig()) 

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("MultiplayerNode")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "syncPosition",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Vector3.self, name: "position")
            ],
            function: MultiplayerNode._mproxy_syncPosition,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                MultiplayerNode._pproxy_syncPosition (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "defaultRpc",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Swift.Void.self),
            arguments: [

            ],
            function: MultiplayerNode._mproxy_defaultRpc,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                MultiplayerNode._pproxy_defaultRpc (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "fullConfig",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Swift.Void.self),
            arguments: [

            ],
            function: MultiplayerNode._mproxy_fullConfig,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                MultiplayerNode._pproxy_fullConfig (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }()

    /// Called automatically before `_ready()`. Configures RPC for methods marked with `@Rpc`.
    override open func _before_ready() {
        super._before_ready()
        rpcConfig(
            method: StringName("sync_position"),
            config: Variant([
                "rpc_mode": Variant(MultiplayerAPI.RPCMode.anyPeer.rawValue),
                "call_local": Variant(false),
                "transfer_mode": Variant(MultiplayerPeer.TransferMode.reliable.rawValue),
                "channel": Variant(0)
            ] as GDictionary)
        )
        rpcConfig(
            method: StringName("default_rpc"),
            config: Variant([
                "rpc_mode": Variant(MultiplayerAPI.RPCMode.authority.rawValue),
                "call_local": Variant(false),
                "transfer_mode": Variant(MultiplayerPeer.TransferMode.unreliable.rawValue),
                "channel": Variant(0)
            ] as GDictionary)
        )
        rpcConfig(
            method: StringName("full_config"),
            config: Variant([
                "rpc_mode": Variant(MultiplayerAPI.RPCMode.authority.rawValue),
                "call_local": Variant(true),
                "transfer_mode": Variant(MultiplayerPeer.TransferMode.unreliableOrdered.rawValue),
                "channel": Variant(2)
            ] as GDictionary)
        )
        }
}
