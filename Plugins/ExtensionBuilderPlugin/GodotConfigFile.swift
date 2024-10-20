import Foundation

/// Basic implementation of a config file parser.
/// This probably exists somewhere already!
class GodotConfigFile {
    static let sectionPattern: Regex = #/\s*\[(?<section>\w+)\]\s*/#
    static let assignmentPattern: Regex = #/\s*(?<key>\S+)\s*=\s*(?<value>.*)\s*/#
    static let stringPattern: Regex = #/"(?<content>.*)"/#

    var content: [String: [String: String]]
    var sections: [String]
    var _encoded: String?

    init() {
        content = [:]
        sections = []
    }

    init(_ url: URL) async throws {
        var section = "_"
        var values: [String: String] = [:]
        var content: [String: [String: String]] = [:]
        var sections: [String] = []

        func endSection() {
            if !values.isEmpty {
                sections.append(section)
                content[section] = values
            }
        }

        for try await line in url.lines {
            if let match = line.matches(of: Self.sectionPattern).first {
                endSection()
                section = String(match.section)
                values = [:]
            } else if let match = line.matches(of: Self.assignmentPattern).first {
                values[String(match.key)] = String(match.value)
            }
        }
        endSection()

        self.content = content
        self.sections = sections
    }

    /// Set a string value in a section.
    func set(_ key: String, raw: String, section: String) {
        if content[section] == nil {
            content[section] = [:]
            sections.append(section)
        }

        content[section]?[key] = raw
        _encoded = nil
    }

    func set(_ key: String, _ value: String, section: String) {
        set(key, raw: "\"\(value)\"", section: section)
    }

    func set(_ key: String, _ value: [String: String], section: String) {
        var values: [String] = []
        for (k, v) in value {
            values.append("\"\(k)\": \"\(v)\"")
        }
        set(key, raw: "{ \(values.joined(separator: ",")) }", section: section)
    }

    func set<T>(_ key: String, _ value: T, section: String) where T: CustomStringConvertible {
        set(key, raw: value.description, section: section)
    }

    /// Get a string value from a section.
    func get(_ key: String, section: String) -> String? {
        if let entry = content[section]?[key],
            let value = entry.matches(of: Self.stringPattern).first
        {
            return String(value.content)
        }
        return nil
    }

    /// Remove a section.
    func remove(section: String) {
        content.removeValue(forKey: section)
        sections.removeAll { $0 == section }
        _encoded = nil
    }

    /// The string-encoded version of the file.
    /// We write out the sections in the order they were added,
    /// to preserve the rough order of the original file.
    var encoded: String {
        if _encoded == nil {
            var chunks: [String] = []
            for section in sections {
                let values = content[section]!
                var output = "[\(section)]\n"
                for (key, value) in values {
                    output.append("\(key) = \(value)\n")
                }
                chunks.append(output)
            }
            _encoded = chunks.joined(separator: "\n")
        }

        return _encoded!
    }

    /// Write the file to a URL as a UTF8 string.
    func write(to url: URL) async throws {
        try encoded.write(to: url, atomically: true, encoding: .utf8)
    }
}
