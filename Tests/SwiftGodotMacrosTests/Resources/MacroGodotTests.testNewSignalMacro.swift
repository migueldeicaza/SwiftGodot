
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
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SimpleSignal.register(as: "burp", in: className)
        SignalWithArguments<Int>.register(as: "lives_changed", in: className)
    }()
}
