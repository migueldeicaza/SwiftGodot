# SwiftGodot API differences to GDScript

This document lists some common differences between GDSscript and SwiftGodot.

## General differences

The SwiftGodot API follows the convention of the Swift platform, and one of the
most notable places where this happens is in the use of camelCase style instead
of the snake_case style used in GDScript.

Enumerations and their values also change, for example, rather than having a
constant value like `CORNER_TOP_LEFT` for the ``Corner`` value, we use
``Corner/topLeft``.

In Swift, function definitions take parameter names, and sometimes this
parameter name is omitted for the first argument. Instead of
`myNode.add_child(box)`, you would use `myNode.addChild (node: box)`.

## Global Scope

Global functions and some constants had to be moved to classes to avoid
polluting the global name space, and you can find them in the ``GD`` class.

## Type Mappings

Godot comes with some of their own data types like strings and dictionaries, but
those types would clash with the existing Swift types with the same names.   

Here is a list of the current data type mappings:

| GDScript type      | SwiftGodot Name       |
|--------------------|-----------------------|
| String             | GString               |
| Dictionary         | VariantDictionary     |
| Dictionary[Element]| TypedDictionary       |
| Array              | VariantArray          |
| Array[Element]     | TypedArray            |


The ``VariantArray`` is a type-erased array that can hold any sort of element that can be managed by Godot.

In addition, there is a strongly-typed version of the
`VariantArray` – ``TypedArray`` that holds specific type.

```swift
let ints = TypedArray<Int>
let objects = TypedArray<Object?>
```

Note that in the context of `Object`-derived classes only `Optional` elements are supported. That reflects exactly how Godot behaves. It allows `nil`s in `Object`-derived typed arrays, but not in other types.

### Old Types

In the past, we used different types for various functions which have now been unified, the old names of types that you might find in older documentation or samples are as follows:

* `GArray`, became `VariantArray`.
* `VariantCollection<BuiltinType>`, became `TypedArray<BuiltinType>`
* `ObjectCollection<ObjectOrSubclassType>`, became `TypedArray<ObjectOrSubclassType?>`

## GDScript Helper Functions

Many global helper functions that are exposed in GDScript have been exposed in
the ``GD`` class as static methods.

This means that you can invoke them like this:

```swift
func reportError (error: Variant) {
    GD.printerr (msg)
}
```

### Godot Math Functions

The various GDScript Math functions like `abs`, `acos`, `atan` as well as their
helper functions like `clamp` are defined as static functions in the ``GD``
class.

Generally, you can use the Swift versions instead of the GDScript versions,
which are more complete and do not incurr a marshaling overhead.

### Random Functions

