class Hi: Node {
    var one: String = "one", two: Int = 20, three: Int = 50 

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Hi")
        assert(ClassDB.classExists(class: className))
        let _pone = PropInfo (
            propertyType: .int,
            propertyName: "one",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        let classInfo = ClassInfo<Hi> (name: className)
        classInfo.registerMethod (name: "_mproxy_get_one", flags: .default, returnValue: _pone, arguments: [], function: Hi._mproxy_get_one)
        classInfo.registerMethod (name: "_mproxy_set_one", flags: .default, returnValue: nil, arguments: [_pone], function: Hi._mproxy_set_one)
        classInfo.registerProperty (_pone, getter: "_mproxy_get_one", setter: "_mproxy_set_one")
        let _ptwo = PropInfo (
            propertyType: .int,
            propertyName: "two",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_two", flags: .default, returnValue: _ptwo, arguments: [], function: Hi._mproxy_get_two)
        classInfo.registerMethod (name: "_mproxy_set_two", flags: .default, returnValue: nil, arguments: [_ptwo], function: Hi._mproxy_set_two)
        classInfo.registerProperty (_ptwo, getter: "_mproxy_get_two", setter: "_mproxy_set_two")
        let _pthree = PropInfo (
            propertyType: .int,
            propertyName: "three",
            className: className,
            hint: .none,
            hintStr: "",
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_three", flags: .default, returnValue: _pthree, arguments: [], function: Hi._mproxy_get_three)
        classInfo.registerMethod (name: "_mproxy_set_three", flags: .default, returnValue: nil, arguments: [_pthree], function: Hi._mproxy_set_three)
        classInfo.registerProperty (_pthree, getter: "_mproxy_get_three", setter: "_mproxy_set_three")
    } ()
}