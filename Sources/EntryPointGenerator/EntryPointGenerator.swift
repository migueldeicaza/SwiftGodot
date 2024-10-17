//
//  EntryPointGenerator.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 17/10/2024.
//

import Foundation
import ArgumentParser
import SwiftSyntax
import SwiftParser

class GodotMacroSearchingVisitor: SyntaxVisitor {
    var classes: [String] = []
    
    override func visit(_ classDecl: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        // Check for attached macros (attributes)
        let attributes = classDecl.attributes
        
        for attribute in classDecl.attributes {
            if let attributeSyntax = attribute.as(AttributeSyntax.self) {
                let attributeName = attributeSyntax.attributeName.description.trimmingCharacters(in: .whitespacesAndNewlines)
                if attributeName == "Godot" {
                    classes.append(classDecl.name.text)
                    break // Found the @Godot macro, no need to check further
                }
            }
        }
            
        // only top level class declarations are supported
        return .skipChildren
    }
}

@main
struct EntryPointGenerator: ParsableCommand {
    @Option(name: .shortAndLong, help: "Output file for generated entry point")
    var outputFile: String
    
    @Argument(help: "Source files containing @Godot classes to generate entry points for.")
    var sourceFiles: [String]

    mutating func run() throws {
        let visitor = GodotMacroSearchingVisitor(viewMode: .all)
        
        for file in sourceFiles {
            let source = try String(contentsOf: URL(fileURLWithPath: file))
            let fileSyntax = Parser.parse(source: source)
            
            _ = visitor.visit(fileSyntax)
        }
        
        let names = visitor.classes
            .map { name in
                "    \(name).self"
            }
            .joined(separator: ",\n")
        
        let source = """
        import SwiftGodot

        #initSwiftExtension(cdecl: "swift_entry_point", types: [
        \(names)
        ])
        
        """
        
        let outputURL = URL(fileURLWithPath: outputFile)
        try source.write(to: outputURL, atomically: true, encoding: .utf8)
    }
}
