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

        var severity: DiagnosticSeverity { .error }

        var message: String {
            switch self {
            case .invalidDeclaration:
                "SceneTree can only be applied to stored properties"
            case .missingTypeAnnotation:
                "SceneTree requires an explicit type declaration"
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "SwiftGodotMacros", id: rawValue)
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

        let optionalType = nodeType.as(OptionalTypeSyntax.self)?.wrappedType
        let unwrappedType = nodeType.as(ImplicitlyUnwrappedOptionalTypeSyntax.self)?.wrappedType ?? nodeType

        if let optionalType {
            // the type was optional, so use an as? case and allow nil
            return [
                """
                get { getNodeOrNull(path: NodePath(stringLiteral: \"\(raw: preferredIdentifier ?? nodeIdentifier.text)\")) as? \(optionalType) }
                """,
            ]
        } else {
            // the type was non-optional, so use as! and force unwrap; this will be a runtime error if the node is not found
            return [
                """
                get { getNodeOrNull(path: NodePath(stringLiteral: \"\(raw: preferredIdentifier ?? nodeIdentifier.text)\")) as? \(unwrappedType) }
                """,
            ]
        }
    }
}
