class Hi: Node {
    static func get_some() -> Int64 { 10 }

    static func _mproxy_get_some(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        return SwiftGodot._wrapCallableResult(self.get_some())

    }
}