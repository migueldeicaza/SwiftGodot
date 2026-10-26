//
//  DocCommentBBCode.swift
//  SwiftGodot
//
//  Converts Swift documentation comments into the BBCode dialect used by
//  Godot's class reference.
//

import Foundation
import SwiftSyntax

/// Extracts the documentation comment (`///` lines and `/** */` blocks) from a
/// declaration'. The lines are returned with the comment markers
/// and common indentation removed.
func docCommentLines(in trivia: Trivia) -> [String] {
    var lines: [String] = []
    for piece in trivia {
        switch piece {
        case .docLineComment(let text):
            lines.append(String(text.dropFirst(3)))
        case .docBlockComment(let text):
            lines.append(contentsOf: docBlockCommentLines(text))
        default:
            break
        }
    }
    return removingCommonIndentation(lines)
}

private func docBlockCommentLines(_ text: String) -> [String] {
    var body = Substring(text)
    if body.hasPrefix("/**") {
        body = body.dropFirst(3)
    }
    if body.hasSuffix("*/") {
        body = body.dropLast(2)
    }
    var lines = body.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    while let first = lines.first, first.allSatisfy(\.isWhitespace) {
        lines.removeFirst()
    }
    while let last = lines.last, last.allSatisfy(\.isWhitespace) {
        lines.removeLast()
    }
    // Strip the " * " decoration when every line carries it.
    let decorated = lines.allSatisfy { line in
        let trimmed = line.drop { $0 == " " || $0 == "\t" }
        return trimmed.isEmpty || trimmed.hasPrefix("*")
    }
    if decorated {
        lines = lines.map { line in
            let trimmed = line.drop { $0 == " " || $0 == "\t" }
            return String(trimmed.dropFirst())
        }
    }
    return lines
}

private func removingCommonIndentation(_ lines: [String]) -> [String] {
    let indentation = lines
        .filter { !$0.allSatisfy(\.isWhitespace) }
        .map { $0.prefix { $0 == " " }.count }
        .min() ?? 0
    return lines.map { line in
        line.allSatisfy(\.isWhitespace) ? "" : String(line.dropFirst(indentation))
    }
}

/// The result of converting a documentation comment.
struct ConvertedDocComment {
    /// The first paragraph, when the comment starts with one.
    var summary: String?
    /// The remaining blocks, in order, followed by any parameters, returns and
    /// throws sections.
    var discussion: [String]

    var isEmpty: Bool {
        summary == nil && discussion.isEmpty
    }

    /// The whole comment as a single description.
    var fullText: String {
        ((summary.map { [$0] } ?? []) + discussion).joined(separator: "\n")
    }
}

/// Converts Markdown found in the Swift documentation comments to Godot's
/// documentation BBCode.
///
/// Godot separates paragraphs with a single newline and writes lists as
/// `- ` lines, so blocks are joined with newlines. Callouts such as
/// `- Note:` become `[b]Note:[/b]`, matching Godot's own class reference, and
/// `- Parameter`, `- Returns:` and `- Throws:` are gathered into sections at
/// the end. Double-backtick symbol references are passed to `resolveSymbol`.
struct DocCommentBBCodeConverter {
    let resolveSymbol: (String) -> String

    /// Callout keywords recognized by Swift's documentation markup.
    private static let calloutKeywords: Set<String> = [
        "attention", "author", "authors", "bug", "complexity", "copyright", "date",
        "experiment", "important", "invariant", "mutatingvariant", "nonmutatingvariant",
        "note", "postcondition", "precondition", "remark", "remarks", "requires",
        "seealso", "since", "tip", "todo", "version", "warning",
    ]

