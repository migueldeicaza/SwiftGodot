class EnumHost: Node {
    enum IntEnum: Int, CaseIterable {
        case a
        case b
    }
    enum Int64Enum: Int64, CaseIterable {
        case low = -1
        case high = 1
    }
    enum StringEnum: String, CaseIterable {
        case one
        case two
    }
    enum PlainEnum {
        case alpha
        case beta
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: EnumHost.self) else {
            return
        }
        let className = StringName("EnumHost")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerEnumIfPossible(EnumHost.IntEnum.self)
        SwiftGodotRuntime._registerEnumIfPossible(EnumHost.Int64Enum.self)
        SwiftGodotRuntime._registerEnumIfPossible(EnumHost.StringEnum.self)
        SwiftGodotRuntime._registerEnumIfPossible(EnumHost.PlainEnum.self)
    }
}
