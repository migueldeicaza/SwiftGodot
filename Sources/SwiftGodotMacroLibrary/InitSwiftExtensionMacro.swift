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

        guard let cDecl = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
		
		let types: ExprSyntax
		if node.argumentList.count >= 2 {
			types = node.argumentList.last!.expression
		} else {
			types = "[]"
		}

        let initModule: DeclSyntax = """
        @_cdecl(\(raw: cDecl.description)) public func enterExtension (interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
            guard let library, let interface, let `extension` else {
                print ("Error: Not all parameters were initialized.")
                return 0
            }
            let types: [Wrapped.Type] = \(types)
            initializeSwiftModule (interface, library, `extension`, initHook: { level in
                switch level {
                case .scene:
                    types.forEach (register)
                default:
                    break
                }
            }, deInitHook: { level in
                switch level {
                case .scene:
                    types.forEach (unregister)
                default:
                    break
                }
            })
            return 1
        }
        """
        return [initModule]
    }
}
