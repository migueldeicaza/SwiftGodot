
class Demo: Node3D {
    var burp: SimpleSignal {
        get {
            SimpleSignal(target: self, signalName: "burp")
        }
    }

    var livesChanged: SignalWithArguments<Int> {
        get {
            SignalWithArguments<Int>(target: self, signalName: "lives_changed")
        }
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Demo")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Demo> (name: className)
        SimpleSignal.register(as: "burp", in: className)
        SignalWithArguments<Int>.register(as: "lives_changed", in: className)
    } ()
}
