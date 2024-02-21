//
//  Constants.swift
//  Generator
//
//  Created by Miguel de Icaza on 3/24/23.
//

import Foundation
import ExtensionApi

func snakeToCamel(_ s: String) -> String {
    let parts = s.split(separator: "_")
    let r = parts[0].lowercased() + parts.dropFirst().map { x in x.prefix(1).capitalized + String(x.dropFirst()).cleverLowercase() }.joined()
    if s.first == "_" {
        return "_" + r
    }
    return r
}

extension String {
    func camelCaseToSnakeCase() -> String {
        let acronymRegex = #/([A-Z]+)([A-Z][a-z]|[0-9])/#
        let normalRegex = #/([a-z0-9])([A-Z])/#
        return processCamelCaseRegex(acronymRegex).processCamelCaseRegex(normalRegex).lowercased()
    }

    fileprivate func processCamelCaseRegex(_ regex: Regex<(Substring, Substring, Substring)>) -> String {
        replacing(regex) { "\($0.1)_\($0.2)" }
    }
}

func camelToSnake(_ s: String) -> String {
    s.camelCaseToSnakeCase()
        .replacingOccurrences(of: "2_D", with: "2D").replacingOccurrences(of: "3_D", with: "3D")
        .replacingOccurrences(of: "2_d", with: "2d").replacingOccurrences(of: "3_d", with: "3d")
}

public extension String {
    func cleverLowercase() -> String {
        var upper = false
        var lower = false

        for x in self {
            upper = upper || x.isUppercase
            lower = lower || x.isLowercase
        }
        if upper && lower {
            return self
        }
        return lowercased()
    }
}

func escapeSwift(_ id: String) -> String {
    switch id {
    case "protocol", "func", "static", "inout", "in", "self", "case", "repeat", "default",
         "import", "init", "continue", "class", "operator", "where", "var", "enum", "nil", "extension", "internal":
        return "`\(id)`"
    default:
        return id
    }
}

extension [String] {
    func commonPrefix() -> String? {
        guard count > 1 else { return nil }
        let alphabeticallySorted = sorted()

        guard let first = alphabeticallySorted.first,
              let last = alphabeticallySorted.last
        else {
            return nil
        }
        let prefix = first.commonPrefix(with: last)
        return prefix != "" ? prefix : nil
    }
}

extension [JGodotValueElement] {
    func commonPrefix() -> String {
        map(\.name).commonPrefix()?.dropAfterLastUnderscore() ?? ""
    }
}

extension String {
    func dropPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix), prefix != self else { return self }
        let prefixSize: Int
        // special-case for https://github.com/migueldeicaza/SwiftGodot/issues/23
        if prefix == "METHOD_", contains("METHOD_FLAG") {
            if self == "METHOD_FLAGS_DEFAULT" {
                prefixSize = "METHOD_FLAGS_".count
            } else {
                prefixSize = "METHOD_FLAG_".count
            }
        } else {
            prefixSize = prefix.count
        }
        let suffix = String(dropFirst(prefixSize))
        return suffix.isValidSwiftName() ? suffix : self
    }

    func dropAfterLastUnderscore() -> String? {
        if let range = range(of: "_", options: .backwards) {
            return String(prefix(upTo: range.upperBound))
        }
        return nil
    }

    func isValidSwiftName() -> Bool {
        wholeMatch(of: #/\b[a-zA-Z_][a-zA-Z0-9_]*\b/#) != nil
    }
}
