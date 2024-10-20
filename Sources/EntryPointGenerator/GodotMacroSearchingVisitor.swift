//
//  GodotMacroSearchingVisitor.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 17/10/2024.
//

import Foundation
import SwiftSyntax

public class GodotMacroSearchingVisitor: SyntaxVisitor {
    public var classes: [String] = []
    
    public override func visit(_ classDecl: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        // Check for attached macros (attributes)
        for attribute in classDecl.attributes {
            if let attributeSyntax = attribute.as(AttributeSyntax.self) {
                let attributeName = attributeSyntax.attributeName.description.trimmingCharacters(in: .whitespacesAndNewlines)
                if attributeName == "Godot" {
                    let className = classDecl.name.text
                    print("Found '\(className)' with @Godot macro.")
                    classes.append(className)
                    break // Found the @Godot macro, no need to check further
                }
            }
        }
            
        // only top level class declarations are supported
        return .skipChildren
    }
}
