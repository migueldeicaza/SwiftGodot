
class SomeNode: Node {
    func square(_ integers: VariantCollection<Int>) -> VariantCollection<Int> {
        integers.map { $0 * $0 }.reduce(into: VariantCollection<Int>()) { $0.append(value: $1) }
    }

    func _mproxy_square(arguments: borrowing Arguments) -> Variant? {
        do { // safe arguments access scope
            let arg0: VariantCollection<Int> = try arguments.argument(ofType: VariantCollection<Int>.self, at: 0)
            let result = square(arg0)
            return Variant(result)

        } catch let error as ArgumentAccessError {
            GD.printErr(error.description)
            return nil
        } catch {
            GD.printErr("Error calling `square`: \(error)")
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
        let prop_0 = PropInfo (propertyType: .array, propertyName: "", className: StringName("Array[int]"), hint: .arrayType, hintStr: "int", usage: .default)
        let prop_1 = PropInfo (propertyType: .array, propertyName: "integers", className: StringName("Array[int]"), hint: .arrayType, hintStr: "int", usage: .default)
        let squareArgs = [
            prop_1,
        ]
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerMethod(name: StringName("square"), flags: .default, returnValue: prop_0, arguments: squareArgs, function: SomeNode._mproxy_square)
    } ()
}