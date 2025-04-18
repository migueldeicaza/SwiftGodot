
class SomeNode: Node {
    func printNames(of nodes: ObjectCollection<Node>) {
        nodes.forEach { print($0.name) }
    }

    static func _mproxy_printNames(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `printNames`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: ObjectCollection<Node>.self, at: 0)
            return SwiftGodot._wrapCallableResult(object.printNames(of: arg0))

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
        SwiftGodot._registerMethod(
            className: className,
            name: "printNames",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(ObjectCollection<Node>.self, name: "nodes")
            ],
            function: SomeNode._mproxy_printNames
        )
    } ()
}