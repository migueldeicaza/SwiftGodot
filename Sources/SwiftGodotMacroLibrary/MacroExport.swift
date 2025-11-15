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
            
            // Probe whether this property is settable and record it in needsSetter
            let needsSetter = Self.bindingNeedsSetter(variableDecl: variableDecl, binding: binding)
            
            if needsSetter {
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
            }
            
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
    
    /// Determines whether a binding is settable based on its syntax.
    /// - Rules:
    ///   - `let` bindings are never settable.
    ///   - `var` without an accessor block is a stored property -> settable.
    ///   - Accessor block:
    ///       - `.getter` form is read-only -> not settable.
    ///       - `.accessors` is settable if it contains `set`, `_modify`, `willSet`, or `didSet`.
    private static func bindingNeedsSetter(variableDecl: VariableDeclSyntax, binding: PatternBindingSyntax) -> Bool {
        // If it's a 'let', it's not settable
        if case .keyword(.let) = variableDecl.bindingSpecifier.tokenKind {
            return false
        }
        
        // No accessor block => stored property => settable
        guard let accessorBlock = binding.accessorBlock else {
            return true
        }
        
        switch accessorBlock.accessors {
        case .getter:
            // Shorthand getter-only computed property
            return false
        case .accessors(let list):
            // If we have an explicit 'set' or '_modify', it's settable.
            // Also consider observers (willSet/didSet) which imply write-ability for stored properties.
            return list.contains { accessor in
                switch accessor.accessorSpecifier.tokenKind {
                case .keyword(.set),
                     .keyword(._modify),
                     .keyword(.willSet),
                     .keyword(.didSet):
                    return true
                default:
                    return false
                }
            }
        #if RESILIENT_LIBRARIES
        @unknown default:
            return false
        #endif
        }
    }
}

