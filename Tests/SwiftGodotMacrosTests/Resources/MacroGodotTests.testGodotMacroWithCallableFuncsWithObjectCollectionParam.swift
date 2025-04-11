
class SomeNode: Node {
    func printNames(of nodes: ObjectCollection<Node>) {
        nodes.forEach { print($0.name) }
    }

    func _mproxy_printNames(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: ObjectCollection<Node>.self, at: 0)
            return SwiftGodot._macroCallableToVariant(printNames(of: arg0))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `printNames`: \(error)")
            return nil
        }
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
            name: StringName("printNames"),
            flags: .default,
            returnValue: _macroGodotGetCallablePropInfo(Swift.Void.self),
            arguments: [_macroGodotGetCallablePropInfo(ObjectCollection<Node>.self, name: "nodes")],
            function: SomeNode._mproxy_printNames
        )
    } ()
}