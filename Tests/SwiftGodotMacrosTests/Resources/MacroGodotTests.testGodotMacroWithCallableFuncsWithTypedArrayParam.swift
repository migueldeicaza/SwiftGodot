class SomeNode: Node {
    func square(_ integers: TypedArray<Int>) -> TypedArray<Int> {
        integers.map { $0 * $0 }.reduce(into: TypedArray<Int>()) { $0.append(value: $1) }
    }

    static func _mproxy_square(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `square`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: TypedArray<Int>.self, at: 0)
            return SwiftGodotRuntime._wrapCallableResult(object.square(arg0))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `square`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_square(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `square`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: TypedArray<Int> = try rargs.fetchArgument(at: 0)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.square(arg0)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `square`: \(String(describing: error))")                    
        }
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "square",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(TypedArray<Int>.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(TypedArray<Int>.self, name: "integers")
            ],
            function: SomeNode._mproxy_square,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                SomeNode._pproxy_square (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }()
}
