
class SomeNode: Node {
    func printNames(of nodes: ObjectCollection<Node>) {
        nodes.forEach { print($0.name) }
    }

    func _mproxy_printNames(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: ObjectCollection<Node>.self, at: 0)
            return SwiftGodot._wrapCallableResult(printNames(of: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `printNames`: \(error.description)")
        }

        return nil
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
            name: "printNames",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(ObjectCollection<Node>.self, name: "nodes")
            ],
            function: SomeNode._mproxy_printNames
        )
    } ()
}