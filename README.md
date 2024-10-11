# SwiftGodot

[![SwiftPM compatible](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Linux%20%7C%20macOS%20%7C%20Windows-333333.svg?style=flat)
[![Swift Package Index](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmigueldeicaza%2FSwiftGodot%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/migueldeicaza/SwiftGodot)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://raw.githubusercontent.com/migueldeicaza/SwiftGodot/main/LICENSE)

SwiftGodot provides Swift language bindings for the Godot 4.2 game
engine using the new [GDExtension](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/what_is_gdextension.html) system (for 4.1 compatibility, use
the 4.1 branch, preview for upcoming 4.3 release is in the 4.3 branch).

SwiftGodot can be used to either build an extension that can be added
to an existing Godot project, where your code is providing services
to the game engine, or it can be used as an API with SwiftGodotKit
which embeds Godot as an application that is driven directly from
Swift.

Tutorials and Documentation:

* [Meet Swift Godot](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot)
* [SwiftGodot API Documentation](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/)
* [Differences to GDScript](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/differences)
* [Tutorials and walkthroughs](https://migueldeicaza.github.io/SwiftGodotDocs/tutorials/swiftgodot-tutorials/)
* SwiftGodot port of [KenneyNL's StarterKit 3D Platformer](https://github.com/lorenalexm/Starter-Kit-3D-Platformer-Swift)

Of interest to the community:
* Running Godot in VisionPro using [GodotVision](https://github.com/kevinw/GodotVision)
* Example Godot on Vision [GodotVisionExample](https://github.com/kevinw/GodotVisionExample)

Driving Godot from Swift has the advantage that on MacOS you can
debug your code from Xcode as well as the Godot code.

https://user-images.githubusercontent.com/36863/232163186-dc7c0290-71db-49f2-b812-c775c55b8b77.mov

# Why SwiftGodot?

* No game stutters caused by GC, unlike C#.

* Learn more: [Swift Godot: Fixing the Multi-million dollar mistake](https://www.youtube.com/watch?v=tzt36EGKEZo)

# Quickly Getting Started

The [SwiftGodotKick](https://github.com/EstevanBR/SwiftGodotKick) project can create a skeleton template
GDExtension with Swift, as well as a standalone SwiftGodotKit project that can be used to quickly
iterate on your game on MacOS.

# Supported Platforms

Currently, SwiftGodot can be used in projects targeting the iOS, Linux, macOS, or Windows platforms. It may be possible to target additional platforms, but testing for other platforms has not been completed and stability cannot be verified at this time.

# Development Status

SwiftGodot is built on the GDExtension framework, which is still in an [experimental](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/what_is_gdextension.html#differences-between-gdextension-and-c-modules) state, and consequently SwiftGodot is still in an experimental state. Compatibility may break in order to fix major bugs or include critical features. That being said, much of the Godot API surface has been implemented and SwiftGodot is suitable for use in small to mid size projects.

# Consuming SwiftGodot

There are two ways of consuming SwiftGodot, you can either reference
this module in SwiftPM by using this address - and it will trigger a
complete source code build for you, or to quickly iterate on MacOS,
you can use a convenient binary in the peer
https://github.com/migueldeicaza/SwiftGodotBinary

Currently this requires Swift 5.9 or Xcode 15.

# Working with this Repository

You should be all set by referencing this as a package from SwiftPM
but if you want to just work on the binding generator, you may want
to open the Generator project and edit the `okList` variable
to trim the build times.

# Driving Godot From Swift

To drive Godot from Swift, use the companion [`SwiftGodotKit`](https://github.com/migueldeicaza/SwiftGodotKit) 
module which embeds Godot directly into your application, which 
allows you to to launch the Godot runtime from your code.


# Creating an Extension

Creating an extension that can be used in Godot requires a few 
components:

* Your Swift code: this is where you bring the magic
* A `.gdextension` file that describes where to find the requires
  Swift library assets
* Some Swift registration code and bootstrap code
* Importing your extension into your project

## Your Swift Code

Your Swift code will be compiled into a shared library that Godot
will call.   To get started, the simplest thing to do is to 
create a Swift Library Package that references the Swift Godot 
package, like this:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyFirstGame",
    products: [
        .library(name: "MyFirstGame", type: .dynamic, targets: ["MyFirstGame"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "main")
    ],
    targets: [
        .target(
            name: "MyFirstGame",
            dependencies: ["SwiftGodot"])]
)
```

The above will compile all of SwiftGodot for you - alternatively, if
you do not need access to the source, you can use the `.binaryTarget`
feature of SwiftPM and reference an `.xcframework` that I have
conveniently published on GitHub at
https://github.com/migueldeicaza/SwiftGodotBinary

The next step is to create your source file with the magic on it,
here we declare a spinning cube:

```swift
import SwiftGodot

@Godot(.tool)
class SpinningCube: Node3D {
    public override func _ready () {
        let meshRender = MeshInstance3D()
        meshRender.mesh = BoxMesh()
        addChild(node: meshRender)
    }

    public override func _process(delta: Double) {
        rotateY(angle: delta)
    }
}
```

Additionally, you need to write some glue code for your 
project to be loadable by Godot, you can do it like this:

```swift
/// We register our new type when we are told that the scene is being loaded
func setupScene (level: GDExtension.InitializationLevel) {
    if level == .scene {
        register(type: SpinningCube.self)
    }
}

// Export our entry point to Godot:
@_cdecl("swift_entry_point")
public func swift_entry_point(
    interfacePtr: OpaquePointer?,
    libraryPtr: OpaquePointer?,
    extensionPtr: OpaquePointer?) -> UInt8
{
    print ("SwiftGodot Extension loaded")
    guard let interfacePtr, let libraryPtr, let extensionPtr else {
        print ("Error: some parameters were not provided")
        return 0
    }
    initializeSwiftModule(interfacePtr, libraryPtr, extensionPtr, initHook: setupScene, deInitHook: { x in })
    return 1
}
```

Alternatively, you can use the `#initSwiftExtension` macro:

```swift
import SwiftGodot

#initSwiftExtension(cdecl: "swift_entry_point", types: [SpinningCube.self])
```

## Bundling Your Extension

To make your extension available to Godot, you will need to 
build the binaries for all of your target platforms, as well
as creating a `.gdextension` file that lists this payload, 
along with the entry point you declared above.

You would create something like this in a file called
`MyFirstGame.gdextension`:

```yml
[configuration]
entry_symbol = "swift_entry_point"
compatibility_minimum = 4.2

[libraries]
macos.debug = "res://bin/MyFirstGame"
macos.release = "res://bin/MyFirstGame"
windows.debug.x86_32 = "res://bin/MyFirstGame"
windows.release.x86_32 = "res://bin/MyFirstGame"
windows.debug.x86_64 = "res://bin/MyFirstGame"
windows.release.x86_64 = "res://bin/MyFirstGame"
linux.debug.x86_64 = "res://bin/MyFirstGame"
linux.release.x86_64 = "res://bin/MyFirstGame"
linux.debug.arm64 = "res://bin/MyFirstGame"
linux.release.arm64 = "res://bin/MyFirstGame"
linux.debug.rv64 = "res://bin/MyFirstGame"
linux.release.rv64 = "res://bin/MyFirstGame"
android.debug.x86_64 = "res://bin/MyFirstGame"
android.release.x86_64 = "res://bin/MyFirstGame"
android.debug.arm64 = "res://bin/MyFirstGame"
android.release.arm64 = "res://bin/MyFirstGame"
```

In the example above, the extension always expects the 
platform specific payload to be called "MyFirstGame", 
regarless of the platform.   If you want to distribute
your extension to other users and have a single payload,
you will need to manually set different names for those.

## Installing your Extension

You need to copy both the new `.gdextension` file into 
an existing project, along with the resources it references.

Once it is there, Godot will load it for you.

## Using your Extension

Once you create your extension and have loaded it into
Godot, you can reference it from your code by using the
"Add Child Node" command in Godot (Command-A on MacOS)
and then finding it in the hierarchy.

In our example above, it would appear under Node3D, as it
is a Node3D subclass.

## Community

Join the community on [Slack](https://join.slack.com/t/swiftongodot/shared_invite/zt-2aqygohvb-stSRGEAN~c3awuMwtaqCAA)

## Contributing

Have a bug fix or feature request you'd like to see added? Consider contributing! Join our [community](#community) to get started.
