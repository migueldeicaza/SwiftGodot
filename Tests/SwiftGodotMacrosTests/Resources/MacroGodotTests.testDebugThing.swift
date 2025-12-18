class DebugThing: SwiftGodot.Object {
    var livesChanged: SignalWithArguments<Swift.Int> {
        get {
            SignalWithArguments<Swift.Int>(target: self, signalName: "lives_changed")
        }
    }
    func do_thing(value: SwiftGodot.Variant?) -> SwiftGodot.Variant? {
        return nil
    }

    static func _mproxy_do_thing(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `do_thing`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: SwiftGodot.Variant?.self, at: 0)
            return SwiftGodotRuntime._wrapCallableResult(object.do_thing(value: arg0))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `do_thing`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_do_thing(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `do_thing`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: SwiftGodot.Variant? = try rargs.fetchArgument(at: 0)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.do_thing(value: arg0)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `do_thing`: \(String(describing: error))")                    
        }
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("DebugThing")
        assert(ClassDB.classExists(class: className))
        SignalWithArguments<Swift.Int>.register(as: "lives_changed", in: className, names: [])
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "do_thing",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(SwiftGodot.Variant?.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(SwiftGodot.Variant?.self, name: "value")
            ],
            function: DebugThing._mproxy_do_thing,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                DebugThing._pproxy_do_thing (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }()
}
