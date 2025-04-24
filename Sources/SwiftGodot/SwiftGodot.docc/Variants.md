# Variants

Follow up on the fundamental building block of Godot's data types.

## Overview

You will often find the type ``Variant`` in Godot source code.   Variants are
Godot's way of passing around certain data types.  They are similar to Swift's
`Any` type, but they can only hold Godot types (most structures and classes
that derive from ``Object``). 

## Creating Variant values

You can create ``Variant``s from types that conform to the
``VariantConvertible`` protocol. 

This includes the following types:

* Godot's native types: ``GString``, ``Vector``, ``Rect``, ``Transform``, ``Plane``, ``Quaternion``,
  ``AABB``,  ``Basis``, ``Projection``, ``Int64``, ``NodePaths``, ``RIDs``, ``Callable``, ``VariantDictionary``, ``Array``
  and PackedArrays.  
* Swift types that SwiftGodot adds convenience conformances for: ``Bool``, ``Int`` (and all signed/unsigned width varieties such as `UInt32`, `Int16`), ``String``, ``Float`` and ``Double``,
* Godot's objects: e.g. ``Node``, ``Area2D``
* Your own subclasses of ``Object`` type.
* Other types that you can manually conform to ``VariantConvertible``.

You can construct a ``Variant`` using these approaches, they are identical:

```swift
let trueVaraint = Variant(true)
let falseVariant = false.toVariant()
```

You can get a string representation of a variant by calling ``Variant``'s
``Variant/description`` method:

```swift
print(trueVariant.description)
```

If you have a ``Variant`` and want to extract its value, there are some patterns which you can use interchangeably,
they are functionally identical:

```swift
func someFunctionTakingBool(_ bool: Bool?, successCount: inout Int) {
    if let bool {
        successCount += 1
        
        print("\(bool) again!")
    }
}

func boolsUnwrapped(variant: Variant?) -> Int {
    var successCount = 0
    
    // 1. Type.init(_ variant: Variant)
    // Available for all types except `Object`-derived
    if let boolValue = Bool(variant) {
        print("I'm \(boolValue)!")
        successCount += 1
    }
    
    // 2. Type.fromVariant
    if let boolValue = Bool.fromVariant(variant) {
        print("Still \(boolValue)...")
        successCount += 1
    }
    
    // 3. Variant.to(Type.self)
    if let boolValue = variant.to(Bool.self) {
        print("Nothing changed, it's \(boolValue)")
        successCount += 1
    }
    
    // 4. The (3) option is even more useful when Swift can deduct the type you want to convert to!
    // Here Swift understands that `variant.to()` should unwrap `Bool` because on the left part says `: Bool`.
    if let boolValue: Bool = variant.to() {
        print("Oh, I see you enjoy Swift type inferrence! I'm \(boolValue)")
        successCount += 1
    }
    
    // 5. (3) can work even if type is specified somewhere else! 
    someFunctionTakingBool(variant.to(), successCount: &successCount)

    return successCount
}

print(boolsUnwrapped(true.toVariant()) // prints 5! We unwrapped our `true` 5 times!
```


Note that all the functions above return `Bool?` because there is no guaruantee that

1. ``Variant?`` is actually not `nil`
2. ``Variant`` even if it's not `nil`, contains a ``Bool``

`variant.to(Type.self)`, `Type.fromVariant(variant)` return `T?`.

