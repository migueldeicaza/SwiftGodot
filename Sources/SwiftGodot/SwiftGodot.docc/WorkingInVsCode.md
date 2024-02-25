# Working in VS Code

Develop and debug SwfitGodot Code in Visual Studio Code

## Overview

Visual Studio Code provides a compelling alternative to Xcode for SwiftGodot
developers on Mac, Linux, or Windows.


### Prerequisites

To develop with SwiftGodot in Visual Studio Code, you will need the following
prerequisites:

1. Godot Engine without .NET support from the [official Godot website](https://godotengine.org/download/). 

2. Visual Studio Code from the [official Visual Studio Code website](https://code.visualstudio.com/Download). 

3. Install Swift from the [official Swift website](https://www.swift.org/install/Swift).  

### Configuring Visual Studio Code

The Swift Extension for Visual Studio Code from the Swift Server Work Group 
provides code completion, code navigation, build task creation, and integration 
with LLDB for debugging, along with many other features for devloping code with
Swift.

Install the Swift Extension for Visual Studio from the 
[Visual Studio
Marketplace](https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang),
or search for Swift on the Extensions tab in Visual Studio Code.

Installing the Swift Extension will automatically install the CodeLLDB Extension
as a dependency for Visual Studio Code for debugging support.

### Create a Swift library package for your project

Create a folder on disk in a file location near the Godot project that you want 
to use with SwiftGodot.  For this article, we will assume you are working
against the sample project and code from the [Meet SwiftGodot Tutorial](https://migueldeicaza.github.io/SwiftGodotDocs/tutorials/swiftgodot-tutorials)

On the commmand line, change directories into the folder you created and run the
swift package command to initialize a new library package:

`swift package init --type library`

You can now open your package folder in Visual Studio Code:

`code .`

Or use the "Open Folder..." File menu option in Visual Studio Code.

### Setup SwiftGodot in Package.swift

Inside Visual Studio Code, open Package.swift

Set your library type to dynamic by adding `type: .dynamic,` to the products library section of your package configuration. E.g.,

```swift
.library(
   name: "SimpleRunnerDriver",
   type: .dynamic,
   targets: ["SimpleRunnerDriver"]),
```

Add the SwiftGodot dependency to your package.


```swift
dependencies: [
   .package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "main")
],
```

Modify your library target to reference the SwitGodot dependency, and add
necessary swift compiler and linker settings:


```swift
.target(
   name: "SimpleRunnerDriver",
   dependencies: [
         "SwiftGodot",
   ],
   swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
),
```

At this point, you should be able to follow the Meet SwiftGodot Tutorial
beginning in Section 2.

### Building your SwiftGodot package

When you are ready to build your SwiftGodot package, the Swift Extension
provides a default Build task you can execute with Visual Studio Code's Build
Shortcut - Ctrl+Shift+B (or Cmd+Shift+B on Mac).  

The initial build, especially on Windows, may take a very long time.

### Setting up your gdextension 

When creating your `gdextension` file, your configuration file will need to 
contain settings specific to your platform, and you will need to copy the
libraries for your operating system and architecture to the `bin` folder inside
your Godot project. 

#### Windows

Windows does not deal well with long paths, so you should make sure that you 
either checkout your SwiftGodot into a toplevel directory, or use the Windows
`subst` command to map a drive name to the location that contains your
SwiftGodot builds.

If you are developing on Windows, your `libraries` and `dependencies` will need
to be specified as `windows.debug.x86_64` and your libraries will be compiled
into `.dll` files, so that these sections should look like this:

```
[libraries]
windows.debug.x86_64 = "res://bin/SimpleRunnerDriver.dll"

[dependencies]
windows.debug.x86_64 = {"res://bin/SwiftGodot.dll" : ""}
```

You can copy these files to your Godot projects `bin` folder from the build 
output folder located in `.build\x86_64-unknown-windows-msvc\debug\` inside
the directory where you initialized your Swift package.

As an additional step on Windows, you will need to copy all of the Swift 
runtime libraries into the `bin` folder with SwiftGodot.dll.  This is means
copying all `*.dll` files from `C:\Program Files\Swift\runtime-development\usr\bin\`

#### Linux

If you are developing on Linux, your `libraries` and `dependencies` will need
to be specified as `linux.debug.x86_64` and your libraries will be compiled into
`lib*.so` files, so that these sections should look like this:

```
[libraries]
linux.debug.x86_64 = "res://bin/libSimpleRunnerDriver.so"

[dependencies]
linux.debug.x86_64 = {"res://bin/libSwiftGodot.so" : ""}
```

You can copy these files to your Godot projects `bin` folder from the build 
output folder located in `.build/x86_64-unknown-linux-gnu/debug/` inside
the directory where you initialized your Swift package.


### Debugging your SwiftGodot code

You can debug your SwiftGodot code on Windows or Linux using the 
CodeLLDB Extension to attach to your game launched from Godot.  

In order to do this, you will need to add an Attach to Process 
launch task  to your project.

In Visual Sutdio Code, switch to the "Run and Debug" tab.

Create a `launch.json` file by tapping on "create a launch.json file"
and selecting "LLDB", which should be the first suggested option.

In the newly created launch.json file, you should have a single
lldb task.  To turn this task into an attach task:

1. Change the value for `request` from `launch` to `attach` 
2. Change the value for `name` to `Attach to PID`
3. Remove the lines for `program`, `args`, and `cwd`
4. Add a line for `pid` with value `${command:pickProcess}`

Your launch configuration for lldb should now look like this:

```json
"type": "lldb",
"request": "attach",
"name": "Attach to PID",
"pid": "${command:pickProcess}"
```

Once you save this file, Attach to PID should be the default debug 
task, and can be run by pressing F5.

To debug your app, 
1. First, take note of running Godot process PIDs by running "Attach to PID" 
and searching for Godot. 

2. Launch your game from Godot

3. Return to Visual Studio and press F5 to run "Attach to PID" again.

4. Search again for Godot and select the PID for your game, which should be the
   only process that wasn't listed in step (1) above.  

> On Linux or Mac, it may be possible to differentiate your game's PID from other 
> Godot PIDs by looking at the additional information Visual Studio Code lists about 
> each process, including command line options.  On Windows, the Godot processes are 
> pretty much identical, making it difficult to differentiate your game from the editor.

At this point, Visual Studio Code should now stop on any breakpoints you have
set, and you should be able to inspect Variables, set Watches, etc.

> Warning: 
> On Mac, you will need to make your Godot engine debuggable following the steps from
> this article [Debug in Xcode](https://migueldeicaza.github.io/SwiftGodotDocs/documentation/swiftgodot/debuginxcode)