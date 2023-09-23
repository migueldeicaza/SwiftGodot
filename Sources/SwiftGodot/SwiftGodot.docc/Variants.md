# Variants

Follow up on the fundamental building block of Godot's data types.

## Overview

You will often find the type ``Variant`` in Godot source code.   Variants are
Godot's way of passing around certain data types.  They are similar to Swift's
`Any` type, but they can only hold Godot types (most structures and classes
that derive from ``GodotObject``). 

## Creating Variant values
You can create Variants from the following structures and types:

* Swift's Bool, Int, Int64, Strings and Floats
* Godot's GString, Vector, Rect, Transform, Plane, Quaternion, AABB, Basis,
  Projection, NodePaths, RIDs, Callable, GDictionary, Array and PackedArrays. 
* Godot's objects

You wrap your data type by calling one of the ``Variant`` constructors, and then
you can pass this variant to Godot functions that expect a ``Variant``.

For example, to pass the value `true`:

```swift
let trueVaraint = Variant (true)
```

You can get a string representation of a variant by calling ``Variant``'s
``Variant/description`` method:

```swift
print (trueVariant.description)
```

## Extracting values from Variants

If you know the kind of return that a variant will return, you can invoke the
failing initializer for that specific type for most structures.

For example, this is how you could get a Vector2 from a variant:

```swift
func distance (variant: Variant) -> Float? {
    guard let vector = Vector2 (variant) else {
	return nil
    }
    return vector.length ()
}
```

Notice that this might return `nil`, which would be the case if the variant
contains a different type than the one you were expecting.   You can check the
type of the variant by accessing the `.gtype` property of the variant.

## Extracting Godot-derived objects from Variants

Godot-derived objects are slightly different.   If you know you have a
``GodotObject`` stored in the variant, you can call the ``Variant/asObject()``
instead.  This is a generic method, so you would invoke it like this:

```swift

func getNode (variant: Variant) -> Node? {
    guard let node = variant.asObject<Node> ()) else {
	return nil
    }
    return node
}
```

The reason to have a method rather than a constructor is that this method will
make sure that only one instance of your objects is surfaced to Swift.

