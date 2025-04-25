# Types Translation

This document contains information on how type translation happens between Swift and Godot.

Scenarios when Godot to/from Swift translations happen:

* `@Callable`
    - `argument` when called by Godot: Godot -> Swift
    - `return value` when called by Godot: Swift -> Godot
* `@Export`
    - `gotten value` when called by Godot: Swift -> Godot
    - `set value` when called by Godot: Godot -> Swift
* `Callable` type:
    ```swift
    let callable = Callable { (int: Int, bool: Bool) -> String in 
        "\(int)\(bool)"
    }
    ```    
    - `argument when` called: Godot -> Swift
    - `return value` called: Swift -> Godot

    Calling such callable is identical to Godot calling `@Callable` function.

If nothing in the type section is specified about the scenarios, it means the type is allowed in all of those.

`Toll-free bridging` means that performance cost of translation is negligible.
# Swift types

#### Swift ``Bool`` – Godot `bool`
Toll-free bridging.
```swift
@Godot class CustomNode: Node {
    @Export var variable = true 
    // Godot will see `bool variable`
}
```
#### Swift `Bool?` – Godot `Variant`
Toll-free bridging.
```swift
@Godot class CustomNode: Node {
    @Export var variable: Bool? = nil 
    // Godot will see `Variant variable`
}
```
---
#### Swift `String` – Godot `String` (SwiftGodot `GString`)
_NOT_ toll-free bridging (`Swift.String` <-> `GString` conversion requires allocation and parsing the underlying utf8)

Original Godot API declaring usage of Godot `String` uses Swift ``String``. Conversion happens automatically.

```swift
@Godot class CustomNode: Node {
    @Export var variable = "Hello"
    // Godot will see `String variable`
}
```
#### Swift `String?` – Godot `Variant`
_NOT_ toll-free bridging (`Swift.String` <-> `GString` conversion requires allocation and parsing the underlying utf8)

```swift
@Godot class CustomNode: Node {
    @Export var variable: String? = "Hello"
    // Godot will see `Variant variable`
}
```
---
#### Swift ``BinaryInteger`` - Godot `int`
Toll-free bridging.
Concrete types: ``Int``, ``UInt``, ``Int64``, ``Int32``, ``Int16``, ``Int8``, ``UInt64``, ``UInt32``, ``UInt16``, ``UInt8``

Godot uses `Int64` as a storage. 

If Godot calls Swift and passes a value that doesn't fit the declared integer width,
unwrapping fails:
```
Int32.fromVariant(Int.max.toVariant()) // is `nil`
```

```swift
@Godot class CustomNode: Node {
    @Export var variable = 130
    // Godot will see `int variable`

    @Callable
    func foo(a: Int32, b: UInt16, c: Int, d: UInt) {
    }
    // Godot will see `void foo(a: int, b: int, c: int, d: int)`
}
```
#### Swift `BinaryInteger?` – Godot `Variant`
```swift
@Godot class CustomNode: Node {
    @Export var variable: Int? = 150
    // Godot will see `Variant variable`    
}
```
---

#### Swift ``BinaryFloatingPoint`` - Godot `float`
Toll-free bridging.
Concrete types: ``Double``, ``Float``
Godot uses ``Double`` as a storage. 

```swift
@Godot class CustomNode: Node {
    @Export var variable = 42.0
    // Godot will see `float variable`

    @Callable
    func foo(a: Float, b: Double) {
    }
    // Godot will see `void foo(a: float, b: float)`
}
```

#### Swift `BinaryFloatingPoint?` - Godot `Variant`

```swift
@Godot class CustomNode: Node {
    @Export var variable: Float? = 42.0
    // Godot will see `Variant variable`
}
```
---
#### Swift closure - Godot `Callable`
_NOT_ toll-free bridging:
1. Each `get` requires allocation of a wrapping `Callable` value.
1. Each `set` requires allocation of a Swift closure wrapping passed `Callable`.

Calling it from Godot is cheap.

Only closures taking ``VariantConvertible`` arguments are allowed.
Only closures returning a ``VariantConvertible`` or `Void` are allowed.
No `async` and `throw` specifiers are allowed.

##### Scenarios allowed:
- `@Export`
- `Callable.init(closure)`

```swift
@Godot class CustomNode: Node {
    @Export var variable = { (lhs: Int, rhs: Int) -> Int in 
        lhs + rhs
    }
    // Godot will see `Callable variable`

    @Export var variable1 = { (lhs: Int, rhs: Int) in 
        print(lhs + rhs)
    }
    // Godot will see `Callable variable1`
}
```
---
#### Swift `Void` (aka empty tuple `()`) 
Toll-free bridging.
##### Scenarios allowed:
- Returned value from `@Callable` function
- Returned value from Swift closure
---
#### Swift ``Array`` - Godot `Array[type]` 
Only ``Swift.Array`` with `Element`s of Godot builtin types or *optional*(!) ``Object``-derived types are allowed.
Expensive bridging, operations takes O(n) during each translation.

