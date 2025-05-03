class MyThing: SwiftGodot.RefCounted {

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("MyThing")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
    }()

}

class OtherThing: SwiftGodot.Node {
    func do_string(value: String?) { }

    static func _mproxy_do_string(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `do_string`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: String?.self, at: 0)
            return SwiftGodot._wrapCallableResult(object.do_string(value: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `do_string`: \(error.description)")
        }

        return nil
    }

    func do_int(value: Int?) {  }

    static func _mproxy_do_int(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `do_int`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Int?.self, at: 0)
            return SwiftGodot._wrapCallableResult(object.do_int(value: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `do_int`: \(error.description)")
        }

        return nil
    }

    func get_thing() -> MyThing? {
        return nil
    }

    static func _mproxy_get_thing(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling `get_thing`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodot._wrapCallableResult(object.get_thing())

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("OtherThing")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodot._registerMethod(
            className: className,
            name: "do_string",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(String?.self, name: "value")
            ],
            function: OtherThing._mproxy_do_string
        )
        SwiftGodot._registerMethod(
            className: className,
            name: "do_int",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Int?.self, name: "value")
            ],
            function: OtherThing._mproxy_do_int
        )
        SwiftGodot._registerMethod(
            className: className,
            name: "get_thing",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(MyThing?.self),
            arguments: [

            ],
            function: OtherThing._mproxy_get_thing
        )
    }()
}