`Type.init(variant)` or just `Type(variant)` is a [failable initializer](https://developer.apple.com/swift/blog/?id=17) 
If the variant does not contain the type you are requesting the result of the call is `nil`.

So in general unwrapping a variant can use the following pattern:

```swift
if let string = String.fromVariant(variant) {
    // do something with `String`!
    print(string)
}
```

or this:

```swift
guard let vector0 = Vector3.fromVariant(variant0) else {
    return
}

guard let vector1 = Vector3.fromVariant(variant1) else {
    return
}

// We are guaranteed to have both vectors now! 
let vector2 = vector0 + vector1
```

You can also use throwing version of those APIs:

```swift
let variants = [
    Vector3.back.toVariant(),
    Vector3.right.toVariant(),
    Vector3.up.toVariant(),
]
                    
do {
    var result = Vector3()
    for variant in variants {
        result += try Vector3.fromVariantOrThrow(variant)
    }
    // use result    
} catch {
    // error is guaranteed typed `VariantConversionError`
    print(error.description)
}
```


## Common Usage Patterns

The following are some examples of how to work with Variants in practice, and
some idioms suitable to be used with Swift.

In the following example, imagine that an API returns a Variant value that
contains a dictionary with string keys and values are ``PackedArrayInt32``, this
is how you would decode this:

```swift
/// This converts a variant that contains a dictionary of string keys and an 
/// array of integers into the native Swift dictionary
func decode (variant: Variant) -> [String: [Int32]]? {
    guard let dict = VariantDictionary (variant) else {
        // If the variant is not a dictionary, we return nil
        return nil
    }
    var result = [String: [Int32]] ()
    for (key, value) in dict {
        guard let packedArray = PackedArrayInt32 (value) else {
            // If the `value` in the dictionary is not of type `PackedArrayInt32`, we ski it
            continue
        }
        result [key] = packedArray
    }
    return result
}
```

The above shows a defensive style of programming, where we prepare for the 
possibility that we do not receive a dictionary, or the values in the dictionary
are not of type ``PackedArrayInt32``.

The following examples shows how to encode an array that contains
paris of file names and sizes into a Godot ``VariantArray`` with
``VariantDictionary`` elements:

```swift
func encode(values: [(String,Int)]) -> Variant {
    let array = VariantArray ()
    for (fileName, size) in values {
        let dict = VariantDictionary ()
        dict ["file_name"] = Variant (fileName)
        dict ["size"] = Variant (size)
        array.append (dict)
    }
    return Variant (array)
}
```


The next example shows how to decode the result of the above.  The ``VariantArray``
and ``VariantDictionary`` are weakly typed, so the inverse operation takes a defensive
approach.

```swift
func decode(variant: Variant) -> [(String, Int)]? {
    guard let array = Array (variant) else {
        // If the variant is not an array, we return nil
        return nil
    }
    var result = [(String, Int)] ()
    for element in array {
        guard let dict = VariantDictionary (element) else {
            // If the element in the array is not a dictionary, we skip it
            continue
        }
        guard let fileNameV = dict ["file_name"], 
              let fileName = String (filenameV) else {
            // If the dictionary does not contain a string with the 
            // key "file_name", we skip it
            continue
        }
        guard let sizeV = dict ["size"],
              let size = Int (sizeV) else {
            // If the dictionary does not contain an integer with the key 
            // "size", or if the value can not be converted to an Int,
            // we skip it
            continue
        }
        result.append ((fileName, size))
    }
    return result
}
```

## Extracting Godot-derived objects from Variants

You can use the same principles to turn a Godot object encoded into a Variant
into a SwiftGodot object that you used above like `Node.fromVariant()` or you
can use the `.asObject()` method on the variant to get the object back.

For example:

```swift
func getNode (variant: Variant) -> Node? {
    guard let node = variant.asObject (Node.self)) else {
	  return nil
    }
    return node
}
```

Or you can use the alternative version:

```swift
func getNode (variant: Variant) -> Node? {
    guard let node = Node.fromVariant(variant) else {
	  return nil
    }
    return node
}
```

The reason why we do not surface object constructors that take a variant, is
that we need to ensure that for any given Godot-object, only a single
SwiftGodot.Object exists.  


## Accessing Array Elements

Some of the variant types contain arrays, either objects, or a particular
packed version of those.   You can access the individual elements of the
those with a convenient subscript provided on the array.

```swift
func foo(_ array: VariantArray) {
    let variant = array[4] // returns Variant? since Godot arrays can store `nil`s
}
```

## Calling Variant Methods

It is possible to invoke the built-in variant methods that exist in the Godot
universe by using the `call` method on a Variant.   This is very similar to the
call method on an Object.

For example, you can invoke this generic "size" method on an array to get the
size of an array, regardless of the specific type of array:

```
func printSize (myArray: Variant) {
    switch variant.call(method: "size") {
    case .failure(let err):
        print (err)
        return 0
    case .success(let val):
        return Int (val) ?? 0
    }
}
```

# Under the hood

SwiftGodot surfaces Variants in two ways, one is `Variant` that we have
discussed above extensively which is a class type, and this is necessary for
ensuring that the variants release the underlying data when they are no longer
in use.   

SwiftGodot surfaces the Variant type in returns and as input parameters to its
API.   

There is an advanced ``FastVariant`` type that uses Swift's `~Copyable` support
that creates a lightweight Variant, and is essentially the same as the C++
counterpart in terms of performance.  This is used internally in SwiftGodot, and
you can convert back and forth from the Variant types, this means that there are
fewer heap allocations and you do not incur on the overhead of
automatic-reference counting, and instead use Swift's built-in type ownership support.

The longer-term plan is to make it so that our APIs can take both Variant and
FastVariant.
