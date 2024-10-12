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
            effects.throwsSpecifier?.presence == .present {
            throw GodotMacroError.unsupportedCallableEffect
        }
        
        var body = ""
        
        let parameters = funcDecl.signature.parameterClause.parameters
        
        var callArgsList: [String] = []
        
        for (index, parameter) in parameters.enumerated() {
            guard let ptype = getTypeName(parameter) else {
                throw MacroError.typeName (parameter)
            }
            
            if ptype == "Variant" {
                body += """
                        let arg\(index): Variant = try arguments.variantArgument(at: \(index))
                
                """
            } else if parameter.isSwiftArray, let elementType = parameter.arrayElementTypeName {
                body += """
                        let arg\(index): [\(elementType)] = try arguments.arrayArgument(ofType: \(elementType).self, at: \(index))
                
                """
            } else if parameter.isVariantCollection, let elementType = parameter.variantCollectionElementTypeName {
                body += """
                        let arg\(index): VariantCollection<\(elementType)> = try arguments.variantCollectionArgument(ofType: \(elementType).self, at: \(index))
                
                """
            } else if parameter.isObjectCollection, let elementType = parameter.objectCollectionElementTypeName {
                body += """
                        let arg\(index): ObjectCollection<\(elementType)> = try arguments.objectCollectionArgument(ofType: \(elementType).self, at: \(index))
                
                """
            } else {
                body += """
                        let arg\(index): \(ptype) = try arguments.argument(ofType: \(ptype).self, at: \(index))
                
                """
            }
            
            let first = parameter.firstName.text
                        
            let labelOrNothing = first != "_" ? "\(first): " : ""
            callArgsList.append("\(labelOrNothing)arg\(index))")
        }
        
        let callArgs = callArgsList.joined(separator: ", ")
        
        var retProp: String? = nil
        var retOptional: Bool = false
        
        if let (retType, _, ro) = getIdentifier (funcDecl.signature.returnClause?.type) {
            retProp = godotTypeToProp (typeName: retType)
            retOptional = ro
        }
        
        if funcDecl.isReturnedTypeGArrayCollection {
            retProp = ".array"
        }
        
        let resultDeclOrNothing: String
        
        if retProp == nil {
            resultDeclOrNothing = ""
        } else {
            resultDeclOrNothing = "let result = "
        }
        
        body += """
            \(resultDeclOrNothing)\(funcName)(\(callArgs))
        """
        
        if retProp != nil {
            if retOptional {
                body += """
                        guard let result else { return nil }
                
                """
            }
            
            if funcDecl.isReturnedTypeSwiftArray, let elementTypeName = funcDecl.returnedSwiftArrayElementType {
                body += """
                        return Variant(
                            result.reduce(into: GArray(\(elementTypeName).self)) { array, element in
                                array.append(Variant(element)) 
                            }
                        )                    
                """
            } else {
                body += """
                        return Variant(result)                    
                """
            }
        } else {
            body += """
                    return nil                
            """
        }
        
        return """
        func _mproxy_\(funcName)(arguments: borrowing Arguments) -> Variant? {
            do {
        \(body)        
            } catch let error as ArgumentAccessError {
                GD.printErr(error.description)
            } catch {
                GD.printErr("Error calling `\(funcName)`: \\(error.localizedDescription)")
            }
        
            return nil
        }
        """
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
