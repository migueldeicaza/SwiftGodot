@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime
import SwiftGodotCore

/// Adds the type described by `name` as an Editor plugin.
///
/// You typically invoke this method from the `setupScene` method when initializing
/// the `.editor` level.   The type specified must subclass `EditorPlugin` and
/// should have been declared with `@Godot(.tool)`.
public func editorAddPlugin(name: StringName) {
    withUnsafeMutablePointer(to: &name.content) { namePtr in
        gi.editor_add_plugin(namePtr)
    }
}

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
