
class SomeNode: Node {
    var someArray: GArray = GArray()

    func _mproxy_set_someArray(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "someArray", someArray) {
            someArray = $0
        }
    }

    func _mproxy_get_someArray(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(someArray)
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
            SwiftGodot._macroGodotGetVariablePropInfo(
                at: \SomeNode.someArray,
                name: "some_array",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_some_array",
            setterName: "set_some_array",
            getterFunction: SomeNode._mproxy_get_someArray,
            setterFunction: SomeNode._mproxy_set_someArray
        )
    } ()
}