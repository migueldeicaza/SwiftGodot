
class SomeNode: Node {
    func getNodeCollection() -> ObjectCollection<Node> {
        let result: ObjectCollection<Node> = [Node(), Node()]
        return result
    }

    func _mproxy_getNodeCollection(arguments: borrowing Arguments) -> Variant? {
        let result = getNodeCollection()
        return Variant(result)

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let prop_0 = PropInfo (propertyType: .array, propertyName: "", className: StringName("Array[Node]"), hint: .arrayType, hintStr: "Node", usage: .default)
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerMethod(name: StringName("getNodeCollection"), flags: .default, returnValue: prop_0, arguments: [], function: SomeNode._mproxy_getNodeCollection)
    } ()
}