//
//  PickerNameProviderMacro.swift
//  SwiftGodot
//
//  Created by Marquis Kurt on 6/9/23.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PickerNameProviderMacro: ExtensionMacro {
    enum ProviderDiagnostic: String, DiagnosticMessage {
        case notAnEnum
        case missingInt
        var severity: DiagnosticSeverity {
            switch self {
            case .notAnEnum: return .error
            case .missingInt: return .error
            }
        }

        var message: String {
            switch self {
            case .notAnEnum:
                return "@PickerNameProvider can only be applied to an 'enum'"
            case .missingInt:
                return "@PickerNameProvider requires an Int64 backing"
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "SwiftGodotMacros", id: rawValue)
        }
    }

    public static func expansion(of node: AttributeSyntax,
                                 attachedTo declaration: some DeclGroupSyntax,
                                 providingExtensionsOf type: some TypeSyntaxProtocol,
                                 conformingTo protocols: [TypeSyntax],
                                 in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {

        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            let enumError = Diagnostic(node: declaration.root, message: ProviderDiagnostic.notAnEnum)
            context.diagnose(enumError)
            return []
        }

        guard let inheritors = enumDecl.inheritanceClause?.inheritedTypes else {
            let missingInt = Diagnostic(node: declaration.root, message: ProviderDiagnostic.missingInt)
            context.diagnose(missingInt)
            return []
        }

        let types = inheritors.map { $0.type.as(IdentifierTypeSyntax.self) }
        //let names = types.map { $0?.name.text }

        let members = enumDecl.memberBlock.members
        let cases = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let elements = cases.flatMap { $0.elements }

        let nameDeclBase = try VariableDeclSyntax("var name: String") {
            try SwitchExprSyntax("switch self") {
                for element in elements {
                    SwitchCaseSyntax(
                            """
                            case .\(element.name):
                                return \(literal: element.name.text.capitalized)
                            """
                    )
                }
            }
        }

        var nameDecl = nameDeclBase
        for modifier in enumDecl.modifiers {
            nameDecl.modifiers.append(modifier)
        }

        let caseIterableExtensionDecl: DeclSyntax =
            """
            extension \(type.trimmed): CaseIterable {}
            """

        guard let caseIterableExtension = caseIterableExtensionDecl.as(ExtensionDeclSyntax.self) else {
            return []
        }

        let nameableExtension = try ExtensionDeclSyntax("extension \(type.trimmed): Nameable") {
            DeclSyntax(nameDecl)
        }

        return [caseIterableExtension, nameableExtension]
    }
}
