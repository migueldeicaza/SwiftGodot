# Signals

Signals in Godot are used by objects to post interesting events that are
taking place, and can be used by users to easily add behavior and react
to changes.

## Overview

Objects in Godot can emit signals, these are notification about certain
events taking place in the objects that can be observed externally.  

In SwiftGodot, there is a convenient interface to connect to a signal, as well
as a low-level framework to manually connect to signals and a mechanism to 
define your own signals.

Objects that emit signals typically do so by using the ``Object/emit(signal:)`` 
method (or the lower-level ``Object/emitSignal(signal:_:)``
function) which takes as a parameter the ``StringName`` of the signal as well
as an optional list of additional arguments.   And users can connect to those
signals and direct a method to be invoked when they are raised.

## Using Signals

To connect to a signal, find the signal that you want to connect to in your
type, and then call the connect method on it.

For example, to connect to the ``Node/ready`` signal, you call its connect
method, like this:

```
func setupBot(robot: Node) {
    robot.ready.connect {
        print("The robot's node is ready")
    }
}
```

Since signals in Godot can include parameters, each signal in Godot 
surfaces a connect method that takes as an argument a function with the
precise signature that it will be invoked with.

If you want to stop receiving notifications, you can disconnect from the
object, to do so, you must keep around the token returned by the connect
method, like this:

```swift
class Demo: Node {
    var readyToken: Callable

    func setup() {
        readyToken = robot.ready.connect {
            print("Ready")
        }
    }

    func teardown() {
        robot.ready.disconnect(readyToken)
    }
}
```

## One-shot signals

A common idiom in Godot is to wait for a signal before continuing - a timeout, an
animation finishing, a player action. Await the `emitted` property of the signal:

```swift
func waitTimer(scene: SceneTree) async throws {
    let timer = scene.createTimer(timeSec: 3)

    try await timer.timeout.emitted

    print("Done waiting!")
}
```

The value you get back is the signal's payload. A ``SimpleSignal`` yields `()`, a signal
with one argument yields that argument, and anything else yields a tuple:

```swift
// SignalWithArguments<Int, String>
let (age, name) = try await player.described.emitted
```

If you are not already in an async function, start a task:

```swift
func waitSomething(scene: SceneTree) {
    Task { @MainActor in
        try await timer.timeout.emitted
        GD.print("timer fired")
    }
}
```

### What can be awaited

Three things:

- **A typed signal** - any built-in signal, or one you declared with `@Signal`. This is
  the case above.
- **A ``Signal`` value** - the builtin Variant type, which is what GDScript hands you and
  what ``Signal/init(object:signal:)`` builds. It carries no static type information, so
  its payload is an array of ``Variant``:
  ```swift
  let arguments = try await Signal(object: node, signal: "lives_changed").emitted
  ```
- **A call into a script that suspends.** In GDScript a function containing `await` is a
  coroutine; calling it returns a handle rather than a value. ``Object/callScriptAsync(method:_:)``
  waits for such a call to finish, and passes an ordinary return value straight through:
  ```swift
  let value = try await object.callScriptAsync(method: "slow", tree.toVariant())
  ```

Awaiting anything else is not supported - there is no general "await a Godot call".

### Cancellation, and signals that never fire

Cancelling the awaiting task disconnects from the signal and throws `CancellationError`,
so an abandoned wait releases everything it was holding:

```swift
let task = Task { @MainActor in
    try await enemy.died.emitted
}
task.cancel()   // disconnects; the await throws
```

One hazard remains, and it is worth knowing: **if the object that declares the signal is
destroyed while you are waiting, the await does not resume.** Godot silently drops the
connection with the object, and nothing is left to wake the task. GDScript's own `await`
behaves the same way. When the emitter might not outlive the wait, bound it - with task
cancellation, or with a timeout.

If the object is *already* gone when the await begins, that is detected and reported as
``SignalAwaitError/targetUnavailable`` rather than hanging.

### Which thread resumes

Two separate things are going on here, and it helps to keep them apart.

The first is a Swift guarantee: **execution resumes on the actor you awaited from.** Await
from a `@MainActor` context and the code after the await runs on `MainActor`. Await from a
bare `Task { }` - which is isolated to nothing - and it resumes on the cooperative thread
pool, where you must not touch the scene tree.

