//
//  GodotMacroSearchingVisitor.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 17/10/2024.
//

import Foundation
import SwiftSyntax

/// Visitor that searches for classes with the @Godot macro
public class GodotMacroSearchingVisitor: SyntaxVisitor {
    /// Initialize the visitor, optionally with a logger.
    internal init(viewMode: SyntaxTreeViewMode, logger: ((String) -> Void)? = nil) {
        self.logger = logger
        super.init(viewMode: viewMode)
    }

    /// List of classes with the @Godot macro
    public var classes: [String] = []

    /// Logger function for verbose output
    public let logger: ((String) -> Void)?
    
    public override func visit(_ classDecl: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        for attribute in classDecl.attributes {
            if let attributeSyntax = attribute.as(AttributeSyntax.self) {
                let attributeName = attributeSyntax.attributeName.trimmedDescription
                if attributeName == "Godot" {
                    let className = classDecl.name.trimmedDescription
                    logger?("Found '\(className)' with @Godot macro.")
                    classes.append(className)
                    break // Found the @Godot macro, no need to check further
                }
            }
        }
            
        // only top level class declarations are supported
        return .skipChildren
    }
}
