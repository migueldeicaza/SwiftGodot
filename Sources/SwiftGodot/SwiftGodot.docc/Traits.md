# ``SwiftGodot`` Package Traits

SwiftGodot ships with package traits so you can choose how much of the generated
Godot API surface is compiled. This helps keep build times and binary sizes in
check when you only need a subset of the engine.

## Available traits

- ``Core`` pulls in the Swift runtime support, generated builtins, and the small
  set of Object-derived types (including ``Node``) needed to materialise handles
  coming back from Godot. This is ideal for utilities or headless tools that do
  not interact with the full scene graph.
- ``Medium`` enables everything from ``Core`` and adds the most common runtime
  services—windowing, input, audio, resource loading/saving, and the rendering
  bridge. Use this for most gameplay code and editor tooling.
- ``Full`` restores the entire generated surface (equivalent to SwiftGodot prior
  to traits) and is still the default when no explicit choice is made.

Traits compose additively. Medium implicitly enables Core, and Full enables
Medium.

## Consuming SwiftGodot with traits

SwiftPM 6.1 or newer is required to target these traits. To depend on
SwiftGodot with a reduced surface area, disable the defaults and opt into the
traits you need:

```swift
.package(
    url: "https://github.com/migueldeicaza/SwiftGodot",
    branch: "main",
    traits: [
        .trait("Core")
    ]
)
```

For ad-hoc builds you can achieve the same result from the command line:

```bash
swift build --disable-default-traits --traits Core
```

Swap `Core` for `Medium` or `Full` to test the other configurations.

## Behavioural differences

Code that lives behind richer traits is guarded with `#if Core`, `#if Medium`,
or `#if Full` directives. When a type is not available in the selected
profile:

- Generated wrappers guarded by the missing trait are not compiled.
- Convenience extensions fall back to basic logging or no-ops where possible so
  Core builds continue to function without the broader runtime.

When in doubt, try the smaller trait first and move up if the compiler reports a
missing type or API.
