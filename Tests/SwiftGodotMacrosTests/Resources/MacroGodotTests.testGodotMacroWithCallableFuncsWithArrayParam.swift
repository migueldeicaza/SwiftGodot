class MultiplierNode: Node {
    func multiply(_ integers: [Int]) -> Int {
        integers.reduce(into: 1) { $0 *= $1 }
    }

    static func _mproxy_multiply(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `multiply`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: [Int].self, at: 0)
            return SwiftGodotRuntime._wrapCallableResult(object.multiply(arg0))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `multiply`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_multiply(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `multiply`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: [Int] = try rargs.fetchArgument(at: 0)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.multiply(arg0)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `multiply`: \(String(describing: error))")                    
        }
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("MultiplierNode")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "multiply",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Int.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo([Int].self, name: "integers")
            ],
            function: MultiplierNode._mproxy_multiply,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                MultiplierNode._pproxy_multiply (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }()
}
