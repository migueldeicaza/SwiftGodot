# Swift Autoloads

Declare autoload nodes in your extension entry point. This API is a prototype.
Import `SwiftGodot` to use it.

```swift
import SwiftGodot

@Godot
class GameState: Node {
    @Export var score: Int = 0
}

#initSwiftExtension(
    cdecl: "swift_entry_point",
    types: [Player.self],
    autoloads: [
        .init(name: "GlobalState", type: GameState.self)
    ]
)
```

The macro registers the autoload types. You do not need to include them in
`types`. You can also use `autoloads` with the explicit `sceneTypes` overload.
Autoload types must initialize at the `.scene` level.

After you build the extension, open the Godot project in the editor. The
extension installs an editor plugin. The plugin writes a scene for each
autoload to `res://swiftgodot/autoloads/<Swift-module>/` and adds it to Project
Settings. Keep these generated scenes and the settings in source control.
Open the editor before you run or export a new build that changes autoloads.
For a small test project, use
`godot --headless --editor --quit-after 120 --path <project>`.

Godot creates the nodes before the main scene, in declaration order. The
nodes receive the usual callbacks and remain alive across scene changes.
The editor also creates instances when it updates its autoload list.

## Access

From Swift:

```swift
if let state = GameState.autoload(named: "GlobalState") {
    state.score += 10
}
```

The helper returns nil if the node does not exist or has a different type.
It finds the node in the scene tree each time. It does not create an instance.

From GDScript:

```gdscript
GlobalState.score += 10
```

Use names that Godot accepts as autoload identifiers. Names must differ from
registered class names, including the Swift node type's name. The plugin
reports a conflict if an existing autoload points to another scene. It does
not replace that entry.

## Changes and removal

Close the editor before you rebuild the extension. Reopen it after the build.
Hot reload is not supported by this prototype. Godot keeps editor instances
of autoload nodes, so their cleanup needs more work before hot reload is safe.

Remove an entry from `autoloads` and reopen the editor to remove its setting.
The plugin removes only entries that still point to its generated scenes.
It also removes unused scene files that still have the generated file marker.

To remove all entries, keep `autoloads: []`, rebuild, and reopen the editor.
After this step, you can remove the argument or the extension. If you remove
the argument or extension first, the saved autoload settings remain.
