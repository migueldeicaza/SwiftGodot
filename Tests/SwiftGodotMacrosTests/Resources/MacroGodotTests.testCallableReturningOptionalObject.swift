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
            name: "get_thing",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(MyThing?.self),
            arguments: [

            ],
            function: OtherThing._mproxy_get_thing
        )
    } ()
}