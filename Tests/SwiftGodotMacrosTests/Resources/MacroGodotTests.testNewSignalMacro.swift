class Demo: Node3D {
    var burp: SimpleSignal {
        get {
            SimpleSignal(target: self, signalName: SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("burp"))
        }
    }

    var livesChanged: SignalWithArguments<Int> {
        get {
            SignalWithArguments<Int>(target: self, signalName: SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("livesChanged"))
        }
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: Demo.self) else {
            return
        }
        let className = StringName("Demo")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SimpleSignal.register(as: StringName(SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("burp")), in: className, names: [])
        SignalWithArguments<Int>.register(as: StringName(SwiftGodotRuntime._convertMemberNameToMatchGodotConvention("livesChanged")), in: className, names: [])
    }
}
