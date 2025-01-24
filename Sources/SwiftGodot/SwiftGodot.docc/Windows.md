# Using SwiftGodot on Windows

## Extension Dependencies

Since Swift is not a system component on Windows, you will need to make a copy
of the Swift runtime libraries that you use, and place those side-by-side the
extension that you created.

On Windows, you can use the `dumpbin /dependents` command to see which which
libraries you need, like this:

```
C:\project> dumpbin /dependents MyExtension.dll
Image has the following dependencies:

    SwiftGodot.dll
    swiftCore.dll
    swift_Concurrency.dll
    swiftWinSDK.dll
    swiftSwiftOnoneSupport.dll
    swiftCRT.dll
    KERNEL32.dll
    VCRUNTIME140.dll
    api-ms-win-crt-runtime-l1-1-0.dll
```

Those files are typically located in `AppData\Local\Programs\Swift\Runtimes`.

## Debug Symbols

On Windows, if you want to get debug symbols in the Windows Native format, build
your extension like this:

```
C:\project> swift build -debug-info-format codeview 
```
## Using Relative Paths

On Windows, you can use relative paths to reference your library, so you do not
need to copy binaries to your game when making changes, like this:

```
windows.x86_64.release = "../../../project/.build/release/SandboxSwift.dll"
windows.x86_64.debug = "../../../project/.build/debug/SandboxSwift.dll"
```

