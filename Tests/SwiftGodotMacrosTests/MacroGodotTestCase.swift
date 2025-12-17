//
//  MacroGodotTestCase.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 10/10/2024.
//

import XCTest
import Foundation
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
    
    /// Set `SWIFTGODOT_REGENERATE_MACRO_TEST_RESOURCES=1` to regenerate expected outputs into `Tests/SwiftGodotMacrosTests/Resources`.
    /// You can also set `SWIFTGODOT_REGENERATE_MACRO_TEST_RESOURCES=/absolute/path` to write elsewhere.
    let regeneratedResourcesPath: String? = {
        let envKey = "SWIFTGODOT_REGENERATE_MACRO_TEST_RESOURCES"
        guard let value = ProcessInfo.processInfo.environment[envKey], !value.isEmpty else {
            return nil
        }
        if value == "1" || value.lowercased() == "true" {
            return URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .appendingPathComponent("Resources")
                .path()
        }
        return value
    }()
        
    
    func regenerateExpansionResource(input: String, outputUrl: URL) {
        let file = Parser.parse(source: input)
                
        let context = BasicMacroExpansionContext(
            sourceFiles: [file: .init(moduleName: "test", fullFilePath: "test.swift")]
        )

        let macroSpecs = Self.macros.mapValues { MacroSpec(type: $0) }

        func contextGenerator(_ syntax: Syntax) -> BasicMacroExpansionContext {
            BasicMacroExpansionContext(sharingWith: context, lexicalContext: syntax.allMacroLexicalContexts())
        }

        let expandedSourceFile = file.expand(
            macroSpecs: macroSpecs,
            contextGenerator: contextGenerator,
            indentationWidth: .spaces(4)
        )
            
        do {
            let output = expandedSourceFile.description.trimmingCharacters(in: .newlines) + "\n"
            try output.write(to: outputUrl, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Failed to write expected data for \(name). \(error)")
        }
    }
    
    /// Compare expansion of `input`  with contents of `TestData/TestCaseClassName.functioName.expected`
    /// If `MacroGodotTestCase.regeneratedResourcesPath` is not `nil`, it will regenerate the expected output into that path instead
    func assertExpansion(of input: String, file: StaticString = #file, line: UInt = #line, function: String = #function, diagnostics: [DiagnosticSpec] = []) {
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
        
        assertExpansion(of: input, into: output, file: file, line: line, diagnostics: diagnostics)
    }
    
    /// Runs comparison of expansion of `input` into `output` using `Self.macros`.
    func assertExpansion(of input: String, into output: String, file: StaticString = #file, line: UInt = #line, diagnostics: [DiagnosticSpec]) {
        assertMacroExpansion(input, expandedSource: output, diagnostics: diagnostics, macros: Self.macros, file: file, line: line)
    }
}
