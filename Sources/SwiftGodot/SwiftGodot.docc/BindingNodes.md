# Referencing Nodes from your Scene

You will find yourself referencing nodes from a scene in your code.   In GDScript, that is usually
achieved by using the dollar sign and the name of the object you want to reference.

With SwiftGodot, you can achieve the same behavior by using the ``BindNode`` property wrapper


In your class declaration, use the ``BindNode`` property wrapper like this to reference the nodes
that you created with the Godot Editor:

```swift
@Godot
class Main: Node {
    @BindNode var startTimer: SwiftGodot.Timer
    @BindNode var music: AudioStreamPlayer
    @BindNode var mobTimer: SwiftGodot.Timer

    func newGame () {
        startTimer.start ()
    }
}
```
