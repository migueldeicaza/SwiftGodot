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
