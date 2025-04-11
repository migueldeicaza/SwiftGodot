
class MultiplierNode: Node {
    func multiply(_ integers: Array<Int>) -> Int {
        integers.reduce(into: 1) { $0 *= $1 }
    }

    func _mproxy_multiply(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Array<Int>.self, at: 0)
            return SwiftGodot._macroCallableToVariant(multiply(arg0))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `multiply`: \(error)")
            return nil
        }
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("MultiplierNode")
        assert(ClassDB.classExists(class: className))
        let prop_0 = PropInfo (propertyType: .int, propertyName: "", className: StringName(""), hint: .none, hintStr: "", usage: .default)
        let prop_1 = PropInfo (propertyType: .array, propertyName: "integers", className: StringName("Array[int]"), hint: .arrayType, hintStr: "int", usage: .default)
        let multiplyArgs = [
            prop_1,
        ]
        let classInfo = ClassInfo<MultiplierNode> (name: className)
        classInfo.registerMethod(name: StringName("multiply"), flags: .default, returnValue: prop_0, arguments: multiplyArgs, function: MultiplierNode._mproxy_multiply)
    } ()
}