//
//  main.swift
//  SwiftGodotMacroLibrary
//
//  Entry point for the macro plugin when it is built from source, as the
//  `SwiftGodotMacroLibrary` macro target of the SwiftGodot package.
//
//  The prebuilt plugin shipped with SwiftGodotBinary excludes this file and
//  starts the same plugin through `PrebuiltEntry.swift` instead.
//

import SwiftCompilerPlugin

try SwiftGodotCompilerPlugin.main()
