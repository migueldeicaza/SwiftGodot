//
//  BuiltinConvertible.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 21/04/2025.
//

/// This is a type which you can use if you want to export your custom type as specific builtin Godot type such as
/// `VariantArray`, `TypedArray`, `VariantDictionary`, etc.
/// Unlike ``VariantConvertible`` instances of your types will be visible in Godot not as `Variant`, but specific builtin you chose.
public protocol GodotBuiltinConvertible: _GodotBridgeableBuiltin {
    /// The exact builtin type which is used as a proxy to represent this type in Godot world
    associatedtype GodotBuiltin: _GodotBridgeableBuiltin
    
    /// Convert to `GodotBuiltin`
    func toGodotBuiltin() -> GodotBuiltin
    
    /// Convert `GodotBuiltin` to `Self`. If it's impossible, throw a ``VariantConversionError``. For example:
    /// ```
    /// struct MyTypeConversionError: Error {
    /// }
    ///
    /// throw VariantConversionError.custom(MyTypeConversionError())
    ///
    /// throw VariantConversionError.custom(nil) // or just nil
    /// ```
    ///
    static func fromGodotBuiltinOrThrow(_ value: GodotBuiltin) throws(VariantConversionError) -> Self
}

extension GodotBuiltinConvertible {
    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `GodotBuiltin`.
    public static var _variantType: Variant.GType {
        GodotBuiltin._variantType
    }
    
    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `GodotBuiltin`.
    public static var _builtinOrClassName: String {
        GodotBuiltin._builtinOrClassName
    }

    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `GodotBuiltin`.
    public static func _argumentPropInfo(name: String) -> PropInfo {
        GodotBuiltin._argumentPropInfo(name: name)
    }

    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `GodotBuiltin`.
    public static var _returnValuePropInfo: PropInfo {
        GodotBuiltin._returnValuePropInfo
    }

    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `GodotBuiltin`.
    public static func _propInfo(name: String, hint: PropertyHint?, hintStr: String?, usage: PropertyUsageFlags?) -> PropInfo {
        GodotBuiltin._propInfo(name: name, hint: hint, hintStr: hintStr, usage: usage)
    }

    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `GodotBuiltin`.
    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
        try fromGodotBuiltinOrThrow(
            GodotBuiltin.fromFastVariantOrThrow(variant)
        )
    }

    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `GodotBuiltin`.
    public func toFastVariant() -> FastVariant? {
        toGodotBuiltin().toFastVariant()
    }
    
    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `GodotBuiltin`.
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        try fromGodotBuiltinOrThrow(
            GodotBuiltin.fromVariantOrThrow(variant)
        )
    }
    
    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `GodotBuiltin`.
    public func toVariant() -> Variant? {
        toGodotBuiltin().toVariant()
    }
}

extension Array: GodotBuiltinConvertible, _GodotBridgeableBuiltin, _GodotBridgeable, _GodotContainerTypingParameter, VariantConvertible where Element: _GodotContainerTypingParameter {
    /// Converts `[Element]` into `TypedArray<Element>`
    ///
    /// This is O(n) operation.
    ///
    /// Godot array will be created and copied per-element.
    public func toGodotBuiltin() -> TypedArray<Element> {
        TypedArray(self)
    }
    
    /// Convert `TypedArray<Element>` into Swift `[Element]`
    ///
    /// This is O(n) operation.
    ///
    /// Swift array will be created and copied per-element.
    public static func fromGodotBuiltinOrThrow(_ value: TypedArray<Element>) throws(VariantConversionError) -> Array<Element> {
        // Via Swift.Array.init<S>(_ s: S) where Element == S.Element, S : Sequence
        Array(value)
    }
}


extension Dictionary: GodotBuiltinConvertible, _GodotBridgeableBuiltin, _GodotBridgeable, _GodotContainerTypingParameter, VariantConvertible where Key: _GodotContainerTypingParameter & Hashable, Value: _GodotContainerTypingParameter {
    /// Converts `[Key: Value]` into `TypedDictionary<Key, Value>`
    ///
    /// This is O(n) operation.
    ///
    /// Godot dictionary will be created and copied per-element.
    public func toGodotBuiltin() -> TypedDictionary<Key, Value> {
        TypedDictionary(self)
    }
    
    /// Convert `TypedDictionary<Key, Value>` into Swift `[Key: Value]`
    ///
    /// This is O(n) operation.
    ///
    /// Swift dictionary will be created and copied per-element.
    public static func fromGodotBuiltinOrThrow(_ value: TypedDictionary<Key, Value>) throws(VariantConversionError) -> [Key: Value] {
        // TypedDictionary is Sequence<Key, Value>
        Dictionary(uniqueKeysWithValues: value)
    }
}
