//
//  MacroGodotArgumentPropInfo.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 11/04/2025.
//

/// Internal API. Optional Variant.
@inline(__always)
@inlinable
public func _argumentPropInfo(
    _ type: Variant?.Type = Variant?.self,
    name: String = ""
) -> PropInfo {
    return Variant._argumentPropInfo(name: name)
}

/// Internal API. Variant.
@inline(__always)
@inlinable
public func _argumentPropInfo(
    _ type: Variant.Type = Variant.self,
    name: String = ""
) -> PropInfo {
    // Same as Optional Variant.
    return Variant._argumentPropInfo(name: name)
}

/// Internal API. Optional VariantConvertible user type.
@inline(__always)
@inlinable
public func _argumentPropInfo<T>(
    _ type: T?.Type = T?.self,
    name: String = ""
) -> PropInfo {
    return Variant._argumentPropInfo(name: name)
}

// Enumeration values
@inline(__always)
@inlinable
public func _argumentPropInfo<T>(
    _ type: T.Type,
    name: String = ""
) -> PropInfo where T: RawRepresentable, T.RawValue == Int {
    PropInfo(
        propertyType: .int,
        propertyName: StringName(name),
        className: "",
        hint: .none,
        hintStr: GString(""),
        usage: .default
    )
}

// Enumeration values, when we can case-iterate
@inline(__always)
@inlinable
public func _argumentPropInfo<T>(
    _ type: T.Type,
    name: String = ""
) -> PropInfo where T: CaseIterable & RawRepresentable, T.RawValue == Int {
    var hintStr = ""
    for c in T.allCases {
        if hintStr != "" {
            hintStr += ","
        }
        hintStr += "\(c):\(c.rawValue)"
    }
    return PropInfo(
        propertyType: .int,
        propertyName: StringName(name),
        className: StringName(String(describing: T.self)),
        hint: .enum,
        hintStr: GString(hintStr),
        usage: .default
    )
}

// Enumeration values
@inline(__always)
@inlinable
public func _argumentPropInfo<T>(
    _ type: T.Type,
    name: String = ""
) -> PropInfo where T: RawRepresentable, T.RawValue == Int64 {
    PropInfo(
        propertyType: .int,
        propertyName: StringName(name),
        className: "",
        hint: .none,
        hintStr: GString(""),
        usage: .default
    )
}

// Enumeration values, when we can case-iterate
@inline(__always)
@inlinable
public func _argumentPropInfo<T>(
    _ type: T.Type,
    name: String = ""
) -> PropInfo where T: CaseIterable & RawRepresentable, T.RawValue == Int64 {
    var hintStr = ""
    for c in T.allCases {
        if hintStr != "" {
            hintStr += ","
        }
        hintStr += "\(c):\(c.rawValue)"
    }
    return PropInfo(
        propertyType: .int,
        propertyName: StringName(name),
        className: StringName(String(describing: T.self)),
        hint: .enum,
        hintStr: GString(hintStr),
        usage: .default
    )
}

/// Internal API. VariantConvertible user type.
@inline(__always)
@inlinable
public func _argumentPropInfo<T>(
    _ type: T.Type = T.self,
    name: String = ""
) -> PropInfo where T: VariantConvertible {
    return Variant._argumentPropInfo(name: name)
}

/// Internal API. Builtin Type.
@inline(__always)
@inlinable
public func _argumentPropInfo<T>(
    _ type: T.Type = T.self,
    name: String = ""
) -> PropInfo where T: _GodotBridgeableBuiltin {
    T._argumentPropInfo(name: name)
}

/// Internal API. Optional Builtin Type.
@inline(__always)
@inlinable
public func _argumentPropInfo<T>(
    _ type: T?.Type = T?.self,
    name: String = ""
) -> PropInfo where T: _GodotBridgeableBuiltin {
    // Same as Optional Variant, for example `Int?` is visible as `Variant` on Godot side
    _argumentPropInfo(Variant?.self, name: name)
}

/// Internal API. Object.
@inline(__always)
@inlinable
public func _argumentPropInfo<T>(
    _ type: T.Type = T.self,
    name: String = ""
) -> PropInfo where T: Object {
    T._argumentPropInfo(name: name)
}

/// Internal API. Optional object.
@inline(__always)
@inlinable
public func _argumentPropInfo<T>(
    _ type: T?.Type = T?.self,
    name: String = ""
) -> PropInfo where T: Object {
    T._argumentPropInfo(name: name)
}

@available(*, unavailable, message: "Void type arguments are not supported")
public func _argumentPropInfo(
    _ type: Void.Type = Void.self,
    name: String = ""
) -> PropInfo {
    fatalError("Unreachable")
}

@available(*, unavailable, message: "Unsupported type used as argument or returned value")
@_disfavoredOverload
public func _argumentPropInfo<T>(
    _ type: T.Type = T.self,
    name: String = ""
) -> PropInfo {
    fatalError("Unreachable")
}

