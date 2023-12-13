//
//  SceneTreeMacro.swift
//  SwiftGodot
//
//  Created by Marquis Kurt on 6/22/23.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SceneTreeMacro: AccessorMacro {
    enum ProviderDiagnostic: String, DiagnosticMessage {
        case invalidDeclaration
        case missingTypeAnnotation
        case nonOptionalTypeAnnotation

        var severity: DiagnosticSeverity { .error }

        var message: String {
            switch self {
            case .invalidDeclaration:
                "SceneTree can only be applied to stored properties"
            case .missingTypeAnnotation:
                "SceneTree requires an explicit type declaration"
            case .nonOptionalTypeAnnotation:
                "Stored properties with SceneTree must be marked as Optional"
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "SwiftGodotMacros", id: rawValue)
        }
    }

    struct MarkOptionalMessage: FixItMessage {
        var message: String {
            "Mark as Optional"
        }

        var fixItID: SwiftDiagnostics.MessageID {
            ProviderDiagnostic.nonOptionalTypeAnnotation.diagnosticID
        }
    }

    public static func expansion(of node: AttributeSyntax,
                                 providingAccessorsOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax]
    {
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            let invalidUsageErr = Diagnostic(node: node.root, message: ProviderDiagnostic.invalidDeclaration)
            context.diagnose(invalidUsageErr)
            return []
        }

        guard let nodeType = varDecl.bindings.first?.typeAnnotation?.type else {
            let missingAnnotationErr = Diagnostic(node: node.root, message: ProviderDiagnostic.missingTypeAnnotation)
            context.diagnose(missingAnnotationErr)
            return []
        }

        guard let nodeIdentifier = varDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            fatalError("No identifier for this expression could be found.")
        }

        let preferredIdentifierExpr = node.arguments?.as(LabeledExprListSyntax.self)?.first?.expression.as(StringLiteralExprSyntax.self)
        let preferredContent = preferredIdentifierExpr?.segments.first?.as(StringSegmentSyntax.self)?.content
        let preferredIdentifier = preferredContent?.text

        let unwrappedType = nodeType.as(OptionalTypeSyntax.self)?.wrappedType ?? nodeType.as(ImplicitlyUnwrappedOptionalTypeSyntax.self)?.wrappedType

        guard let unwrappedType else {
            let newOptional = OptionalTypeSyntax(wrappedType: nodeType)
            let addOptionalFix = FixIt(message: MarkOptionalMessage(),
                                       changes: [.replace(oldNode: Syntax(nodeType), newNode: Syntax(newOptional))])
            let nonOptional = Diagnostic(node: nodeType.root,
                                         message: ProviderDiagnostic.nonOptionalTypeAnnotation,
                                         fixIts: [addOptionalFix])
            context.diagnose(nonOptional)
            return [
                """
                get { getNodeOrNull(path: NodePath(stringLiteral: \"\(raw: preferredIdentifier ?? nodeIdentifier.text)\")) as? \(nodeType) }
                """,
            ]
        }

        return [
            """
            get { getNodeOrNull(path: NodePath(stringLiteral: \"\(raw: preferredIdentifier ?? nodeIdentifier.text)\")) as? \(unwrappedType) }
            """,
        ]
    }
}
