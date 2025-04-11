import SwiftGodot
class ArrayTest: Node {
   var firstNames: VariantCollection<String> = ["Thelonius"]

   func _mproxy_set_firstNames(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
       SwiftGodot._macroExportSet(args, "firstNames", firstNames) {
           firstNames = $0
       }
   }

   func _mproxy_get_firstNames(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
       SwiftGodot._macroExportGet(firstNames)
   }
   var lastNames: VariantCollection<String> = ["Monk"]

   func _mproxy_set_lastNames(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
       SwiftGodot._macroExportSet(args, "lastNames", lastNames) {
           lastNames = $0
       }
   }

   func _mproxy_get_lastNames(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
       SwiftGodot._macroExportGet(lastNames)
   }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("ArrayTest")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<ArrayTest> (name: className)
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetVariablePropInfo(
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
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._macroGodotGetVariablePropInfo(
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
    } ()
}