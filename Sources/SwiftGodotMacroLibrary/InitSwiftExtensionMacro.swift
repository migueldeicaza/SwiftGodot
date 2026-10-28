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
        let autoloads = node.arguments.first(where: { $0.label?.text == "autoloads" })?.expression
        let fileID = context.location(of: node, at: .afterLeadingTrivia, filePathMode: .fileID)?.file
            .as(StringLiteralExprSyntax.self)?.segments.compactMap {
                $0.as(StringSegmentSyntax.self)?.content.text
            }.joined() ?? "SwiftExtension/EntryPoint.swift"
        let moduleName = String(fileID.split(separator: "/").first ?? "SwiftExtension")
        let suffix = String(moduleName.map { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "_") ? $0 : "_" })
        let pluginClassName = "SwiftGodotAutoloadPlugin_" + suffix
        let pluginName = "_SwiftGodotAutoloadSupport." + pluginClassName

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
            hookDef = "let hook: (ExtensionInitializationLevel, Bool) -> () = \(hookMethod)"
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

            if let autoloads {
                p("let autoloads: [Autoload] = \(autoloads)")
            }

            if let types = node.arguments.first(where: { $0.label?.text == "types" })?.expression.trimmedDescription {
                let registrationTypes = autoloads == nil ? types : "autoloads.typesForRegistration(adding: \(types))"
                p("""
                let types: [ExtensionInitializationLevel: [Object.Type]]
                do {
                    types = try \(registrationTypes).prepareForRegistration()
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
                let registrationSceneTypes = autoloads == nil ? sceneTypes.trimmedDescription : "autoloads.typesForRegistration(adding: \(sceneTypes))"

                p("""
                var types: [ExtensionInitializationLevel: [Object.Type]] = [:]
                types[.core] = \(coreTypes).topologicallySorted()
                types[.editor] = \(editorTypes).topologicallySorted()
                types[.scene] = \(registrationSceneTypes).topologicallySorted()
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
                    }\(autoloads == nil ? "" : "\n        \(pluginName).autoloads = autoloads\n        SwiftGodotAutoloads.initialize(pluginType: \(pluginName).self)")
                }
                \(hookInit)
            }, deInitHook: { level in\(autoloads == nil ? "" : "\n    if level == .editor {\n        SwiftGodotAutoloads.deinitialize(pluginType: \(pluginName).self)\n    }")
                types[level]?.reversed().forEach(unregister)
                \(hookDeinit)
            }, minimumInitializationLevel: minimumInitializationLevel(for: types))
            return 1
            """)
        }

        var declarations: [DeclSyntax] = ["\(raw: p.result)"]
        if autoloads != nil {
            declarations.append("""
            enum _SwiftGodotAutoloadSupport {
                @Godot(.tool)
                final class \(raw: pluginClassName): EditorPlugin {
                    static var autoloads: [Autoload] = []

                    override func _enterTree() {
                        SwiftGodotAutoloads.synchronize(Self.autoloads, owner: \(literal: suffix), plugin: self)
                    }
                }
            }
            """)
        }
        return declarations
    }
}
