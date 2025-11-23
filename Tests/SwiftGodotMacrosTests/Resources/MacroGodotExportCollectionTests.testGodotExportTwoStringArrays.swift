import SwiftGodot
class ArrayTest: Node {
   var firstNames: TypedArray<String> = ["Thelonius"]

   static func _mproxy_set_firstNames(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
       guard let object = _unwrap(self, pInstance: pInstance) else {
           SwiftGodot.GD.printErr("Error calling setter for firstNames: failed to unwrap instance \(String(describing: pInstance))")
           return nil
       }

       SwiftGodot._invokeSetter(arguments, "firstNames", object.firstNames) {
           object.firstNames = $0
       }
       return nil
   }

   static func _mproxy_get_firstNames(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
       guard let object = _unwrap(self, pInstance: pInstance) else {
           SwiftGodot.GD.printErr("Error calling getter for firstNames: failed to unwrap instance \(String(describing: pInstance))")
           return nil
       }

       return SwiftGodot._invokeGetter(object.firstNames)
   }
   var lastNames: TypedArray<String> = ["Monk"]

   static func _mproxy_set_lastNames(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
       guard let object = _unwrap(self, pInstance: pInstance) else {
           SwiftGodot.GD.printErr("Error calling setter for lastNames: failed to unwrap instance \(String(describing: pInstance))")
           return nil
       }

       SwiftGodot._invokeSetter(arguments, "lastNames", object.lastNames) {
           object.lastNames = $0
       }
       return nil
   }

   static func _mproxy_get_lastNames(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
       guard let object = _unwrap(self, pInstance: pInstance) else {
           SwiftGodot.GD.printErr("Error calling getter for lastNames: failed to unwrap instance \(String(describing: pInstance))")
           return nil
       }

       return SwiftGodot._invokeGetter(object.lastNames)
   }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("ArrayTest")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \ArrayTest.firstNames,
                name: "first_names",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_first_names",
            setterName: "set_first_names",
            getterFunction: ArrayTest._mproxy_get_firstNames,
            setterFunction: ArrayTest._mproxy_set_firstNames
        )
        SwiftGodot._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodot._propInfo(
                at: \ArrayTest.lastNames,
                name: "last_names",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_last_names",
            setterName: "set_last_names",
            getterFunction: ArrayTest._mproxy_get_lastNames,
            setterFunction: ArrayTest._mproxy_set_lastNames
        )
    }()
}