Implemented via ``GodotBuiltinConvertible``

Prefer using `TypedArray` for frequent operations

```swift
@Godot class CustomNode: Node {
    @Export var variable0: TypedArray<Vector3> = []
    // Godot will see `Array[Vector3] variable0`

    @Export var variable1: TypedArray<Object?> = []
    // Godot will see `Array[Object] variable1`
}
```

#### Swift Optional ``Array`` - Godot `Variant`
Only ``Swift.Array`` with `Element`s of Godot builtin types or *optional*(!) ``Object``-derived types are allowed.
Expensive bridging, operations takes O(n) during each translation.

Implemented via ``GodotBuiltinConvertible``

Prefer using `TypedArray` for frequent operations

```swift
@Godot class CustomNode: Node {
    @Export var variable0: TypedArray<Vector3>? = []
    // Godot will see `Variant variable0`

    @Export var variable1: TypedArray<Object?>? = []
    // Godot will see `Variant variable1`
}
```

---
#### Swift enum - Godot `int`, Godot `String`, Godot `bool`
Toll-free bridging, but:
* If `RawValue` == `String` - requires `Swift.String` <-> `SwiftGodot.GString` conversion and `Hashable` lookup to decide if enum indeed has a case represented by such string.

Only ``RawRepresentable`` enums are allowed. `RawValue` must be ``BinaryInteger``, ``String`` or ``Bool``

``CaseIterable`` enum with ``RawValue: BinaryInteger`` also generate a named picker in Editor.

```swift
enum BoolEnum: Bool {
    case absolutelyTrue = true
    case undeniablyFalse = false
}

enum IntEnum: Int {
    case zero = 0
    case one = 1
    case two = 2
}

enum OrwellEnum: String {
    case war = "peace"
    case freedom = "slavery"
}

enum SelectionEnum: Int, CaseIterable {
    case the
    case house
    case that
    case jack
    case built
}

@Godot class CustomNode: Node {
    @Export var variable0 = BoolEnum.absolutelyTrue
    // Godot will see `bool variable0`

    @Export var variable1 = IntEnum.one
    // Godot will see `int variable1`

    @Export var variable2 = OrwellEnum.war
    // Godot will see `String variable2`

    @Export var variable3 = SelectionEnum.jack
    // Godot will see `int variable3`, 
    // Editor will provide a selection from `the`, `house`, `that`, `jack`, `built` for the property
}
```

# SwiftGodot types

#### SwiftGodot ``Variant`` - Godot `Variant`
_NOT_ toll-free bridging. Requires a heap allocation of `Variant` every time value is translated from Godot.

Guaranteed to contain non-nil Godot value.

```swift
@Godot class CustomNode: Node {
    @Export var variable = 42.toVariant()
    // Godot will see `Variant variable`
}
```
#### SwiftGodot ``Variant?`` - Godot `Variant`
_NOT_ toll-free bridging. Requires a heap allocation of `Variant` every time non-nil value is translated from Godot.

`Variant?.some` - Godot `Variant` containing non-`null` value.

`Variant?.none`, aka `nil` - Godot `Variant` containing `null`.

```swift
@Godot class CustomNode: Node {
    @Export var variable: Variant? = nil
    // Godot will see `Variant variable`
}
```

---

#### SwiftGodot dumb types - Corresponding Godot builtin types
Toll-free bridging.
All dumb Godot builtin types such as: ``Projection``, ``Vector3``, that basically just contain numbers and are represented as Swift `struct`.

```swift
@Godot class CustomNode: Node {
    @Export var variable = Vector3()
    // Godot will see `Array variable`
}
```

#### SwiftGodot ``Optional`` dumb types - Godot `Variant`
Toll-free bridging.
```swift
@Godot class CustomNode: Node {
    @Export var variable: Vector3? = nil 
    // Godot will see `Variant variable`
}
```
---
#### SwiftGodot non-`Object` reference types - Corresponding Godot builtin types
_NOT_ toll-free bridging. Requires a heap allocation of the Swift wrapper every time the value is translated from `Godot` to `Swift`.

All built-in types of Godot which are represented as Swift `class` such as: ``VariantArray``, ``VariantDictionary``, ``RID``, ``PackedFloat32Array``, etc.

These types appear exactly as they are in Godot except `GString`(Godot `String`), `VariantArray` (Godot `Array`), and `VariantDictionary`(Godot `Dictionary`), which are renamed to avoid collision with native Swift types.

```swift
@Godot class CustomNode: Node {
    @Export var variable = VariantArray()
    // Godot will see `Array variable`
}
```

#### SwiftGodot ``Optional`` reference types - Godot `Variant`
_NOT_ toll-free bridging. Requires a heap allocation of the Swift wrapper every time the non-nil value is translated from `Godot` to `Swift`.
```swift
@Godot class CustomNode: Node {
    @Export var variable: VariantArray? = nil 
    // Godot will see `Variant variable`
}
```
---

#### SwiftGodot ``Object``-derived types - Corresponding Godot types
_Almost_ toll-free bridging:
Allocation only happens when Godot object never seen by Swift shows up during Godot -> Swift translation.

