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

        let enumsExpr = node.arguments.first(where: { $0.label?.text == "enums" })?.expression ?? "[]"
        let registerDocs = node.arguments.first(where: { $0.label?.text == "registerDocs" })?.expression ?? "false"
        let hookMethod = node.arguments.first(where: { $0.label?.text == "hookMethod" })?.expression

        // Build per-element registerEnum(...) calls if enums is an array literal
        let enumRegistrationStatements: String = {
            if let array = enumsExpr.as(ArrayExprSyntax.self) {
                return array.elements.map { elem in
                    "registerEnum(\(elem.expression))"
                }.joined(separator: "\n                    ")
            } else {
                return """
                for e in \(enumsExpr) {
                        registerEnum(e)
                    }
                """
            }
        }()
        var hookInit = ""
        var hookDeinit = ""
        var hookDef = ""
        if let hookMethod {
            hookDef = "let hook: (GDExtension.InitializationLevel, Bool) -> () = \(hookMethod)"
            hookInit = "hook (level, true)"
            hookDeinit = "hook (level, false)"
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
            \(hookDef)
            initializeSwiftModule (interface, library, `extension`, initHook: { level in
                types[level]?.forEach(register)
                if level == .scene {
                    \(enumRegistrationStatements)
                } else if level == .editor {
                    if \(registerDocs) {
                        EditorInterop.loadLibraryDocs()
                    }
                }
                \(hookInit)
            }, deInitHook: { level in
                types[level]?.reversed().forEach(unregister)
                \(hookDeinit)
            })
            return 1
            """)
        }

        return ["\(raw: p.result)"]
    }
}
