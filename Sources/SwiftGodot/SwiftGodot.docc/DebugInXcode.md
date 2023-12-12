# Debug in Xcode

Debug Swift code written for Godot in Xcode.

## Overview

Debugging your SwiftGodot-based extensions using Xcode can either be done with a
binary Godot executable that you got directly from the Godot project, or using
your own build of Godot.

### Make an Official Godot Engine debuggable

These steps are only required if you are using an official Godot built.  If you
compiled your own Godot locally, you do not need to do folow any of these steps.

1. Download Godot Engine without .Net support version in the [official website](https://godotengine.org/download/macos/).

2. Add `com.apple.security.get-task-allow` entitlement and resign it.

```shell
mkdir -p /tmp/Godot
cp -R ~/Downloads/Godot.app /tmp/Godot/
cd /tmp/Godot/
codesign --display --xml --entitlements Godot.entitlements Godot.app
open Godot.entitlements 
# By default Finder will choose Xcode to open .entitlements file.
# You can open and edit it through any other application which can handle xml.
# Add <key>com.apple.security.get-task-allow</key><true/> in the opened Editor Application
codesign -s - --deep --force --options=runtime --entitlements Godot.entitlements Godot.app
cp -Rf ./Godot.app ~/Downloads/Godot.app
```

> Warning:
> Alternatively you can also [disable macOS's
> SIP](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection)
> to allow debugging anything. Use at your risk.

### Debug Swift code

1. Launch the re-signed Godot app, choose our target project and open it in
   Godot.

2. Open our Swift Package via Xcode and add breakpoints.

3. Choose Debug -> Attach to Process in the menu bar of Xcode and locate the
   existing Godot process here (Remember the pids of the existing Godot
   process).

4. Go to Godot Editor and launch the game.

5. Choose Debug -> Attach to Process in the menu bar of Xcode again and choose
   the new Godot process whose pid is not in the pids list we get in Step 3.

6. Trigger some event if needed and we'll hit the breakpoints we have added in
   Step 2.

![Screenshot of Xcode hitting a breakpoint](debug.png)
