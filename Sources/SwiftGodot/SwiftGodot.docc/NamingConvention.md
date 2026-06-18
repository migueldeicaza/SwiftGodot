# Godot Naming Convention

How SwiftGodot exposes your Swift symbols to Godot, and how to turn the
automatic conversion off.

## Overview

Swift and Godot use different naming conventions. Swift uses `camelCase` for
methods, properties, and enum cases; Godot uses `snake_case` for methods,
properties, signals, and arguments, and `UPPER_SNAKE_CASE` for enum constants.
(Class names are `PascalCase` in both, so they are never changed.)

By default SwiftGodot bridges this gap for you: every symbol you register with
the engine is exposed under Godot's convention. This is controlled by the
`automatic_godot_naming_convention` package trait, which is **enabled by
default**.

### What gets converted

With the trait enabled (the default), the names Godot sees are:

| Swift declaration | Exposed to Godot as |
| --- | --- |
| `@Callable func computeSpeedValue(targetNode:)` | method `compute_speed_value`, argument `target_node` |
| `@Export var maxHealthPoints: Int` | property `max_health_points` (+ `get_max_health_points` / `set_max_health_points`) |
| `@Signal var playerDidJump: SignalWithArguments<Int>` | signal `player_did_jump` |
| `@Rpc func syncWorldState()` | RPC method `sync_world_state` |
| `enum DamageKind: Int { case fireDamage }` | constant `FIRE_DAMAGE` |
| `class PlayerShip: Node` | class `PlayerShip` (unchanged) |

Single-word identifiers are unchanged (`func run()` stays `run`), and the
conversion is idempotent, so names that are already in Godot style (such as
`get_health` or `_ready`) are left as-is.

This matters whenever you reference a symbol by its string name — for example
calling it from GDScript, or via ``Object/call(method:_:)``,
``Object/connect(signal:callable:flags:)``, or ``Node/rpc(method:)``. Use the
Godot name in those cases:

```gdscript
# GDScript calling a Swift @Callable `func computeSpeedValue(...)`
node.compute_speed_value(target)
```

## Disabling the conversion

If you are upgrading an existing project that already exposes Swift names
verbatim (the behavior before this trait existed), or you simply prefer to
control every Godot name yourself, disable the trait in the package that
depends on SwiftGodot.

Specify the `traits:` argument on the dependency and omit the defaults. Because
`automatic_godot_naming_convention` is SwiftGodot's only default trait, an empty
trait set turns it off:

```swift
// Package.swift
.package(
    url: "https://github.com/migueldeicaza/SwiftGodot",
    from: "0.0.0",
    traits: []            // opt out of default traits -> no automatic conversion
)
```

To keep some traits while disabling the naming conversion, list exactly the ones
you want (still omitting `automatic_godot_naming_convention`):

```swift
.package(
    url: "https://github.com/migueldeicaza/SwiftGodot",
    from: "0.0.0",
    traits: ["with_multi_process"]
)
```

In Xcode, open the package dependency's settings and toggle **Package Traits**;
from the command line you can build with `swift build --disable-default-traits`
(or `--traits …` to choose an explicit set).

With the trait disabled, **all** of the conversions above are turned off and
your Swift identifiers are registered with Godot exactly as written
(`computeSpeedValue`, `maxHealthPoints`, `playerDidJump`, `fireDamage`, …). This
is a single, package-wide switch — it is not configurable per declaration.

## Deprecated: `@Callable(autoSnakeCase:)`

Before this trait, ``Callable`` accepted an `autoSnakeCase` argument to opt a
single method into `snake_case` conversion. Naming is now governed entirely by
the `automatic_godot_naming_convention` trait, so the argument is ignored and
deprecated. Use plain `@Callable` and control naming with the trait instead.
