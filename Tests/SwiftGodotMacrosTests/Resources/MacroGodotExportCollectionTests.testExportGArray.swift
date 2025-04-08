
class SomeNode: Node {
    var someArray: GArray = GArray()

    func _mproxy_set_someArray(args: borrowing Arguments) -> Variant? {
        _macroEnsureVariantConvertible(GArray.self)
        GArray._macroExportSetter(args, "someArray", property: &someArray)
        return nil
    }

    func _mproxy_get_someArray (args: borrowing Arguments) -> Variant? {
        _macroEnsureVariantConvertible(GArray.self)
        return someArray.toVariant()
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let _psomeArray = PropInfo (
            propertyType: .array,
            propertyName: "someArray",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerMethod (name: "_mproxy_get_someArray", flags: .default, returnValue: _psomeArray, arguments: [], function: SomeNode._mproxy_get_someArray)
        classInfo.registerMethod (name: "_mproxy_set_someArray", flags: .default, returnValue: nil, arguments: [_psomeArray], function: SomeNode._mproxy_set_someArray)
        classInfo.registerProperty (_psomeArray, getter: "_mproxy_get_someArray", setter: "_mproxy_set_someArray")
    } ()
}