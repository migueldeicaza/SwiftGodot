import SwiftGodot

private func updateSwiftLanguageRegistration(level: ExtensionInitializationLevel, isInit: Bool) {
    print("SwiftGodotLanguage init hook: level=\(level) init=\(isInit)")
    switch level {
    case .scene:
        if isInit {
            let language = SwiftScriptLanguage()
            swiftLanguageInstance = language
            let result = Engine.registerScriptLanguage(language)
            if result != GodotError.ok {
                GD.printErr("Swift language registration failed: \(result)")
            }
            let overrides = SwiftScript.implementedOverrides().map { $0.description }.joined(separator: ", ")
            print("SwiftScript overrides: \(overrides)")
        } else {
            if let language = swiftLanguageInstance {
                let result = Engine.unregisterScriptLanguage(language)
                if result != GodotError.ok {
                    GD.printErr("Swift language unregistration failed: \(result)")
                }
            }
            swiftLanguageInstance = nil
        }
    case .editor:
        if isInit {
            let saverClassName = StringName(String(describing: SwiftScriptResourceSaver.self))
            let saverRegistered = ClassDB.classExists(class: saverClassName)
            print("SwiftGodotLanguage: saver class exists before register? \(saverRegistered)")
            if !saverRegistered {
                register(type: SwiftScriptResourceSaver.self)
            }
            let saver = SwiftScriptResourceSaver()
            swiftScriptSaver = saver
            ResourceSaver.addResourceFormatSaver(saver)
            let extensions = ResourceSaver.getRecognizedExtensions(type: SwiftScript())
            print("SwiftGodotLanguage: saver extensions for SwiftScript: \(extensions)")
            print("SwiftGodotLanguage: registered SwiftScriptResourceSaver")
        } else {
            if let saver = swiftScriptSaver {
                ResourceSaver.removeResourceFormatSaver(saver)
                print("SwiftGodotLanguage: unregistered SwiftScriptResourceSaver")
            }
            swiftScriptSaver = nil
        }
    default:
        break
    }
}

#initSwiftExtension(
    cdecl: "swift_language_entry_point",
    editorTypes: [SwiftScriptResourceSaver.self],
    sceneTypes: [SwiftScriptLanguage.self, SwiftScript.self],
    hookMethod: updateSwiftLanguageRegistration
)
