// like this
class TestClass: Node {     
    /* comment *//* comment */ var/* comment */ signal/* comment */: /* comment */ SimpleSignal // Comment {
        get {
            SimpleSignal(target: self, signalName: "signal")
        }
    }
    /* comment */
    public func /* comment */foo/* comment */(
        /* can do that too -> */var /* comment */lala: Int // COMMENT            
    ) -> /* comment */ Int // COMMENT
    {
        0
    }            

    static func _mproxy_foo(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `foo`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Int.self, at: 0)
            return SwiftGodot._wrapCallableResult(object.foo(var: arg0))

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
        let className = StringName("TestClass")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SimpleSignal.register(as: "signal", in: className)
        SwiftGodot._registerMethod(
            className: className,
            name: "foo",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Int.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Int.self, name: "lala")
            ],
            function: TestClass._mproxy_foo
        )
    }()
}