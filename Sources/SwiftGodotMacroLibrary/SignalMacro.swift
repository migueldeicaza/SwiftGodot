//
//  SignalMacro.swift
//  SwiftGodot
//
//  Created by Padraig O Cinneide on 2023-10-19.

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SignalMacro: DeclarationMacro {
    
    enum ProviderDiagnostic: Error, DiagnosticMessage {
        case tooManyArguments
        case argumentsInUnexpectedSyntax

        var severity: DiagnosticSeverity { .error }

        var message: String {
            switch self {
            case .argumentsInUnexpectedSyntax:
                "Failed to parse arguments. Define arguments in the form [\"argumentName\": Type.self]"
            case .tooManyArguments:
                "Too many arguments in the arguments dictionary. A maximum of 6 are supported."
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
        
        for (index, argument) in node.argumentList.enumerated() {
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
        
        let signalWrapperType = switch arguments.count {
        case 0: "SignalWithNoArguments"
        case 1: "SignalWith1Argument<\(genericTypeList)>"
        case 2: "SignalWith2Arguments<\(genericTypeList)>"
        case 3: "SignalWith3Arguments<\(genericTypeList)>"
        case 4: "SignalWith4Arguments<\(genericTypeList)>"
        case 5: "SignalWith5Arguments<\(genericTypeList)>"
        case 6: "SignalWith6Arguments<\(genericTypeList)>"
        default:
            throw ProviderDiagnostic.tooManyArguments
        }
        
        let argumentList = ["\"" + signalName.godotName + "\""] + arguments
            .enumerated()
            .map { index, argument in
                "argument\(index + 1)Name: \(argument.name)"
            }
            
        let argumentsString = argumentList.joined(separator: ", ")
        
        return [
            DeclSyntax(
                try VariableDeclSyntax(
                "static let \(raw: signalName.swiftName) = \(raw: signalWrapperType)(\(raw: argumentsString))"
                )
            )
        ]
    }
    
}



