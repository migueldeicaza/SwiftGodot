//
//  MacroGodotReturnedPropInfo.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 13/04/2025.
//

/// Internal API. Optional Variant.
@inline(__always)
@inlinable
public func _returnedPropInfo(
    _ type: Variant?.Type = Variant?.self
) -> PropInfo {
    return Variant._propInfo(name: "", hint: nil, hintStr: nil, usage: .nilIsVariant)
}

/// Internal API. Variant.
@inline(__always)
@inlinable
public func _returnedPropInfo(
    _ type: Variant.Type = Variant.self
) -> PropInfo {
    // Same as Optional Variant.
    _returnedPropInfo(Variant?.self)
}

/// Internal API. Builtin Type.
@inline(__always)
@inlinable
public func _returnedPropInfo<T>(
    _ type: T.Type = T.self
) -> PropInfo where T: _GodotBridgeableBuiltin {
    T._propInfo(name: "", hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. Optional Builtin Type.
@inline(__always)
@inlinable
public func _returnedPropInfo<T>(
    _ type: T?.Type = T?.self
) -> PropInfo where T: _GodotBridgeableBuiltin {
    // Same as Optional Variant, we facade Optional Builtin Types this way
    _returnedPropInfo(Variant?.self)
}

/// Internal API. Object.
@inline(__always)
@inlinable
public func _returnedPropInfo<T>(
    _ type: T.Type = T.self
) -> PropInfo where T: Object {
    T._propInfo(name: "", hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. Optional object.
@inline(__always)
@inlinable
public func _returnedPropInfo<T>(
    _ type: T?.Type = T?.self
) -> PropInfo where T: Object {
    T._propInfo(name: "", hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. Swift Builtin Array.
@inline(__always)
@inlinable
public func _returnedPropInfo<T>(
    _ type: [T].Type = [T].self
) -> PropInfo where T: _GodotBridgeableBuiltin {
    VariantCollection<T>._propInfo(name: "", hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. Swift Object Array.
@inline(__always)
@inlinable
public func _returnedPropInfo<T>(
    _ type: [T].Type = [T].self
) -> PropInfo where T: Object {
    ObjectCollection<T>._propInfo(name: "", hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. VariantCollection.
@inline(__always)
@inlinable
public func _returnedPropInfo<T>(
    _ type: VariantCollection<T>.Type = VariantCollection<T>.self
) -> PropInfo where T: _GodotBridgeableBuiltin {
    VariantCollection<T>._propInfo(name: "", hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. ObjectCollection.
@inline(__always)
@inlinable
public func _returnedPropInfo<T>(
    _ type: ObjectCollection<T>.Type = ObjectCollection<T>.self
) -> PropInfo where T: Object {
    ObjectCollection<T>._propInfo(name: "", hint: nil, hintStr: nil, usage: nil)
}

/// Internal API. Void.
@inline(__always)
@inlinable
public func _returnedPropInfo(
    _ type: Void.Type = Void.self
) -> PropInfo {
    return _propInfoDefault(propertyType: .nil, name: "")
}

@available(*, unavailable, message: "Unsupported type used as argument or returned value")
@_disfavoredOverload
public func _returnedPropInfo<T>(
    _ type: T.Type = T.self
) -> PropInfo {
    fatalError("Unreachable")
}

