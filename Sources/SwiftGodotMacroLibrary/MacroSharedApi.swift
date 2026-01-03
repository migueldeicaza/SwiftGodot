//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 9/25/23.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum GodotMacroError: Error, DiagnosticMessage {
    case godotMacroNotOnClass
    case exportMacroNotOnVariable
    case signalMacroNotOnVariable
    case callableMacroNotOnFunction
    case rpcMacroNotOnFunction
    case signalMacroNoType(String)
    case signalMacroAccessorBlock(String)
    case signalMacroInitializer(String)
    case signalMacroMultipleBindings
    case noIdentifier(PatternBindingListSyntax.Element)
    case unknownError(Error)
    case callableMacroOnThrowingOrAsyncFunction
    case unsupportedStaticMember
    case exportMacroOnReadonlyVariable(String)
    case nameCollision(String)
    case legacySignalMacroUnexpectedArgumentsSyntax
    case legacySignalMacroTooManyArguments
    case illegalCallableAutoSnakeCaseArgument(String)    
    
    var severity: DiagnosticSeverity {
        return .error
    }

    var message: String {
        switch self {
        case .illegalCallableAutoSnakeCaseArgument(let expr):
            "`autoSnakeCase: \(expr)` is illegal. `true` or `false` expected."
        case .exportMacroOnReadonlyVariable:
            "@Export attribute can only be applied to mutable stored or computed { get set } property"
        case .godotMacroNotOnClass:
            "@Godot attribute can only be applied to a class"
        case .exportMacroNotOnVariable:
            "@Export attribute can only be applied to variables"
        case .signalMacroNotOnVariable:
            "@Signal attribute can only be applied to variables"
        case .callableMacroNotOnFunction:
            "@Callable attribute can only be applied to functions"
        case .rpcMacroNotOnFunction:
            "@Rpc attribute can only be applied to functions"
        case .noIdentifier(let e):
            "Unexpected binding pattern \(e). \(IdentifierPatternSyntax.self) expected"
        case .unknownError(let e):
            "Unknown nested error processing this directive: \(e)"
        case .callableMacroOnThrowingOrAsyncFunction:
            "@Callable does not support asynchronous or throwing functions"
        case .unsupportedStaticMember:
            "`static` or `class` member is not supported"
        case .nameCollision(let name):
            "Same name `\(name)` for two different declarations. GDScript doesn't support it."
        case .signalMacroNoType(let name):
            "`\(name)` missing explicit `SignalWithArguments<...>` or `SimpleSignal` type annotation required for @Signal macro"
        case .legacySignalMacroUnexpectedArgumentsSyntax:
            "Failed to parse arguments. Define arguments in the form [\"argumentName\": Type.self]"
        case .legacySignalMacroTooManyArguments:
            "Too many arguments in the arguments dictionary. A maximum of 6 are supported."
        case .signalMacroInitializer(let name):
            "@Signal attribute can not be applied to `\(name)` with an intitializer expression"
        case .signalMacroAccessorBlock(let name):
            "@Signal attribute can not be applied to `\(name)` with acccessor block"
        case .signalMacroMultipleBindings:
            "@Signal attribute can not be applied to declaration with multiple bindings. It's an Swift `AccessorMacro` restriction."
        }
    }
    
    var diagnosticID: MessageID {
        MessageID(domain: "SwiftGodotMacros", id: message)
    }
}

enum MacroError: Error {
    case typeName(FunctionParameterSyntax)
    case missingParameterName(FunctionParameterSyntax)
    case noVariablesFound(VariableDeclSyntax)
    case unsupportedType(VariableDeclSyntax)
    case propertyGetSet
    
    var localizedDescription: String {
        switch self {
        case .typeName (let p):
            return "Could not lookup the typename \(p)"
        case .missingParameterName(let p):
            return "Missing a parameter name \(p)"
        case .noVariablesFound(let v):
            return "No variables were found on \(v)"
        case .unsupportedType(let v):
            return "This type is not supported in the macro binding \(v)"
        case .propertyGetSet:
            return "Properties exported to Godot must be readable and writable"
        }
    }
}

struct SignalName {
    let godotName: String
    let swiftName: String
}

extension ExprSyntax {
    func signalName() -> SignalName? {
        // Extract the signalName parameter if it's wrapped in quotes, eg: "name"
        if let stringLiteralExpr = StringLiteralExprSyntax(self),
           let segmentSyntax = StringSegmentSyntax(stringLiteralExpr.segments.first),
           case let .stringSegment(signalName) = segmentSyntax.content.tokenKind {
            return SignalName(
                godotName: signalName,
                swiftName: signalName.snakeToCamelcase()
            )
        }
        
        return nil
    }
    
    /// Extracts a type name
    func typeName() -> String? {
        if let memberAccessSyntax = MemberAccessExprSyntax(self),
           let base = memberAccessSyntax.base,
           let decl = DeclReferenceExprSyntax(base),
           case let .identifier(name) = decl.baseName.tokenKind {
            return name
        }
        
        return nil
    }
}


private extension String {
    func swiftName() -> String {
        if self == uppercased() {
            lowercased()
        } else {
            lowercaseFirstLetter()
        }
    }

    func snakeToCamelcase() -> String {
        let parts = split(separator: "_")

        guard let firstItem = parts.first else {
            return ""
        }

        return String(firstItem).swiftName() +
            parts.dropFirst().map { String($0).uppercaseFirstLetter() }.joined()
    }

    private func lowercaseFirstLetter() -> String {
        if let firstLetter = first {
            firstLetter.lowercased() + dropFirst()
        } else {
            self
        }
    }

    private func uppercaseFirstLetter() -> String {
        if let firstLetter = first {
            firstLetter.uppercased() + dropFirst()
        } else {
            self
        }
    }
}
