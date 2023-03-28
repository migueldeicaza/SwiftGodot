//
//  Constants.swift
//  Generator
//
//  Created by Miguel de Icaza on 3/24/23.
//

import Foundation

func snakeToCamel (_ s: String) -> String {
    let parts = s.split (separator: "_")
    let r = parts [0].lowercased() + parts.dropFirst().map { x in x.prefix (1).capitalized + String (x.dropFirst()).cleverLowercase() }.joined()
    if s.first == "_" {
        return "_" + r
    }
    return r
}

extension String {
    func camelCaseToSnakeCase() -> String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return self.processCamalCaseRegex(pattern: acronymPattern)?
            .processCamalCaseRegex(pattern: normalPattern)?.lowercased() ?? self.lowercased()
    }
              
    fileprivate func processCamalCaseRegex(pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
    }
}

func camelToSnake (_ s: String) -> String {
    s.camelCaseToSnakeCase()
        .replacingOccurrences(of: "2_D", with: "2D").replacingOccurrences(of: "3_D", with: "3D")
        .replacingOccurrences(of: "2_d", with: "2d").replacingOccurrences(of: "3_d", with: "3d")
}

extension String {
    public func cleverLowercase () -> String
    {
        var upper = false
        var lower = false
        
        for x in self {
            upper = upper || x.isUppercase
            lower = lower || x.isLowercase
        }
        if upper && lower {
            return self
        }
        return self.lowercased()
    }
}

func escapeSwift (_ id: String) -> String {
    switch id {
    case "protocol", "func", "static", "inout", "in", "self", "case", "repeat", "default",
         "import", "init", "continue", "class", "operator", "where", "var", "enum", "nil", "extension", "internal":
        return "`\(id)`"
    default:
        return id
    }
}
