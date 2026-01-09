# Engine Singletons

Engine singletons are objects that remain globally accessible throughout the
lifetime of your game. They can be accessed from any code, including GDScript,
by name via `Engine.getSingleton()`.

## Overview

There are two types of singletons to understand:

1. **Built-in Godot Singletons**: These are accessed using static methods on their
   respective classes (see <doc:Differences> for details).
2. **Custom Engine Singletons**: Objects you register with the engine to make
   globally accessible.

This document covers creating and using custom engine singletons.

## Defining a Singleton

A singleton is defined like any other custom type. Use the `@Godot` macro and
derive from `Object` or one of its subclasses:

```swift
@Godot
class MyGameManager: Object {
    static let singletonName = StringName("MyGameManager")

    @Callable
    func saveGame() {
        // Save game logic
    }

    @Callable
    func loadGame() {
        // Load game logic
    }
}
```

> Important: Use `Object` or a manually-managed base class rather than
> `RefCounted`. Reference-counted singletons may be prematurely deallocated
> since nothing holds a strong reference to them after registration.

## Registering a Singleton

Register your singleton during the `.scene` initialization level. This is the
earliest point where it is safe to register singletons:

```swift
func setupScene(level: GDExtension.InitializationLevel) {
    if level == .scene {
        register(type: MyGameManager.self)

        // Register the singleton with the Engine
        Engine.registerSingleton(
            name: MyGameManager.singletonName,
            instance: MyGameManager()
        )
    }
}

@_cdecl("swift_entry_point")
public func swift_entry_point(
    interfacePtr: OpaquePointer?,
    libraryPtr: OpaquePointer?,
    extensionPtr: OpaquePointer?) -> UInt8
{
    guard let interfacePtr, let libraryPtr, let extensionPtr else {
        return 0
    }
    initializeSwiftModule(interfacePtr, libraryPtr, extensionPtr,
                          initHook: setupScene,
                          deInitHook: teardownScene)
    return 1
}
```

## Unregistering a Singleton

Clean up your singleton during deinitialization to prevent memory leaks:

```swift
func teardownScene(level: GDExtension.InitializationLevel) {
    if level == .scene {
        if let singleton = Engine.getSingleton(name: MyGameManager.singletonName) {
            Engine.unregisterSingleton(name: MyGameManager.singletonName)
            singleton.free()
        }
    }
}
```

## Accessing Your Singleton

### From Swift

```swift
if let gameManager = Engine.getSingleton(name: StringName("MyGameManager")) as? MyGameManager {
    gameManager.saveGame()
}
```

### From GDScript

```gdscript
var game_manager = Engine.get_singleton("MyGameManager")
game_manager.save_game()
```

## Node-Derived Singletons

Singletons can derive from `Node`, but they require special handling to function
properly. A `Node`-derived singleton must be added to a scene tree to receive
lifecycle callbacks like `_ready()`, `_enterTree()`, and `_process()`.

### The Main Loop

The `MainLoop` in Godot is always a `SceneTree` and is always present. You can
add your `Node`-derived singleton as a child of the root node:

```swift
if let sceneTree = Engine.getMainLoop() as? SceneTree,
   let root = sceneTree.root {
    root.addChild(node: myNodeSingleton)
}
```

Nodes added to the main loop's root:
- Receive the usual `_ready`, `_enterTree`, `_process` callbacks
- Are **not** removed when loading a new scene
- This is exactly how Godot's "Autoload Singletons" work internally

### Safe Registration of Node Singletons

It is **not** safe to add a node to the scene tree during GDExtension
initialization. Doing so leads to crashes. Instead, use `callDeferred()` to
defer the addition until it is safe:

```swift
@Godot
class MyNodeSingleton: Node {
    static let singletonName = StringName("MyNodeSingleton")

    override func _ready() {
        print("MyNodeSingleton is ready!")
    }

    override func _process(delta: Double) {
        // Called every frame
    }
}

func setupScene(level: GDExtension.InitializationLevel) {
    if level == .scene {
        register(type: MyNodeSingleton.self)

        let singleton = MyNodeSingleton()

        // Register with the Engine so it can be found by name
        Engine.registerSingleton(
            name: MyNodeSingleton.singletonName,
            instance: singleton
        )

        // Defer adding to the scene tree until it is safe
        singleton.callDeferred(method: StringName("_addToSceneTree"))
    }
}
```

Add a callable method to handle the deferred addition:

```swift
@Godot
class MyNodeSingleton: Node {
    static let singletonName = StringName("MyNodeSingleton")

    @Callable
    func _addToSceneTree() {
        if let sceneTree = Engine.getMainLoop() as? SceneTree,
           let root = sceneTree.root {
            root.addChild(node: self)
        }
    }

    override func _ready() {
        print("MyNodeSingleton is ready and in the tree!")
    }
}
```

## Complete Example

Here is a complete example of a Node-derived singleton that tracks game state:

```swift
import SwiftGodot

@Godot
class GameState: Node {
    static let singletonName = StringName("GameState")

    @Export var score: Int = 0
    @Export var lives: Int = 3

    @Signal var scoreChanged: SignalWithArguments<Int>
    @Signal var livesChanged: SignalWithArguments<Int>

    @Callable
    func addScore(points: Int) {
        score += points
        scoreChanged.emit(score)
    }

    @Callable
    func loseLife() {
        lives -= 1
        livesChanged.emit(lives)
        if lives <= 0 {
            gameOver()
        }
    }

    @Callable
    func gameOver() {
        print("Game Over!")
    }

    @Callable
    func _addToSceneTree() {
        if let sceneTree = Engine.getMainLoop() as? SceneTree,
           let root = sceneTree.root {
            root.addChild(node: self)
        }
    }

    override func _ready() {
        print("GameState singleton ready")
    }
}

// Registration
func setupScene(level: GDExtension.InitializationLevel) {
    if level == .scene {
        register(type: GameState.self)

        let gameState = GameState()
        Engine.registerSingleton(name: GameState.singletonName, instance: gameState)
        gameState.callDeferred(method: StringName("_addToSceneTree"))
    }
}

func teardownScene(level: GDExtension.InitializationLevel) {
    if level == .scene {
        if let singleton = Engine.getSingleton(name: GameState.singletonName) {
            Engine.unregisterSingleton(name: GameState.singletonName)
            if let node = singleton as? Node {
                node.queueFree()
            } else {
                singleton.free()
            }
        }
    }
}
```

Usage from GDScript:

```gdscript
func _on_coin_collected():
    var game_state = Engine.get_singleton("GameState")
    game_state.add_score(100)

func _on_player_hit():
    var game_state = Engine.get_singleton("GameState")
    game_state.lose_life()
```

## Key Points

- Register singletons at the `.scene` initialization level
- Use `Object` (not `RefCounted`) as the base class to prevent premature deallocation
- Node-derived singletons must be added to the scene tree to receive lifecycle callbacks
- Use `callDeferred()` to safely add nodes to the tree during initialization
- Nodes in the main loop's root persist across scene changes
- Always unregister and free singletons during deinitialization
