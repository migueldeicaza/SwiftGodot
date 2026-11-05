@_cdecl("libchrysalis_entry_point") public func enterExtension(interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
    guard let library, let interface, let `extension` else {
        print ("Error: Not all parameters were initialized.")
        return 0
    }

    let autoloads: [Autoload] = [Autoload(name: "Butterfly", type: ButterflyNode.self)]
    let types: [ExtensionInitializationLevel: [Object.Type]]
    do {
        types = try autoloads.typesForRegistration(adding: [ChrysalisNode.self]).prepareForRegistration()
    } catch {
        GD.printErr("Error during GDExtension initialization: \(error)")
        return 0
    }

    initializeSwiftModule (interface, library, `extension`, initHook: { level in
        types[level]?.forEach(register)
        if level == .scene {

        } else if level == .editor {
            if false {
                EditorInterop.loadLibraryDocs()
            }
            _SwiftGodotAutoloadSupport.SwiftGodotAutoloadPlugin_TestModule.autoloads = autoloads
            SwiftGodotAutoloads.initialize(pluginType: _SwiftGodotAutoloadSupport.SwiftGodotAutoloadPlugin_TestModule.self)
        }

    }, deInitHook: { level in
        if level == .editor {
            SwiftGodotAutoloads.deinitialize(pluginType: _SwiftGodotAutoloadSupport.SwiftGodotAutoloadPlugin_TestModule.self)
        }
        types[level]?.reversed().forEach(unregister)

    }, minimumInitializationLevel: minimumInitializationLevel(for: types))
    return 1
}
enum _SwiftGodotAutoloadSupport {
    @Godot(.tool)
    final class SwiftGodotAutoloadPlugin_TestModule: EditorPlugin {
        static var autoloads: [Autoload] = []

        override func _enterTree() {
            SwiftGodotAutoloads.synchronize(Self.autoloads, owner: "TestModule", plugin: self)
        }
    }
}
