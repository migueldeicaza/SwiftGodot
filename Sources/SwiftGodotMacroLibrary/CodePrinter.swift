//
//  Printer.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 22/04/2025.
//

class CodePrinter {
    enum Brackets {
        case parentheses
        case square
        case curly
        
        var left: String {
            switch self {
            case .parentheses:
                "("
            case .curly:
                "{"
            case .square:
                "["
            }
        }
        
        var right: String {
            switch self {
            case .parentheses:
                ")"
            case .curly:
                "}"
            case .square:
                "]"
            }
        }
    }
    
    var result = ""
    private var indentStr: String {
        String(repeating: "    ", count: indent)
    }
    
    private var indent = 0

    // Prints the string, indenting any newlines with the current indentation
    func p(_ str: String) {
        for x in str.split(separator: "\n", omittingEmptySubsequences: false) {
            print("\(indentStr)\(x)", to: &result)
        }
    }

    // Prints a block, automatically indents the code in block and surrounds it with brackets of choice
    func b(_ str: String, _ brackets: Brackets, afterBlock: String, block: () throws -> Void) rethrows {
        p (str + "\(brackets.left)")
        indent += 1
        try block()
        indent -= 1
        p("\(brackets.right)\(afterBlock)")
    }

    func callAsFunction(_ str: String) {
        p(str)
    }

    func callAsFunction(_ str: String, _ brackets: Brackets, afterBlock: String = "", block: () throws -> Void) rethrows {
        try b(str, brackets, afterBlock: afterBlock, block: block)
    }
}
