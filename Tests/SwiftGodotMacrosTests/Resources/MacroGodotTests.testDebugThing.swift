
class DebugThing: SwiftGodot.Object {
    @Signal var livesChanged: SignalWithArguments<Swift.Int>
    func do_thing(value: SwiftGodot.Variant?) -> SwiftGodot.Variant? {
        return nil
    }

    func _mproxy_do_thing(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: SwiftGodot.Variant?.self, at: 0)
            return SwiftGodot._wrapCallableResult(do_thing(value: arg0))

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
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<DebugThing> (name: className)
        SignalWithArguments<Swift.Int>.register("lives_changed", info: classInfo)
        classInfo.registerMethod(
            name: "do_thing",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(SwiftGodot.Variant?.self),
            arguments: [
                SwiftGodot._argumentPropInfo(SwiftGodot.Variant?.self, name: "value")
            ],
            function: DebugThing._mproxy_do_thing
        )
    } ()
}