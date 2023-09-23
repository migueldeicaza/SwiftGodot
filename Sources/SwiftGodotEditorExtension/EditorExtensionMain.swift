//
//  EditorExtensionMain.swift
//  
//
//  Created by Miguel de Icaza on 4/7/23.
//

import Foundation
import SwiftGodot

extension PackedStringArray {
    convenience init (_ values: [String]) {
        self.init ()
        for x in values {
            append(value: x)
        }
    }
}

func setupScene (level: GDExtension.InitializationLevel) {
    if level == .editor {
        var e: Engine = Engine.shared
        register(type: SwiftLanguageIntegration.self)
        register(type: SwiftScript.self)
        register(type: SwiftResourceFormatSaver.self)
        register(type: SwiftResourceFormatLoader.self)
        register(type: SwiftEditorPlugin.self)
        
        let f = SwiftResourceFormatSaver()
        ResourceSaver.shared.addResourceFormatSaver(formatSaver: f)
        let l = SwiftResourceFormatLoader ()
        ResourceLoader.shared.addResourceFormatLoader(formatLoader: l, atFront: false)
        
        e.registerScriptLanguage(language: SwiftLanguageIntegration.shared)
        
        if Engine.shared.isEditorHint() {
            SwiftEditorPlugin.registerPlugin ()
        }
    }
}
@_cdecl ("swift_godot_editor_exension_main")
public func swift_entry_point(
    interfacePtr: OpaquePointer?,
    libraryPtr: OpaquePointer?,
    extensionPtr: OpaquePointer?) -> UInt8
{
    print ("SwiftGodotEditorExtension: Starting up")
    guard let interfacePtr, let libraryPtr, let extensionPtr else {
        return 0
    }
    initializeSwiftModule(interfacePtr, libraryPtr, extensionPtr, initHook: setupScene, deInitHook: { x in })
    return 1
}
