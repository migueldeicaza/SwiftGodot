var greetings: ObjectCollection<Node3D> = []

func _mproxy_set_greetings(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
    SwiftGodot._macroExportSet(args, "greetings", greetings) {
        greetings = $0
    }
}

func _mproxy_get_greetings(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
    SwiftGodot._wrapGetterResult(greetings)
}