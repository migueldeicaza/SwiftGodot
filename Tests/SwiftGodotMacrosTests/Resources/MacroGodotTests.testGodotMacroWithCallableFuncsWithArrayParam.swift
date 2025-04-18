
class MultiplierNode: Node {
    func multiply(_ integers: [Int]) -> Int {
        integers.reduce(into: 1) { $0 *= $1 }
    }

    static func _mproxy_multiply(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `multiply`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: [Int].self, at: 0)
            return SwiftGodot._wrapCallableResult(object.multiply(arg0))

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
        SwiftGodot._registerMethod(
            className: className,
            name: "multiply",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Int.self),
            arguments: [
                SwiftGodot._argumentPropInfo([Int].self, name: "integers")
            ],
            function: MultiplierNode._mproxy_multiply
        )
    } ()
}