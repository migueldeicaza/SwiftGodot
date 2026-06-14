//
//  TestSuiteSearchingVisitor.swift
//  SwiftGodot
//
//  Searches for classes annotated with the @SwiftGodotTestSuite macro.
//

import Foundation
import SwiftSyntax

/// Visitor that collects the names of all classes decorated with @SwiftGodotTestSuite.
public class TestSuiteSearchingVisitor: SyntaxVisitor {
    /// Initialize the visitor, optionally with a logger.
    internal init(viewMode: SyntaxTreeViewMode, logger: ((String) -> Void)? = nil) {
        self.logger = logger
        super.init(viewMode: viewMode)
    }

    /// Names of the classes decorated with @SwiftGodotTestSuite, in the order encountered.
    public var suites: [String] = []

    /// Logger function for verbose output.
    public let logger: ((String) -> Void)?

    public override func visit(_ classDecl: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        for attribute in classDecl.attributes {
            if let attributeSyntax = attribute.as(AttributeSyntax.self) {
                let attributeName = attributeSyntax.attributeName.trimmedDescription
                if attributeName == "SwiftGodotTestSuite" {
                    let className = classDecl.name.trimmedDescription
                    logger?("Found '\(className)' with @SwiftGodotTestSuite macro.")
                    suites.append(className)
                    break
                }
            }
        }

        // Only top level class declarations are supported.
        return .skipChildren
    }
}
