//
//  GodotNaming.swift
//  SwiftGodot
//
//  Converts Swift identifiers to the naming convention Godot expects when a
//  symbol is registered with the engine (methods, properties, signals,
//  arguments, enum constants).
//
//  Behavior is controlled by the `automatic_godot_naming_convention` package trait, which
//  defines `SWIFTGODOT_GODOT_NAMING`. These functions are intentionally NOT
//  `@inlinable`: macro-expanded code in client modules always *calls* them, but
//  the trait-dependent branch is resolved when this runtime is compiled, so a
//  single switch in the package manifest flips behavior for every consumer.
//

// MARK: - Public, trait-gated entry points (called from macro-expanded code)

#if SWIFTGODOT_GODOT_NAMING

/// Internal API. Converts a Swift member identifier (method, property, signal,
/// argument, getter/setter) to Godot's `snake_case` convention.
public func _convertMemberNameToMatchGodotConvention(_ name: String) -> String {
    _godotMemberCase(name)
}

/// Internal API. Converts a Swift enum case identifier to Godot's
/// `UPPER_SNAKE_CASE` constant convention.
public func _convertEnumCaseNameToMatchGodotConvention(_ name: String) -> String {
    _godotEnumCase(name)
}

#else

/// Internal API. With the `automatic_godot_naming_convention` trait disabled, names are passed
/// through verbatim.
public func _convertMemberNameToMatchGodotConvention(_ name: String) -> String {
    name
}

/// Internal API. With the `automatic_godot_naming_convention` trait disabled, names are passed
/// through verbatim.
public func _convertEnumCaseNameToMatchGodotConvention(_ name: String) -> String {
    name
}

#endif

// MARK: - Conversion implementation (Foundation-free, always compiled, testable)

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
func _godotMemberCase(_ s: String) -> String {
    let chars = Array(s)
    let n = chars.count
    guard n > 0 else { return s }

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

/// camelCase / PascalCase → `UPPER_SNAKE_CASE` (Godot enum constant convention).
func _godotEnumCase(_ s: String) -> String {
    _godotMemberCase(s).uppercased()
}
