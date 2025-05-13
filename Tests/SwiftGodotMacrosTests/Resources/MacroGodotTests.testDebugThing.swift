
class DebugThing: SwiftGodot.Object {
    var livesChanged: SignalWithArguments<Swift.Int> {
        get {
            SignalWithArguments<Swift.Int>(target: self, signalName: "lives_changed")
        }
    }
    func do_thing(value: SwiftGodot.Variant?) -> SwiftGodot.Variant? {
        return nil
    }

    static func _mproxy_do_thing(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `do_thing`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: SwiftGodot.Variant?.self, at: 0)
            return SwiftGodot._wrapCallableResult(object.do_thing(value: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `do_thing`: \(error.description)")
        }

        return nil
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("DebugThing")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SignalWithArguments<Swift.Int>.register(as: "lives_changed", in: className)
        SwiftGodot._registerMethod(
            className: className,
            name: "do_thing",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(SwiftGodot.Variant?.self),
            arguments: [
                SwiftGodot._argumentPropInfo(SwiftGodot.Variant?.self, name: "value")
            ],
            function: DebugThing._mproxy_do_thing
        )
    }()
}