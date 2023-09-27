//
//  NativeHandleDiscardingMacro.swift
//  SwiftGodot
//
//  Created by Marquis Kurt on 5/27/23.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NativeHandleDiscardingMacro: MemberMacro {
    enum ProviderDiagnostic: String, DiagnosticMessage {
        case notAClass
        case missingNode
        var severity: DiagnosticSeverity {
            switch self {
            case .notAClass: return .error
            case .missingNode: return .error
            }
        }

        var message: String {
            switch self {
            case .notAClass:
                return "@NativeHandleDiscarding can only be applied to a 'class'"
            case .missingNode:
                return "@NativeHandleDiscarding requires inheritance to 'Node' or a subclass"
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "SwiftGodotMacros", id: rawValue)
        }
    }

    public static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
            guard declaration.as(ClassDeclSyntax.self) != nil else {
                let classError = Diagnostic(node: declaration.root, message: ProviderDiagnostic.notAClass)
                context.diagnose(classError)
                return []
            }

            let initSyntax = try InitializerDeclSyntax("required init(nativeHandle _: UnsafeRawPointer)") {
                StmtSyntax("fatalError(\"init(nativeHandle:) has not been implemented\")")
            }

            return [DeclSyntax(initSyntax)]
    }
}
