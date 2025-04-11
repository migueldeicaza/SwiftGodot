import SwiftGodot
class ArrayTest: Node {
   var firstNames: VariantCollection<String> = ["Thelonius"]

   func _mproxy_set_firstNames(args: borrowing Arguments) -> Variant? {
       _macroExportSet(args, "firstNames", firstNames) {
           firstNames = $0
       }
   }

   func _mproxy_get_firstNames(args: borrowing Arguments) -> Variant? {
       _macroExportGet(firstNames)
   }
   var lastNames: VariantCollection<String> = ["Monk"]

   func _mproxy_set_lastNames(args: borrowing Arguments) -> Variant? {
       _macroExportSet(args, "lastNames", lastNames) {
           lastNames = $0
       }
   }

   func _mproxy_get_lastNames(args: borrowing Arguments) -> Variant? {
       _macroExportGet(lastNames)
   }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("ArrayTest")
        assert(ClassDB.classExists(class: className))
        let _pfirstNames = PropInfo (
            propertyType: .array,
            propertyName: "first_names",
            className: StringName("Array[String]"),
            hint: .arrayType,
            hintStr: "String",
            usage: .default)
        let classInfo = ClassInfo<ArrayTest> (name: className)
        classInfo.registerMethod (name: "get_first_names", flags: .default, returnValue: _pfirstNames, arguments: [], function: ArrayTest._mproxy_get_firstNames)
        classInfo.registerMethod (name: "set_first_names", flags: .default, returnValue: nil, arguments: [_pfirstNames], function: ArrayTest._mproxy_set_firstNames)
        classInfo.registerProperty (_pfirstNames, getter: "get_first_names", setter: "set_first_names")
        let _plastNames = PropInfo (
            propertyType: .array,
            propertyName: "last_names",
            className: StringName("Array[String]"),
            hint: .arrayType,
            hintStr: "String",
            usage: .default)
        classInfo.registerMethod (name: "get_last_names", flags: .default, returnValue: _plastNames, arguments: [], function: ArrayTest._mproxy_get_lastNames)
        classInfo.registerMethod (name: "set_last_names", flags: .default, returnValue: nil, arguments: [_plastNames], function: ArrayTest._mproxy_set_lastNames)
        classInfo.registerProperty (_plastNames, getter: "get_last_names", setter: "set_last_names")
    } ()
}