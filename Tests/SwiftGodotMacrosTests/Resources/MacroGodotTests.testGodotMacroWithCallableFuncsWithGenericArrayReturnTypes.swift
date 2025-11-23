
class CallableCollectionsNode: Node {
    func get_ages() -> Array<Int> {
        [1, 2, 3, 4]
    }

    static func _mproxy_get_ages(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling `get_ages`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodot._wrapCallableResult(object.get_ages())

    }
    func get_markers() -> Array<Marker3D> {
        [.init(), .init(), .init()]
    }

    static func _mproxy_get_markers(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling `get_markers`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodot._wrapCallableResult(object.get_markers())

    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("CallableCollectionsNode")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodot._registerMethod(
            className: className,
            name: "get_ages",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Array<Int>.self),
            arguments: [

            ],
            function: CallableCollectionsNode._mproxy_get_ages
        )
        SwiftGodot._registerMethod(
            className: className,
            name: "get_markers",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Array<Marker3D>.self),
            arguments: [

            ],
            function: CallableCollectionsNode._mproxy_get_markers
        )
    }()
}