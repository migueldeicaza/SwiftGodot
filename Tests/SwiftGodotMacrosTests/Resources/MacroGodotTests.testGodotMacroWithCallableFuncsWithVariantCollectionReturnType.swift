
class SomeNode: Node {
    func getIntegerCollection() -> VariantCollection<Int> {
        let result: VariantCollection<Int> = [0, 1, 1, 2, 3, 5, 8]
        return result
    }

    func _mproxy_getIntegerCollection(arguments: borrowing Arguments) -> Variant? {
        let result = getIntegerCollection()
        return Variant(result)

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let prop_0 = PropInfo (propertyType: .array, propertyName: "", className: StringName("Array[int]"), hint: .arrayType, hintStr: "int", usage: .default)
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerMethod(name: StringName("getIntegerCollection"), flags: .default, returnValue: prop_0, arguments: [], function: SomeNode._mproxy_getIntegerCollection)
    } ()
}