
class SomeNode: Node {
    func square(_ integers: TypedArray<Int>) -> TypedArray<Int> {
        integers.map { $0 * $0 }.reduce(into: TypedArray<Int>()) { $0.append(value: $1) }
    }

    static func _mproxy_square(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `square`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: TypedArray<Int>.self, at: 0)
            return SwiftGodot._wrapCallableResult(object.square(arg0))

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
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodot._registerMethod(
            className: className,
            name: "square",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(TypedArray<Int>.self),
            arguments: [
                SwiftGodot._argumentPropInfo(TypedArray<Int>.self, name: "integers")
            ],
            function: SomeNode._mproxy_square
        )
    }()
}