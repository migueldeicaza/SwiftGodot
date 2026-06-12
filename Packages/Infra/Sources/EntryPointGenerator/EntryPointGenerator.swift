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

    @Option(name: .shortAndLong, help: "Produce more output.") 
    var verbose: Bool = false

    mutating func run() throws {
        let visitor = GodotMacroSearchingVisitor(viewMode: .all, logger: verbose ? logVerbose : nil)
        
        logVerbose("Scanning source files...")
        for file in sourceFiles {
            logVerbose("Scanning '\(file)'...")
            let source = try String(contentsOf: URL(fileURLWithPath: file))
            let fileSyntax = Parser.parse(source: source)
            
            visitor.walk(fileSyntax)
        }
        
        let names = visitor.classes
            .map { name in "    \(name).self" }
            .joined(separator: ",\n")
        
        let source = """
        import SwiftGodot

        #initSwiftExtension(cdecl: "swift_entry_point", types: [
        \(names)
        ])
        
        """
        
        let count = visitor.classes.count
        logVerbose("Writing \(count) to '\(outputFile)'...")
        let outputURL = URL(fileURLWithPath: outputFile)
        try source.write(to: outputURL, atomically: true, encoding: .utf8)
        log("Generated swift_entry_point, registering \(count) classes, in \(outputURL.lastPathComponent).")
    }

    /// Log a message to the console.
    func log(_ message: String) {
        print(message)
    }

    /// Log a message to the console if verbose mode is enabled.
    func logVerbose(_ message: String) {
        if verbose {
            print(message)
        }
    }
}
