
private class TestNode: Node {
    func foo(variant: Variant?) -> Variant? {
        return variant
    }

    func _mproxy_foo(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Variant?.self, at: 0)
            return SwiftGodot._wrapCallableResult(foo(variant: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `foo`: \(error.description)")
        }

        return nil
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("TestNode")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<TestNode> (name: className)
        classInfo.registerMethod(
            name: "foo",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Variant?.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Variant?.self, name: "variant")
            ],
            function: TestNode._mproxy_foo
        )
    } ()
}