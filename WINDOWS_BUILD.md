# Building for Windows

The build process for the Windows platform differs a bit from macOS or Linux. 
One of the largest contributors to that is the Swift build chain on Windows does not support macros [apple/swift#68272](https://github.com/apple/swift/issues/68272) at this time.
Many core concepts are the same between the other platforms and Windows, and those will be highlighted here.

This document assumes that you already have the Swift 5.9 build chain installed on your system - A sample GitHub Action for building on Windows will be provided if not.

## The Swift package

Your first deviation from building for macOS is the `Package.swift` file. The `-Xlinker` flag used for __dynamic_lookup__ is not supported on Windows. To work around that, and still maintain ability to build on non-Windows platforms, we create an empty `[LinkerSetting]` array, only populate if building on macOS. The modified file should now look similar to the following:

```swift
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var linkerSettings: [LinkerSetting] = []
#if os(macOS)
linkerSettings.append(
	.unsafeFlags([
		"-Xlinker", "-undefined",
		"-Xlinker", "dynamic_lookup"	
	])
)
#endif

let package = Package(
    name: "SwiftGodotCrossBuild",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftGodotCrossBuild",
			type: .dynamic,
            targets: ["SwiftGodotCrossBuild"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "main"),
    ],
    targets: [
        .target(
            name: "SwiftGodotCrossBuild",
            dependencies: ["SwiftGodot"],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])],
            linkerSettings: linkerSettings
        )
    ]
)
```

## Macros - The lack thereof

Since there is currently no support for macros on Windows at this time, both the classes you write and the Swift GDExtension entry point will need to be more verbose. 

### Defining the SpinningCube

Using the `SpinningCube` sample class shown in the base documentation as a starting point, you will need to add a few initializers that would otherwise be provided by the macros on macOS.

At the top of your class definition in `SpinningCube.swift`, you will need to add the following code while also removing any macros you already have in place.

```swift
// MARK: - Required initializers for Godot
required init(nativeHandle _: UnsafeRawPointer) {
	fatalError("init(nativeHandle:) called, it is a sign that something is wrong, as these objects should not be re-hydrated")
}

required init() {
	SpinningCube._initClass
	super.init()
}

static var _initClass: Void = {
	let className = StringName("SpinningCube")
	let classInfo = ClassInfo<SpinningCube>(name: className)
} ()
```

While it would be possible for you to use compiler directives as seen in the `Package.swift` and continue to use macros on other platforms this may be seen as muddying the code.

The complete `SpinningCube.swift` file should now look like the following:

```swift
import SwiftGodot

class SpinningCube: Node3D {
	required init(nativeHandle _: UnsafeRawPointer) {
		fatalError("init(nativeHandle:) called, it is a sign that something is wrong, as these objects should not be re-hydrated")
	}

	required init() {
		SpinningCube._initClass
		super.init()
	}

	static var _initClass: Void = {
		let className = StringName("SpinningCube")
		let classInfo = ClassInfo<SpinningCube>(name: className)
	} ()


    public override func _ready() {
        let renderer = MeshInstance3D()
        renderer.mesh = BoxMesh()
        addChild(node: renderer)
    }
    
    public override func _process(delta: Double) {
        rotateY(angle: delta)
    }
}
```

### GDExtension entry point

The last bit of code change needed to get the sample project working on Windows will be within the `Entry.swift` file. These required changes here require far more than your `SpinningCube.swift` updates; though they can all be done in around 21 lines of code. The needed updates are covered already in the documentation for other platforms, but will be covered here again.

To start, delete the line containing the `#initSwiftExtension` macro if it already exists. Next you will need to define a function to register your classes; to stay consistent it should be named `setupScene`. You should have something similar to this function:

```swift
/// MARK: - Register your custom classes with Godot
func setupScene(level: GDExtension.InitializationLevel) {
	if level == .scene {
		register(type: SpinningCube.self)
	}
}
```

The next step will be to define your `swift_entry_point` function. While far more verbose than a single macro, it is still rather straight forward. It verifies the `OpaquePointer` parameters passed to the function then hands them off to the `initializeSwiftModule` function. The code should come together like so:

```swift
/// MARK: - Expose the entry point to GDExtension
@_cdecl("swift_entry_point")
public func swift_entry_point(
	interfacePtr: OpaquePointer?,
	libraryPtr: OpaquePointer?,
	extensionPtr: OpaquePointer?
) -> UInt8 {
	print("Extension loaded.")
	guard let interfacePtr, let libraryPtr, let extensionPtr else {
		print("Error: Some parameters were not provided!")
		return 0
	}
	initializeSwiftModule(interfacePtr, libraryPtr, extensionPtr, initHook: setupScene, deInitHook: { x in })
	return 1
}
```

With those code changes made to `Entry.swift`, you should be ready to build for Windows! The complete file for the entry point will now be as follows:

```swift
import SwiftGodot

func setupScene(level: GDExtension.InitializationLevel) {
	if level == .scene {
		register(type: SpinningCube.self)
	}
}

@_cdecl("swift_entry_point")
public func swift_entry_point(
	interfacePtr: OpaquePointer?,
	libraryPtr: OpaquePointer?,
	extensionPtr: OpaquePointer?
) -> UInt8 {
	print("Extension loaded.")
	guard let interfacePtr, let libraryPtr, let extensionPtr else {
		print("Error: Some parameters were not provided!")
		return 0
	}
	initializeSwiftModule(interfacePtr, libraryPtr, extensionPtr, initHook: setupScene, deInitHook: { x in })
	return 1
}
```

## Building

From your root project directory, all you should have to do now is clean and build your code! A simple command of `swift package clean && swift build` will be all you need.

### The GitHub Action

If handing off your build process to GitHub Actions is more your thing, here is a starting point for a `build.yml` file. You will need to make use of [Build Artifacts](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts) to download your projects __.dll__ file; that though is beyond the scope of this document.
