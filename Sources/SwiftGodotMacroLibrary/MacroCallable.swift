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
        var genMethod = "func _mproxy_\(funcName) (arguments: borrowing Arguments) -> Variant? {\n"
        var retProp: String? = nil
        var retOptional: Bool = false
        
        if let effects = funcDecl.signature.effectSpecifiers,
           effects.asyncSpecifier?.presence == .present ||
            effects.throwsSpecifier?.presence == .present {
            throw GodotMacroError.unsupportedCallableEffect
        }
        
        if let (retType, _, ro) = getIdentifier (funcDecl.signature.returnClause?.type) {
            retProp = godotTypeToProp (typeName: retType)
            genMethod += """
                do {
                    let result = \(funcName)(
            
            """
            retOptional = ro
        } else {
            genMethod += """
                do {
                    \(funcName)(         
            
            """
        }
        
        if funcDecl.returnTypeIsGArrayCollection {
            retProp = ".array"
        }
        
        let parameters = funcDecl.signature.parameterClause.parameters
        let parameterCount = parameters.count
        
        for (index, parameter) in parameters.enumerated() {
            guard let ptype = getTypeName(parameter) else {
                throw MacroError.typeName (parameter)
            }
            
            let commaOrNothing = index < parameterCount - 1 ? "," : ""
            
            let first = parameter.firstName.text
                        
            if first != "_" {
                genMethod.append ("\(first): ")
            }
            
            let labelOrNothing = first != "_" ? "\(first): " : ""
            
            if ptype == "Variant" {
                genMethod += """
                            \(labelOrNothing)try arguments.variantArgument(at: \(index))\(commaOrNothing)
                
                """
            } else if parameter.isArray, let elementType = parameter.arrayElementTypeName {
                genMethod += """
                            \(labelOrNothing)try arguments.arrayArgument(ofType: \(elementType).self, at: \(index))\(commaOrNothing)
                
                """
            } else if parameter.isVariantCollection, let elementType = parameter.variantCollectionElementTypeName {
                genMethod += """
                            \(labelOrNothing)try arguments.variantCollectionArgument(ofType: \(elementType).self, at: \(index))\(commaOrNothing)
                
                """
            } else if parameter.isObjectCollection, let elementType = parameter.objectCollectionElementTypeName {
                genMethod += """
                            \(labelOrNothing)try arguments.objectCollectionArgument(ofType: \(elementType).self, at: \(index))\(commaOrNothing)
                
                """
            } else {
                genMethod += """
                            \(labelOrNothing)try arguments.argument(ofType: \(ptype).self, at: \(index))\(commaOrNothing)
                
                """
            }
        }
        
        genMethod += """
                )
        """
        
        if retProp != nil {
            if retOptional {
                genMethod += """
                        guard let result else { return nil }
                        return result
                    }
                """
            }
            
            if funcDecl.returnTypeIsArray, let elementTypeName = funcDecl.arrayElementType {
                genMethod += """
                        return Variant(
                            result.reduce(into: GArray(\(elementTypeName).self)) { array, element in
                                array.append(Variant(element)) 
                            }
                        )
                    }
                """
            } else {
                genMethod += """
                        return Variant(result)
                    }
                """
            }
        } else {
            genMethod += """
                    return nil
                }
            """
        }
        
        genMethod += """
            } catch let error as ArgumentAccessError {
                GD.printErr("\\(error.description)")
            } catch {
                GD.printErr("\\(error.localizedDescription)")
            }
            
            return nil
        }
        """
    
        return genMethod
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
