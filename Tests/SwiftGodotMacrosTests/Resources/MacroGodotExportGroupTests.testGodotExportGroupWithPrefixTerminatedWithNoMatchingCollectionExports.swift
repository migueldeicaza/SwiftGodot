
class Garage: Node {
    var bar: VariantCollection<Bool> = [false]

    func _mproxy_set_bar(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportSet(args, "bar", bar) {
            bar = $0
        }
    }

    func _mproxy_get_bar(args: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        SwiftGodot._macroExportGet(bar)
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Garage")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Garage> (name: className)
        classInfo.addPropertyGroup(name: "Example", prefix: "example")
        classInfo.registerPropertyWithGetterSetter(
            SwiftGodot._propInfo(
                at: \Garage.bar,
                name: "bar",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_bar",
            setterName: "set_bar",
            getterFunction: Garage._mproxy_get_bar,
            setterFunction: Garage._mproxy_set_bar
        )
    } ()
}
