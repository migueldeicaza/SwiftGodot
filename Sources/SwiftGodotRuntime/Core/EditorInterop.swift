//
//  EditorInterop.swift
//  SwiftGodot
//
//  Created by Miguel de Icaza on 12/12/25.
//
#if os(macOS)
// We avoid Foundation on non-APple platforms to reduce the dependencies,
// but on MacOS, we can bring it.
import Foundation
#endif

public class EditorInterop {
    //  Gets the path to the current GDExtension library.
    public static func getLibraryPath() -> String? {
        let res = GString()
        gi.get_library_path(extensionInterface.getLibrary(), &res.content)
        return GString.stringFromGStringPtr(ptr: &res.content)
    }

    /// Adds the Godot XML documentation to the editor at runtime
    public static func loadHelp(xmlString: String) {
        GD.print("Loading from \(getLibraryPath())")
        if #available(iOS 26.0, macOS 26.0, *) {
            let span = xmlString.utf8Span
            span.span.withUnsafeBytes { buffer in
                // Bind to CChar (Int8) because the imported symbol expects CChar*
                let ptr = buffer.bindMemory(to: CChar.self)
                gi.editor_help_load_xml_from_utf8_chars_and_len(ptr.baseAddress, Int64(span.count))
            }
        } else {
            // Use raw UTF-8 bytes (no extra trailing null), then bind to CChar
            let bytes = Array(xmlString.utf8)
            bytes.withUnsafeBufferPointer { buffer in
                guard let base = buffer.baseAddress else { return }
                let ptr = UnsafeRawPointer(base).bindMemory(to: CChar.self, capacity: buffer.count)
                gi.editor_help_load_xml_from_utf8_chars_and_len(ptr, Int64(buffer.count))
            }
        }
    }

    /// Adds the Godot XML documentation to the editor at runtime
    public static func loadHelp(buffer: [UInt8]) {
        buffer.withUnsafeBufferPointer { buffer in
            guard let base = buffer.baseAddress else { return }
            // Bind to CChar (Int8) for the imported function
            let ptr = UnsafeRawPointer(base).bindMemory(to: CChar.self, capacity: buffer.count)
            gi.editor_help_load_xml_from_utf8_chars_and_len(ptr, Int64(buffer.count))
        }
    }

#if os(macOS)
    /// Adds the Godot XML documentation to the editor at runtime
    static func loadHelp(fromData data: Data) {
        data.withUnsafeBytes { ptr in
            gi.editor_help_load_xml_from_utf8_chars_and_len(ptr, Int64(data.count))
        }
    }
#endif

    public static func loadLibraryDocs() {
        guard let basePath = getLibraryPath() else {
            return
        }
#if os(macOS)
        let url = URL(fileURLWithPath: basePath)
        let parent = url.deletingLastPathComponent()
        let docs = parent.appending(components: "Resources", "doc_classes")
        if let contents = try? FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil) {
            for file in contents {
                guard file.path().hasSuffix(".xml") else {
                    continue
                }
                if let contents = try? Data(contentsOf: file) {
                    loadHelp(fromData: contents)
                }
            }
        }
#else
        // MacOS has .frameworks that are convenient ways of distributing this, but
        // Windows and Linux do not, not sure what would be a good place to load
        // the docs from.
#endif
    }
}
