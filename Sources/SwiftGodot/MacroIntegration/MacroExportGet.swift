//
//  MacroExportGet.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 09/04/2025.
//

/// Internal API. Required for macros.
@inline(__always)
@inlinable
public func _macroExportGet<T>(_ value: T) -> Variant? where T: _GodotBridgeable {
    return value.toVariant()
}

/// Internal API. Required for macros.
@inline(__always)
@inlinable
public func _macroExportGet<T>(_ value: T?) -> Variant? where T: _GodotBridgeable {
    return value.toVariant()
}

/// Internal API. Required for macros.
@available(*, unavailable, message: "The type is not supported by @Export macro")
@_disfavoredOverload
public func _macroExportGet(_ value: (any Any)?) -> Variant? {
    fatalError("Unreachable")
}
