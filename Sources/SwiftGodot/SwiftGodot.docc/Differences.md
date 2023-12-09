# SwiftGodot API differences to GDScript

## General differences

The SwiftGodot API follows the convention of the Swift platform, and one of the
most notable places where this happens is in the use of camelCase style instead
of the snake_case style used in GDScript.

Enumerations and their values also change, for example, rather than having a
constant value like `CORNER_TOP_LEFT` for the
[`Corner`](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/corner)
value, we use `.topLeft`

In Swift, function definitions take parameter names, and sometimes this
parameter name is omitted for the first argument.   Instead of `myNode.add_child
(box)`, you would use `myNode.addChild (node: box)`.

## Global Scope

Global functions and some constants had to be moved to classes to avoid
polluting the global name space, and you can find them in the [`GD
class`](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/gd).

## Type Mappings

Godot comes with some of their own data types like strings and dictionaries, but
those types would clash with the existing Swift types with the same names.   

Here is a list of the current data type mappings:

| GDScript type | SwiftGodot Name |
|---------------|-----------------|
| string        | GString         |
| dictionary    | GDictionary     |
| array         | GArray          |

The
[`GArray`](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/garray)
is a type-erased array that can hold any sort of element that can be managed by
Godot (Variants or Objects).

In addition, there are two special kinds of strongly-typed versions of the
GArray:

* [VariantCollection](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/variantcollection) hat holds:
[Variant](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/variants) elements.

* [ObjectCollection](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/variantcollection)
  that holds any
  SwiftGodot.[GodotObject](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/godotobject)
  instances.

## GDScript Helper Functions

Many global helper functions that are exposed in GDScript have been exposed in
the [GD
class](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/gd/)
as static methods.

This means that you can invoke them like this:

```
func reportError (error: Variant) {
	GD.printerr (msg)
}
```

### Godot Math Functions

The various GDScript Math functions like `abs`, `acos`, `atan` as well as their
helper functions like `clamp` are defined as static functions in the [GD class](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/gd/).

Generally, you can use the Swift versions instead of the GDScript versions,
which are more complete and do not incurr a marshaling overhead.

### Random Functions

The random functions like `randi`, `randf` and under the  [GD
class](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/gd/).
But Swift provides a set of random functions that are just as good, like
[`Int.random(in:)`](https://developer.apple.com/documentation/swift/int/random(in:)-9mjpw)
or
[`Double.random(in:)`](https://developer.apple.com/documentation/swift/double/random(in:)-6idef)
that operate on Swift ranges.

## Idiom Mapping 

| GDScript Idiom      | SwiftGodot Equivalent                  |
|---------------------|----------------------------------------|
| instance_from_id(n) | GD.instanceFromId (instanceId: n)      |

## @export annotations

The `@export` annotation works the same way as it does in GDScript.   Some 
parameters and directives are different see the [Exports
documentation](Exports.md) for additional information.

## Signals

Generally, use the `#signal` macro to declare a new signal for your classes,
like this:

```
class Demo: Node {
    #signal("lives_changed", argument: ["new_lives_count": Int.self])
```

For additional information on defining and connecting to signals see the
[Signals Documentation](Signals.md).

## @onready annotation

GDScript supports an `@onready` annotation on variables, like this:


```gdscript
@onready var my_label = get_node("MyLabel")
```

This does not exist in SwiftGodot, to achieve a similar behavior, initialize
those variables in an overwritten `_ready` method, so code like this:

```
class Demo: Node {
	var myLabel: Node3D

	override func _ready () {
		myLabel = getNode (path: "myLabel") as? Node3D
	}
}
```

If you do not need to load the node right away, and you merely need to be able
to access it, you can use this instead:

```
class Demo: Node {
	@BindNode var myLabel: Node3D
}
```

## Singletons

Godot Singletons surface their API as static methods, to make the code more
shorter, for example:

```
let pressed = Input.isActionPressed(ui_down)
```

However, in some very rare cases this is not enough. For example, you may want to access a member from the base class GodotObject, like `connect`. For such use cases we provide a static property named `shared` that returns the singleton instance. 

```
let demo = Input.shared.joyConnectionChanged.connect { device, connected in 
   print ("joyConnectionChanged called")
}
```

## String

SwiftGodot generally exposes a Swift-string based API, but there are some
convenience methods that you might have come to expect from the Godot String
(things like
[validateFilename](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/gstring/validatefilename()),
those APIs are available in the  [`GString`
class](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/gstring).

## Callable

In SwiftGodot, you can create `Callable` instances, either by using a StringName
that binds a method that you have exported (via, the `@Callable` macro), or you
can pass directly a Swift function that takes an array of `Variant` arguments,
and returns an optional `Variant` result, like this:

```
func myCallback (args: [Variant])-> Variant? {
	print ("MyCallback invoked with \(args.count) arguments")
	return nil
}

let myCallable = Callable (myCallback)
```

## Async/Await

GDScript comes with an `await` primitive, you can achieve similar functionality
with the Swift built-in await/async stack.   Unlike GDScript, await can only be
invoked from `async` methods.

This means that code like this wont work:

```
func demo () {
	await someSignal.emitted
}
```

For this to work, this needs to be in an async context, like this one:

```
func demo () async {
	await someSignal.emitted
}
```

If you are inside of a function that is not async, you need to wrap your code in
Task, like this:

```
func demo () {
	// We are not an async function, but we can start a Task
	Task {
		await someSignal.emitted
	}
}
```