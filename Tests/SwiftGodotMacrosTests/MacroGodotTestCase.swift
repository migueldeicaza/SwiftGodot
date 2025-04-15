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
    
    /// Set it to local path to regenerate expansions test data in case the macro was updated
    let regeneratedResourcesPath: String? =
        nil
//        URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Resources").path()
        
    
    func regenerateExpansionResource(input: String, outputUrl: URL) {
        let file = Parser.parse(source: input)
                
        let context = BasicMacroExpansionContext(
            sourceFiles: [file: .init(moduleName: "test", fullFilePath: "test.swift")]
        )

        let expandedSourceFile = file.expand(macros: Self.macros, contextGenerator: { _ in context }, indentationWidth: .spaces(4))
            
        do {
            try expandedSourceFile.description.write(to: outputUrl, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Failed to write expected data for \(name). \(error)")
        }
    }
    
    /// Compare expansion of `input`  with contents of `TestData/TestCaseClassName.functioName.expected`
    /// If `MacroGodotTestCase.regeneratedResourcesPath` is not `nil`, it will regenerate the expected output into that path instead
    func assertExpansion(of input: String, file: StaticString = #file, line: UInt = #line, function: String = #function) {
        let resourceName = "\(Self.self).\(function.dropLast(2))"
        
        if let regeneratedResourcesPath {
            let outputResourceUrl = URL(fileURLWithPath: regeneratedResourcesPath).appendingPathComponent("\(resourceName).swift")
            regenerateExpansionResource(input: input, outputUrl: outputResourceUrl)
            return
        }
        
        guard let outputResource = Bundle.module.url(forResource: resourceName, withExtension: "swift", subdirectory: "Resources") else {
            XCTFail("No expected data found for \(name)")
            return
        }
        
        guard let output = try? String(contentsOf: outputResource) else {
            XCTFail("Failed to read expected data for \(name)")
            return
        }
        
        assertExpansion(of: input, into: output, file: file, line: line)
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
