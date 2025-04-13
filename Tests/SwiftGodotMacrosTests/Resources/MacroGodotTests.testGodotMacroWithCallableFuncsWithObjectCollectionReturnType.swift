
class SomeNode: Node {
    func getNodeCollection() -> ObjectCollection<Node> {
        let result: ObjectCollection<Node> = [Node(), Node()]
        return result
    }

    func _mproxy_getNodeCollection(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        return SwiftGodot._wrapCallableResult(getNodeCollection())

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
            name: "getNodeCollection",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(ObjectCollection<Node>.self),
            arguments: [

            ],
            function: SomeNode._mproxy_getNodeCollection
        )
    } ()
}