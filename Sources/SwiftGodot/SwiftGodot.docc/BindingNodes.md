# Referencing Nodes from your Scene

You will find yourself referencing nodes from a scene in your code. In
GDScript, that is usually achieved by using the dollar sign and the name of the
object you want to reference.

With SwiftGodot, you can achieve the same behavior by using the
``@Node`` macro to define a property.

The macro takes a single parameter, which is the path to the node in your
scene that you want to reference:

```swift
@Godot
class Main: Node {
    @Node("CharacterBody2D") var player: PlayerController?
    @Node("locations/spawnpoint") var spawnpoint: Node2D?
    @Node("Telepoint") var teleportArea: Area2D
}
```

When you access the property, the node is looked up, using the specified path.

### Implicit Path

You can also omit the path - in which case the name of the property
is also assumed to be the path to the node.

```swift
@Godot
class Main: Node {
    @Node var myNode: Node2D? // this is the eqivalent of @Node("myNode")...
}
```

### Missing Nodes

Node lookup happens at runtime, when you access the property, and it's possible that the node won't be found.

This could happen because the path is wrong, or the node has been removed from the scene. 
It is also possible that a node is found, but it's the wrong type.

What happens in this situation depends on whether you defined the associated
property as an optional type.

If a property is defined as optional (eg `player` or `spawnpoint` in the above
example), then the property value will simply be `nil`.

However, it is also possible to define a non-optional property (eg `teleportArea`
in the above example). In this situation, accessing the property will cause
a fatal runtime error if the associated node can't be found.

Which style you use is largely a matter of personal preference. 

The optional style produces more resilient code that can keep running as you
modify your scenes, but requires you to unwrap the optional property every
time you use it.

Using the non-optional style is equivalent to asserting that the node must
be present, and that it's a coding error if it isn't. If you know that your
node is loaded as part of a scene file and will never be missing, you may
prefer this style, which results in more compact code.