class Hi: Node {
    class var int = 10

    static func _mproxy_set_int(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for int: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodot._invokeSetter(arguments, "int", object.int) {
            object.int = $0
        }
        return nil
    }

    static func _mproxy_get_int(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling getter for int: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodot._invokeGetter(object.int)
    }
}