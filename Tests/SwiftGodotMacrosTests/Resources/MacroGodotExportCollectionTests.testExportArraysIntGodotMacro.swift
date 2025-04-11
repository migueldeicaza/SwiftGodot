
class SomeNode: Node {
    var someNumbers: VariantCollection<Int> = []

    func _mproxy_set_someNumbers(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "someNumbers", someNumbers) {
            someNumbers = $0
        }
    }

    func _mproxy_get_someNumbers(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(someNumbers)
    }
    var someOtherNumbers: VariantCollection<Int> = []

    func _mproxy_set_someOtherNumbers(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "someOtherNumbers", someOtherNumbers) {
            someOtherNumbers = $0
        }
    }

    func _mproxy_get_someOtherNumbers(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(someOtherNumbers)
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
                at: \SomeNode.someNumbers,
                name: "some_numbers",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_some_numbers",
            setterName: "set_some_numbers",
            getterFunction: SomeNode._mproxy_get_someNumbers,
            setterFunction: SomeNode._mproxy_set_someNumbers
        )
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetPropInfo(
                at: \SomeNode.someOtherNumbers,
                name: "some_other_numbers",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_some_other_numbers",
            setterName: "set_some_other_numbers",
            getterFunction: SomeNode._mproxy_get_someOtherNumbers,
            setterFunction: SomeNode._mproxy_set_someOtherNumbers
        )
    } ()
}