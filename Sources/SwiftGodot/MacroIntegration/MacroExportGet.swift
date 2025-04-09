//
//  MacroExportGet.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 09/04/2025.
//

/// Internal API. Builtin types.
@inline(__always)
@inlinable
public func _macroExportGet<T>(_ value: T) -> Variant? where T: _GodotBridgeable {
    return value.toVariant()
}

/// Internal API. Optional builtin types.
@inline(__always)
@inlinable
public func _macroExportGet<T>(_ value: T?) -> Variant? where T: _GodotBridgeable {
    return value.toVariant()
}

/// Internal API. Objects.
@inline(__always)
@inlinable
public func _macroExportGet<T>(_ value: T) -> Variant? where T: Object {
    return value.toVariant()
}

/// Internal API. Optional objects.
@inline(__always)
@inlinable
public func _macroExportGet<T>(_ value: T?) -> Variant? where T: Object {
    return value.toVariant()
}

/// Internal API. Catch-all overload for all unsupported types.
@available(*, unavailable, message: "The type is not supported by @Export macro")
@_disfavoredOverload
public func _macroExportGet(_ value: (any Any)?) -> Variant? {
    fatalError("Unreachable")
}
