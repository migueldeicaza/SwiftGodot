
class SomeNode: Node {
    var greetings: VariantCollection<String> = []

    func _mproxy_set_greetings(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "greetings", greetings) {
            greetings = $0
        }
    }

    func _mproxy_get_greetings(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(greetings)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetPropInfo(
                at: \SomeNode.greetings,
                name: "greetings",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_greetings",
            setterName: "set_greetings",
            getterFunction: SomeNode._mproxy_get_greetings,
            setterFunction: SomeNode._mproxy_set_greetings
        )
    } ()
}