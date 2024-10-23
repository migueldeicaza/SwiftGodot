// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/24.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


public struct NuSignalMacro: DeclarationMacro {

    enum ProviderDiagnostic: Error, DiagnosticMessage {
        case argumentsInUnexpectedSyntax

        var severity: DiagnosticSeverity { .error }

        var message: String {
            switch self {
            case .argumentsInUnexpectedSyntax:
                "Failed to parse arguments. Define arguments in the form [\"argumentName\": Type.self]"
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "SwiftGodotMacros", id: message)
        }
    }

    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {

        var signalName: SignalName? = nil
        var arguments = [(name: String, type: String)]()

        for (index, argument) in node.arguments.enumerated() {
            if index == 0 {
                signalName = argument.expression.signalName()
            }
            if index == 1 {
                if argument.expression.description == ".init()" {
                    // its an empty dictionary, so no arguments
                    continue
                }

                guard let dictSyntax = DictionaryExprSyntax(argument.expression) else {
                    throw ProviderDiagnostic.argumentsInUnexpectedSyntax
                }

                if case .colon = dictSyntax.content {
                    // its an empty dictionary, so no arguments
                    continue
                }

                guard let pairList = DictionaryElementListSyntax(dictSyntax.content) else {
                    throw ProviderDiagnostic.argumentsInUnexpectedSyntax
                }

                for pair in pairList {
                    guard let typeName = pair.value.typeName() else {
                        throw ProviderDiagnostic.argumentsInUnexpectedSyntax
                    }
                    arguments.append((pair.key.description, typeName))
                }
            }
        }

        guard let signalName else { return [] }

        let genericTypeList = arguments.map { $0.type }.joined(separator: ", ")

        let signalWrapperType = arguments.isEmpty ? "GenericSignal< /* no args */ >" : "GenericSignal<\(genericTypeList)>"

        return [
            DeclSyntax(
                try VariableDeclSyntax(
                    "static let _\(raw: signalName.swiftName) = \(raw: signalWrapperType).self"
                )
            ),
            DeclSyntax(
                try VariableDeclSyntax(
                    "var \(raw: signalName.swiftName): \(raw: signalWrapperType) { \(raw: signalWrapperType)(target: self, signalName: \"\(raw: signalName.godotName)\") }"
                )
            ),
        ]
    }

}
