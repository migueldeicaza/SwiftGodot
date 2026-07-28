# Binary releases

SwiftGodot publishes prebuilt Apple-platform XCFrameworks after each GitHub
release. The release workflow uploads the artifacts to the matching SwiftGodot
release, then updates and tags
[SwiftGodotBinary](https://github.com/migueldeicaza/SwiftGodotBinary).

The binary package contains four XCFrameworks:

- `SwiftGodot`, dynamically linked to `SwiftGodotRuntime`
- `SwiftGodotRuntime`, which contains the GDExtension support implementation
- `GDExtension`, the C headers with an otherwise empty static library
- `SwiftGodotMacroPlugin`, the prebuilt macro implementation

The first three contain macOS Apple silicon and Intel slices, an iOS device
slice, and iOS Simulator slices. Swift module interfaces are emitted in Release
builds so compatible newer Swift compilers can consume the binaries.

## The prebuilt macro plugin

Macro plugins are host tools, so `SwiftGodotMacroPlugin.xcframework` holds one
macOS Apple silicon and Intel static library: the SwiftGodot macro
implementations and the swift-syntax they use, compiled together and exposing
the single C entry point `swiftgodot_macro_plugin_main`. SwiftGodotBinary
declares a `SwiftGodotMacroLibrary` macro target whose only source calls that
function, which keeps the plugin module name every `#externalMacro` declaration
spells while removing swift-syntax from the package graph. Consumers therefore
neither check out nor compile swift-syntax, and they do not depend on SwiftPM
finding a swift-syntax prebuilt for their exact toolchain build — those are
published per toolchain and are frequently missing.

That XCFramework ships no headers. Xcode copies the headers of every
XCFramework into one shared include directory, so a second `module.modulemap`
there collides with the one from `GDExtension.xcframework` and the client build
fails with "Multiple commands produce ... include/module.modulemap". The shim
declares the entry point with `@_silgen_name` instead, which is sound here
because a parameterless function returning `Int32` uses the same calling
convention in C and in Swift.

`scripts/build-macro-plugin` also strips the archive. The objects otherwise
keep a debug map that names the temporary build directory, and every client
link then warns "unable to open object file" once per module.

`scripts/build-macro-plugin` builds that XCFramework. It compiles
`Sources/SwiftGodotMacroLibrary` as a static library, excluding `main.swift`,
because an archive that defines `main` cannot be linked into the shim; the
plugin entry point for that build is `PrebuiltEntry.swift`. Because the archive
is linked by the consumer's own toolchain and exposes no Swift module, it is not
tied to the Swift version that produced it.

## One-time repository setup

Add a `SWIFTGODOT_BINARY_TOKEN` Actions secret to SwiftGodot. It must be able to
read and write repository contents in `migueldeicaza/SwiftGodotBinary`. A
fine-grained personal access token scoped only to that repository is sufficient.
The normal workflow `GITHUB_TOKEN` uploads assets to the SwiftGodot release.

## Release behavior

Publishing a GitHub release triggers `.github/workflows/binaries.yml`. It:

1. checks out the release tag and pins Xcode 26.6 / Swift 6.3.3,
2. builds macOS, iOS, and iOS Simulator Release frameworks and the macro
   plugin,
3. packages one zip per XCFramework,
4. generates and validates the SwiftGodotBinary manifest and source support
   targets through a separate consumer package, failing if the consumer
   resolves swift-syntax, then commits and tags that update,
5. uploads the assets and pushes the binary repository commit and tag.

The commit-before-tag ordering fixes the historical off-by-one tags in the
binary repository. Re-running is guarded: the workflow accepts an existing
binary tag only when it already points to the generated commit, and stops
before replacing release assets if it does not.

## Manual validation and publishing

Run a workflow dry run for an existing release tag without changing either
repository:

```sh
gh workflow run binaries.yml -f tag=<tag> -f publish=false
```

Set `publish=true` to upload the assets and update SwiftGodotBinary. The tag
must contain this binary automation; use this for releases made after the
workflow lands.

For a local macOS-only smoke test:

```sh
SWIFTGODOT_PLATFORMS=macos scripts/build-binary-artifacts .build/binary-smoke
scripts/test-binary-package .build/binary-smoke
```

Omit `SWIFTGODOT_PLATFORMS` to build every supported Apple destination. The
macro plugin is always built for both macOS architectures; set
`SWIFTGODOT_MACRO_PLUGIN_ARCHS=arm64` to halve that step while iterating
locally.
