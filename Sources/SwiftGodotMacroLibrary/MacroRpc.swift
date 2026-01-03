//
//  MacroRpc.swift
//  SwiftGodot
//
//  Created by Claude on 2025-01-02.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A peer macro that marks a function for RPC configuration.
/// This is a marker macro - it doesn't generate any peer code itself.
/// The @Godot macro detects this attribute and generates the rpcConfig call.
public struct GodotRpc: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        // Validate that @Rpc is applied to a function
        guard declaration.as(FunctionDeclSyntax.self) != nil else {
            let error = Diagnostic(node: declaration.root, message: GodotMacroError.rpcMacroNotOnFunction)
            context.diagnose(error)
            return []
        }

        // This is a marker macro - no peer code is generated.
        // The @Godot macro will detect @Rpc and generate rpcConfig registration.
        return []
    }
}
