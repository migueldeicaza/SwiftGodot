let greetings: TypedArray<String> = []

static func _mproxy_get_greetings(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
    guard let object = _unwrap(self, pInstance: pInstance) else {
        SwiftGodotRuntime.GD.printErr("Error calling getter for greetings: failed to unwrap instance \(String(describing: pInstance))")
        return nil
    }

    return SwiftGodotRuntime._invokeGetter(object.greetings)
}
