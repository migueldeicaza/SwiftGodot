//
//  TypedDictionary.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 24/04/2025.
//

/// This type represents typed Godot dictionary, such as `Dictionary[int, String]` or `Dictionary[String, Object]`.
///
/// In Swift it serves as a type-safe view into underlying ``VariantDictionary`` stored in `dictionary` property.
/// It guarantees that only `Key: Value` pairs are possible.
///
/// Both `Key` and `Value` reflect semantics of how Godot treats nullability.
/// Allowed types are:
/// 1. All builtin types such as ``Vector3``, ``VariantArray``,  etc.
/// 2. Optional `Object`-inherited classes. `Object?`, `Node?`, `Camera3D?`, etc.
///
/// Example:
/// ```
/// ```
///
/// # Compilation troubleshooting
///
/// #### ❌ `Type 'ObjectType' does not conform to protocol '_GodotTypingParameter'`
/// You used `ObjectType` as `Key` or `Value` generic parameter.
/// You should use `ObjectType?`.
/// Godot doesn't guarantee non-nullability of `ObjectType` keys or values.
///
/// #### ❌ `'TypedArray' requires that 'Type' inherit from 'Object'`
/// You used `SomeType?` as `Key` or `Value` generic parameter.
/// You should use `SomeType` instead.
/// Godot guarantees non-nullability of such `SomeType` in the context of being a `Key` or `Value`.
public struct TypedDictionary<Key: _GodotTypingParameter, Value: _GodotTypingParameter> {
    
}
