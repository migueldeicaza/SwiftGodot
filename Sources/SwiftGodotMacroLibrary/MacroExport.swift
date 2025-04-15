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
    static func makeGetAccessor(identifier: String) -> String {
        """
        static func _mproxy_get_\(identifier)(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
            guard let object = _unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling getter for \(identifier): failed to unwrap instance \\(pInstance)")
                return nil
            }
        
            return SwiftGodot._invokeGetter(object.\(identifier))            
        }                        
        """
    }
    
    static func makeSetAccessor(identifier: String) -> String {
        """
        static func _mproxy_set_\(identifier)(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
            guard let object = _unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling getter for \(identifier): failed to unwrap instance \\(pInstance)")
                return nil
            }
        
            SwiftGodot._invokeSetter(arguments, "\(identifier)", object.\(identifier)) {
                object.\(identifier) = $0
            }        
            return nil
        }
        """
    }
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            let classError = Diagnostic(node: declaration.root, message: GodotMacroError.requiresVar)
            context.diagnose(classError)
            return []
        }
        
        guard !variableDecl.bindings.isEmpty else {
            throw GodotMacroError.noVariablesFound
        }
        
        var declarations: [DeclSyntax] = []
        
        for binding in variableDecl.bindings {
            guard let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
                throw GodotMacroError.expectedIdentifier(binding)
            }
            
            let identifier = identifierPattern.identifier.text
            
            if let accessors = binding.accessorBlock {
                if CodeBlockSyntax (accessors) != nil {
                    throw MacroError.propertyGetSet
                }
                
                if let block = AccessorBlockSyntax(accessors) {
                    var hasSet = false
                    var hasGet = false
                    switch block.accessors {
                    case .accessors(let list):
                        for accessor in list {
                            switch accessor.accessorSpecifier.tokenKind {
                            case .keyword(let val):
                                switch val {
                                case .didSet, .willSet:
                                    hasSet = true
                                    hasGet = true
                                case .set:
                                    hasSet = true
                                case .get:
                                    hasGet = true
                                default:
                                    break
                                }
                            default:
                                break
                            }
                        }
                    default:
                        throw MacroError.propertyGetSet
                    }
                    
                    if hasSet == false || hasGet == false {
                        throw MacroError.propertyGetSet
                    }
                }
            }
            
            declarations.append(DeclSyntax(stringLiteral: makeSetAccessor(identifier: identifier)))
            declarations.append(DeclSyntax(stringLiteral: makeGetAccessor(identifier: identifier)))
        }
        
        return declarations
    }
}
