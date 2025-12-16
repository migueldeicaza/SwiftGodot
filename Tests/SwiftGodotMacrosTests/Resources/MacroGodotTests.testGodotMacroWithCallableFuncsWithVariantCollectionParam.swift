
class SomeNode: Node {
    func square(_ integers: TypedArray<Int>) -> TypedArray<Int> {
        integers.map { $0 * $0 }.reduce(into: TypedArray<Int>()) { $0.append(value: $1) }
    }

    static func _mproxy_square(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `square`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: TypedArray<Int>.self, at: 0)
            return SwiftGodotRuntime._wrapCallableResult(object.square(arg0))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `square`: \(error.description)")
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
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "square",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(TypedArray<Int>.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(TypedArray<Int>.self, name: "integers")
            ],
            function: SomeNode._mproxy_square
        )
    } ()
}
