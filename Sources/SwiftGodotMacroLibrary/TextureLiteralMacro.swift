//
//  TextureLiteralMacro.swift
//  SwiftGodot
//
//  Created by Marquis Kurt on 6/11/23.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Texture2DLiteralMacro: ExpressionMacro {
    enum ProviderDiagnostic: String, DiagnosticMessage {
        case missingArguments
        var severity: DiagnosticSeverity {
            switch self {
            case .missingArguments: return .error
            }
        }

        var message: String {
            switch self {
            case .missingArguments:
                return "Argument 'path' is missing."
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "SwiftGodotMacros", id: rawValue)
        }
    }

    public static func expansion(of node: some FreestandingMacroExpansionSyntax,
                                 in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            let argumentError = Diagnostic(node: node.root, message: ProviderDiagnostic.missingArguments)
            context.diagnose(argumentError)
            return "\"\""
        }
        let location: AbstractSourceLocation = context.location(of: node)!
        return """
        {
            guard let texture: Texture2D = GD.load(path: \(argument)) else {
                GD.pushError("Texture could not be loaded.", \(raw: location.file), \(raw: location.line))
                preconditionFailure(
                    "Texture could not be loaded.",
                    file: \(raw: location.file),
                    line: \(raw: location.line))
            }
            return texture
        }()
        """
    }
}
