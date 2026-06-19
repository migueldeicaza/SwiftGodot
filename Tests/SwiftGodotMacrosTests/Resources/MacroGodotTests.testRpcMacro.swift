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
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: MultiplayerNode.self) else {
            return
        }
        let className = StringName("MultiplayerNode")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: StringName(SwiftGodotRuntime._translateMemberIdentifier("syncPosition")),
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Vector3.self, name: SwiftGodotRuntime._translateMemberIdentifier("position"))
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
            name: StringName(SwiftGodotRuntime._translateMemberIdentifier("defaultRpc")),
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
            name: StringName(SwiftGodotRuntime._translateMemberIdentifier("fullConfig")),
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
    }

    /// Called automatically before `_ready()`. Configures RPC for methods marked with `@Rpc`.
    override open func _before_ready() {
        super._before_ready()
        let rpcConfigDictionary0 = GDictionary()
        rpcConfigDictionary0[Variant("rpc_mode")] = Variant(MultiplayerAPI.RPCMode.anyPeer.rawValue)
        rpcConfigDictionary0[Variant("call_local")] = Variant(false)
        rpcConfigDictionary0[Variant("transfer_mode")] = Variant(MultiplayerPeer.TransferMode.reliable.rawValue)
        rpcConfigDictionary0[Variant("channel")] = Variant(0)
        rpcConfig(
            method: StringName(SwiftGodotRuntime._translateMemberIdentifier("syncPosition")),
            config: Variant(rpcConfigDictionary0)
        )
        let rpcConfigDictionary1 = GDictionary()
        rpcConfigDictionary1[Variant("rpc_mode")] = Variant(MultiplayerAPI.RPCMode.authority.rawValue)
        rpcConfigDictionary1[Variant("call_local")] = Variant(false)
        rpcConfigDictionary1[Variant("transfer_mode")] = Variant(MultiplayerPeer.TransferMode.unreliable.rawValue)
        rpcConfigDictionary1[Variant("channel")] = Variant(0)
        rpcConfig(
            method: StringName(SwiftGodotRuntime._translateMemberIdentifier("defaultRpc")),
            config: Variant(rpcConfigDictionary1)
        )
        let rpcConfigDictionary2 = GDictionary()
        rpcConfigDictionary2[Variant("rpc_mode")] = Variant(MultiplayerAPI.RPCMode.authority.rawValue)
        rpcConfigDictionary2[Variant("call_local")] = Variant(true)
        rpcConfigDictionary2[Variant("transfer_mode")] = Variant(MultiplayerPeer.TransferMode.unreliableOrdered.rawValue)
        rpcConfigDictionary2[Variant("channel")] = Variant(2)
        rpcConfig(
            method: StringName(SwiftGodotRuntime._translateMemberIdentifier("fullConfig")),
            config: Variant(rpcConfigDictionary2)
        )
        }
}
