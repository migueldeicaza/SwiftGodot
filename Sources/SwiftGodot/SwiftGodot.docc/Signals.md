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

Objects that emit signals typically do so by using the ``Object/emitSignal(signal:_:)``
function which takes as a parameter the ``StringName`` of the signal as well
as an optional list of additional arguments.   And users can connect to those
signals and direct a method to be invoked when they are raised.

## Using Signals

To connect to a signal, find the signal that you want to connect to in your
type, and then call the connect method on it.

For example, to connect to the ``Node/ready`` signal, you call its connect
method, like this:

```
func setupBot (robot: Node) {
    robot.ready.connect {
        print ("The robot's node is ready")
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
    var readyToken: Object

    func setup () {
        readyToken = robot.ready.connect {
            print ("Ready")
        }
    }

    func teardown () {
        robot.ready.disconnect (readyToken)
    }
}
```

## One-shot signals

One common idiom in Godot code is to wait for a signal to be raised before 
continuing execution.   For example, you might want to wait for a timeout
or an action.

In those cases, you can await the `emitted` property of the generated
signal, like this:

```swift
func waitTimer (scene: SceneTree) async {
    // Creates the timer
    let timer = scene.createTimer (timeSec: 3)

    // Wait until the timer fires
    await timer.timeout.emitted

    print ("Done waiting!")
}
```

If you do not have an async function, you can await your signal with
the following idiom:

```swift
func waitSomething (scene: SceneTree) {
    // Creates a task, but executes on the main actor
    Task { @MainActor in
        await timer.timeout.emitted
        print ("happy on the main thread")
    }    
}
```

## Declaring your own Signals

It is also possible to define your own signals to broadcast them, both
to other Swift component as well as using them in Godot or from the 
Godot Scripting language.

Signals belong to your class, so you need to declare those once per class,
and then every instance of your class can emit them.

This process is currently a little bit more elaborate than consuming them,
but I am hoping that with the upcoming reflection support in Swift, or
with Swift Macros, I can simplify this process.

Signals can have zero or more parameters, and you will need to declare
the parameters that your signal consumes, any potential return values (these
are quite unusual, but the API supports it), and the name of your signal.

### Signals with no parameters

The following example shows how to declare a a signal named `burp` that
is emitted by your code:

```
class Demo: Node3D {
    static burpSignalName = StringName ("burp")

    // This idiom is the equivalent of a class constructor for Swift
    static var initClass: Void = {
        let classInfo = ClassInfo<Demo> (name: "Demo")

        classInfo.registerSignal (burpSignal)
    }()

    // Constructor showing how to initialize the class and declare the signal
    required init () {
        super.init ()
        let _ = Demo.initClass
    }

    // Convenience method to emit the signal
    public func emitBurp () {
        let result = emitSignal (signal: burpSignalName)
    }
}
```

We start by declaring the ``StringName`` for the signal that we are
declaring, in this case `burp`.  Since signals are registered for classes,
we use an idiom to initialize the class once.   This will use ``ClassInfo`` 
to declare our signal, and we register it there.   Since this is a signal
that takes no arguments, merely calling ``ClassInfo/registerSignal(name:arguments:)`` is enough.

The method `emitBurp` shows what you need to do to emit the signal from
your code.

The `result` variable contains a status code that you can inspect.  If there
is a mistake in your declaration, or how you emitted the signal, the
result will describe the reason.

### Signals with parameters

Signals that include parameters require a little bit more of work, both
to declare them and to emit them.

Signals can only carry parameters that can be represented by the Godot
``Variant`` type.   While it can not represent all possible Swift objects,
it can pass all the Godot objects and some core types like integers, floats
and strings around.

To register a signal with parameters, you create an array of ``PropInfo``
elements, one for each parameters of your function.   This information
contains information that is not only used at runtime, but can be shown
to the user in the Godot editor.

The following example shows how to register a signal that passes a 
string argument:

```
static let printerSignal = StringName ("printer")

// This idiom is the equivalent of a class constructor for Swift
static var initClass: Bool = {
    let classInfo = ClassInfo<Demo> (name: "Demo")

    let printArgs = [
        PropInfo(
            propertyType: .string,
            propertyName: StringName ("text"),
            className: "Demo",
            hint: .flags,
            hintStr: "Text",
            usage: .default)
    ]
    classInfo.registerSignal (name: Demo.printerSignal, arguments: printArgs)
    return true
}
```

See the documentation for ``PropInfo`` for more information on the
meaning of the parameters.

Emitting this signal is also a little bit different.   Unlike our previous
example, it is necessary to wrap every argument into a ``Variant`` instance.

This is how we would emit that:

```
func emitPrint (text: String) {
    let result = emitSignal(signal: SpinningCube.printerSignal, Variant (text))
}
```

## Using the low-level Signal framework

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

