class Hi: Node {
    var goodName: String = "Supertop"

    func _mproxy_set_goodName(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "goodName", goodName) {
            goodName = $0
        }
    }

    func _mproxy_get_goodName(args: borrowing Arguments) -> Variant? {
        _macroExportGet(goodName)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Hi")
        assert(ClassDB.classExists(class: className))
        let _pgoodName = PropInfo (
            propertyType: .string,
            propertyName: "goodName",
            className: className,
            hint: .none,
            hintStr: "",
            usage: [.editor, .array])
        let classInfo = ClassInfo<Hi> (name: className)
        classInfo.registerMethod (name: "_mproxy_get_goodName", flags: .default, returnValue: _pgoodName, arguments: [], function: Hi._mproxy_get_goodName)
        classInfo.registerMethod (name: "_mproxy_set_goodName", flags: .default, returnValue: nil, arguments: [_pgoodName], function: Hi._mproxy_set_goodName)
        classInfo.registerProperty (_pgoodName, getter: "_mproxy_get_goodName", setter: "_mproxy_set_goodName")
    } ()
}