All Godot class types such as: ``Object``, ``Node``, ``Camera3D``, ``Resource``, etc.

These types appear exactly as they are in Godot, no exceptions!

Guaranteed to be non-nil.

```swift
@Godot class CustomNode: Node {
    @Export var variable = Camera3D()
    // Godot will see `Camera3D variable`
}
```

#### SwiftGodot ``Optional`` ``Object``-derived types - Godot `Object`-derived types
_Almost_ toll-free bridging:
Allocation only happens when Godot object never seen by Swift shows up during Godot -> Swift translation.

```swift
@Godot class CustomNode: Node {
    @Export var variable: Camera3D? = nil
    // Godot will see `Camera3D variable`
}
```

---

#### SwiftGodot `TypedArray` - Godot `Array[type]`
_NOT_ toll-free bridging. Requires a heap allocation of the Swift wrapper every time the value is translated from `Godot` to `Swift`.

```swift
@Godot class CustomNode: Node {
    @Export var variable0: TypedArray<Int> = []
    // Godot will see `Array[int] variable0`

    @Export var variable1: TypedArray<Object?> = []
    // Godot will see `Array[int] variable1`
}
```


#### SwiftGodot Optional `TypedArray` - Godot `Variant`
_NOT_ toll-free bridging. Requires a heap allocation of the Swift wrapper every time the value is translated from `Godot` to `Swift`.

```swift
@Godot class CustomNode: Node {
    @Export var variable0: TypedArray<Int>? = []
    // Godot will see `Variant variable0`

    @Export var variable1: TypedArray<Object?>? = []
    // Godot will see `Variant variable1`
}
```
---

# Your custom types
#### ``Optional`` and non-optional `@Godot` classes - Godot `Object`-derived types
_Almost_ toll-free bridging.
Allocation only happens when type is initialized. That's how classes work in Swift.

All classes using `@Godot` will be visible in Godot exactly as you name it.
```swift
@Godot class CustomNode: Node {    
}

@Godot class AnotherNode: Node {
    @Export var variable0: AnotherNode? = nil
    // Godot will see `AnotherNode variable`

    @Export var variable1 = CustomNode()
    // Godot will see `CustomNode variable`
}
```

#### ``Optional`` and non-optional VariantConvertible - Godot `Variant`
_Maybe_ toll-free bridging:
1. The conversion runtime doesn't require allocations.
2. Cost of conversions depends on how expensive your `VariantConvertible` implementation is. Conversion will happened every time the type is translated back and forth between Swift and Godot.

You can conform your own types to `VariantConvertible`. They will be visible as `Variant`.
```swift
extension Date: VariantConvertible {
    public func toFastVariant() -> FastVariant? {
        timeIntervalSince1970.toFastVariant()
    }

    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Date {
        Date(timeIntervalSince1970: try TimeInterval.fromFastVariantOrThrow(variant))
    }
}

@Godot class CustomNode: Node {
    @Export var variable0: Date? = nil
    // Godot will see `Variant variable0`

    @Export var variable1 = Date.now
    // Godot will see `Variant variable1`
}
```

#### ``GodotBuiltinConvertible`` - Corresponding Godot builtin types 
_Maybe_ toll-free bridging:
1. The conversion runtime doesn't require allocations.
2. Cost of conversions depends on how expensive your `GodotBuiltinConvertible` implementation is. Conversion will happened every time the type is translated back and forth between Swift and Godot.

You can conform your own types to `GodotBuiltinConvertible`. They will be visible as type corresponding to `GodotBuiltinConvertible.GodotBuiltin`.
```swift
extension Date: GodotBuiltinConvertible {
    public func toGodotBuiltin() -> Double {
        timeIntervalSince1970
    }

    public static func fromGodotBuiltinOrThrow(_ value: Double) throws(VariantConversionError) -> Self {
        Date(timeIntervalSince1970: value)
    }
}

@Godot class CustomNode: Node {
    @Export var variable0 = Date.now
    // Godot will see `float variable0`
}
```

#### `Optional` ``GodotBuiltinConvertible`` - Godot `Variant`
_Maybe_ toll-free bridging:
1. The conversion runtime doesn't require allocations.
2. Cost of conversions depends on how expensive your `GodotBuiltinConvertible` implementation is. Conversion will happened every time the type is translated back and forth between Swift and Godot.

You can conform your own types to `GodotBuiltinConvertible`. They will be visible as type corresponding to `GodotBuiltinConvertible.GodotBuiltin`.
```swift
extension Date: GodotBuiltinConvertible {
    public func toGodotBuiltin() -> Double {
        timeIntervalSince1970
    }

    public static func fromGodotBuiltinOrThrow(_ value: Double) throws(VariantConversionError) -> Self {
        Date(timeIntervalSince1970: value)
    }
}

@Godot class CustomNode: Node {
    @Export var variable0: Date? = Date.now
    // Godot will see `Variant variable0`
}
```

