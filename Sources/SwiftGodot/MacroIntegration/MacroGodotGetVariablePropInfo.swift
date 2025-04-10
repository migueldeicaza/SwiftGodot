//
//  MacroGodotGet.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 10/04/2025.
//

/// Internal API. Builtin type.
@inline(__always)
@inlinable
public func _macroGodotGetVariablePropInfo<Root, T>(
    at keyPath: KeyPath<Root, T>,
    name: String,
    userHint: PropertyHint?,
    userHintStr: String?,
    userUsage: PropertyUsageFlags?
) -> PropInfo where T: _GodotBridgeable {
    T._macroGodotGetVariablePropInfo(
        rootType: Root.self,
        name: name,
        userHint: userHint,
        userHintStr: userHintStr,
        userUsage: userUsage
    )
}

/// Internal API. Optional Builtin type.
@inline(__always)
@inlinable
public func _macroGodotGetVariablePropInfo<Root, T>(
    at keyPath: KeyPath<Root, T?>,
    name: String,
    userHint: PropertyHint?,
    userHintStr: String?,
    userUsage: PropertyUsageFlags?
) -> PropInfo where T: _GodotBridgeable {
    T._macroGodotGetVariablePropInfo(
        rootType: Root.self,
        name: name,
        userHint: userHint,
        userHintStr: userHintStr,
        userUsage: userUsage
    )
}

/// Internal API. Object.
@inline(__always)
@inlinable
public func _macroGodotGetVariablePropInfo<Root, T>(
    at keyPath: KeyPath<Root, T>,
    name: String,
    userHint: PropertyHint?,
    userHintStr: String?,
    userUsage: PropertyUsageFlags?
) -> PropInfo where T: Object {
    T._macroGodotGetVariablePropInfo(
        rootType: Root.self,
        name: name,
        userHint: userHint,
        userHintStr: userHintStr,
        userUsage: userUsage
    )
}

@available(*, unavailable, message: "Type is not supported for @Export")
@_disfavoredOverload
public func _macroGodotGetVariablePropInfo<Root, T>(
    at keyPath: KeyPath<Root, T>,
    name: String,
    userHint: PropertyHint?,
    userHintStr: String?,
    userUsage: PropertyUsageFlags?
) -> PropInfo {
    fatalError("Unreachable")
}
