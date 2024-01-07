# ``SwiftGodot``

Framework to write Godot Game Extensions using the Swift Programming Language.

SwiftGodot provides a binding that allows developers to use the Swift language
to author code in Swift that can be used in a game (these are called "GD
Extension"), and can also be used to drive Godot directly from Swift (the
companion library "SwiftGodotKit" provides a simple interface to embed and host
Godot into an existing application).

The benefit is using a safe, high-performance language, along with its ecosystem
of libraries with your Godot game.   And it runs side-by-side with GDScript or
your existing C# code.

SwiftGodot works by supporting the public extension API from Godot and mapping
that API to Swift idioms.   If you are familiar with Godot and the GDScript
language, you can read the <doc:Differences> document to get a taste on how
things are done in this binding.

## Topics

### Developing with SwiftGodot

Guides to get you started with SwiftGodot, and work in either Xcode on Mac or
Visual Studio on Linux, Mac and Windows:

- <doc:SwiftGodot-Tutorials>
- <doc:DebugInXcode>
- <doc:WorkingInVsCode>

### Articles and Tutorials

Going in depth with SwiftGodot:

- <doc:Differences>
- <doc:Variants>
- <doc:Exports>
- <doc:Signals>
- <doc:CustomTypes>
- <doc:BindingNodes>


### Godot Nodes

Some interesting Godot types:

- ``Node``
  - ``Viewport``
    - ``Window``
    - ``SubViewport``
  - ``CanvasItem``
    - ``Node2D``
    - ``Control``
  - ``Node3D``
  - ``AnimationPlayer``
  - ``AnimationTree``
  - ``AudioStreamPlayer``
  - ``CanvasLayer``
  - ``HTTPRequest``
  - ``MultiplayerSpawner``
  - ``MultiplayerSynchronizer``
  - ``NavigationAgent2D``
  - ``NavigationAgent3D``
  - ``NavigationObstacle2D``
  - ``NavigationObstacle3D``
  - ``ResourcePreloader``
  - ``ShaderGlobalsOverride``
  - ``SkeletonIK3D``
  - ``Timer``
  - ``WorldEnvironment``
