enum Demo: Int, CaseIterable {
    case first
}
enum Demo64: Int64, CaseIterable {
    case first
}
class SomeNode: Node {
    var demo: Demo

    func _mproxy_set_demo(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "demo", demo) {
            demo = $0
        }
    }

    func _mproxy_get_demo(args: borrowing Arguments) -> Variant? {
        _macroExportGet(demo)
    }
    var demo64: Demo64

    func _mproxy_set_demo64(args: borrowing Arguments) -> Variant? {
        _macroExportSet(args, "demo64", demo64) {
            demo64 = $0
        }
    }

    func _mproxy_get_demo64(args: borrowing Arguments) -> Variant? {
        _macroExportGet(demo64)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let _pdemo = PropInfo (
            propertyType: .int,
            propertyName: "demo",
            className: className,
            hint: .enum,
            hintStr: tryCase (Demo.self),
            usage: .default)
        let classInfo = ClassInfo<SomeNode> (name: className)
        classInfo.registerMethod (name: "_mproxy_get_demo", flags: .default, returnValue: _pdemo, arguments: [], function: SomeNode._mproxy_get_demo)
        classInfo.registerMethod (name: "_mproxy_set_demo", flags: .default, returnValue: nil, arguments: [_pdemo], function: SomeNode._mproxy_set_demo)
        classInfo.registerProperty (_pdemo, getter: "_mproxy_get_demo", setter: "_mproxy_set_demo")
        let _pdemo64 = PropInfo (
            propertyType: .int,
            propertyName: "demo64",
            className: className,
            hint: .enum,
            hintStr: tryCase (Demo64.self),
            usage: .default)
        classInfo.registerMethod (name: "_mproxy_get_demo64", flags: .default, returnValue: _pdemo64, arguments: [], function: SomeNode._mproxy_get_demo64)
        classInfo.registerMethod (name: "_mproxy_set_demo64", flags: .default, returnValue: nil, arguments: [_pdemo64], function: SomeNode._mproxy_set_demo64)
        classInfo.registerProperty (_pdemo64, getter: "_mproxy_get_demo64", setter: "_mproxy_set_demo64")
        func tryCase <T : RawRepresentable & CaseIterable> (_ type: T.Type) -> GString {
            GString (type.allCases.map { v in
                "\(v):\(v.rawValue)"
            } .joined(separator: ","))
        }
        func tryCase <T : RawRepresentable> (_ type: T.Type) -> String {
            ""
        }
    } ()
}