
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

    func _mproxy_set_data(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "data", &data)
        return nil
    }

    func _mproxy_get_data (args: borrowing Arguments) -> Variant? {
        _macroExportGet(data)
    }

    override public class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("MyClass")
        assert(ClassDB.classExists(class: className))
        let _pdata = PropInfo (
            propertyType: .object,
            propertyName: "data",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        let classInfo = ClassInfo<MyClass> (name: className)
        classInfo.registerMethod (name: "_mproxy_get_data", flags: .default, returnValue: _pdata, arguments: [], function: MyClass._mproxy_get_data)
        classInfo.registerMethod (name: "_mproxy_set_data", flags: .default, returnValue: nil, arguments: [_pdata], function: MyClass._mproxy_set_data)
        classInfo.registerProperty (_pdata, getter: "_mproxy_get_data", setter: "_mproxy_set_data")
    } ()
}