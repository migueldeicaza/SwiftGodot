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
    static func makeGetAccessor (varName: String, typeName: String, isOptional: Bool, isEnum: Bool) -> String {
        let name = "_mproxy_get_\(varName)"
        if isEnum {
            return """
            func \(name) (args: borrowing Arguments) -> Variant? {
                \(varName).rawValue.toVariant()                
            }
            """

        } else {
            return """
            func \(name) (args: borrowing Arguments) -> Variant? {
                _macroEnsureVariantConvertible(\(typeName).self)
                return \(varName).toVariant()        
            }                        
            """
        }
    }
    
    static func makeSetAccessor (varName: String, typeName: String, isOptional: Bool, isEnum: Bool) -> String {
        let name = "_mproxy_set_\(varName)"
        var body: String = ""

        if isEnum {
            body =
            """
                guard let arg = args.first else {
                    GD.printErr("Unable to set `\(varName)`, no arguments")
                    return nil
                }
            
                guard let variant = arg else {
                    GD.printErr("Unable to set `\(varName)`, argument is nil")
                    return nil
                }
            
                guard let int = Int.fromVariant(variant) else {
                    GD.printErr("Unable to set `\(varName)`, argument is not int")
                    return nil
                }
            
                guard let newValue = \(typeName)(rawValue: \(typeName).RawValue(int)) else {
                    GD.printErr("Unable to set `\(varName)`, \\(int) is not a valid \(typeName) rawValue")
                    return nil
                }
            
                self.\(varName) = newValue
            """
        } else {
            // TODO: check that no leak happens in deinit for `RefCounted`. Someone has to unreference them?
            body = """
                _macroEnsureVariantConvertible(\(typeName).self)
                \(typeName)._macroExportSetter(args, "\(varName)", property: &\(varName)) 
            """
        }
                
        return """
        func \(name)(args: borrowing Arguments) -> Variant? {
        \(body)    
            return nil
        }
        """
    }

    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            let classError = Diagnostic(node: declaration.root, message: GodotMacroError.requiresVar)
            context.diagnose(classError)
            return []
        }
        var isOptional = false
        guard let last = varDecl.bindings.last else {
            throw GodotMacroError.noVariablesFound
        }
        guard var type = last.typeAnnotation?.type else {
            throw GodotMacroError.noTypeFound(varDecl)
        }
        if let optSyntax = type.as (OptionalTypeSyntax.self) {
            isOptional = true
            type = optSyntax.wrappedType
        }
        
        guard varDecl.isSwiftArray == false else {
            let classError = Diagnostic(node: declaration.root, message: GodotMacroError.requiresGArrayCollection)
            context.diagnose(classError)
            return []
        }
        
        guard type.is(IdentifierTypeSyntax.self) else {
            throw GodotMacroError.unsupportedType(varDecl)
        }
        
        guard (type.isGArrayCollection && isOptional) == false else {
            throw GodotMacroError.requiresNonOptionalGArrayCollection
        }
        
        var isEnum = false
        if case let .argumentList (arguments) = node.arguments, let expression = arguments.first?.expression {
            isEnum = expression.description.trimmingCharacters(in: .whitespacesAndNewlines) == ".enum"
        }
        if isEnum && isOptional {
            throw GodotMacroError.noSupportForOptionalEnums
            
        }
        var results: [DeclSyntax] = []
        
        for singleVar in varDecl.bindings {
            guard let ips = singleVar.pattern.as(IdentifierPatternSyntax.self) else {
                throw GodotMacroError.expectedIdentifier(singleVar)
            }
            let varName = ips.identifier.text
            
            if let accessors = last.accessorBlock {
                if CodeBlockSyntax (accessors) != nil {
                    throw MacroError.propertyGetSet
                }
                if let block = AccessorBlockSyntax (accessors) {
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
            
            if let elementTypeName = varDecl.gArrayCollectionElementTypeName {
                results.append (DeclSyntax(stringLiteral: makeGArrayCollectionGetProxyAccessor(varName: varName, elementTypeName: elementTypeName)))
                results.append (DeclSyntax(stringLiteral: makeGArrayCollectionSetProxyAccessor(varName: varName, elementTypeName: elementTypeName)))
            } else if let typeName = type.as(IdentifierTypeSyntax.self)?.name.text {
                results.append (DeclSyntax(stringLiteral: makeSetAccessor(varName: varName, typeName: typeName, isOptional: isOptional, isEnum: isEnum)))
                results.append (DeclSyntax(stringLiteral: makeGetAccessor(varName: varName, typeName: typeName, isOptional: isOptional, isEnum: isEnum)))
            }
        }
        
        return results
    }
}

private extension GodotExport {
    private static func makeGArrayCollectionGetProxyAccessor(varName: String, elementTypeName: String) -> String {
        """
        func _mproxy_get_\(varName)(args: borrowing Arguments) -> Variant? {
            return Variant(\(varName).array)
        }
        """
    }
    
    private static func makeGArrayCollectionSetProxyAccessor(varName: String, elementTypeName: String) -> String {
        """
        func _mproxy_set_\(varName)(args: borrowing Arguments) -> Variant? {
            guard let arg = args.first else {
                GD.printErr("Unable to set `\(varName)`, no arguments")
                return nil
            }
        
            guard let variant = arg else {
                GD.printErr("Unable to set `\(varName)`, argument is `nil`")
                return nil
            }
            guard let gArray = GArray(variant),
                  gArray.isTyped(),
                  gArray.isSameTyped(array: GArray(\(elementTypeName).self)) else {
                return nil
            }
            \(varName).array = gArray
            return nil
        }
        """
    }
}
