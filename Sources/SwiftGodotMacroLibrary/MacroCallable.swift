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

public struct GodotCallable: PeerMacro {
    static func process (funcDecl: FunctionDeclSyntax) throws -> String {
        let funcName = funcDecl.name.text
        
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
        \(indentation)    return SwiftGodot._macroCallableToVariant(\(funcName)(\(callArgs)))
        
        """
        
        if parameters.isEmpty {
            return """
            func _mproxy_\(funcName)(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
            \(body)                
            }
            """
        } else {
            return """
            func _mproxy_\(funcName)(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
                do { // safe arguments access scope
            \(body)        
                } catch let error as SwiftGodot.ArgumentAccessError {
                    SwiftGodot.GD.printErr(error.description)
                    return nil
                } catch {
                    SwiftGodot.GD.printErr("Error calling `\(funcName)`: \\(error)")
                    return nil
                }
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
