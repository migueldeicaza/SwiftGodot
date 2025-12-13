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

        let sceneTypes: ExprSyntax
        if let types = node.arguments.first(where: { $0.label?.text == "types" })?.expression {
            sceneTypes = types
        } else {
            sceneTypes = node.arguments.first(where: { $0.label?.text == "sceneTypes" })?.expression ?? "[]"
        }
        let coreTypes = node.arguments.first(where: { $0.label?.text == "coreTypes" })?.expression ?? "[]"
        let editorTypes = node.arguments.first(where: { $0.label?.text == "editorTypes" })?.expression ?? "[]"
        let serverTypes = node.arguments.first(where: { $0.label?.text == "serverTypes" })?.expression ?? "[]"
        let enumsExpr = node.arguments.first(where: { $0.label?.text == "enums" })?.expression ?? "[]"

        // Build per-element registerEnum(...) calls if enums is an array literal
        let enumRegistrationStatements: CodeBlockItemListSyntax = {
            if let array = enumsExpr.as(ArrayExprSyntax.self) {
                // Collect elements and build one call per element
                let items: [CodeBlockItemSyntax] = array.elements.map { elem in
                    let call: ExprSyntax = "registerEnum(\(elem.expression))"
                    return CodeBlockItemSyntax(item: .expr(call))
                }
                return CodeBlockItemListSyntax(items)
            } else {
                // Fallback: keep the runtime loop if not an array literal
                let loop: ExprSyntax = """
                for e in \(enumsExpr) {
                    registerEnum(e)
                }
                """
                return CodeBlockItemListSyntax {
                    CodeBlockItemSyntax(item: .expr(loop))
                }
            }
        }()

        // Build the init function, inserting the generated enum registration statements at .scene level
        let initModule: DeclSyntax = """
        @_cdecl(\(raw: cDecl.trimmedDescription)) public func enterExtension (interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
            guard let library, let interface, let `extension` else {
                print ("Error: Not all parameters were initialized.")
                return 0
            }
            var types: [ExtensionInitializationLevel: [Object.Type]] = [:]
            types[.core] = \(coreTypes).topologicallySorted()
            types[.editor] = \(editorTypes).topologicallySorted()
            types[.scene] = \(sceneTypes).topologicallySorted()
            types[.servers] = \(serverTypes).topologicallySorted()
            initializeSwiftModule (interface, library, `extension`, initHook: { level in
                types[level]?.forEach(register)
                if level == .scene {
                    \(enumRegistrationStatements)
                }
            }, deInitHook: { level in
                types[level]?.reversed().forEach(unregister)
            })
            return 1
        }
        """

        return [initModule]
    }
}
