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

@main
struct EntryPointGenerator: ParsableCommand {
    @Option(name: .shortAndLong, help: "Output file for generated entry point")
    var outputFile: String
    
    @Argument(help: "Source files containing @Godot classes to generate entry points for.")
    var sourceFiles: [String]

    mutating func run() throws {
        let visitor = GodotMacroSearchingVisitor(viewMode: .all)
        
        print("Scanning source files...")
        for file in sourceFiles {
            print("Scanning '\(file)'...")
            let source = try String(contentsOf: URL(fileURLWithPath: file))
            let fileSyntax = Parser.parse(source: source)
            
            visitor.walk(fileSyntax)
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
        
        print("Writing \(visitor.classes.count) to '\(outputFile)'...")
        let outputURL = URL(fileURLWithPath: outputFile)
        try source.write(to: outputURL, atomically: true, encoding: .utf8)
        print("Success! Entry point is `swift_entry_point`.")
    }
}
