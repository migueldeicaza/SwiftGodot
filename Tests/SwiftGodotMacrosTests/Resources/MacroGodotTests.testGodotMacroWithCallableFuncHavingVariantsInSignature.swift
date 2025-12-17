private class TestNode: Node {
    func foo(variant: Variant?) -> Variant? {
        return variant
    }

    static func _mproxy_foo(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `foo`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Variant?.self, at: 0)
            return SwiftGodotRuntime._wrapCallableResult(object.foo(variant: arg0))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `foo`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_foo(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `foo`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Variant? = try rargs.fetchArgument(at: 0)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.foo(variant: arg0)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `foo`: \(String(describing: error))")                    
        }
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("TestNode")
        assert(ClassDB.classExists(class: className))
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "foo",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Variant?.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Variant?.self, name: "variant")
            ],
            function: TestNode._mproxy_foo,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                TestNode._pproxy_foo (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }()
}
