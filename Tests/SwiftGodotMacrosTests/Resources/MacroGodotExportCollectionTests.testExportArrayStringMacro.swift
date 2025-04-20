var greetings: TypedArray<String> = []

static func _mproxy_set_greetings(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
    guard let object = _unwrap(self, pInstance: pInstance) else {
        SwiftGodot.GD.printErr("Error calling getter for greetings: failed to unwrap instance \(String(describing: pInstance))")
        return nil
    }

    SwiftGodot._invokeSetter(arguments, "greetings", object.greetings) {
        object.greetings = $0
    }
    return nil
}

static func _mproxy_get_greetings(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
    guard let object = _unwrap(self, pInstance: pInstance) else {
        SwiftGodot.GD.printErr("Error calling getter for greetings: failed to unwrap instance \(String(describing: pInstance))")
        return nil
    }

    return SwiftGodot._invokeGetter(object.greetings)
}
