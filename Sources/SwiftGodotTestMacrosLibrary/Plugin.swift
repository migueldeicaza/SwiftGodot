//
//  Plugin.swift
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SwiftGodotTestMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SwiftGodotTestMacro.self,
        SwiftGodotTestSuiteMacro.self,
    ]
}
