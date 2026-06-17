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
        let isStatic = funcDecl.hasClassOrStaticModifier
        
        if funcDecl.hasAsyncOrThrowsSpecifier {
            throw GodotMacroError.callableMacroOnThrowingOrAsyncFunction
        }

        // The body for the regular call
        var body = ""
        // The body for the ptrcall
        var bodyPtr = ""

        let parameters = funcDecl.parameters
        
        var callArgsList: [String] = []
        
        // Is there are no arguments, there is no do-catch scope to sanitize arguments access
        let indentation = parameters.isEmpty ? "" : "    "
        
        if !isStatic {
            body += """
            \(indentation)    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            \(indentation)        SwiftGodotRuntime.GD.printErr("Error calling `\(funcName)`: failed to unwrap instance \\(String(describing: pInstance))")
            \(indentation)        return nil
            \(indentation)    }
            """

            bodyPtr += """
            \(indentation)    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            \(indentation)        SwiftGodotRuntime.GD.printErr("Error calling `\(funcName)`: failed to unwrap instance \\(String(describing: pInstance))")
            \(indentation)        return
            \(indentation)    }
            """
        }

        let objectOrSelf = isStatic ? "self" : "object"

        // Godot only fills in default values for a contiguous run of trailing arguments. When the
        // variant call path is invoked with fewer arguments than declared, fall back to the Swift
        // default expression for any omitted trailing parameter. The ptrcall path always receives a
        // complete argument list, so it does not need the fallback.
        let parameterArray = Array(parameters)
        var trailingDefaultCount = 0
        for parameter in parameterArray.reversed() {
            guard parameter.defaultValueExpr != nil else { break }
            trailingDefaultCount += 1
        }
        let firstDefaultIndex = parameterArray.count - trailingDefaultCount

        for (index, parameter) in parameters.enumerated() {
            let ptype = parameter.type.trimmedDescription

            if index >= firstDefaultIndex, let defaultExpr = parameter.defaultValueExpr {
                body += """
                        let arg\(index) = arguments.count > \(index) ? try arguments.argument(ofType: \(ptype).self, at: \(index)) : (\(defaultExpr.trimmedDescription) as \(ptype))
                """
            } else {
                body += """
                        let arg\(index) = try arguments.argument(ofType: \(ptype).self, at: \(index))
                """
            }

            callArgsList.append("\(parameter.labelForCaller)arg\(index)")

            bodyPtr += """

            \(indentation)let arg\(index): \(ptype) = try rargs.fetchArgument(at: \(index))
            """
        }
        
        let callArgs = callArgsList.joined(separator: ", ")
        
        body += """
        \(indentation)    return SwiftGodotRuntime._wrapCallableResult(\(objectOrSelf).\(funcName)(\(callArgs)))
        
        """

        bodyPtr += """
        
        \(indentation)    SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, \(objectOrSelf).\(funcName)(\(callArgs))) 
        
        """

        let ptrCallDecl: String

        if !parameters.isEmpty {
            bodyPtr = """
            do { // safe arguments access scope
                \(bodyPtr)
            } catch {
                SwiftGodotRuntime.GD.printErr("Error calling `\(funcName)`: \\(String(describing: error))")                    
            }
        """
        }
        
        ptrCallDecl = """
        
        static func _pproxy_\(funcName)(        
        _ pInstance: UnsafeMutableRawPointer?,
        _ rargs: SwiftGodotRuntime.RawArguments,
        _ returnValue: UnsafeMutableRawPointer?) {
        \(bodyPtr)
        }
        """

        if parameters.isEmpty {
            return """
            static func _mproxy_\(funcName)(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
            \(body)                
            }\(ptrCallDecl)
            """
        } else {
            return """
            static func _mproxy_\(funcName)(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
                do { // safe arguments access scope
            \(body)        
                } catch {
                    SwiftGodotRuntime.GD.printErr("Error calling `\(funcName)`: \\(error.description)")                    
                }
            
                return nil
            }\(ptrCallDecl)
            """
        }
    }
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            let classError = Diagnostic(node: declaration.root, message: GodotMacroError.callableMacroNotOnFunction)
            context.diagnose(classError)
            return []
        }
        return [SwiftSyntax.DeclSyntax(stringLiteral: try process(funcDecl: funcDecl))]
    }
    
}