    func convert(_ lines: [String]) -> ConvertedDocComment {
        var blocks: [(text: String, isParagraph: Bool)] = []
        var parameters: [(name: String, text: String)] = []
        var returns: [String] = []
        var throwsText: [String] = []
        var paragraph: [String] = []

        func flushParagraph() {
            guard !paragraph.isEmpty else { return }
            blocks.append((inline(paragraph.joined(separator: " ")), true))
            paragraph.removeAll()
        }

        var index = 0
        while index < lines.count {
            let line = lines[index]
            let indentation = line.prefix { $0 == " " }.count
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                flushParagraph()
                index += 1
                continue
            }

            // Fenced code block.
            if trimmed.hasPrefix("```") || trimmed.hasPrefix("~~~") {
                flushParagraph()
                let fence = String(trimmed.prefix(3))
                var code: [String] = []
                index += 1
                while index < lines.count, !lines[index].trimmingCharacters(in: .whitespaces).hasPrefix(fence) {
                    code.append(String(lines[index].dropFirst(min(indentation, lines[index].prefix { $0 == " " }.count))))
                    index += 1
                }
                index += 1
                blocks.append((codeBlock(code), false))
                continue
            }

            // Indented code block.
            if indentation >= 4, paragraph.isEmpty {
                var code: [String] = []
                while index < lines.count {
                    let codeLine = lines[index]
                    let codeIndentation = codeLine.prefix { $0 == " " }.count
                    if !codeLine.isEmpty && codeIndentation < 4 {
                        break
                    }
                    code.append(String(codeLine.dropFirst(min(4, codeIndentation))))
                    index += 1
                }
                while code.last?.isEmpty == true {
                    code.removeLast()
                }
                blocks.append((codeBlock(code), false))
                continue
            }

            // Heading.
            if let heading = headingText(trimmed) {
                flushParagraph()
                blocks.append(("[b]\(inline(heading))[/b]", false))
                index += 1
                continue
            }

            // Block quote, possibly a DocC aside such as `> Note: ...`.
            if trimmed.hasPrefix(">") {
                flushParagraph()
                var quoted: [String] = []
                while index < lines.count {
                    let quoteLine = lines[index].trimmingCharacters(in: .whitespaces)
                    guard quoteLine.hasPrefix(">") else { break }
                    quoted.append(String(quoteLine.dropFirst()).trimmingCharacters(in: .whitespaces))
                    index += 1
                }
                let text = quoted.joined(separator: " ")
                if let (keyword, rest) = callout(text) {
                    blocks.append(("[b]\(keyword):[/b] \(inline(rest))", false))
                } else {
                    blocks.append((inline(text), false))
                }
                continue
            }

            // List item, possibly a callout, parameter, returns or throws field.
            if let (marker, content) = listItem(trimmed) {
                flushParagraph()
                var text = content
                index += 1
                // Lazy continuation lines belong to the item.
                while index < lines.count {
                    let next = lines[index]
                    let nextTrimmed = next.trimmingCharacters(in: .whitespaces)
                    if nextTrimmed.isEmpty || listItem(nextTrimmed) != nil || nextTrimmed.hasPrefix("```") {
                        break
                    }
                    text += " " + nextTrimmed
                    index += 1
                }

                if indentation == 0, let field = field(text) {
                    switch field {
                    case .parameter(let name, let description):
                        parameters.append((name, inline(description)))
                    case .parameters:
                        // Nested `- name: description` items follow.
                        while index < lines.count {
                            let next = lines[index]
                            let nextIndentation = next.prefix { $0 == " " }.count
                            let nextTrimmed = next.trimmingCharacters(in: .whitespaces)
                            if nextTrimmed.isEmpty {
                                index += 1
                                continue
                            }
                            guard nextIndentation > 0, let (_, item) = listItem(nextTrimmed) else { break }
                            var itemText = item
                            index += 1
                            while index < lines.count {
                                let continuation = lines[index].trimmingCharacters(in: .whitespaces)
                                if continuation.isEmpty || listItem(continuation) != nil {
                                    break
                                }
                                itemText += " " + continuation
                                index += 1
                            }
                            if let colon = itemText.firstIndex(of: ":") {
                                let name = itemText[..<colon].trimmingCharacters(in: .whitespaces)
                                let description = itemText[itemText.index(after: colon)...].trimmingCharacters(in: .whitespaces)
                                parameters.append((name, inline(description)))
                            }
                        }
                    case .returns(let description):
                        returns.append(inline(description))
                    case .throws(let description):
                        throwsText.append(inline(description))
                    case .callout(let keyword, let description):
                        blocks.append(("[b]\(keyword):[/b] \(inline(description))", false))
                    }
                    continue
                }

                let nesting = String(repeating: "  ", count: indentation / 2)
                blocks.append(("\(nesting)\(marker) \(inline(text))", false))
                continue
            }

            paragraph.append(trimmed)
            index += 1
        }
        flushParagraph()

        if !parameters.isEmpty {
            blocks.append(("[b]Parameters:[/b]", false))
            for parameter in parameters {
                blocks.append(("- [param \(parameter.name)]: \(parameter.text)", false))
            }
        }
        for text in returns {
            blocks.append(("[b]Returns:[/b] \(text)", false))
        }
        for text in throwsText {
            blocks.append(("[b]Throws:[/b] \(text)", false))
        }

