//
//  SwiftGodotTestSuiteMacro.swift
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

/// Macro that adds SwiftGodotTestSuiteProtocol conformance and generates allTests property.
/// Scans the class for methods decorated with @SwiftGodotTest and generates the allTests array.
public struct SwiftGodotTestSuiteMacro: MemberMacro, ExtensionMacro {

    // MARK: - MemberMacro: Generates allTests property

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Validate it's attached to a class
        guard declaration.is(ClassDeclSyntax.self) else {
            throw SwiftGodotTestMacroError.notAClass
        }

        // Find all methods with @SwiftGodotTest attribute
        let testMethods = declaration.memberBlock.members.compactMap { member -> String? in
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else {
                return nil
            }

            // Check if the function has @SwiftGodotTest attribute
            let hasTestAttribute = funcDecl.attributes.contains { attribute in
                guard let attr = attribute.as(AttributeSyntax.self),
                      let identifierType = attr.attributeName.as(IdentifierTypeSyntax.self) else {
                    return false
                }
                return identifierType.name.text == "SwiftGodotTest"
            }

            guard hasTestAttribute else { return nil }
            return funcDecl.name.text
        }

        // Generate the test entries
        let testEntries: String
        if testMethods.isEmpty {
            testEntries = ""
        } else {
            testEntries = testMethods.map { name in
                "SwiftGodotTestInvocation(name: \"\(name)\", run: \(name))"
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
