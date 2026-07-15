# Binary releases

SwiftGodot publishes prebuilt Apple-platform XCFrameworks after each GitHub
release. The release workflow uploads the artifacts to the matching SwiftGodot
release, then updates and tags
[SwiftGodotBinary](https://github.com/migueldeicaza/SwiftGodotBinary).

The binary package contains two XCFrameworks:

- `SwiftGodot`, dynamically linked to `SwiftGodotRuntime`
- `SwiftGodotRuntime`, which contains the GDExtension support implementation

Each contains macOS Apple silicon and Intel slices, an iOS device slice, and
iOS Simulator slices. Swift module interfaces are emitted in Release builds so
compatible newer Swift compilers can consume the binaries. Macro implementations
and GDExtension headers remain small source targets in SwiftGodotBinary.

## One-time repository setup

Add a `SWIFTGODOT_BINARY_TOKEN` Actions secret to SwiftGodot. It must be able to
read and write repository contents in `migueldeicaza/SwiftGodotBinary`. A
fine-grained personal access token scoped only to that repository is sufficient.
The normal workflow `GITHUB_TOKEN` uploads assets to the SwiftGodot release.

## Release behavior

Publishing a GitHub release triggers `.github/workflows/binaries.yml`. It:

1. checks out the release tag and pins Xcode 26.5 / Swift 6.3,
2. builds macOS, iOS, and iOS Simulator Release frameworks,
3. packages `SwiftGodot.xcframework.zip` and
   `SwiftGodotRuntime.xcframework.zip`,
4. generates and validates the SwiftGodotBinary manifest and source support
   targets, then commits and tags that update,
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
```

Omit `SWIFTGODOT_PLATFORMS` to build every supported Apple destination.
