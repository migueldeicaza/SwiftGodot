# Referencing Nodes from your Scene

You will find yourself referencing nodes from a scene in your code.   In
GDScript, that is usually achieved by using the dollar sign and the name of the
object you want to reference.

With SwiftGodot, you can achieve the same behavior by using the
``SceneTreeMacro`` macro (or if you are not using Macros, the ``BindNode``
property wrapper.    The macro can produce a nil value if the node is not found,
which forces you to check if it succeeded, and will produce more resilient code
as you modify your scenes.

## SceneTree

You typically use the `path` parameter to specify the path to the node in your
scene that you want to reference:

```swift
@Godot
class Main: Node {
    @SceneTree(path: "CharacterBody2D") var player: PlayerController?
    @SceneTree(path: "locations/spawnpoint") var spawnpoint: Node2D?
    @SceneTree(path: "Telepoint") var teleportArea: Area2D?
}
```

## BindNode

BindNode is an older version, but is not as convenient as using the SceneTree
macro.

In your class declaration, use the ``BindNode`` property wrapper like this to
reference the nodes that you created with the Godot Editor:

```swift
@Godot
class Main: Node {
    @BindNode(withPath:"timer") var startTimer: SwiftGodot.Timer
    @BindNode(withPath:"music") var music: AudioStreamPlayer
    @BindNode(withPath:"mobTimer") var mobTimer: SwiftGodot.Timer

    func newGame () {
        startTimer.start ()
    }
}
```

If you omit the `withPath` parameter, depending on your system, the result might
not resolve at runtime.
