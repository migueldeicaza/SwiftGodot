//
//  GenerationSettings.swift
//  Generator
//
//  Created by Code Assistant on 2024-06-03.
//

import Foundation

/// Names of classes (without the `.swift` suffix) that should be generated in this run.
var classWhitelist: Set<String> = []
var classFilterProvided = false

/// Names of builtin types (without the `.swift` suffix) that should be generated in this run.
var builtinWhitelist: Set<String> = []
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
    return classWhitelist.contains(name)
}

func shouldGenerateBuiltin(_ name: String) -> Bool {
    guard builtinFilterProvided else { return true }
    return builtinWhitelist.contains(name)
}

/// Finds the closest ancestor that is part of the whitelist, falling back to `Object`.
func fallbackClassName(for original: String) -> String {
    guard classFilterProvided, !classWhitelist.contains(original) else {
        return original
    }

    let args = CommandLine.arguments.joined(separator: " ")
    print("Looking for \(original) but did not exit in \(args)")
    var currentName = original
    while let inherits = classMap[currentName]?.inherits {
        if classWhitelist.contains(inherits) {
            return inherits
        }
        currentName = inherits
    }

    print("SwiftGodot Generator warning: falling back to Object for missing type '\(original)'.\n")

    return "Object"
}
