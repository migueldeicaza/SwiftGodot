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
        let _pfirstNames = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \ArrayTest.firstNames,
            name: "first_names",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        let classInfo = ClassInfo<ArrayTest> (name: className)
        classInfo.registerMethod (name: "get_first_names", flags: .default, returnValue: _pfirstNames, arguments: [], function: ArrayTest._mproxy_get_firstNames)
        classInfo.registerMethod (name: "set_first_names", flags: .default, returnValue: nil, arguments: [_pfirstNames], function: ArrayTest._mproxy_set_firstNames)
        classInfo.registerProperty (_pfirstNames, getter: "get_first_names", setter: "set_first_names")
        let _plastNames = SwiftGodot._macroGodotGetVariablePropInfo(
            at: \ArrayTest.lastNames,
            name: "last_names",
            userHint: nil,
            userHintStr: nil,
            userUsage: nil
        )
        classInfo.registerMethod (name: "get_last_names", flags: .default, returnValue: _plastNames, arguments: [], function: ArrayTest._mproxy_get_lastNames)
        classInfo.registerMethod (name: "set_last_names", flags: .default, returnValue: nil, arguments: [_plastNames], function: ArrayTest._mproxy_set_lastNames)
        classInfo.registerProperty (_plastNames, getter: "get_last_names", setter: "set_last_names")
    } ()
}