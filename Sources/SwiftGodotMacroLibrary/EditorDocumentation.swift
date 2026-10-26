//
//  EditorDocumentation.swift
//  SwiftGodot
//
//  Builds the Godot class reference XML for a `@Godot` class from the
//  documentation comments on the class and its exported members.
//

import Foundation
import SwiftSyntax

/// Collects the documentation comments of a `@Godot` class while the macro
/// processes its members, and renders them as Godot class reference XML.
///
/// Godot loads all registered classes and inspects their structure (methods, properties, signals etc)
/// It uses the names discovered in this inspection to match items to documentation, so the XML
/// just matches those names.
struct EditorDocumentation {
    /// Whether the `@Godot` macro generates documentation. Enabled by building
    /// SwiftGodot with the `with_editor_documentation` package trait. The generated
    /// text is only compiled into modules that define
    /// `SWIFTGODOT_INCLUDE_EDITOR_DOCUMENTATION`.
#if SWIFTGODOT_EDITOR_DOCUMENTATION
    nonisolated(unsafe) static var isEnabled = true
#else
    nonisolated(unsafe) static var isEnabled = false
#endif

    enum Kind {
        case method
        case member
        case signal
        case constant
    }

    private struct Entry {
        let kind: Kind
        let godotName: String
        let comment: [String]
        let deprecation: String?
    }

    let className: String
    private var classComment: [String] = []
    private var classDeprecation: String?
    private var entries: [Entry] = []

    /// Godot references keyed by the Swift names that documentation comments
    /// use for them (`name`, `name(_:label:)`, `Enum/case`).
    private var symbols: [String: String] = [:]
    private var enumNames: Set<String> = []

    init(className: String) {
        self.className = className
    }

    mutating func setClassComment(from decl: some DeclSyntaxProtocol, attributes: AttributeListSyntax) {
        classComment = docCommentLines(in: decl.leadingTrivia)
        classDeprecation = deprecationMessage(in: attributes)
    }

    /// Records an exported member, so that it is documented and can be referred
    /// to from other comments.
    mutating func add(
        _ kind: Kind,
        swiftNames: [String],
        godotName: String,
        trivia: Trivia,
        attributes: AttributeListSyntax? = nil
    ) {
        let reference: String
        switch kind {
        case .method: reference = "[method \(godotName)]"
        case .member: reference = "[member \(godotName)]"
        case .signal: reference = "[signal \(godotName)]"
        case .constant: reference = "[constant \(godotName)]"
        }
        for name in swiftNames where symbols[name] == nil {
            symbols[name] = reference
        }

        // Overloads share a Godot name; document the first.
        guard !entries.contains(where: { $0.kind == kind && $0.godotName == godotName }) else { return }
        let comment = docCommentLines(in: trivia)
        let deprecation = attributes.flatMap(deprecationMessage(in:))
        guard !comment.isEmpty || deprecation != nil else { return }
        entries.append(Entry(kind: kind, godotName: godotName, comment: comment, deprecation: deprecation))
    }

    /// Records the cases of a nested enumeration, which Godot registers as
    /// integer constants of the class named after each case.
    mutating func addEnum(_ enumDecl: EnumDeclSyntax) {
        let enumName = enumDecl.name.text
        enumNames.insert(enumName)
        for member in enumDecl.memberBlock.members {
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else { continue }
            for element in caseDecl.elements {
                let caseName = element.name.identifier?.name ?? element.name.text
                add(
                    .constant,
                    swiftNames: ["\(enumName)/\(caseName)"],
                    godotName: caseName,
                    trivia: caseDecl.leadingTrivia,
                    attributes: caseDecl.attributes
                )
            }
        }
    }

    // MARK: Rendering

