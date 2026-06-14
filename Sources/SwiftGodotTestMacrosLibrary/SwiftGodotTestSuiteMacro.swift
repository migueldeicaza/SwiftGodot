//
//  SwiftGodotTestSuiteMacro.swift
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

/// Macro that adds SwiftGodotTestSuiteProtocol conformance and generates allTests property.
/// Scans the class for methods whose name begins with `test` and generates the allTests array.
public struct SwiftGodotTestSuiteMacro: MemberMacro, ExtensionMacro {

    // MARK: - MemberMacro: Generates allTests property

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(ClassDeclSyntax.self) else {
            throw SwiftGodotTestMacroError.notAClass
        }

        // Find all test methods: instance methods whose name begins with `test`,
        // take no arguments, and have no effect specifiers (async/throws).
        let testMethods = declaration.memberBlock.members.compactMap { member -> String? in
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else {
                return nil
            }

            // The token text strips surrounding backticks, so a method written as
            // `func \`test\`()` reports a name of "test" here.
            let name = funcDecl.name.text
            guard name.hasPrefix("test") else { return nil }

            let signature = funcDecl.signature
            guard signature.parameterClause.parameters.isEmpty else { return nil }
            guard signature.effectSpecifiers == nil else { return nil }
            guard signature.returnClause == nil else { return nil }

            return name
        }

        let testEntries: String
        if testMethods.isEmpty {
            testEntries = ""
        } else {
            testEntries = testMethods.map { name in
                // Escape the reference in case the method name needs backticks.
                "SwiftGodotTestInvocation(name: \"\(name)\", run: `\(name)`)"
            }.joined(separator: ",\n            ")
        }

        let allTestsDecl: DeclSyntax = """
            var allTests: [SwiftGodotTestInvocation] {
                [
                    \(raw: testEntries)
                ]
            }
            """

        return [allTestsDecl]
    }

    // MARK: - ExtensionMacro: Adds protocol conformance

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let ext = try ExtensionDeclSyntax("extension \(type): SwiftGodotTestSuiteProtocol {}")
        return [ext]
    }
}
