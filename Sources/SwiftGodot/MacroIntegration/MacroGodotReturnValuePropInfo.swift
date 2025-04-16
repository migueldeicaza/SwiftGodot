//
//  MacroGodotReturnValuePropInfo.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 13/04/2025.
//

/// Internal API. Optional Variant.
@inline(__always)
@inlinable
public func _returnValuePropInfo(
    _ type: Variant?.Type = Variant?.self
) -> PropInfo {
    Variant._returnValuePropInfo
}

/// Internal API. Variant.
@inline(__always)
@inlinable
public func _returnValuePropInfo(
    _ type: Variant.Type = Variant.self
) -> PropInfo {
    Variant._returnValuePropInfo
}

/// Internal API. VariantConvertible user type.
@inline(__always)
@inlinable
@_disfavoredOverload
public func _returnValuePropInfo<T>(
    _ type: T.Type = T.self
) -> PropInfo where T: VariantConvertible {
    Variant._returnValuePropInfo
}

/// Internal API. Optional VariantConvertible user type.
@inline(__always)
@inlinable
@_disfavoredOverload
public func _returnValuePropInfo<T>(
    _ type: T?.Type = T?.self
) -> PropInfo where T: VariantConvertible {
    Variant._returnValuePropInfo
}


/// Internal API. Builtin Type.
@inline(__always)
@inlinable
public func _returnValuePropInfo<T>(
    _ type: T.Type = T.self
) -> PropInfo where T: _GodotBridgeableBuiltin {
    T._returnValuePropInfo
}

/// Internal API. Optional Builtin Type.
@inline(__always)
@inlinable
public func _returnValuePropInfo<T>(
    _ type: T?.Type = T?.self
) -> PropInfo where T: _GodotBridgeableBuiltin {
    // Same as Optional Variant, we facade Optional Builtin Types this way
    Variant._returnValuePropInfo
}

/// Internal API. Object.
@inline(__always)
@inlinable
public func _returnValuePropInfo<T>(
    _ type: T.Type = T.self
) -> PropInfo where T: Object {
    T._returnValuePropInfo
}

/// Internal API. Optional object.
@inline(__always)
@inlinable
public func _returnValuePropInfo<T>(
    _ type: T?.Type = T?.self
) -> PropInfo where T: Object {
    T._returnValuePropInfo
}

/// Internal API. Swift Builtin Array.
@inline(__always)
@inlinable
public func _returnValuePropInfo<T>(
    _ type: [T].Type = [T].self
) -> PropInfo where T: _GodotBridgeableBuiltin {
    VariantCollection<T>._returnValuePropInfo
}

/// Internal API. Swift Object Array.
@inline(__always)
@inlinable
public func _returnValuePropInfo<T>(
    _ type: [T].Type = [T].self
) -> PropInfo where T: Object {
    ObjectCollection<T>._returnValuePropInfo
}

/// Internal API. VariantCollection.
@inline(__always)
@inlinable
public func _returnValuePropInfo<T>(
    _ type: VariantCollection<T>.Type = VariantCollection<T>.self
) -> PropInfo where T: _GodotBridgeableBuiltin {
    VariantCollection<T>._returnValuePropInfo
}

/// Internal API. ObjectCollection.
@inline(__always)
@inlinable
public func _returnValuePropInfo<T>(
    _ type: ObjectCollection<T>.Type = ObjectCollection<T>.self
) -> PropInfo where T: Object {
    ObjectCollection<T>._returnValuePropInfo
}

/// Internal API. Void.
@inline(__always)
@inlinable
public func _returnValuePropInfo(
    _ type: Void.Type = Void.self
) -> PropInfo {
    return _propInfoDefault(propertyType: .nil, name: "")
}

@available(*, unavailable, message: "Unsupported type used as argument or returned value")
@_disfavoredOverload
public func _returnValuePropInfo<T>(
    _ type: T.Type = T.self
) -> PropInfo {
    fatalError("Unreachable")
}