The second is a question about the host: **is that actor running on Godot's thread?**
`MainActor` means Swift's main executor, which is the libdispatch main queue. Godot runs
its own event loop, so whether that queue is ever drained depends on the platform. On
macOS the display server spins the run loop, which does drain it - measured, and the
`MainActor` thread is Godot's main thread. On Linux and Windows Godot never touches that
queue, so a `Task { @MainActor in }` may not be scheduled at all.

So: prefer `Task { @MainActor in }`, and confirm it on your target platform before relying
on it. If you need a guarantee across platforms, drive the work from Godot's own message
queue with `Callable(...).callDeferred()`, which is what `MainActor` is standing in for.

## Declaring your own Signals

It is also possible to define your own signals to broadcast them, both
to other Swift component as well as using them in Godot or from the 
Godot Scripting language.

Signals belong to your class, so you need to declare those once per class,
and then every instance of your class can emit them.

Signals can have zero or more parameters, and you will need to declare
the parameters that your signal consumes, any potential return values (these
are quite unusual, but the API supports it), and the name of your signal.

### Signals with no parameters

The following example shows how to declare a a signal named `burp` that
is emitted by your code:

```
@Godot
class Demo: Node3D {
    @Signal var burp: SimpleSignal
}
```

The free-standing macro `@Signal` declares a signal named burp. This macro
will turn signal variable names using the camel-case naming convention into
Godot signals using snake-case.

So for example if you were to declare a signal called 'livesChanged' it
would be exposed to Godot as 'lives_changed', and to your Swift code as
'livesChanged'.

### Signals with parameters

Signals can carry additional information when they are emitted, and
you can pass any type that can be encoded as a Godot Variant to them
(this includes Swift core types like integers, doubles, strings, but
also Godot objects and the Godot core types;   See the documentation
for ``Variant`` for more information).

To use signals with parameters, you need to declare the parameter
types using the generic SignalWithArguments class, specifying the Swift 
type of each parameter.


In the following example we create a signal exposed to godot called
`lives_changed` that takes an integer value, and it is surfaced to 
Swift as the signal 'livesChanged'.

The example below also shows how to emit the signal with the additional
integer payload:

```swift
@Godot 
class Player: Node2D {
    @Signal var livesChanged: SignalWithArguments<Int>

    func startGame() {
        livesChanged.emit(5)
    }
}
```

## Connecting Everything Together

This example shows how you can create a signal and connect to it:

```swift
@Godot 
class Player: Node2D {
    @Signal var gameStarted: SimpleSignal
    @Signal var livesChanged: SignalWithArguments<Int>

    func startGame() {
        // No arguments
        gameStarted.emit()

        // One argument of type int
        livesChanged.emit(5)
    }
}

class Level: Area2D {
    func _ready() { 
        player.gameStarted.connect {
            GD.print("got game started signal!")
        }

        player.livesChanged.connect { newLivesCount in
            print ("New lives: \(newLivesCount)")
        }
    }
}
```

## Low-Level Signal API

This section is here for explanation purposes, but you should not need
to use this in your Godot code with Swift.

### Using the low-level Signal framework

While SwiftGodot provides a convenient way of connecting to objects,
if you need to connect to objects that are not included in the binding
or you want to implement additional semantics, you can always use the
low-level API for connecting signals.

To connect a signal directly, you use the ``Object/connect(signal:callable:flags:)``
method.   The first parameter is the ``StringName`` describing the signal
and the second one is refenrece to the method to invoke.  The ``Callable``
is a pair of the object instance and the ``StringName`` of the method to invoke.

For example:

```
let callable = Callable(object: self, method: StringName ("MyCallback"))
object.connect(signal: "some_signal", callable)
```

This would call a method registered with Godot under the name `MyCallback`
on the provided instance when the `object` raises the `some_signal`.

To surface a Swift method to Godot, and thus be able to reference it with 
a StringName, you would use a similar method to register a signal:

```
func mySwiftCallback () {
   print ("MyCallback has been invoked!")
}

func setup () {
    classInfo.registerMethod(
        name: "MyCallback", 
        flags: .default, 
        returnValue: nil, 
        arguments: [], 
        function: Demo.mySwiftCallback)
}
```

## Emitting Signals

To emit a signal defined with the @Signal macro, you call ``SignalWithArguments/emit()`
on the signal's property. If the signal takes arguments, the emit() method
will accept arguments of the correct types.

You can also use this method to emit built-in signals on a foreign object,
such as the ``ready`` signal on a ``Node`` instance, to pretend the object
triggered that signal.

I will not pass any judgement on this, I merely want to empower you to get the 
job done.
