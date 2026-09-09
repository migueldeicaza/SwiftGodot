class Plugin: EditorPlugin {
    override func _forward3dGuiInput(viewportCamera: Camera3D?, event: InputEvent?) -> Int32 { 0 }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: Plugin.self) else {
            return
        }
        let className = StringName("Plugin")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
    }

    override open class func implementedOverrides () -> [StringName] {
        return super.implementedOverrides () + [
            StringName("_forward_3d_gui_input"),
        ]
    }
}
