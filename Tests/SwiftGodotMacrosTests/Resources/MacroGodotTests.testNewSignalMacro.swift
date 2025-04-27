
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

    private static let _initializeClass: Void = {
        let className = StringName(takingOver: getActualClassName())
        assert(ClassDB.classExists(class: className))
        SimpleSignal.register(as: "burp", in: className)
        SignalWithArguments<Int>.register(as: "lives_changed", in: className)
    }()

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static func getActualClassName() -> FastStringName {
        FastStringName("Demo")
    }

    open override func getActualClassName() -> FastStringName {
        Self.getActualClassName()
    }
}