    /// The class reference XML, or `nil` when nothing is documented.
    func xml() -> String? {
        guard !classComment.isEmpty || classDeprecation != nil || !entries.isEmpty else { return nil }

        let converter = DocCommentBBCodeConverter(resolveSymbol: resolveSymbol)
        let classDoc = converter.convert(classComment)

        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"
        xml += "<class name=\"\(escapedAttribute(className))\"\(deprecationAttribute(classDeprecation))>\n"
        xml += "<brief_description>\(escapedText(classDoc.summary ?? ""))</brief_description>\n"
        xml += "<description>\(escapedText(classDoc.discussion.joined(separator: "\n")))</description>\n"

        func section(_ kind: Kind, container: String, render: (Entry, String) -> String) {
            let sectionEntries = entries.filter { $0.kind == kind }
            guard !sectionEntries.isEmpty else { return }
            xml += "<\(container)>\n"
            for entry in sectionEntries {
                xml += render(entry, escapedText(converter.convert(entry.comment).fullText)) + "\n"
            }
            xml += "</\(container)>\n"
        }

        section(.method, container: "methods") { entry, text in
            "<method name=\"\(escapedAttribute(entry.godotName))\"\(deprecationAttribute(entry.deprecation))><description>\(text)</description></method>"
        }
        section(.member, container: "members") { entry, text in
            "<member name=\"\(escapedAttribute(entry.godotName))\" type=\"\"\(deprecationAttribute(entry.deprecation))>\(text)</member>"
        }
        section(.signal, container: "signals") { entry, text in
            "<signal name=\"\(escapedAttribute(entry.godotName))\"\(deprecationAttribute(entry.deprecation))><description>\(text)</description></signal>"
        }
        section(.constant, container: "constants") { entry, text in
            "<constant name=\"\(escapedAttribute(entry.godotName))\" value=\"\"\(deprecationAttribute(entry.deprecation))>\(text)</constant>"
        }
        xml += "</class>\n"
        return xml
    }

    /// Resolves a DocC symbol reference (` ``name`` `) to a Godot reference.
    private func resolveSymbol(_ reference: String) -> String {
        var components = reference
            .split(separator: "/")
            .map { component in
                // Drop DocC disambiguation suffixes such as `-swift.property`.
                var name = String(component)
                if let dash = name.lastIndex(of: "-"), !name[..<dash].hasSuffix("(") {
                    let suffix = name[name.index(after: dash)...]
                    if !suffix.isEmpty, !suffix.contains(")") {
                        name = String(name[..<dash])
                    }
                }
                return name
            }
        if components.count > 1, components.first == className {
            components.removeFirst()
        }
        let path = components.joined(separator: "/")

        if let symbol = symbols[path] {
            return symbol
        }
        if components.count == 1 {
            let name = components[0]
            let baseName = name.split(separator: "(").first.map(String.init) ?? name
            if let symbol = symbols[baseName] {
                return symbol
            }
            if enumNames.contains(baseName) {
                return "[enum \(baseName)]"
            }
            if let first = baseName.first, first.isUppercase, baseName.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }) {
                return "[\(baseName)]"
            }
        }
        return "[code]\(reference)[/code]"
    }

    /// The message of an `@available(*, deprecated)` attribute, empty when it
    /// has none, or `nil` when the declaration is not deprecated.
    private func deprecationMessage(in attributes: AttributeListSyntax) -> String? {
        for element in attributes {
            guard case .attribute(let attribute) = element,
                  attribute.attributeName.trimmedDescription == "available",
                  case .availability(let arguments) = attribute.arguments else { continue }
            var isDeprecated = false
            var message: String?
            var renamed: String?
            for argument in arguments {
                switch argument.argument {
                case .token(let token) where token.text == "deprecated":
                    isDeprecated = true
                case .availabilityLabeledArgument(let labeled):
                    let label = labeled.label.text
                    if label == "deprecated" {
                        isDeprecated = true
                    }
                    if case .string(let literal) = labeled.value {
                        let text = literal.segments.map(\.content.text).joined()
                        if label == "message" {
                            message = text
                        } else if label == "renamed" {
                            renamed = text
                        }
                    }
                default:
                    break
                }
            }
            if isDeprecated {
                if let message {
                    return message
                }
                if let renamed {
                    return "Use [code]\(renamed)[/code] instead."
                }
                return ""
            }
        }
        return nil
    }

    private func deprecationAttribute(_ message: String?) -> String {
        guard let message else { return "" }
        return " deprecated=\"\(escapedAttribute(message))\""
    }

    private func escapedText(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    private func escapedAttribute(_ text: String) -> String {
        escapedText(text)
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "\n", with: "&#10;")
    }
}

/// Encodes `text` as a single-line Swift string literal.
func swiftStringLiteral(_ text: String) -> String {
    var literal = "\""
    for scalar in text.unicodeScalars {
        switch scalar {
        case "\\": literal += "\\\\"
        case "\"": literal += "\\\""
        case "\n": literal += "\\n"
        case "\r": literal += "\\r"
        case "\t": literal += "\\t"
        default:
            if scalar.value < 0x20 {
                literal += "\\u{\(String(scalar.value, radix: 16))}"
            } else {
                literal.unicodeScalars.append(scalar)
            }
        }
    }
    return literal + "\""
}
