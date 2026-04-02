//
//  GenerationSettings.swift
//  Generator
//
//

import Foundation

/// Names of classes (without the `.swift` suffix) that should be generated in this run.
var classesToGenerate: Set<String> = []
var classFilterProvided = false

/// Names of classes available to be referenced when generating code, including dependencies.
var availableClassNames: Set<String> = []
var availableClassFilterProvided = false

/// Explicitly allowed reference-type degradations for split targets.
/// Key is the original class name and value is the only permitted fallback ancestor.
var allowedClassFallbacks: [String: String] = [:]

/// Names of builtin types (without the `.swift` suffix) that should be generated in this run.
var builtinClassesToGenerate: Set<String> = []
var builtinFilterProvided = false

/// Godot reference types whose Swift wrappers should not be surfaced in this module.
/// Instead, raw helper methods returning `GodotNativeObjectPointer?` will be generated.
var deferredReturnTypes: Set<String> = []

/// Godot reference types that require high-level Swift extensions to be emitted in this module.
var deferredExtensionTypes: Set<String> = []

/// Godot classes (without the `.swift` suffix) that are expected to contain raw helper methods
/// for the deferred return types. Extensions will only be generated for classes in this set.
var deferredExtensionSourceClasses: Set<String> = []

/// Optional lines to inject after the standard generated file preamble.
var additionalPreamble: String = ""

/// Keeps track of the classes we actually surface (after filtering).
var classesSelectedForGeneration: [String] = []

/// Utility that trims whitespace and removes the `.swift` suffix when present.
func normalizedSymbolName(from entry: String) -> String {
    let trimmed = entry.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return "" }
    if trimmed.hasSuffix(".swift") {
        return String(trimmed.dropLast(".swift".count))
    }
    return trimmed
}

/// Utility to turn the raw contents of a filter file into normalized symbol names.
func normalizedSymbolEntries(from content: String) -> [String] {
    content
        .split(whereSeparator: \.isNewline)
        .map { normalizedSymbolName(from: String($0)) }
        .filter { !$0.isEmpty }
}

func shouldGenerateClass(_ name: String) -> Bool {
    guard classFilterProvided else { return true }
    return classesToGenerate.contains(name)
}

func shouldGenerateBuiltin(_ name: String) -> Bool {
    guard builtinFilterProvided else { return true }
    return builtinClassesToGenerate.contains(name)
}

/// Resolves a reference type against the available class whitelist.
/// Missing reference types are treated as generator configuration errors and
/// must be surfaced explicitly instead of silently degrading to `Object`.
func fallbackClassName(for original: String) -> String {
    guard classFilterProvided else {
        return original
    }

    guard !availableClassNames.contains(original) else {
        return original
    }

    let args = CommandLine.arguments.joined(separator: " ")
    print("Looking for \(original) but did not exist in \(args)")
    var currentName = original
    while let inherits = classMap[currentName]?.inherits {
        if availableClassNames.contains(inherits) {
            if allowedClassFallbacks[original] == inherits {
                return inherits
            }
            fatalError("""
            SwiftGodot Generator error: missing reference type '\(original)' in the current generation target.

            The closest available ancestor is '\(inherits)', but silently degrading '\(original)' to '\(inherits)' would change the generated API surface.
            Add '\(original).swift' to the target's generated class list or dependency class list instead of relying on fallback.
            If this degradation is intentional for a split target, add an explicit allowed fallback entry for '\(original)=\(inherits)'.
            """)
        }
        currentName = inherits
    }

    if let expectedFallback = allowedClassFallbacks[original] {
        return expectedFallback
    }

    fatalError("""
    SwiftGodot Generator error: missing reference type '\(original)' in the current generation target.

    No available ancestor was found for '\(original)'. Add '\(original).swift' to the target's generated class list or dependency class list.
    """)
}
