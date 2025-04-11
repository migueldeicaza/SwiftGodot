//
//  MacroGodotGetCallablePropInfo.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 11/04/2025.
//

/// This file contains the overloads for generating PropInfo in the context, where functions callable by Godot
/// are registered
/// `name` is optional in all overloads. If it's nil - the function is called for returned value `PropInfo`, if not - for argument and it contains argument name.


/// Internal API. Optional Variant.
@inline(__always)
@inlinable
public func _macroGodotGetCallablePropInfo(
    _ type: Variant?.Type = Variant?.self,
    name: String = ""
) -> PropInfo {
    let usage: PropertyUsageFlags?
    if name.isEmpty {
        // return value
        usage = .nilIsVariant
    } else {
        usage = nil
    }
    
    return Variant._macroGodotGetPropInfo(name: name, hint: nil, hintStr: nil, usage: usage)
}

/// Internal API. Variant.
@inline(__always)
@inlinable
public func _macroGodotGetCallablePropInfo(
    _ type: Variant.Type = Variant.self,
    name: String = ""
) -> PropInfo {
    // Same as Optional Variant.
    _macroGodotGetCallablePropInfo(Variant?.self, name: name)
}

/// Internal API. Builtin Type.
@inline(__always)
@inlinable
public func _macroGodotGetCallablePropInfo<T>(
    _ type: T.Type = T.self,
    name: String = ""
) -> PropInfo where T: _GodotBridgeableBuiltin {
    T._macroGodotGetPropInfo(name: name, hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. Optional Builtin Type.
@inline(__always)
@inlinable
public func _macroGodotGetCallablePropInfo<T>(
    _ type: T?.Type = T?.self,
    name: String = ""
) -> PropInfo where T: _GodotBridgeableBuiltin {
    // Same as Optional Variant, we facade Optional Builtin Types this way
    _macroGodotGetCallablePropInfo(Variant?.self, name: name)
}

/// Internal API. Object.
@inline(__always)
@inlinable
public func _macroGodotGetCallablePropInfo<T>(
    _ type: T.Type = T.self,
    name: String = ""
) -> PropInfo where T: Object {
    T._macroGodotGetPropInfo(name: name, hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. Optional object.
@inline(__always)
@inlinable
public func _macroGodotGetCallablePropInfo<T>(
    _ type: T?.Type = T?.self,
    name: String = ""
) -> PropInfo where T: Object {
    T._macroGodotGetPropInfo(name: name, hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. Swift Builtin Array.
@inline(__always)
@inlinable
public func _macroGodotGetCallablePropInfo<T>(
    _ type: [T].Type = [T].self,
    name: String = ""
) -> PropInfo where T: _GodotBridgeableBuiltin, T: VariantStorable {
    VariantCollection<T>._macroGodotGetPropInfo(name: name, hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. Swift Object Array.
@inline(__always)
@inlinable
public func _macroGodotGetCallablePropInfo<T>(
    _ type: [T].Type = [T].self,
    name: String = ""
) -> PropInfo where T: Object {
    ObjectCollection<T>._macroGodotGetPropInfo(name: name, hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. VariantCollection.
@inline(__always)
@inlinable
public func _macroGodotGetCallablePropInfo<T>(
    _ type: VariantCollection<T>.Type = VariantCollection<T>.self,
    name: String = ""
) -> PropInfo where T: _GodotBridgeableBuiltin, T: VariantStorable {
    VariantCollection<T>._macroGodotGetPropInfo(name: name, hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. ObjectCollection.
@inline(__always)
@inlinable
public func _macroGodotGetCallablePropInfo<T>(
    _ type: ObjectCollection<T>.Type = ObjectCollection<T>.self,
    name: String = ""
) -> PropInfo where T: Object {
    ObjectCollection<T>._macroGodotGetPropInfo(name: name, hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. Void.
@inline(__always)
@inlinable
public func _macroGodotGetCallablePropInfo(
    _ type: Void.Type = Void.self,
    // no name: String arg for source compatibility with macro
) -> PropInfo? {
    return nil
}

@available(*, unavailable, message: "Void type arguments are not supported")
public func _macroGodotGetCallablePropInfo(
    _ type: Void.Type = Void.self,
    name: String // no default arg
) -> PropInfo {
    fatalError("Unreachable")
}

@available(*, unavailable, message: "Unsupported type used as argument or returned value")
@_disfavoredOverload
public func _macroGodotGetCallablePropInfo<T>(
    _ type: T.Type = T.self,
    name: String = ""
) -> PropInfo {
    fatalError("Unreachable")
}

