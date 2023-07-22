# Using Custom Types

You will typically extend the functionality of your Godot game by creating
classes that derive from one of the various Godot types and adjust the
behavior accordingly.

Today there is some manual registration work that as a developer you need to do
(like informing SwiftGodot of your types, methods, properties and signals -
along with their arguments).   Swift is getting soon a macro capability that
will reduce much of the work involved here, and I am exploring a promising
reflection path to reduce some of the steps.

This document describes what you need to do today.

## Overview

Creating a subclass of a Godot type involves a few steps:

1. Subclassing an existing Godot type with the usual Swift syntax.
2. Registering your type with Godot, so users can create instasnces of it
and configure it from the user interface.
3. Augment the type with your own custom behaviors.
4. Expose your properties, methods and signals to the Godot Editor.

## Topics

### Subclassing a Godot Type

To subclass a Godot type, you would follow the usual Swift idiom to subclass,
and additionally, you must define two required constructors in your source code,
like this:

```swift
class MySprite: Sprite {
    var timePassed: Double

    required init () {
        timePassed = 0
        super.init()
    }

    required init (nativeHandle: UnsafeRawPointer) {
	fatalError ("Will never be invoked")
    }

    override func _process (delta: Double) {
        time_passed += delta
    
        var newPos = Vector2(x: Float (10 + (10 * sin(time_passed * 2.0))),
                             y: Float (10.0 + (10.0 * cos(time_passed * 1.5))))
    
        self.position = newPos
    }
}
```

You might be wondering why the second constructor is needed and why it calls
`fatalError`.  It is not necessary for user code, but I have not found a way to
avoid having it implemented.   So for now, you need to declare it.

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
programming languages, like GDScript or C#, and you might want to [surface
signals](Signals) that your object emits that can be wired up externally.

To surface this methods, you will use the `ClassInfo` type that is used to
register these capabilities, and you must invoke this once per class that you
define.   I like to use this lazy class initialization idiom and call it from my
constructors:

```swift
class SwiftSprite: Sprite2D {
    static var initClass: Void = {
        let classInfo = ClassInfo<SwiftSprite> (name: "SwiftSprite")   
    }

    required init () {
	SwiftSprite.initClass
	super.init()
    }
```

Notice that the constructor is now referencing the `initClass` variable, which
is defined as a lazy property, and will execute the code in `initClass` only
once on first use.

Inside `initClass`, you will use ``ClassInfo`` to register all your
capabilities, and you declare it like this:

```swift
   let classInfo = ClassInfo<SwiftSprite> (name: "SwiftSprite")
```

We will come back to it shortly, but before I want to let you know about a
work-horse of this process, the ``PropInfo`` structure.

In SwiftGodot, the ``PropInfo`` structure is used to define argument types,
properties and return values.  It looks like this:

```swift
let textArgument =  PropInfo(
    propertyType: .string,
    propertyName: StringName ("myArg"),
    className: "SwiftSprite",
    hint: .typeString,
    hintStr: "Text", 
    usage: .propertyUsageDefault)
```

In this case, we are declaring a property of the Godot type string, and we call
this `myArg`.  The `className` is the name of the class that we are defining it,
and we can provide additional hints as to how this might be used (The Godot
editor can provide custom UI Editors based on this information).

#### Surfacing Methods

To register a method, in your class initialization routine, you will be calling
methods of the ``ClassInfo`` to register your method, like this:

```swift
let printArgs = [
    PropInfo(
	propertyType: .string,
	propertyName: StringName ("myArg"),
	className: "SpinningCube",
	hint: .flags,
	hintStr: "Text",
	usage: .propertyUsageDefault)
]

classInfo.registerMethod(
    name: "readyCallback", 
    flags: .default, 
    returnValue: nil, 
    arguments: printArgs, 
    function: SpinningCube.readyCallback)
```

The above code registers a method called `readyCallback` that takes a single
argument of type `String` and returns nothing.  It takes a single argument
because the `printArgs` structure above only describes one argument.  And the
argument is of type String.

The `returnValue` in this case is passed as nil, indicating that the method does
not return anything.   To return a value, you would create a matching
``PropInfo`` that described the return value.

Lastly, the method is bound to the Swift method `SpinningCube.readyCallback`,
which is expected to have the following signature:

```swift
func readyCallback (args: [Variant]) -> Variant? {
    guard let firstArg = args.first else { 
	return nil 
    }
    guard let strArg = String (firstArg) else { 
	print ("This method expects the first variant argument to be of type string")
    }
    print ("readyCallback method called with value: \(strArg)")
    return nil
}
```

The method is passed an array of `Variant` objects, which is the way that Godot
passes values around.   Godot boxes all kinds of interesting types into
Variants.   

The code above is written defensively to ensure that if
the registration changes over time, we do not accidentally misbehave.   This is
an area where macros and the reflection work could make a difference, and let
you use strong types for parameters, without having to do any of that checking
or having to even convert variant values to the types you would need to use.

Once this has taken place, this method can be invoked externally.

#### Surfacing Properties

Properties are made up of two methods, a method that can return the current
value, and a method that can update the value.   To surface a property, you
first must declare the two methods that will do the work for getting and setting
the value, and then you register the property with the ``ClassInfo``.

This is an example:

```swift
let foodArgs = [
    PropInfo(propertyType: .string,
        propertyName: "Food",
        className: StringName ("food"),
        hint: .typeString,
        hintStr: "Some kind of food",
        usage: .propertyUsageDefault)
]

// We declare our setter method, which will take one argument
classInfo.registerMethod(
    name: "demo_set_favorite_food", 
    flags: .default, 
    returnValue: nil, 
    arguments: foodArgs, 
    function: SwiftSprite.demoSetFavoriteFood)

// And we declare our getter method, which will return a string:
classInfo.registerMethod(
	name: "demo_get_favorite_food", 
	flags: .default, 
	returnValue: foodArgs [0], 
	arguments: [], 
	function: SwiftSprite.demoGetFavoriteFood)

// And now we declare the property that references both methods:
let foodProp = PropInfo (
    propertyType: .string,
    propertyName: "favorite_food",
    className: "SwiftSprite",
    hint: .multilineText,
    hintStr: "Name of your favorite food",
    usage: .propertyUsageDefault)
classInfo.registerProperty(foodProp, 
    getter: "demo_get_favorite_food", 
    setter: "demo_set_favorite_food")
```

The above code surfaces a property called `demo_favorite_food` to Godot of the
type string.  Additionally, we inform Godot that the string is multiline text,
so it will give us a UI for that.

You can additionally spice up your property by calling the `addPropertyGroup` to
put all of your properties on a dedicated section:

```swift
    classInfo.addPropertyGroup(name: "Miguel's Demo", prefix: "demo_")
```
<img width="264" alt="image" src="https://github.com/xibbon/LaTerminalApp/assets/36863/5770926f-5f2b-4905-8499-1e2bb0762a11">

