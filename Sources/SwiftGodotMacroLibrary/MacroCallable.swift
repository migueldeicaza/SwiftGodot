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
        var genMethod = "func _mproxy_\(funcName) (args: borrowing Arguments) -> Variant? {\n"
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
                    
                } catch {
                    GD.printErr("\\(error)")
                    return nil
                }
            """
            genMethod.append ("    let result = \(funcName) (")
            retOptional = ro
        } else {
            genMethod.append ("    \(funcName) (")
        }
        
        if funcDecl.returnTypeIsGArrayCollection {
            retProp = ".array"
        }
        
        var argsList: [String] = []
        
        for (index, parameter) in funcDecl.signature.parameterClause.parameters.enumerated() {
            guard let ptype = getTypeName(parameter) else {
                throw MacroError.typeName (parameter)
            }
            let first = parameter.firstName.text
            if index != 0 {
                genMethod.append (", ")
            }
            if first != "_" {
                genMethod.append ("\(first): ")
            }
            
            
            
            if ptype == "Variant" {
                genMethod.append ("args [\(index)]!")
            } else if parameter.isArray, let elementType = parameter.arrayElementTypeName {
                genMethod += """
                guard let arg = args.first else {
                    GD.printErr("Unable to call `\(funcName)`, no arguments")
                    return nil
                }
                
                guard let variant = arg else {
                    GD.printErr("Unable to call `\(funcName)`, argument is nil")
                    return nil
                }
                
                guard let array = GArray(variant) else {
                    GD.printErr("Unable to call `\(funcName)`, argument is not `GArray`")
                    return nil
                }
                
                var result: [\(elementType)] = []
                result.reserveCapacity(array.count)
                for element in array {        
                    guard let element = \(elementType).makeOrUnwrap(element) else {
                        GD.printErr("Unable to call `\(funcName)`, array contains unexpected \\(element?.description ?? "nil")")
                        return nil
                    }
                
                    result.append(element)
                }
                """
                genMethod.append ("GArray (args [\(index)]!)!.compactMap(\(elementType).makeOrUnwrap)")
            } else if parameter.isVariantCollection, let elementType = parameter.variantCollectionElementTypeName {
                genMethod += """
                guard let arg = args.first else {
                    GD.printErr("Unable to call `\(funcName)`, no arguments")
                    return nil
                }
                
                guard let variant = arg else {
                    GD.printErr("Unable to call `\(funcName)`, argument is nil")
                    return nil
                }
                
                guard let array = GArray(variant) else {
                    GD.printErr("Unable to call `\(funcName)`, argument is not `GArray`")
                    return nil
                }
                
                let result = VariantCollection<\(elementType)>()
                for element in array {        
                    guard let element = \(elementType).makeOrUnwrap(element) else {
                        GD.printErr("Unable to call `\(funcName)`, array contains unexpected \\(element?.description ?? "nil")")
                        return nil
                    }
                
                    result.append(element)
                }
                """
            } else if parameter.isObjectCollection, let elementType = parameter.objectCollectionElementTypeName {
                genMethod += """
                guard let arg = args.first else {
                    GD.printErr("Unable to call `\(funcName)`, no arguments")
                    return nil
                }
                
                guard let variant = arg else {
                    GD.printErr("Unable to call `\(funcName)`, argument is nil")
                    return nil
                }
                
                guard let array = GArray(variant) else {
                    GD.printErr("Unable to call `\(funcName)`, argument is not `GArray`")
                    return nil
                }
                
                let result = ObjectCollection<\(elementType)>()
                for element in array {                    
                    result.append(\(ptype).makeOrUnwrap(element))
                }
                """
            } else {
                genMethod.append ("\(ptype).makeOrUnwrap (args [\(index)]!)!")
            }
        }
        
        genMethod.append (")\n")
        if retProp != nil {
            if retOptional {
                genMethod.append ("    guard let result else { return nil }\n")
            }
            if funcDecl.returnTypeIsArray, let elementTypeName = funcDecl.arrayElementType {
                genMethod.append ("    return Variant ( result.reduce(into: GArray(\(elementTypeName).self)) { $0.append(Variant($1)) })\n")
            } else {
                genMethod.append ("    return Variant (result)\n")
            }
        } else {
            genMethod.append ("    return nil\n")
        }
        if genMethod != "" {
            genMethod.append("}\n")
        }
    
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
