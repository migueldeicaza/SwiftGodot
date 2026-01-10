import SwiftGodot

private func updateSwiftLanguageRegistration(level: ExtensionInitializationLevel, isInit: Bool) {
    switch level {
    case .scene:
        if isInit {
            let language = SwiftScriptLanguage()
            swiftLanguageInstance = language
            let result = Engine.registerScriptLanguage(language)
            if result != GodotError.ok {
                GD.printErr("Swift language registration failed: \(result)")
            }
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
            if !ClassDB.classExists(class: saverClassName) {
                register(type: SwiftScriptResourceSaver.self)
            }
            let loaderClassName = StringName(String(describing: SwiftScriptResourceLoader.self))
            if !ClassDB.classExists(class: loaderClassName) {
                register(type: SwiftScriptResourceLoader.self)
            }
            let saver = SwiftScriptResourceSaver()
            swiftScriptSaver = saver
            ResourceSaver.addResourceFormatSaver(saver)
            let loader = SwiftScriptResourceLoader()
            swiftScriptLoader = loader
            ResourceLoader.addResourceFormatLoader(loader)
        } else {
            if let saver = swiftScriptSaver {
                ResourceSaver.removeResourceFormatSaver(saver)
            }
            swiftScriptSaver = nil
            if let loader = swiftScriptLoader {
                ResourceLoader.removeResourceFormatLoader(loader)
            }
            swiftScriptLoader = nil
        }
    default:
        break
    }
}

#initSwiftExtension(
    cdecl: "swift_language_entry_point",
    editorTypes: [SwiftScriptResourceSaver.self, SwiftScriptResourceLoader.self],
    sceneTypes: [SwiftScriptLanguage.self, SwiftScript.self],
    hookMethod: updateSwiftLanguageRegistration
)
