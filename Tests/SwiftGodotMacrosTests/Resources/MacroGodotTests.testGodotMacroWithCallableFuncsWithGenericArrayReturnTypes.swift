
class CallableCollectionsNode: Node {
    func get_ages() -> Array<Int> {
        [1, 2, 3, 4]
    }

    func _mproxy_get_ages(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        return SwiftGodot._macroCallableToVariant(get_ages())

    }
    func get_markers() -> Array<Marker3D> {
        [.init(), .init(), .init()]
    }

    func _mproxy_get_markers(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        return SwiftGodot._macroCallableToVariant(get_markers())

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("CallableCollectionsNode")
        assert(ClassDB.classExists(class: className))
        let prop_0 = PropInfo (propertyType: .array, propertyName: "", className: StringName("Array[int]"), hint: .arrayType, hintStr: "int", usage: .default)
        let classInfo = ClassInfo<CallableCollectionsNode> (name: className)
        classInfo.registerMethod(name: StringName("get_ages"), flags: .default, returnValue: prop_0, arguments: [], function: CallableCollectionsNode._mproxy_get_ages)
        let prop_1 = PropInfo (propertyType: .array, propertyName: "", className: StringName("Array[Marker3D]"), hint: .arrayType, hintStr: "Marker3D", usage: .default)
        classInfo.registerMethod(name: StringName("get_markers"), flags: .default, returnValue: prop_1, arguments: [], function: CallableCollectionsNode._mproxy_get_markers)
    } ()
}