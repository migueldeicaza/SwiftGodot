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
        
        // Is there are no arguments, there is no do-catch scope to sanitize arguments access
        let indentation = parameters.isEmpty ? "" : "    "
        
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
            callArgsList.append("\(labelOrNothing)arg\(index)")
        }
        
        let callArgs = callArgsList.joined(separator: ", ")
        
        var retProp: String? = nil
        var isReturnedTypeOptional: Bool = false
        
        if let (returnedTypeName, _, ro) = getIdentifier (funcDecl.signature.returnClause?.type) {
            retProp = godotTypeToProp (typeName: returnedTypeName)
            isReturnedTypeOptional = ro
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
        \(indentation)    \(resultDeclOrNothing)\(funcName)(\(callArgs))
        
        """
        
        if retProp != nil {
            if isReturnedTypeOptional {
                body += """
                \(indentation)    guard let result else { return nil }
                
                """
            }
            
            if funcDecl.isReturnedTypeSwiftArray, let elementType = funcDecl.returnedSwiftArrayElementType {
                body += """
                \(indentation)    return Variant(
                \(indentation)        result.reduce(into: GArray(\(elementType).self)) { array, element in
                \(indentation)            array.append(Variant(element))
                \(indentation)        }
                \(indentation)    )
                
                """
            } else {
                body += """
                \(indentation)    return Variant(result)  
                  
                """
            }
        } else {
            body += """
            \(indentation)    return nil                
            """
        }
        
        if parameters.isEmpty {
            return """
            func _mproxy_\(funcName)(arguments: borrowing Arguments) -> Variant? {
            \(body)                
            }
            """
        } else {
            return """
            func _mproxy_\(funcName)(arguments: borrowing Arguments) -> Variant? {
                do { // safe arguments access scope
            \(body)        
                } catch let error as ArgumentAccessError {
                    GD.printErr(error.description)
                    return nil
                } catch {
                    GD.printErr("Error calling `\(funcName)`: \\(error.localizedDescription)")
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
