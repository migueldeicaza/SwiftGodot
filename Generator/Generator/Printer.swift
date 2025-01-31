//
//  Printer.swift
//  Generator
//
//  Created by Miguel de Icaza on 4/19/23.
//

import Foundation

class Printer {
    let name: String
    // Where we accumulate our output for the p/b routines
    var result = ""
    var indentStr = ""  // The current indentation string, based on `indent`
    let addPreamble: Bool
    var indent = 0 {
        didSet {
            indentStr = String(repeating: "    ", count: indent)
        }
    }

    fileprivate init(name: String, addPreamble: Bool) {
        self.name = name
        self.addPreamble = addPreamble
    }

    fileprivate static let preamble =
        """
        // This file is auto-generated, do not edit.
        @_implementationOnly import GDExtension

        #if CUSTOM_BUILTIN_IMPLEMENTATIONS
        #if canImport(Darwin)
        import Darwin
        #elseif os(Windows)
        import ucrt
        import WinSDK
        #elseif canImport(Glibc)
        import Glibc
        #elseif canImport(Musl)
        import Musl
        #else
        #error("Unable to identify your C library.")
        #endif
        #endif



        """

    // Prints the string, indenting any newlines with the current indentation
    func p (_ str: String) {
        for x in str.split(separator: "\n", omittingEmptySubsequences: false) {
            print("\(indentStr)\(x)", to: &result)
        }
    }

    func `if`(_ `if`: String, then: () -> (), else: () -> ()) {
        p ("if \(`if`) {")
        indent += 1
        then()
        indent -= 1
        p ("} else {")
        indent += 1
        `else`()
        indent -= 1
        p ("}")
    }

    // Prints a variable definition
    func staticVar(visibility: String = "", name: String, type: String, block: () -> ()) {
        if generateResettableCache {
            p ("fileprivate static var _c_\(name): \(type)? = nil")
            p ("fileprivate static var _g_\(name): UInt16 = 0")
            b("\(visibility)static var \(name): \(type) ") {
                self("if _g_\(name) == swiftGodotLibraryGeneration") {
                    self("if let _c_\(name)") {
                        self("return _c_\(name)")
                    }
                }
                p ("_g_\(name) = swiftGodotLibraryGeneration")
                self("func load () -> \(type)") {
                    block()
                }
                self("let ret = load ()")
                self("_c_\(name) = ret")
                self("return ret")
            }
        } else {
            b("\(visibility)static var \(name): \(type) =", suffix: "()", block: block)
        }
    }

    // Prints a block, automatically indents the code in the closure
    func b(_ str: String, arg: String? = nil, suffix: String = "", block: () -> ()) {
        p (str + " {" + (arg ?? ""))
        indent += 1
        let saved = indent
        block()
        if indent != saved {
            print("Indentation out of sync, the nested block messed with indentation")
        }
        indent -= 1
        p ("}\(suffix)\n")
    }

    func callAsFunction(_ str: String) {
        p (str)
    }

    func callAsFunction(_ str: String, arg: String? = nil, suffix: String = "", block: () -> ()) {
        b(str, arg: arg, suffix: suffix, block: block)
    }

    func save(_ file: String) {
        let output = (addPreamble ? Self.preamble : "") + result

        let existing = try? String(contentsOfFile: file)
        if existing != output {
            try! output.write(toFile: file, atomically: false, encoding: .utf8)
        }
    }
}

actor PrinterFactory {
    static let shared = PrinterFactory()

    private var printers: [Printer] = []

    func initPrinter(_ name: String, withPreamble: Bool) -> Printer {
        let printer = Printer(name: name, addPreamble: withPreamble)
        printers.append(printer)
        return printer
    }

    func save(_ file: String) {
        let combined = printers.sorted(by: { $0.name < $1.name }).map ({ $0.result }).joined(separator: "\n")
        let output = Printer.preamble + combined

        let existing = try? String(contentsOf: URL(fileURLWithPath: file), encoding: .utf8)
        if existing != output {
            try! output.write(toFile: file, atomically: false, encoding: .utf8)
        }
    }

    func saveMultiplexed(_ root: String) {
        for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            let combined =
                printers
                .filter({ $0.name.uppercased().first == letter })
                .sorted(by: { $0.name < $1.name })
                .map ({ $0.result })
                .joined(separator: "\n")
            let output = Printer.preamble + combined

            let url = URL(fileURLWithPath: root).appending(path: "SwiftGodot\(letter).swift")
            let existing = try? String(contentsOf: url, encoding: .utf8)
            if existing != output {
                try? output.write(to: url, atomically: false, encoding: .utf8)
            }
        }
    }

}
