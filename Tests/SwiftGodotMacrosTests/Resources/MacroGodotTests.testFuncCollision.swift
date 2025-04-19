class OtherThing: SwiftGodot.Node {            
    func foo(value: Int?) { }

    static func _mproxy_foo(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `foo`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Int?.self, at: 0)
            return SwiftGodot._wrapCallableResult(object.foo(value: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `foo`: \(error.description)")
        }

        return nil
    }

    func foo() -> MyThing? {
        return nil
    }

    static func _mproxy_foo(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling `foo`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodot._wrapCallableResult(object.foo())

    }
}