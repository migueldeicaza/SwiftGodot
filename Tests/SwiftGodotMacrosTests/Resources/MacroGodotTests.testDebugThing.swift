
class DebugThing: SwiftGodot.Object {
    @Signal var livesChanged: SignalWithArguments<Swift.Int>
    func do_thing(value: SwiftGodot.Variant?) -> SwiftGodot.Variant? {
        return nil
    }

    func _mproxy_do_thing(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: SwiftGodot.Variant?.self, at: 0)
            return SwiftGodot._macroCallableToVariant(do_thing(value: arg0))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `do_thing`: \(error)")
            return nil
        }
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
                name: StringName("do_thing"),
                flags: .default,
                returnValue: _macroGodotGetCallablePropInfo(SwiftGodot.Variant?.self),
                arguments: [_macroGodotGetCallablePropInfo(SwiftGodot.Variant?.self, name: "value")],
                function: DebugThing._mproxy_do_thing
            )
    } ()
}