        var result = ConvertedDocComment(summary: nil, discussion: [])
        if let first = blocks.first, first.isParagraph {
            result.summary = first.text
            result.discussion = blocks.dropFirst().map(\.text)
        } else {
            result.discussion = blocks.map(\.text)
        }
        return result
    }

    // MARK: Blocks

    private func codeBlock(_ lines: [String]) -> String {
        "[codeblock]\n" + lines.joined(separator: "\n") + "\n[/codeblock]"
    }

    private func headingText(_ line: String) -> String? {
        let hashes = line.prefix { $0 == "#" }.count
        guard (1...6).contains(hashes) else { return nil }
        let rest = line.dropFirst(hashes)
        guard rest.first == " " else { return nil }
        return rest.trimmingCharacters(in: .whitespaces)
    }

    /// Returns the marker (`-` or `1.`) and content of a list item.
    private func listItem(_ line: String) -> (String, String)? {
        if let first = line.first, "-*+".contains(first), line.dropFirst().first == " " {
            return ("-", String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces))
        }
        let digits = line.prefix { $0.isASCII && $0.isNumber }
        if !digits.isEmpty {
            let rest = line.dropFirst(digits.count)
            if let delimiter = rest.first, delimiter == "." || delimiter == ")", rest.dropFirst().first == " " {
                return ("\(digits).", String(rest.dropFirst(2)).trimmingCharacters(in: .whitespaces))
            }
        }
        return nil
    }

    private enum Field {
        case parameter(String, String)
        case parameters
        case returns(String)
        case `throws`(String)
        case callout(String, String)
    }

    private func field(_ text: String) -> Field? {
        guard let colon = text.firstIndex(of: ":") else { return nil }
        let head = text[..<colon].trimmingCharacters(in: .whitespaces)
        let description = text[text.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        let words = head.split(separator: " ")
        if words.count == 2, words[0].lowercased() == "parameter" {
            return .parameter(String(words[1]), description)
        }
        switch head.lowercased() {
        case "parameters":
            return description.isEmpty ? .parameters : nil
        case "returns":
            return .returns(description)
        case "throws":
            return .throws(description)
        default:
            if let (keyword, rest) = callout(text) {
                return .callout(keyword, rest)
            }
            return nil
        }
    }

    private func callout(_ text: String) -> (String, String)? {
        guard let colon = text.firstIndex(of: ":") else { return nil }
        let keyword = text[..<colon].trimmingCharacters(in: .whitespaces)
        let normalized = keyword.lowercased().replacingOccurrences(of: " ", with: "")
        guard Self.calloutKeywords.contains(normalized) else { return nil }
        return (keyword, text[text.index(after: colon)...].trimmingCharacters(in: .whitespaces))
    }

    // MARK: Inline markup

    /// Converts inline Markdown: code spans, symbol references, emphasis,
    /// links and literal brackets (which BBCode would otherwise take as tags).
    func inline(_ text: String) -> String {
        let characters = Array(text)
        var output = ""
        var openEmphasis: [String] = []
        var index = 0

        func matches(_ delimiter: String, at position: Int) -> Bool {
            let delimiterCharacters = Array(delimiter)
            guard position + delimiterCharacters.count <= characters.count else { return false }
            return Array(characters[position..<position + delimiterCharacters.count]) == delimiterCharacters
        }

        func isWordCharacter(_ position: Int) -> Bool {
            guard position >= 0, position < characters.count else { return false }
            return characters[position].isLetter || characters[position].isNumber
        }

        func isWhitespace(_ position: Int) -> Bool {
            guard position >= 0, position < characters.count else { return true }
            return characters[position].isWhitespace
        }

        /// Whether `delimiter` at `position` could close an emphasis run.
        func canClose(_ delimiter: String, at position: Int) -> Bool {
            guard !isWhitespace(position - 1) else { return false }
            if delimiter.hasPrefix("_") {
                return !isWordCharacter(position + delimiter.count)
            }
            return true
        }

        func closingDelimiterExists(_ delimiter: String, after position: Int) -> Bool {
            var search = position
            while search < characters.count {
                if characters[search] == "`" {
                    // Skip code spans.
                    let run = characters[search...].prefix { $0 == "`" }.count
                    if let close = closingBackticks(run, after: search + run) {
                        search = close + run
                        continue
                    }
                }
                if matches(delimiter, at: search), canClose(delimiter, at: search) {
                    // A single `*` must not be the start of `**`.
                    if delimiter.count == 1, matches(delimiter + delimiter, at: search) {
                        search += 2
                        continue
                    }
                    return true
                }
                search += 1
            }
            return false
        }

        func closingBackticks(_ count: Int, after position: Int) -> Int? {
            var search = position
            while search < characters.count {
                if characters[search] == "`" {
                    let run = characters[search...].prefix { $0 == "`" }.count
                    if run == count {
                        return search
                    }
                    search += run
                } else {
                    search += 1
                }
            }
            return nil
        }

        func emphasisTag(_ delimiter: String) -> String {
            switch delimiter {
            case "**", "__": "b"
            case "~~": "s"
            default: "i"
            }
        }

        while index < characters.count {
            let character = characters[index]

            // Backslash escapes.
            if character == "\\", index + 1 < characters.count, characters[index + 1].isPunctuation || characters[index + 1].isSymbol {
                output += literal(characters[index + 1])
                index += 2
                continue
            }

            // Code spans and double-backtick symbol references.
            if character == "`" {
                let run = characters[index...].prefix { $0 == "`" }.count
                if let close = closingBackticks(run, after: index + run) {
                    var content = String(characters[(index + run)..<close])
                    if content.hasPrefix(" ") && content.hasSuffix(" ") && content.count > 1 {
                        content = String(content.dropFirst().dropLast())
                    }
                    if run == 2 {
                        output += resolveSymbol(content)
                    } else {
                        // Godot does not parse tags inside [code], so brackets stay as they are.
                        output += "[code]\(content)[/code]"
                    }
                    index = close + run
                } else {
                    output += String(repeating: "`", count: run)
                    index += run
                }
                continue
            }

            // Images keep their alternative text; links become [url].
            if character == "!", index + 1 < characters.count, characters[index + 1] == "[",
               let (text, _, end) = link(in: characters, at: index + 1) {
                output += inline(text)
                index = end
                continue
            }
            if character == "[" {
                if let (text, destination, end) = link(in: characters, at: index) {
                    output += "[url=\(destination)]\(inline(text))[/url]"
                    index = end
                } else {
                    output += "[lb]"
                    index += 1
                }
                continue
            }
            if character == "]" {
                output += "[rb]"
                index += 1
                continue
            }

            // Autolinks.
            if character == "<", let close = characters[index...].firstIndex(of: ">") {
                let destination = String(characters[(index + 1)..<close])
                if destination.hasPrefix("http://") || destination.hasPrefix("https://") || destination.hasPrefix("mailto:") {
                    output += "[url]\(destination)[/url]"
                    index = close + 1
                    continue
                }
            }

            // Emphasis and strikethrough.
            if character == "*" || character == "_" || character == "~" {
                let candidates = character == "~" ? ["~~"] : [String(repeating: String(character), count: 2), String(character)]
                var handled = false
                for delimiter in candidates where matches(delimiter, at: index) {
                    if openEmphasis.last == delimiter, canClose(delimiter, at: index) {
                        openEmphasis.removeLast()
                        output += "[/\(emphasisTag(delimiter))]"
                    } else if !isWhitespace(index + delimiter.count),
                              !(delimiter.hasPrefix("_") && isWordCharacter(index - 1)),
                              closingDelimiterExists(delimiter, after: index + delimiter.count) {
                        openEmphasis.append(delimiter)
                        output += "[\(emphasisTag(delimiter))]"
                    } else {
                        continue
                    }
                    index += delimiter.count
                    handled = true
                    break
                }
                if handled {
                    continue
                }
            }

            output += literal(character)
            index += 1
        }

        for delimiter in openEmphasis.reversed() {
            output += "[/\(emphasisTag(delimiter))]"
        }
        return output
    }

    /// Parses `[text](destination)` starting at the opening bracket.
    private func link(in characters: [Character], at start: Int) -> (String, String, Int)? {
        var depth = 0
        var index = start
        var textEnd: Int?
        while index < characters.count {
            if characters[index] == "[" {
                depth += 1
            } else if characters[index] == "]" {
                depth -= 1
                if depth == 0 {
                    textEnd = index
                    break
                }
            }
            index += 1
        }
        guard let textEnd, textEnd + 1 < characters.count, characters[textEnd + 1] == "(" else { return nil }
        guard let close = characters[(textEnd + 2)...].firstIndex(of: ")") else { return nil }
        let destination = String(characters[(textEnd + 2)..<close]).trimmingCharacters(in: .whitespaces)
        guard !destination.isEmpty, !destination.contains(" ") else { return nil }
        return (String(characters[(start + 1)..<textEnd]), destination, close + 1)
    }

    private func literal(_ character: Character) -> String {
        switch character {
        case "[": "[lb]"
        case "]": "[rb]"
        default: String(character)
        }
    }
}
