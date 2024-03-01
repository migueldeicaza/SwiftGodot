# Running Code in the Godot Editor

There are cases where you might want some of your Swift code for your extension
to run while it is being used in the Godot Editor.

To achieve this, you can include the `.tool` parameter to the `@Godot` macro,
like this:

```swift
@Godot(.tool)
class Line3D: MeshInstance3D {

    // This will be called in the editor
    override func _ready() {
	// Run some code here
    }

    // And so will this one
    override func _process(delta _: Double) {
	// Check if we are running in the editor, or in the game
        if Engine.isEditorHint() {
            doEditorWork ()
        } else {
	    doGameWork ()
	}
    }
}
```

You can use it for doing many things, but it is mostly useful in level design
for visually presenting things that are hard to predict ourselves. Here are some
use cases: 

* If you have a cannon that shoots cannonballs affected by physics (gravity),
  you  can draw the cannonball's trajectory in the editor, making level design a
  lot easier.

* If you have jumppads with varying jump heights, you can draw the maximum jump
  height a player would reach if it jumped on one, also making level design
  easier. 

* If your player doesn't use a sprite, but draws itself using code, you can 
  make that drawing code execute in the editor to see your player.

> Warning: `.tool` extensions run inside the editor, and let you access the 
  scene tree of the currently edited scene. This is a powerful feature which 
  also comes with caveats, as the editor does not include protections for 
  potential misuse of `@Godot(.tool)` scripts. Be extremely cautious when 
  manipulating the scene tree, especially via ``Node/queueFree``, as it can
  cause crashes if you free a node while the editor runs logic involving it.

# Detecting the Editor

In your code, you can call the ``Engine/isEditorHint()`` to determine whether
the code is running inside the editor or in the game, and adjust your various
methods accordingly.