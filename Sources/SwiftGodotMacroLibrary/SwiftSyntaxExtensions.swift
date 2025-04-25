//
//  SwiftSyntaxExtensions.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 22/04/2025.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension DeclModifierListSyntax {
    var containsClassOrStatic: Bool {
        contains { modifier in
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

extension FunctionEffectSpecifiersSyntax {
    var containsAsyncOrThrows: Bool {
        asyncSpecifier?.presence == .present || throwsClause?.throwsSpecifier.presence == .present
    }
}

extension FunctionDeclSyntax {
    var hasClassOrStaticModifier: Bool {
        modifiers.containsClassOrStatic
    }
    
    var hasAsyncOrThrowsSpecifier: Bool {
        signature.effectSpecifiers?.containsAsyncOrThrows == true
    }
    
    var parameters: FunctionParameterListSyntax {
        signature.parameterClause.parameters
    }
    
    func hasAttribute(named name: String) -> Bool {
        attributes.hasAttribute(named: name)
    }
    
    var hasCallableAttribute: Bool {
        hasAttribute(named: "Callable")
    }
}

extension FunctionParameterSyntax {
    /// `(arg: Int)` -> `arg: `
    /// `(_ arg: Int)` -> ``
    var labelForCaller: String {
        let first = firstName.text
                    
        if first == "_" {
            return ""
        } else {
            return first + ": "
        }
    }
    
    /// Name as seen by function body
    var internalName: String {
        secondName?.text ?? firstName.text
    }
}

extension VariableDeclSyntax {
    var hasClassOrStaticModifier: Bool {
        modifiers.containsClassOrStatic
    }
    
    func hasAttribute(named name: String) -> Bool {
        attributes.hasAttribute(named: name)
    }
    
    var hasSignalAttribute: Bool {
        hasAttribute(named: "Signal")
    }
    
    var hasExportAttribute: Bool {
        hasAttribute(named: "Export")
    }
}

extension AttributeListSyntax {
    func attribute(named name: String) -> AttributeSyntax? {
        for element in self {
            guard case let .attribute(attribute) = element else {
                continue
            }
                        
            if attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text == name {
                return attribute
            }
        }
        
        return nil
    }
    
    func hasAttribute(named name: String) -> Bool {
        attribute(named: name) != nil
    }
}

extension PatternBindingSyntax {
    /// Returns `true` if it's a settable variable binding, `false` otherwise
    var isSettableBinding: Bool {
        if let accessors = accessorBlock {
            if CodeBlockSyntax(accessors) != nil {
                return false
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
                case .getter:
                    return false
                }
                
                if hasSet == false || hasGet == false {
                    return true
                }
            }
        }
        
        return true
    }
}
