import SwiftGodot

@Godot(.tool)
final class SwiftScriptResourceLoader: ResourceFormatLoader {
    override func _getRecognizedExtensions() -> PackedStringArray {
        PackedStringArray([swiftLanguageExtension])
    }

    override func _recognizePath(_ path: String, type: StringName) -> Bool {
        guard path.lowercased().hasSuffix(".\(swiftLanguageExtension)") else {
            return false
        }
        return _handlesType(type)
    }

    override func _handlesType(_ type: StringName) -> Bool {
        let name = type.description
        return name.isEmpty || name == "Resource" || name == "Script" || name == "SwiftScript"
    }

    override func _getResourceType(path: String) -> String {
        let lowercased = path.lowercased()
        return lowercased.hasSuffix(".\(swiftLanguageExtension)") ? "SwiftScript" : ""
    }

    override func _load(path: String, originalPath: String, useSubThreads: Bool, cacheMode: Int32) -> Variant? {
        guard let file = FileAccess.open(path: path, flags: .read) else {
            let err = FileAccess.getOpenError()
            return Variant(Int64(err.rawValue))
        }
        defer {
            file.close()
        }

        let source = file.getAsText()
        let script = SwiftScript()
        script.updateFromSource(source)
        return Variant(script)
    }
}
