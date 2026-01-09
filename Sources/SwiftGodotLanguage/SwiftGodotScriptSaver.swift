import SwiftGodot

@Godot(.tool)
final class SwiftScriptResourceSaver: ResourceFormatSaver {
    override func _recognize(resource: Resource?) -> Bool {
        let className = resource?.godotClassName.description ?? "<nil>"
        let recognized = resource?.isClass("SwiftScript") == true || resource is SwiftScript
        print("SwiftGodotLanguage saver recognize: resource=\(String(describing: resource)) class=\(className) recognized=\(recognized)")
        return recognized
    }

    override func _recognizePath(resource: Resource?, path: String) -> Bool {
        let recognized = path.hasSuffix(".\(swiftLanguageExtension)")
        print("SwiftGodotLanguage saver recognizePath: path=\(path) recognized=\(recognized)")
        return recognized
    }

    override func _getRecognizedExtensions(resource: Resource?) -> PackedStringArray {
        if resource is SwiftScript {
            return PackedStringArray([swiftLanguageExtension])
        }
        return PackedStringArray()
    }

    override func _save(resource: Resource?, path: String, flags: UInt32) -> GodotError {
        print("SwiftGodotLanguage saver save: resource=\(String(describing: resource)) path=\(path)")
        guard let script = resource as? SwiftScript else {
            let className = resource?.godotClassName.description ?? "<nil>"
            print("SwiftGodotLanguage saver save: unexpected resource \(String(describing: resource)) class=\(className)")
            return .errInvalidParameter
        }

        guard let file = FileAccess.open(path: path, flags: .write) else {
            let err = FileAccess.getOpenError()
            print("SwiftGodotLanguage saver save: open failed path=\(path) error=\(err)")
            return err
        }

        _ = file.storeString(script._getSourceCode())
        let err = file.getError()
        if err != .ok && err != .errFileEof {
            print("SwiftGodotLanguage saver save: store failed path=\(path) error=\(err)")
            return .errCantCreate
        }
        return .ok
    }
}