The random functions like `randi`, `randf` and under the ``GD`` class. But Swift
provides a set of random functions that are just as good, like
 [Int.random(in:)](https://developer.apple.com/documentation/swift/int/random(in:)-9mjpw)
or
[Double.random(in:)](https://developer.apple.com/documentation/swift/double/random(in:)-6idef)
that operate on Swift ranges.

## Idiom Mapping 

| GDScript Idiom      | SwiftGodot Equivalent                  |
|---------------------|----------------------------------------|
| instance_from_id(n) | GD.instanceFromId (instanceId: n)      |

### Checking for the contents of a variant

You can check in one go if a given variant contains a valid object and is of a
given type, with the ``Variant/asObject(_:)`` method, combined with Swift's
"let":

```swift
func demo(input: Variant) {
	if let node = input.asObject(Node.self) {
		// We have a happy node inside 'input'
	} else {
		print ("The variant did not wrap an object, if it did, it was either nil, or was not of type Node")
	}
}
```

## @export annotations

The `@export` annotation works the same way as it does in GDScript. Some
parameters and directives are different see the <doc:Exports> documentation
for additional information.

## Signals

Generally, use the `@Signal` macro to declare a new signal for your classes,
like this:

```swift
class Demo: Node {
    @Signal var livesChanged: SignalWithArguments<Int>
}
```

For additional information on defining and connecting to signals see the
<doc:Signals> documentation.

## @onready annotation

GDScript supports an `@onready` annotation on variables, like this:


```gdscript
@onready var my_label = get_node("MyLabel")
```

This does not exist in SwiftGodot, to achieve a similar behavior, initialize
those variables in an overwritten `_ready` method, so code like this:

```swift
@Godot
class Demo: Node {
	var myLabel: Node3D?

	override func _ready () {
		myLabel = getNode (path: "myLabel") as? Node3D
	}
}
```

If you do not need to load the node right away, and you merely need to be able
to access it, you can use this instead:

```swift
class Demo: Node {
	@BindNode var myLabel: Node3D
}
```

## Running code before nodes are added to the Scene Tree

If you need to run some code in your constructor, but overriding the `_ready()`
function is already too late for you, you can use the following idiom:

```swift
@Godot
class NetworkedNode: Node {
    required init(_ context: InitContext) {
        super.init(context)
        onInit()
    }

    func onInit() {
        print("Was init!")
    }
}
```

## Singletons

Godot Singletons surface their API as static methods, to make the code more
shorter, for example:

```swift
let pressed = Input.isActionPressed(ui_down)
```

However, in some very rare cases this is not enough. For example, you may want 
to access a member from the base class SwiftGodot.Object, like `connect`. For such
use cases we provide a static property named `shared` that returns the singleton
instance. 

```swift
let demo = Input.shared.joyConnectionChanged.connect { device, connected in 
   print ("joyConnectionChanged called")
}
```

## String

SwiftGodot generally exposes a Swift-string based API, but there are some
convenience methods that you might have come to expect from the Godot String
(things like ``GString/validateFilename``, those APIs are available in the
``GString`` class).

## Callable

In SwiftGodot, you can create `Callable` instances by directly passing a Swift function that takes `borrowing Arguments` parameter,
and returns a `Variant?` result, like this:

```swift
func myCallback(args: borrowing Arguments) -> Variant? {
	print ("MyCallback invoked with \(args.count) arguments")
	if let argument = try? arguments.argument(ofType: Int.self, at: 0) {
		print("First argument was an int: \(argument)")
	}
	return nil
}

let myCallable = Callable(myCallback)
```
For more convenience you can pass a closure containing arguments and return value that Godot can understand:
```swift
let myCallable = Callable { (int: Int, bool: Bool, object: Object?) -> Camera3D? in 
	// do something 
	if let camera = object as? Camera3D? {
		if int > 2 || bool {
			return camera
		}
	}

	return camera
}
```
Conversion from `Arguments` to corresponding arguments will happen automatically. Or not, then function won't be called and you will see a error log specifying what went wrong.

---


Alternatively, you can use a StringName that binds a method that you have exported (via, the `@Callable` macro), like this:

```swift
@Callable func myCallback(message: String) {
	GD.print(message)
}
```

You can call the callable in GDScript by invoking call() method of the exported Swift type.

```GDScript
MySwiftNode.myCallback.call("Hello from Swift!")
```

## Async/Await

GDScript comes with an `await` primitive, you can achieve similar functionality
with the Swift built-in await/async stack.   Unlike GDScript, await can only be
invoked from `async` methods.

This means that code like this wont work:

```swift
func demo() {
	try await someSignal.emitted
}
```

For this to work, this needs to be in an async context, like this one:

```swift
func demo() async throws {
	try await someSignal.emitted
}
```

If you are inside of a function that is not async, you need to wrap your code in
Task, like this:

```swift
func demo() {
	// We are not an async function, but we can start a Task
	Task { @MainActor in
		try await someSignal.emitted
	}
}
```

### What `await` accepts

GDScript's `await` takes a signal, or a call to a coroutine - a function that itself
contains `await`. SwiftGodot covers both, plus the builtin `Signal` Variant type:

| GDScript | SwiftGodot |
|---|---|
| `await some_signal` | `try await someSignal.emitted` |
| `await obj.get_signal("x")` | `try await Signal(object: obj, signal: "x").emitted` |
| `await obj.some_coroutine()` | `try await obj.callScriptAsync(method: "some_coroutine")` |

A typed signal's payload comes back with its Swift types - `()` for a `SimpleSignal`, the
argument itself for a one-argument signal, a tuple otherwise. A `Signal` value carries no
static type information, so it yields `[Variant?]`.

### Differences worth knowing

- **`await` throws here.** Cancelling the task disconnects from the signal and throws
  `CancellationError`; a signal whose object is already gone throws
  `SignalAwaitError.targetUnavailable` instead of hanging. GDScript has neither.
- **A destroyed emitter never resumes the wait**, in Swift exactly as in GDScript. Bound
  the wait with cancellation if the emitter might not survive it.
- **Resumption thread.** GDScript always resumes on the main thread. Swift resumes on the
  actor you awaited from, so a bare `Task { }` resumes on the cooperative pool, where
  touching the scene tree is not safe. Use `Task { @MainActor in }` - and see
  <doc:Signals> for the platform caveat about whether `MainActor` is scheduled at all
  under Godot.
