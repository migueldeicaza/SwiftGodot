
class SomeNode: Node {
    func square(_ integers: VariantCollection<Int>) -> VariantCollection<Int> {
        integers.map { $0 * $0 }.reduce(into: VariantCollection<Int>()) { $0.append(value: $1) }
    }

    func _mproxy_square(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: VariantCollection<Int>.self, at: 0)
            return SwiftGodot._macroCallableToVariant(square(arg0))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `square`: \(error)")
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
            name: StringName("square"),
            flags: .default,
            returnValue: _macroGodotGetCallablePropInfo(VariantCollection<Int>.self),
            arguments: [_macroGodotGetCallablePropInfo(VariantCollection<Int>.self, name: "integers")],
            function: SomeNode._mproxy_square
        )
    } ()
}