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
        .map { "    " + $0.replacingOccurrences(of: "\\", with: "\\\\") } // 4 spaces
        .joined(separator: "\n")
}

class MacroGodotTestCase: XCTestCase {
    class var macros: [String: Macro.Type] {
        [:]
    }
    
    /// Runs comparison of expansion of `input` into `output` using `Self.macros`. If `generateNew` is true, copies the body of new test content into the clipboard (macOS only, other OS will do nothing)
    func assertExpansion(generateNew: Bool = false, of input: String, into output: String, file: StaticString = #file, line: UInt = #line) {
        if generateNew {
            let file = Parser.parse(source: input)
            
            let context = BasicMacroExpansionContext(
                sourceFiles: [file: .init(moduleName: "test", fullFilePath: "test.swift")]
            )

            let expandedSourceFile = file.expand(macros: Self.macros, contextGenerator: { _ in context }, indentationWidth: .spaces(4))
            
            let testBody = """
            assertExpansion(
                of: \"""
            \(indentCodeLiteral(input))
                \""",
                into: \"""
            \(indentCodeLiteral(expandedSourceFile.description))
                \"""
            )
            """
            
            #if canImport(AppKit)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(testBody, forType: .string)
            #endif
            XCTFail()
        }
        
        assertMacroExpansion(input, expandedSource: output, macros: Self.macros, file: file, line: line)
    }
}
