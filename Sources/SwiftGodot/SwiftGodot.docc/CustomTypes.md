# Using Custom Types

You will typically extend the functionality of your Godot game by creating
classes that derive from one of the various Godot types and adjust the
behavior accordingly.

## Overview

Creating a subclass of a Godot type involves a few steps:

1. Subclassing an existing Godot type with the usual Swift syntax.
2. Registering your type with Godot, so users can create instances of it
and configure it from the user interface.
3. Augment the type with your own custom behaviors.
4. Expose your properties, methods and signals to the Godot Editor.

## Topics

### Subclassing a Godot Type

To subclass a Godot type, you would follow the usual Swift idiom to subclass,
and annotate it with the @Godot macro, like this:

```swift
@Godot
class MySprite: Sprite {
    var timePassed: Double = 0

    override func _process (delta: Double) {
        time_passed += delta
    
        var newPos = Vector2(x: Float (10 + (10 * sin(time_passed * 2.0))),
                             y: Float (10.0 + (10.0 * cos(time_passed * 1.5))))
    
        self.position = newPos
    }
}
```

The `@Godot` macro does a few things, it creates a default constructor that
follows the convention to call the parent `init()` method and performs any
registrations that you might have done in your class for variables or methods.

As you will see later, the @Godot macro is applied to a class definition, and
will scan your type for various other macros to integrate with Godot.   These
attributes will not work if you attempt to apply those in a Swift
extension-method, as the @Godot macro has no visibility into those.

### Register Your Type

Now we need to tell Godot about the existence of your type, to do this you need
to call the `register(type:)` method.   I like to register all my types at
startup, but you can do this at any time after the module has been initialized.

Your module gets initialized on a callback from Godot at different stages, this
is how I register my types:

```swift
/// This method will be invoked at different stages of the execution,
/// in our example, we register the type when the level being used is
/// `.scene`.

func setupScene (level: GDExtension.InitializationLevel) {
    if level == .scene {
        register(type: SwiftSprite.self)
    }
}

/// This is the entry point referenced from the `.gdextension` file
/// that you used to declare the Swift extension:
@_cdecl ("swift_entry_point")
public func swift_entry_point(
    interfacePtr: OpaquePointer?,
    libraryPtr: OpaquePointer?,
    extensionPtr: OpaquePointer?) -> UInt8
{
    print ("SwiftSprite: Starting up")
    guard let interfacePtr, let libraryPtr, let extensionPtr else {
        return 0
    }
    initializeSwiftModule(interfacePtr, libraryPtr, extensionPtr, initHook: setupScene, deInitHook: { x in })
    return 1
}
```

### Defining your class behavior

To make your custom type interesting, you will want to alter the default
behavior that Godot provides.   In Godot, this is achieved by overwriting one or
more of the virtual methods available in a class.

In Godot, methods that can be overwritten start with an underscore, like
`_ready` for example.  

While this would not have been my choice desining the API, I find that there is
enough external documentation in the Godot  world, that I decided to stick to
it.

In the example shown above, we overwrote the method `_process` which is invoked
continously by Godot and we use it to change the position of our sprite.

### Surfacing Methods, Properties and Signals

In addition to modifying the behavior of a built-in type, you might want to
surface properties that would allow users to customize your type from the Godot
editor, or expose methods that can be invoked by users from either other
programming languages, like GDScript or C#, and you might want to surface
<doc:Signals> that your object emits that can be wired up externally.

To do this, you will be using the `@Godot` macro to annotate your class, like
this:

```swift
@Godot
class SwiftSprite: Sprite2D {
}
```

When you use the `@Godot` macro, a number of additional macros can be used inside
your class, like `#signal` [to define signals](Signals.md), `@Callable` to surface a method to
Godot, and `@Export` to [surface properties](Exports.md).

Behind the scenes these macros use the lower-level ``ClassDB`` API to define functions,
properties and their values.

### Overriding Methods

The Godot Object model does not surface a traditional object-oriented system.
Not all the methods surfaced by the Godot API can be overwritten.  The
SwiftGodot binding makes this explicit.   Methods that can be overwritten are
declared as `open`, while those that can not be overwritten are declared as
`public`.

Godot prefixes all of the overwritable methods with an underscore (we have seen
in this guide some examples already, like `_process`).

Another important difference is that Godot does not expect your code to call the
"super" method, in fact, those methods do nothing in SwiftGodot.   

Of course, if your Swift code relies on a class hierarhcy where you do delegate
code to the original implementation, you should still call the base class
method.   For example:

```
@Godot 
class Base: Node2D {
    override func _ready () { 
        /* important work */ 
        /* no need to call super._ready */
    }
}

class Derived: Base {
    override func _ready () {
        /* some prep work here */
        /* because we want to execute the Base._ready important work */
        super._ready ()
        /* some additional work here */
    }
}
```

You can think of those methods that can be overwritten as hooks into Godot, but
with an important distinction.   When you override those methods, Godot knows
that you overwrote them, and might take a different course of action based on it.

#### Surfacing Methods

To surface a method, apply the `@Callable` attribute to it, this will register
the method with Godot.

The only limitation is that the parameters of those methods need to be one
of the types that Godot can surface to the rest of the engine: anything that can
be passed in a ``Variant``.


```swift
@Callable
func readyCallback (text: String) {
    print ("readyCallback method called with value: \(text)")
    return nil
}
```

Now your method can be invoked from the Godot editor or from scripts written in other languages.

The functions can be any of the types that can be wrapped in a
[Variant](Variant.md) including the core Swift data types for integers and
floats, the Godot Object subclasses as well as ``VariantCollection`` and
``ObjectCollection``.

The `@Callable` macro only works in your class definition, and will not work
on Swift class extensions.

#### Surfacing Properties and Variables

To surface properties and variables, use the ``Export`` attribute on them.

The simplest use case works like this:

```swift
@Godot
class Demo: Node3D {
    @Export var greeting: String = 0
}
```

The above code surfaces a property called `greeting` to Godot of the
type string.  Strings and numbers can be edited in many interesting 
ways in the Godot editor, and that is exposed via two optional parameters
to the `Export` attribute: a ``PropertyHint`` and sometimes those hints
can take an optional string with additional confirmation information.

To learn more, read the <doc:Exports> page.

#### Signals

Surfacing signals is covered in the <doc:Signals> document.

## Low-Leve Details: PropInfo

In SwiftGodot, the ``PropInfo`` structure is used to define argument types,
properties and return values.  You will be exposed to these when you define 
signal parameters.

This is only required if you do not use the various macros provided by 
SwiftGodot.

It looks like this:

```swift
let textArgument =  PropInfo(
    propertyType: .string,
    propertyName: StringName ("myArg"),
    className: "SwiftSprite",
    hint: .typeString,
    hintStr: "", 
    usage: .default)
```

In this case, we are declaring a property of the Godot type string, and we call
this `myArg`.  The `className` is the name of the class that we are defining it,
and we can provide additional hints as to how this might be used (The Godot
editor can provide custom UI Editors based on this information).
