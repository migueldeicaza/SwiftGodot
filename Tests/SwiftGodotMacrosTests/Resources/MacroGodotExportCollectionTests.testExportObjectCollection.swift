var greetings: ObjectCollection<Node3D> = []

func _mproxy_set_greetings(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
    SwiftGodot._invokeSetter(args, "greetings", greetings) {
        greetings = $0
    }
}

func _mproxy_get_greetings(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
    SwiftGodot._invokeGetter(greetings)
}
