//
//  MacroGodotTestCase.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 10/10/2024.
//

import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftSyntax
import SwiftParser
import SwiftSyntaxMacroExpansion

#if canImport(AppKit)
import AppKit
#endif

func indentCodeLiteral(_ code: String) -> String {
    code
        .components(separatedBy: .newlines)
        .map { "        " + $0 } // 8 spaces
        .joined(separator: "\n")
}

class MacroGodotTestCase: XCTestCase {
    class var macros: [String: Macro.Type] {
        [:]
    }
    
    /// Generates test body for comparing expansion of `input` using `Self.macros`
    /// `output` is in fact ignored and is just a convenience to replace `assertExpansion` with `generateTestBody` when test needs to be updated.
    /// and copes it into a Pasteboard, if `AppKit` can be imported.
    func generateTestBody(of input: String, into output: String) {
        let file = Parser.parse(source: input)
        
        let context = BasicMacroExpansionContext(
            sourceFiles: [file: .init(moduleName: "test", fullFilePath: "test.swift")]
        )

        let expandedSourceFile = file.expand(macros: Self.macros, in: context, indentationWidth: .spaces(4))
        
        let testBody = """
        assertExpansion(of: \"""
        \(indentCodeLiteral(input))
        \"""
            into: \"""
        \(indentCodeLiteral(expandedSourceFile.description))
        \"""
        )
        """
        
        #if canImport(AppKit)
        NSPasteboard.general.setString(testBody, forType: .string)
        #endif
    }
    
    /// Runs comparison of expansion of `input` into `output` using `Self.macros`.
    func assertExpansion(of input: String, into output: String) {
        assertMacroExpansion(input, expandedSource: output, macros: Self.macros)
    }
}
