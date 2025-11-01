//
//  InitSwiftExtensionMacro.swift
//  SwiftGodot
//
//  Created by Marquis Kurt on 5/27/23.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct InitSwiftExtensionMacro: DeclarationMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax,
                                 in context: some MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {

        guard let cDecl = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        
        let p = CodePrinter()
        p("@_cdecl(\(cDecl.trimmedDescription)) public func enterExtension(interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8", .curly) {
            p("""
            guard let library, let interface, let `extension` else {
                print ("Error: Not all parameters were initialized.")
                return 0
            }
            
            """)
            
            if let types = node.arguments.first(where: { $0.label?.text == "types" })?.expression.trimmedDescription {
                p("""
                let types: [GDExtension.InitializationLevel: [Object.Type]]
                do {
                    types = try \(types).prepareForRegistration()
                } catch {
                    GD.printErr("Error during GDExtension initialization: \\(error)")
                    return 0
                }
                """)
            } else {
                let sceneTypes = node.arguments.first(where: { $0.label?.text == "sceneTypes" })?.expression ?? "[]"
                let coreTypes = node.arguments.first(where: { $0.label?.text == "coreTypes" })?.expression ?? "[]"
                let editorTypes = node.arguments.first(where: { $0.label?.text == "editorTypes" })?.expression ?? "[]"
                let serverTypes = node.arguments.first(where: { $0.label?.text == "serverTypes" })?.expression ?? "[]"
                
                p("""
                var types: [GDExtension.InitializationLevel: [Object.Type]] = [:]
                types[.core] = \(coreTypes).topologicallySorted()
                types[.editor] = \(editorTypes).topologicallySorted()
                types[.scene] = \(sceneTypes).topologicallySorted()
                types[.servers] = \(serverTypes).topologicallySorted()                
                """)
            }
            
            p("""
            initializeSwiftModule (interface, library, `extension`, initHook: { level in
                types[level]?.forEach(register)
            }, deInitHook: { level in
                types[level]?.reversed().forEach(unregister)
            }, minimumInitializationLevel: minimumInitializationLevel(for: types))
            return 1
            """)
        }
                
        return ["\(raw: p.result)"]
    }
}
