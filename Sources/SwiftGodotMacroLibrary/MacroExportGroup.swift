//
//  MacroExportGroup.swift
//
//  Created by Estevan Hernandez on 12/4/23.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GodotMacroExportGroup: DeclarationMacro {
    public static func expansion(
      of node: some FreestandingMacroExpansionSyntax,
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}
