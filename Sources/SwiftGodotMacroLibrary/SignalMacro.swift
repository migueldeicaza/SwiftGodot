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
                if argument.expression.trimmedDescription == ".init()" {
                    // its an empty dictionary, so no arguments
                    continue
                }
                
                guard let dictSyntax = DictionaryExprSyntax(argument.expression) else {
                    throw GodotMacroError.legacySignalMacroUnexpectedArgumentsSyntax
                }
                
                if case .colon = dictSyntax.content {
                    // its an empty dictionary, so no arguments
                    continue
                }
                
                guard let pairList = DictionaryElementListSyntax(dictSyntax.content) else {
                    throw GodotMacroError.legacySignalMacroUnexpectedArgumentsSyntax
                }
                
                for pair in pairList {
                    guard let typeName = pair.value.typeName() else {
                        throw GodotMacroError.legacySignalMacroUnexpectedArgumentsSyntax
                    }
                    arguments.append((pair.key.trimmedDescription, typeName))
                }
            }
        }
        
        guard let signalName else { return [] }
        
        let genericTypeList = arguments.map { $0.type }.joined(separator: ", ")
        
        let signalWrapperType = switch arguments.count {
        case 0: 
            "SignalWithNoArguments"
        case 1:
            "SignalWith1Argument<\(genericTypeList)>"
        case 2...6:
            "SignalWith\(arguments.count)Arguments<\(genericTypeList)>"
        default:
            throw GodotMacroError.legacySignalMacroTooManyArguments
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



