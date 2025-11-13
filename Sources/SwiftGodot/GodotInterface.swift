//
//  GodotInterface.swift
//  SwiftGodot
//
//  Created by Miguel de Icaza on 11/13/25.
//
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime

/// Adds the specified type as a Godot Editor Plugin.
///
/// You typically invoke this method from the `setupScene` method when initializing
/// the `.editor` level.   The type specified should have been declared with `@Godot(.tool)`
public func editorAddPlugin<T:EditorPlugin> (type: T.Type) {
    let typeStr = String (describing: type)
    editorAddPlugin(name: StringName(typeStr))
}

/// Removes a Godot editor plugin from the editor by name
public func editorRemovePlugin(name: StringName) {
    withUnsafeMutablePointer(to: &name.content) { namePtr in
        gi.editor_remove_plugin(namePtr)
    }
}

/// Removes a Godot editor plugin.
public func editorRemovePlugin<T:EditorPlugin> (type: T.Type) {
    let typeStr = String (describing: type)
    editorRemovePlugin(name: StringName(typeStr))
}
