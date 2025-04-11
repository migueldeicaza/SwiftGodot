
class SomeNode: Node {
    func getIntegerCollection() -> VariantCollection<Int> {
        let result: VariantCollection<Int> = [0, 1, 1, 2, 3, 5, 8]
        return result
    }

    func _mproxy_getIntegerCollection(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        return SwiftGodot._macroCallableToVariant(getIntegerCollection())

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerMethod(
            name: StringName("getIntegerCollection"),
            flags: .default,
            returnValue: _macroGodotGetCallablePropInfo(VariantCollection<Int>.self),
            arguments: [],
            function: SomeNode._mproxy_getIntegerCollection
        )
    } ()
}