import SwiftGodot

@Godot(.tool)
final class SwiftScriptResourceSaver: ResourceFormatSaver {
    override func _recognize(resource: Resource?) -> Bool {
        resource?.isClass("SwiftScript") == true || resource is SwiftScript
    }

    override func _recognizePath(resource: Resource?, path: String) -> Bool {
        path.hasSuffix(".\(swiftLanguageExtension)")
    }

    override func _getRecognizedExtensions(resource: Resource?) -> PackedStringArray {
        if resource is SwiftScript {
            return PackedStringArray([swiftLanguageExtension])
        }
        return PackedStringArray()
    }

    override func _save(resource: Resource?, path: String, flags: UInt32) -> GodotError {
        guard let script = resource as? SwiftScript else {
            return .errInvalidParameter
        }

        guard let file = FileAccess.open(path: path, flags: .writeRead) else {
            return FileAccess.getOpenError()
        }
        defer {
            file.close()
        }

        _ = file.storeString(script.sourceCode)
        file.flush()
        let err = file.getError()
        if err != .ok && err != .errFileEof {
            return .errCantCreate
        }
        return .ok
    }
}
