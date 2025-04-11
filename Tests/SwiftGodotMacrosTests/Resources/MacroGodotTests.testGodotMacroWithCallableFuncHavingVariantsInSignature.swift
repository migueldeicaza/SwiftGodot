
private class TestNode: Node {
    func foo(variant: Variant?) -> Variant? {
        return variant
    }

    func _mproxy_foo(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Variant?.self, at: 0)
            return SwiftGodot._macroCallableToVariant(foo(variant: arg0))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `foo`: \(error)")
            return nil
        }
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
            name: StringName("foo"),
            flags: .default,
            returnValue: _macroGodotGetCallablePropInfo(Variant? .self),
            arguments: [_macroGodotGetCallablePropInfo(Variant?.self, name: "variant")],
            function: TestNode._mproxy_foo
        )
    } ()
}