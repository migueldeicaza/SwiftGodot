
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

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
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
    } ()
}
