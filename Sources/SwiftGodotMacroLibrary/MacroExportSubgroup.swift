//
//  MacroExportSubgroup.swift
//
//  Created by Estevan Hernandez on 1/20/24.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GodotMacroExportSubgroup: DeclarationMacro {
    public static func expansion(
      of node: some FreestandingMacroExpansionSyntax,
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}
