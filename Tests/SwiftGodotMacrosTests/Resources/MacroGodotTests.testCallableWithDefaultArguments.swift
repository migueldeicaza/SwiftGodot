class Greeter: Node {
    func greet(_ name: String, greeting: String = "Hello", times: Int = 1) -> String {
        Array(repeating: "\(greeting), \(name)", count: times).joined(separator: " ")
    }

    static func _mproxy_greet(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `greet`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: String.self, at: 0)
            let arg1 = arguments.count > 1 ? try arguments.argument(ofType: String.self, at: 1) : ("Hello" as String)
            let arg2 = arguments.count > 2 ? try arguments.argument(ofType: Int.self, at: 2) : (1 as Int)
            return SwiftGodotRuntime._wrapCallableResult(object.greet(arg0, greeting: arg1, times: arg2))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `greet`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_greet(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `greet`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: String = try rargs.fetchArgument(at: 0)
        let arg1: String = try rargs.fetchArgument(at: 1)
        let arg2: Int = try rargs.fetchArgument(at: 2)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.greet(arg0, greeting: arg1, times: arg2)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `greet`: \(String(describing: error))")                    
        }
    }
    func attach(to node: Node? = nil) {}

    static func _mproxy_attach(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `attach`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = arguments.count > 0 ? try arguments.argument(ofType: Node?.self, at: 0) : (nil as Node?)
            return SwiftGodotRuntime._wrapCallableResult(object.attach(to: arg0))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `attach`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_attach(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `attach`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Node? = try rargs.fetchArgument(at: 0)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.attach(to: arg0)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `attach`: \(String(describing: error))")                    
        }
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: Greeter.self) else {
            return
        }
        let className = StringName("Greeter")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: StringName(SwiftGodotRuntime._translateMemberIdentifier("greet")),
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(String.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(String.self, name: SwiftGodotRuntime._translateMemberIdentifier("name")),
                SwiftGodotRuntime._argumentPropInfo(String.self, name: SwiftGodotRuntime._translateMemberIdentifier("greeting")),
                SwiftGodotRuntime._argumentPropInfo(Int.self, name: SwiftGodotRuntime._translateMemberIdentifier("times"))
            ],
            defaultArguments: [
                SwiftGodotRuntime._wrapDefaultArgument(SwiftGodotRuntime._wrapCallableResult("Hello" as String)),
                SwiftGodotRuntime._wrapDefaultArgument(SwiftGodotRuntime._wrapCallableResult(1 as Int))
            ],
            function: Greeter._mproxy_greet,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                Greeter._pproxy_greet (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: StringName(SwiftGodotRuntime._translateMemberIdentifier("attach")),
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Node?.self, name: SwiftGodotRuntime._translateMemberIdentifier("node"))
            ],
            defaultArguments: [
                SwiftGodotRuntime._wrapDefaultArgument(SwiftGodotRuntime._wrapCallableResult(nil as Node?))
            ],
            function: Greeter._mproxy_attach,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                Greeter._pproxy_attach (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }
}
