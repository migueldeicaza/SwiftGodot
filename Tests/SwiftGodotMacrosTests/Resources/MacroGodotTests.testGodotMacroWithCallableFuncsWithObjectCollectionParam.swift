
class SomeNode: Node {
    func printNames(of nodes: ObjectCollection<Node>) {
        nodes.forEach { print($0.name) }
    }

    func _mproxy_printNames(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0: ObjectCollection<Node> = try arguments.argument(ofType: ObjectCollection<Node>.self, at: 0)
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
        let prop_0 = PropInfo (propertyType: .array, propertyName: "nodes", className: StringName("Array[Node]"), hint: .arrayType, hintStr: "Node", usage: .default)
        let printNamesArgs = [
            prop_0,
        ]
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerMethod(name: StringName("printNames"), flags: .default, returnValue: nil, arguments: printNamesArgs, function: SomeNode._mproxy_printNames)
    } ()
}