//
//  SupportSources.swift
//  SwiftGodot/Generator
//
//  The hand-written sources of the SwiftGodot target, as a consumer target that
//  generates its own bindings gets them (see --support-source).
//

import Foundation

/// `source`, the hand-written source `name`, for a consumer target: it names the
/// runtime `runtimeModuleName`, and each top-level declaration that uses a class
/// that is not generated is left out (and listed in `omittedMembers`). A
/// declaration's comments and attributes go with it; `#if` lines are kept.
func consumerSupportSource (_ source: String, name: String) -> String {
    var scanner = SwiftLineScanner ()
    var output = ""
    var chunk = ""
    var chunkDeclaration: String?
    var chunkIdentifiers = Set<String> ()

    func flush () {
        let missing = chunkIdentifiers.filter { classMap [$0] != nil && !availableClassNames.contains ($0) }.sorted ()
        if missing.isEmpty {
            output += chunk
        } else {
            let declaration = chunkDeclaration ?? ""
            let classes = missing.count == 1 ? "\(missing [0]), which is" : "\(missing.joined (separator: ", ")), which are"
            output += "// Left out: \(declaration) uses \(classes) not generated here.\n"
            omittedMembersLock.lock ()
            omittedMembers.append ("\(name): \(declaration): \(missing.joined (separator: ", "))")
            omittedMembersLock.unlock ()
        }
        chunk = ""
        chunkDeclaration = nil
        chunkIdentifiers = []
    }

    var lines = source.split (separator: "\n", omittingEmptySubsequences: false)
    if lines.last == "" {
        lines.removeLast ()
    }
    for line in lines {
        let wasAtTopLevel = scanner.isAtTopLevel
        let (code, identifiers) = scanner.scan (line)
        let trimmed = code.trimmingCharacters (in: .whitespaces)
        if wasAtTopLevel && trimmed.range (of: #"^#(if|elseif|else|endif)\b"#, options: .regularExpression) != nil {
            flush ()
            output += line + "\n"
            continue
        }
        chunk += line + "\n"
        chunkIdentifiers.formUnion (identifiers)
        if chunkDeclaration == nil && !trimmed.isEmpty
            && trimmed.range (of: #"^(@\w+(\([^()]*\))?\s*)+$"#, options: .regularExpression) == nil {
            chunkDeclaration = trimmed.trimmingCharacters (in: CharacterSet (charactersIn: "{ "))
        }
        if chunkDeclaration != nil && scanner.isAtTopLevel {
            flush ()
        }
    }
    flush ()

    if runtimeModuleName == "SwiftGodotRuntime" {
        return output
    }
    return output.replacingOccurrences (of: #"\bSwiftGodotRuntime\b"#, with: runtimeModuleName, options: .regularExpression)
}

/// Follows comments, string literals and brackets across the lines of a Swift source.
struct SwiftLineScanner {
    private enum Mode {
        case string (multiline: Bool)
        case interpolation (depth: Int)
    }
    private var modes: [Mode] = []
    private var blockComments = 0
    private var depth = 0

    /// True between declarations: outside any bracket, string or comment.
    var isAtTopLevel: Bool { modes.isEmpty && blockComments == 0 && depth == 0 }

    /// The line's code, without comments or the contents of string literals, and
    /// the identifiers in it (including those in string interpolations).
    mutating func scan (_ line: Substring) -> (code: String, identifiers: Set<String>) {
        let chars = Array (line)
        var code = ""
        var identifiers = Set<String> ()
        var i = 0
        func at (_ text: String) -> Bool {
            chars [i...].starts (with: text)
        }
        while i < chars.count {
            let c = chars [i]
            if blockComments > 0 {
                if at ("*/") {
                    blockComments -= 1
                    i += 2
                } else if at ("/*") {
                    blockComments += 1
                    i += 2
                } else {
                    i += 1
                }
                continue
            }
            if case .string (let multiline)? = modes.last {
                if c == "\\" {
                    if i + 1 < chars.count && chars [i + 1] == "(" {
                        modes.append (.interpolation (depth: 0))
                    }
                    i += 2
                } else if multiline ? at ("\"\"\"") : c == "\"" {
                    modes.removeLast ()
                    code += "\""
                    i += multiline ? 3 : 1
                } else {
                    i += 1
                }
                continue
            }
            if at ("//") {
                break
            }
            if at ("/*") {
                blockComments += 1
                i += 2
                continue
            }
            if c == "\"" {
                let multiline = at ("\"\"\"")
                modes.append (.string (multiline: multiline))
                code += "\""
                i += multiline ? 3 : 1
                continue
            }
            if c.isLetter || c == "_" {
                var end = i
                while end < chars.count && (chars [end].isLetter || chars [end].isNumber || chars [end] == "_") {
                    end += 1
                }
                let word = String (chars [i..<end])
                identifiers.insert (word)
                code += word
                i = end
                continue
            }
            if case .interpolation (let interpolationDepth)? = modes.last {
                if c == "(" {
                    modes [modes.count - 1] = .interpolation (depth: interpolationDepth + 1)
                } else if c == ")" {
                    if interpolationDepth == 0 {
                        modes.removeLast ()
                        i += 1
                        continue
                    }
                    modes [modes.count - 1] = .interpolation (depth: interpolationDepth - 1)
                }
            } else if "([{".contains (c) {
                depth += 1
            } else if ")]}".contains (c) {
                depth -= 1
            }
            code.append (c)
            i += 1
        }
        return (code, identifiers)
    }
}
