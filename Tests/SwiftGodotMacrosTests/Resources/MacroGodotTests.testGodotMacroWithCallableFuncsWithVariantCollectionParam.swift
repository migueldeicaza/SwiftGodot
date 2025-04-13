
class SomeNode: Node {
    func square(_ integers: VariantCollection<Int>) -> VariantCollection<Int> {
        integers.map { $0 * $0 }.reduce(into: VariantCollection<Int>()) { $0.append(value: $1) }
    }

    func _mproxy_square(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: VariantCollection<Int>.self, at: 0)
            return SwiftGodot._wrapCallableResult(square(arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `square`: \(error.description)")
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
            name: "square",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(VariantCollection<Int>.self),
            arguments: [
                SwiftGodot._argumentPropInfo(VariantCollection<Int>.self, name: "integers")
            ],
            function: SomeNode._mproxy_square
        )
    } ()
}