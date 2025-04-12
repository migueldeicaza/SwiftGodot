
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
        let classInfo = ClassInfo<MyClass> (name: className)
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \MyClass.data,
                name: "data",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_data",
            setterName: "set_data",
            getterFunction: MyClass._mproxy_get_data,
            setterFunction: MyClass._mproxy_set_data
        )
    } ()
}
