var greetings: ObjectCollection<Node3D> = []

func _mproxy_set_greetings(args: borrowing Arguments) -> Variant? {
    _macroExportSet(args, "greetings", greetings) {
        greetings = $0
    }
}

func _mproxy_get_greetings(args: borrowing Arguments) -> Variant? {
    _macroExportGet(greetings)
}