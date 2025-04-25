//
//  MacroExport.swift
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

public struct GodotExport: PeerMacro {    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            let classError = Diagnostic(node: declaration.root, message: GodotMacroError.exportMacroNotOnVariable)
            context.diagnose(classError)
            return []
        }
        
        var declarations: [DeclSyntax] = []
        
        for binding in variableDecl.bindings {
            guard let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
                throw GodotMacroError.noIdentifier(binding)
            }
            
            let identifier = identifierPattern.identifier.text
            
            if !binding.isSettableBinding {
                throw GodotMacroError.exportMacroOnReadonlyVariable(identifier)
            }
            
            declarations.append("""
            static func _mproxy_set_\(raw: identifier)(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
                guard let object = _unwrap(self, pInstance: pInstance) else {
                    SwiftGodot.GD.printErr("Error calling setter for \(raw: identifier): failed to unwrap instance \\(String(describing: pInstance))")
                    return nil
                }
            
                SwiftGodot._invokeSetter(arguments, "\(raw: identifier)", object.\(raw: identifier)) {
                    object.\(raw: identifier) = $0
                }
                return nil
            }                    
            """)
            
            declarations.append("""
            static func _mproxy_get_\(raw: identifier)(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
                guard let object = _unwrap(self, pInstance: pInstance) else {
                    SwiftGodot.GD.printErr("Error calling getter for \(raw: identifier): failed to unwrap instance \\(String(describing: pInstance))")
                    return nil
                }
            
                return SwiftGodot._invokeGetter(object.\(raw: identifier))            
            }                        
            """)
        }
        
        return declarations
    }
}
