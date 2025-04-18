
class Demo: Node3D {
    @Signal var burp: SimpleSignal

    @Signal var livesChanged: SignalWithArguments<Int>

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Demo")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Demo> (name: className)
        SimpleSignal.register("burp", info: classInfo)
        SignalWithArguments<Int>.register("lives_changed", info: classInfo)
    } ()
}
