//
//  GodotNaming.swift
//  SwiftGodot
//
//  Swift→Godot identifier naming, in two layers:
//
//   * Pure case converters — `snakeCaseIdentifier(_:)` and
//     `screamingSnakeCaseIdentifier(_:)` — always apply the conversion,
//     independent of any trait. Foundation-free and deterministic.
//
//   * Trait-gated translation — `_translateMemberIdentifier(_:)` and
//     `_translateConstantIdentifier(_:)` — apply the conversion when the
//     `consistent_name_translation` package trait is enabled (the default) and
//     return the identifier verbatim when it is disabled. These are what the
//     macros emit calls to. They are intentionally NOT `@inlinable`: the
//     trait-dependent branch (the `SWIFTGODOT_CONSISTENT_NAME_TRANSLATION`
//     define) is resolved when this runtime is compiled, so one switch in the
//     package manifest flips behavior for every consumer without re-expanding or
//     recompiling client code.
//

// MARK: - Pure case converters (always convert, trait-independent)

/// camelCase / PascalCase → `snake_case`.
///
/// Reproduces the legacy regex behavior used by the generator and the macro
/// library (`camelCaseToSnakeCase()` followed by the `2_D`/`3_D` fix-ups):
///   acronym rule:   `([A-Z]+)([A-Z][a-z]|[0-9])` → `$1_$2`
///   normal rule:    `([a-z0-9])([A-Z])`           → `$1_$2`
///   then lowercase, then collapse `2_d`/`3_d` back to `2d`/`3d`.
///
/// Leading underscores are preserved (`_ready` stays `_ready`) and the function
/// is idempotent on already-snake input (`get_my_prop` stays `get_my_prop`).
public func snakeCaseIdentifier(_ name: String) -> String {
    let chars = Array(name)
    let n = chars.count
    guard n > 0 else { return name }

    func isUpper(_ c: Character) -> Bool { c >= "A" && c <= "Z" }
    func isLower(_ c: Character) -> Bool { c >= "a" && c <= "z" }
    func isDigit(_ c: Character) -> Bool { c >= "0" && c <= "9" }

    var out: [Character] = []
    out.reserveCapacity(n + n / 2)

    for i in 0 ..< n {
        let c = chars[i]
        if i > 0 {
            let prev = chars[i - 1]
            if isUpper(c), isLower(prev) || isDigit(prev) {
                // normal rule: lower/digit followed by an uppercase
                out.append("_")
            } else if isUpper(c), isUpper(prev), i + 1 < n, isLower(chars[i + 1]) {
                // acronym rule (a): caps run then the cap that starts a new word
                out.append("_")
            } else if isDigit(c), isUpper(prev) {
                // acronym rule (b): caps run immediately followed by a digit
                out.append("_")
            }
        }
        out.append(c)
    }

    var lowered = String(out.map { c -> Character in
        if let ascii = c.asciiValue, ascii >= 65, ascii <= 90 {
            return Character(UnicodeScalar(ascii + 32))
        }
        return c
    })

    // After lowercasing, both "2_D" and "2_d" are "2_d"; collapse the spurious split.
    lowered = lowered.replacing("2_d", with: "2d")
    lowered = lowered.replacing("3_d", with: "3d")
    return lowered
}

/// camelCase / PascalCase → `SCREAMING_SNAKE_CASE` (Godot enum-constant convention).
public func screamingSnakeCaseIdentifier(_ name: String) -> String {
    snakeCaseIdentifier(name).uppercased()
}

// MARK: - Trait-gated translation (called from macro-expanded code)

#if SWIFTGODOT_CONSISTENT_NAME_TRANSLATION

/// The name a Swift member (method, property, signal, argument, getter/setter)
/// is registered under in Godot: the `snake_case` form under the
/// `consistent_name_translation` trait (the default), verbatim when disabled.
public func _translateMemberIdentifier(_ name: String) -> String {
    snakeCaseIdentifier(name)
}

/// The name a Swift enum case is registered under as a Godot integer constant:
/// the `UPPER_SNAKE_CASE` form under the `consistent_name_translation` trait
/// (the default), verbatim when disabled.
public func _translateConstantIdentifier(_ name: String) -> String {
    screamingSnakeCaseIdentifier(name)
}

#else

/// With the `consistent_name_translation` trait disabled, the identifier is returned verbatim.
public func _translateMemberIdentifier(_ name: String) -> String {
    name
}

/// With the `consistent_name_translation` trait disabled, the identifier is returned verbatim.
public func _translateConstantIdentifier(_ name: String) -> String {
    name
}

#endif
