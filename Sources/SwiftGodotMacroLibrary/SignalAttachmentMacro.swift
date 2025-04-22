// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/24.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SignalAttachmentMacro: AccessorMacro {
    enum ProviderDiagnostic: Error, DiagnosticMessage {
        case invalidDeclaration
        case missingTypeAnnotation

        var severity: DiagnosticSeverity { .error }
        
        var message: String {
            switch self {
                case .invalidDeclaration:
                    "Signal can only be applied to stored properties"
                case .missingTypeAnnotation:
                    "Signal requires an explicit type declaration of SimpleSignal or SignalWithArguments<...>"
            }
        }
        
        var diagnosticID: MessageID {
            MessageID(domain: "SwiftGodotMacros", id: message)
        }
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            let invalidUsageErr = Diagnostic(node: node.root, message: ProviderDiagnostic.invalidDeclaration)
            context.diagnose(invalidUsageErr)
            return []
        }

        guard let signalType = varDecl.bindings.first?.typeAnnotation?.type else {
            let missingAnnotationErr = Diagnostic(node: node.root, message: ProviderDiagnostic.missingTypeAnnotation)
            context.diagnose(missingAnnotationErr)
            return []
        }

        guard let signalName = varDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            fatalError("No identifier for this expression could be found.")
        }

        return [
            """
            get { \(raw: signalType)(target: self, signalName: \"\(raw: signalName.camelCaseToSnakeCase())\") }
            """
        ]
    }
    
}
