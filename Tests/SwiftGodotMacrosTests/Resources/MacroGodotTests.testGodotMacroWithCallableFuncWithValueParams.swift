class MathHelper: Node {
    func multiply(_ a: Int, by b: Int) -> Int { a * b}

    static func _mproxy_multiply(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `multiply`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Int.self, at: 0)
            let arg1 = try arguments.argument(ofType: Int.self, at: 1)
            return SwiftGodotRuntime._wrapCallableResult(object.multiply(arg0, by: arg1))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `multiply`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_multiply(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `multiply`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Int = try rargs.fetchArgument(at: 0)
        let arg1: Int = try rargs.fetchArgument(at: 1)
            RawReturnWriter.writeResult(returnValue, object.multiply(arg0, by: arg1)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `multiply`: \(String(describing: error))")                    
        }
    }
    func divide(_ a: Float, by b: Float) -> Float { a / b }

    static func _mproxy_divide(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `divide`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Float.self, at: 0)
            let arg1 = try arguments.argument(ofType: Float.self, at: 1)
            return SwiftGodotRuntime._wrapCallableResult(object.divide(arg0, by: arg1))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `divide`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_divide(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `divide`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Float = try rargs.fetchArgument(at: 0)
        let arg1: Float = try rargs.fetchArgument(at: 1)
            RawReturnWriter.writeResult(returnValue, object.divide(arg0, by: arg1)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `divide`: \(String(describing: error))")                    
        }
    }
    func areBothTrue(_ a: Bool, and b: Bool) -> Bool { a == b }

    static func _mproxy_areBothTrue(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `areBothTrue`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Bool.self, at: 0)
            let arg1 = try arguments.argument(ofType: Bool.self, at: 1)
            return SwiftGodotRuntime._wrapCallableResult(object.areBothTrue(arg0, and: arg1))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `areBothTrue`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_areBothTrue(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `areBothTrue`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Bool = try rargs.fetchArgument(at: 0)
        let arg1: Bool = try rargs.fetchArgument(at: 1)
            RawReturnWriter.writeResult(returnValue, object.areBothTrue(arg0, and: arg1)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `areBothTrue`: \(String(describing: error))")                    
        }
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("MathHelper")
        assert(ClassDB.classExists(class: className))
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "multiply",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Int.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Int.self, name: "a"),
                SwiftGodotRuntime._argumentPropInfo(Int.self, name: "b")
            ],
            function: MathHelper._mproxy_multiply,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                MathHelper._pproxy_multiply (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "divide",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Float.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Float.self, name: "a"),
                SwiftGodotRuntime._argumentPropInfo(Float.self, name: "b")
            ],
            function: MathHelper._mproxy_divide,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                MathHelper._pproxy_divide (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "areBothTrue",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Bool.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Bool.self, name: "a"),
                SwiftGodotRuntime._argumentPropInfo(Bool.self, name: "b")
            ],
            function: MathHelper._mproxy_areBothTrue,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                MathHelper._pproxy_areBothTrue (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }()
}