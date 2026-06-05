# Building for Windows

The build process for the Windows platform requires a very recent
version of Swift, anything after 5.9.1 will do (5.9.0 will not).
Linux.

Windows support is generally the same as Linux or MacOS, with a couple of important differences:

* Path sizes that break the build
* Names of shared libraries.

Windows has a problem with very deep directory structures that the
Swift Build system can produce, and this is compounded by the default
location of files that you might have, something like
'C:\Users\Users\migueldeicaza\Documents\GitHub\Experiments\MyGames`
and you find yourself with odd errors.

You should use the `subst` command in Windows to map a new drive to
that path.

The issue of shared libraries comes down to the extension name of
shared libraries (you need to use `.dll` instead of `.dylib` or `.so`)
when describing those in your extension file.

You will also need to copy the swift standard library DLLs. The default installer adds them to 
`C:/Users/[USER]/AppData/Local/Programs/Swift/Runtimes/[Swift Version]/usr/bin`

Also add this section to your godot `.gdextension` after the `libraries` sections. This allows the dlls to copy automatically when exporting your project.

```
[dependencies]
windows.debug = {
    "res://bin/BlocksRuntime.dll" : "",
    "res://bin/dispatch.dll" : "",
    "res://bin/Foundation.dll" : "",
    "res://bin/FoundationNetworking.dll" : "",
    "res://bin/FoundationXML.dll" : "",
    "res://bin/swiftCore.dll" : "",
    "res://bin/swiftCRT.dll" : "",
    "res://bin/swiftDispatch.dll" : "",
    "res://bin/swiftDistributed.dll" : "",
    "res://bin/swiftObservation.dll" : "",
    "res://bin/swiftRegexBuilder.dll" : "",
    "res://bin/swiftRemoteMirror.dll" : "",
    "res://bin/swiftSwiftOnoneSupport.dll" : "",
    "res://bin/swiftWinSDK.dll" : "",
    "res://bin/swift_Concurrency.dll" : "",
    "res://bin/swift_Differentiation.dll" : "",
    "res://bin/swift_RegexParser.dll" : "",
    "res://bin/swift_StringProcessing.dll" : "",
}
windows.release = {
    "res://bin/BlocksRuntime.dll" : "",
    "res://bin/dispatch.dll" : "",
    "res://bin/Foundation.dll" : "",
    "res://bin/FoundationNetworking.dll" : "",
    "res://bin/FoundationXML.dll" : "",
    "res://bin/swiftCore.dll" : "",
    "res://bin/swiftCRT.dll" : "",
    "res://bin/swiftDispatch.dll" : "",
    "res://bin/swiftDistributed.dll" : "",
    "res://bin/swiftObservation.dll" : "",
    "res://bin/swiftRegexBuilder.dll" : "",
    "res://bin/swiftRemoteMirror.dll" : "",
    "res://bin/swiftSwiftOnoneSupport.dll" : "",
    "res://bin/swiftWinSDK.dll" : "",
    "res://bin/swift_Concurrency.dll" : "",
    "res://bin/swift_Differentiation.dll" : "",
    "res://bin/swift_RegexParser.dll" : "",
    "res://bin/swift_StringProcessing.dll" : "",
}

```

## Building

From your root project directory, all you should have to do now is
clean and build your code! A simple command of `swift package clean &&
swift build` will be all you need.

### The GitHub Action

If handing off your build process to GitHub Actions is more your
thing, here is a starting point for a `build.yml` file. You will need
to make use of [Build
Artifacts](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts)
to download your projects __.dll__ file; that though is beyond the
scope of this document.

```yml
name: Swift Builds
on: [push]

jobs:
  windows:
    name: Windows
    runs-on: windows-latest
    steps:
      - uses: compnerd/gha-setup-swift@main
        with:
          branch: swift-5.9-release
          tag: 5.9-RELEASE
      - uses: actions/checkout@v4
      - name: Get Swift version
        run: swift --version
      - name: Run Swift build
        run: swift package clean && swift build
```

## Using a prebuilt library on Windows (and probably Linux)

SPM does not allow using `.binaryTarget` on platforms other than macOS and iOS, probably due to the lack of an archive format akin to `(xc)framework` for those platforms. 

However, using unsafe compiler and linker flags, we can mimic that behavior and still use a prebuilt library on Windows, while still benefiting from the macros and plugins.

Here are instructions on how to do that:
1. Obtain the prebuilt binary
    1. first, clone SwiftGodot somewhere and build it for release independently of your project using `swift build -c release` (this might take a while)
    2. inside `.build`, you will find a `release` folder, rename it to `SwiftGodotBinary` and store it somewhere, this is your "binary target"
    - make sure there is a `Modules` directory inside, as well as `SwiftGodotMacroLibrary-tool.exe`, `EntryPointGenerator-tool.exe`, `SwiftGodot.lib` and `SwiftGodot.dll`
2. Copy the entry point plugin
    - This is necessary because, sadly, SPM doesn't allow specifying `swiftSettings` for plugins. Otherwise, we would have used `-load-plugin-executable` to register the "tool" referenced by the plugin
    1. Add a new folder at the root of your package called `Plugins/EntryPointGeneratorPlugin`
    2. Inside, copy `EntryPointGeneratorPlugin.swift` from the SwiftGodot source code
        - In the end, you should have `Plugins/EntryPointGeneratorPlugin/EntryPointGeneratorPlugin.swift`
    3. Open the file and replace `generatorPath` by the path to `EntryPointGenerator-tool.exe` (can be found in `SwiftGodotBinary`):
        ```swift
        let generatorPath = URL(filePath: "path\\to\\SwiftGodotBinary\\EntryPointGenerator-tool.exe")
        ```
3. Edit the package manifest
    1. Open your `Package.swift` and remove all references of the previous SwiftGodot dependency
    2. At the top of the file, add the following declaration, replacing the path with the actual path to `SwiftGodotBinary` on your disk:
        ```swift
        let swiftGodotBinaryPath = "path\\to\\SwiftGodotBinary"
        ``` 
    3. Then, inside all targets that use `SwiftGodot`, add the following settings:
        ```swift
        swiftSettings: [
            .unsafeFlags([
                "-I", "\(swiftGodotBinaryPath)\\Modules", // allows importing SwiftGodot
                "-load-plugin-executable", "\(swiftGodotBinaryPath)\\SwiftGodotMacroLibrary-tool.exe#SwiftGodotMacroLibrary", // allows using macros
            ])
        ],
        linkerSettings: [
            .unsafeFlags([
                // Allows linking SwiftGodot / finding SwiftGodot.dll
                "-L", swiftGodotBinaryPath, 
                "-l", "\(swiftGodotBinaryPath)\\SwiftGodot.lib",
            ])
        ],
        plugins: [
            // Entry point generator plugin (don't forget to declare it below as well)
            .plugin(name: "EntryPointGeneratorPlugin")
        ]
        ```
    4. Finally, declare the plugin in the list of targets:
        ```swift
        .plugin(
            name: "EntryPointGeneratorPlugin",
            capability: .buildTool()
        ),
        ```
4. `swift package clean`, `swift build` and you're good to go!
