
class MultiplierNode: Node {
    func multiply(_ integers: Array<Int>) -> Int {
        integers.reduce(into: 1) { $0 *= $1 }
    }

    func _mproxy_multiply(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Array<Int>.self, at: 0)
            return SwiftGodot._wrapCallableResult(multiply(arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `multiply`: \(error.description)")
        }

        return nil
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("MultiplierNode")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<MultiplierNode> (name: className)
        classInfo.registerMethod(
            name: "multiply",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Int.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Array<Int>.self, name: "integers")
            ],
            function: MultiplierNode._mproxy_multiply
        )
    } ()
}