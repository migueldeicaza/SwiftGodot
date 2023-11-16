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
        var genMethod = "func _mproxy_\(funcName) (args: [Variant]) -> Variant? {\n"
        var retProp: String? = nil
        var retOptional: Bool = false
        
        if let (retType, ro) = getIdentifier (funcDecl.signature.returnClause?.type) {
            retProp = godotTypeToProp (typeName: retType)
            genMethod.append ("\tlet result = \(funcName) (")
            retOptional = ro
        } else {
            genMethod.append ("\t\(funcName) (")
        }
        //     let result = computeGodot (String (args [0]), Int (args [1]))
        
        var argc = 0
        for parameter in funcDecl.signature.parameterClause.parameters {
            guard let ptype = getTypeName(parameter) else {
                throw MacroError.typeName (parameter)
            }
            let first = parameter.firstName.text
            if argc != 0 {
                genMethod.append (", ")
            }
            if first != "_" {
                genMethod.append ("\(first): ")
            }
            
            if ptype == "Variant" {
                genMethod.append ("args [\(argc)]")
            } else {
                genMethod.append ("\(ptype).makeOrUnwrap (args [\(argc)])!")
            }
            
            argc += 1
        }
        
        genMethod.append (")\n")
        if retProp != nil {
            if retOptional {
                genMethod.append ("\tguard let result else { return nil }\n")
            }
            genMethod.append ("\treturn Variant (result)\n")
        } else {
            genMethod.append ("\treturn nil\n")
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
