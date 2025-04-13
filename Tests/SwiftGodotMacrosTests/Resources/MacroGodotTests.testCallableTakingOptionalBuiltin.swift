class MyThing: SwiftGodot.RefCounted {

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("MyThing")
        assert(ClassDB.classExists(class: className))
    } ()

}

class OtherThing: SwiftGodot.Node {
    func do_string(value: String?) { }

    func _mproxy_do_string(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: String?.self, at: 0)
            return SwiftGodot._wrapCallableResult(do_string(value: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `do_string`: \(error.description)")
        }

        return nil
    }

    func do_int(value: Int?) {  }

    func _mproxy_do_int(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Int?.self, at: 0)
            return SwiftGodot._wrapCallableResult(do_int(value: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `do_int`: \(error.description)")
        }

        return nil
    }

    func get_thing() -> MyThing? {
        return nil
    }

    func _mproxy_get_thing(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        return SwiftGodot._wrapCallableResult(get_thing())

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("OtherThing")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<OtherThing> (name: className)
        classInfo.registerMethod(
            name: "do_string",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(String?.self, name: "value")
            ],
            function: OtherThing._mproxy_do_string
        )
        classInfo.registerMethod(
            name: "do_int",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Int?.self, name: "value")
            ],
            function: OtherThing._mproxy_do_int
        )
        classInfo.registerMethod(
            name: "get_thing",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(MyThing?.self),
            arguments: [

            ],
            function: OtherThing._mproxy_get_thing
        )
    } ()
}