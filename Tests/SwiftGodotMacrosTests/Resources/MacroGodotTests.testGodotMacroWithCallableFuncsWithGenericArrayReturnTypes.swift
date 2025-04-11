
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
        let classInfo = ClassInfo<CallableCollectionsNode> (name: className)
        classInfo.registerMethod(
            name: StringName("get_ages"),
            flags: .default,
            returnValue: _macroGodotGetCallablePropInfo(Array<Int>.self),
            arguments: [],
            function: CallableCollectionsNode._mproxy_get_ages
        )
        classInfo.registerMethod(
                name: StringName("get_markers"),
                flags: .default,
                returnValue: _macroGodotGetCallablePropInfo(Array<Marker3D>.self),
                arguments: [],
                function: CallableCollectionsNode._mproxy_get_markers
            )
    } ()
}