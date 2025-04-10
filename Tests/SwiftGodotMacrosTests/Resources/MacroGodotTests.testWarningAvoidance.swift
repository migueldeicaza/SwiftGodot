
final class MyData: Resource {

    override public class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("MyData")
        assert(ClassDB.classExists(class: className))
    } ()
}
final class MyClass: Node {
    var data: MyData = .init()

    func _mproxy_set_data(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "data", data) {
            data = $0
        }
    }

    func _mproxy_get_data(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(data)
    }

    override public class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("MyClass")
        assert(ClassDB.classExists(class: className))
        let _pdata = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \MyClass.data,
            name: "data",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        let classInfo = ClassInfo<MyClass> (name: className)
        classInfo.registerMethod (name: "get_data", flags: .default, returnValue: _pdata, arguments: [], function: MyClass._mproxy_get_data)
        classInfo.registerMethod (name: "set_data", flags: .default, returnValue: nil, arguments: [_pdata], function: MyClass._mproxy_set_data)
        classInfo.registerProperty (_pdata, getter: "get_data", setter: "set_data")
    } ()
}