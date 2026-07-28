//
//  PrebuiltEntry.swift
//  SwiftGodotMacroLibrary
//
//  C entry point for the prebuilt macro plugin.
//
//  `scripts/build-macro-plugin` compiles these sources as a static library and
//  packages it as the `SwiftGodotMacroPlugin` XCFramework. SwiftGodotBinary
//  links that archive into a `SwiftGodotMacroLibrary` macro target whose only
//  source calls this function, so consumers of the binary package never build
//  swift-syntax.
//
//  The module name of this target must stay `SwiftGodotMacroLibrary`: the
//  compiler asks the plugin for macro types by their qualified name, which is
//  what every `#externalMacro(module: "SwiftGodotMacroLibrary", ...)`
//  declaration in SwiftGodot spells.
//

import Foundation
import SwiftCompilerPlugin

/// Runs the SwiftGodot compiler plugin and returns its exit status.
@_cdecl("swiftgodot_macro_plugin_main")
public func swiftgodot_macro_plugin_main() -> Int32 {
    do {
        try SwiftGodotCompilerPlugin.main()
    } catch {
        FileHandle.standardError.write(Data("SwiftGodot macro plugin failed: \(error)\n".utf8))
        return 1
    }
    return 0
}
