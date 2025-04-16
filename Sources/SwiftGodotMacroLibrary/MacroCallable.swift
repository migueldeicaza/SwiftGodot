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

extension FunctionDeclSyntax {
    var hasClassOrStaticModifier: Bool {
        modifiers.contains { modifier in
            switch modifier.name.tokenKind {
            case .keyword(let keyword):
                switch keyword {
                case .static, .class:
                    return true
                default:
                    return false
                }
            default:
                return false
            }
        }
    }
}

public struct GodotCallable: PeerMacro {
    static func process (funcDecl: FunctionDeclSyntax) throws -> String {
        let funcName = funcDecl.name.text
        
        let isStatic = funcDecl.hasClassOrStaticModifier
        
        if let effects = funcDecl.signature.effectSpecifiers,
           effects.asyncSpecifier?.presence == .present ||
            effects.throwsClause?.throwsSpecifier.presence == .present {
            throw GodotMacroError.unsupportedCallableEffect
        }
        
        var body = ""
        
        let parameters = funcDecl.signature.parameterClause.parameters
        
        var callArgsList: [String] = []
        
        // Is there are no arguments, there is no do-catch scope to sanitize arguments access
        let indentation = parameters.isEmpty ? "" : "    "
        
        if !isStatic {
            body += """
            \(indentation)    guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
            \(indentation)        SwiftGodot.GD.printErr("Error calling `\(funcName)`: failed to unwrap instance \\(pInstance)")
            \(indentation)        return nil
            \(indentation)    }
            """
        }
        
        let objectOrSelf = isStatic ? "self" : "object"
        
        for (index, parameter) in parameters.enumerated() {
            let ptype = parameter.type.description
            
            body += """
                    let arg\(index) = try arguments.argument(ofType: \(ptype).self, at: \(index))            
            """
            
            let first = parameter.firstName.text
                        
            let labelOrNothing = first != "_" ? "\(first): " : ""
            callArgsList.append("\(labelOrNothing)arg\(index)")
        }
        
        let callArgs = callArgsList.joined(separator: ", ")
        
        body += """
        \(indentation)    return SwiftGodot._wrapCallableResult(\(objectOrSelf).\(funcName)(\(callArgs)))
        
        """
        
        if parameters.isEmpty {
            return """
            static func _mproxy_\(funcName)(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
            \(body)                
            }
            """
        } else {
            return """
            static func _mproxy_\(funcName)(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
                do { // safe arguments access scope
            \(body)        
                } catch {
                    SwiftGodot.GD.printErr("Error calling `\(funcName)`: \\(error.description)")                    
                }
            
                return nil
            }
            """
        }
    }
    
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            let classError = Diagnostic(node: declaration.root, message: GodotMacroError.requiresFunction)
            context.diagnose(classError)
            return []
        }
        return [SwiftSyntax.DeclSyntax (stringLiteral: try process (funcDecl: funcDecl))]
    }
    
}
