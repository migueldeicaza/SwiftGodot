# Concurrency

Running Swift `async` code on Godot's main thread, waiting across frames, and tying tasks
to a node's lifetime.

## Overview

Godot's scene tree may only be touched from its main thread. Swift concurrency runs code
on actors, so async code that touches Godot needs an actor whose executor *is* Godot's
main thread. That actor is ``GodotMainActor``.

### Why not MainActor

`MainActor` runs on the process's main dispatch queue. On macOS Godot's main thread
services that queue while it pumps AppKit events, so `@MainActor` code happens to run on
the right thread. On Linux and Windows it does not: `MainActor` jobs run on a different
thread, racing the engine. Code that works on a Mac becomes an intermittent crash
elsewhere. Even on macOS this it's relying on an implementation detail that's a coincidence.

``GodotMainActor`` behaves the same everywhere. Its jobs run on Godot's main thread at the
start of each frame, from `SceneTree`'s `process_frame` signal, before any node's
`_process`. Nothing needs to be set up.

```swift
@Callable
func openDoor() {
    Task { @GodotMainActor in
        try await door.animationFinished.emitted
        door.collision.disabled = true
    }
}
```

Annotate functions and types with `@GodotMainActor` as you would with `@MainActor`. From
synchronous code that Godot calls on its main thread, such as `_process` or a signal
callback, `GodotMainActor.assumeIsolated { ... }` calls isolated code directly.

### Waiting for frames

``GodotFrames`` provides the waits that GDScript writes as
`await get_tree().process_frame` or `await get_tree().create_timer(t).timeout`:

```swift
let frames = GodotFrames()
try await frames.next()                         // the next frame
try await frames.wait(frames: 10)
try await frames.wait(seconds: 0.5)             // process time, scaled by Engine.timeScale
try await frames.waitUntil { player.isOnFloor() }
```

A wait resumes at the start of the frame before any node's normal processing. Code after it
sees the same state that frame's `_process` will.

### Tasks that follow a node

A node's coroutine-style logic usually shouldn't outlive the node, or advance while it is
paused. ``GodotTasks`` runs named tasks for an owner node:

```swift
@Godot
class Door: Node3D {
    lazy var tasks = GodotTasks(owner: self)

    @Callable
    func open() {
        tasks.run("Open") { frames in
            animation.play("open")
            try await frames.wait(for: animation.animationFinished)
            try await frames.wait(seconds: 2)
            animation.play("close")
        }
    }
}
```

- A task first runs on the next frame its owner can process.
- Its ``GodotFrames`` waits, including `GodotFrames.wait(for:)`,
  only advance on frames the owner is in the tree and in a mode where it's processing.
- It is cancelled the moment the owner is freed, whatever it is waiting on: another
  object's signal, a script call, or a frame. A cancelled signal await disconnects.
- Running a name that is in use cancels the earlier task. `cancel(_:)`,
  `cancel(where:)` and `cancelAll()` cancel explicitly.

A cancelled task ends at its current wait, which throws `CancellationError`. Other errors
thrown from a task are logged.

### Shutdown

When the engine shuts down every ``GodotTasks`` task and every frame wait is cancelled
and run down. No task is left suspended on, or resumed into, a dying engine.
This uses the main loop callbacks available in Godot 4.5 and later.

### Timing

- Jobs queued for ``GodotMainActor`` from any thread run at the start of the next frame.
- A task waiting on a signal emitted from code already running on ``GodotMainActor`` resumes
  in that same frame. One emitted elsewhere, for example from a `_process`, resumes at
  the start of the next frame. GDScript, by contrast, resumes inside the `emit` call.
- Under a custom `MainLoop` without `process_frame`, jobs run from the main loop's frame
  callback, after `_process`.

## Topics

### Actor

- ``GodotMainActor``

### Waiting and tasks

- ``GodotFrames``
- ``GodotTasks``
