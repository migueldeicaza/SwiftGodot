//
//  VariantConvertibeNode.swift
//  SwiftGodot
//
//  Created by Miguel de Icaza on 11/13/25.
//

public extension _GodotBridgeable where Self: Node {
    typealias TypedArrayElement = Self?


    /// Internal API. Returns ``PropInfo`` for when any ``Object`` or its subclass instance is used as a property in API visible to Godot
    @inline(__always)
    @inlinable
    static func _propInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        var hint = hint
        var hintStr = hintStr

        if hint == nil && hintStr == nil {
            hint = .nodeType
            hintStr = _builtinOrClassName
        }

        // This is _propInfoDefault
        return PropInfo(
            propertyType: _variantType,
            propertyName: StringName(name),
            className: StringName(_builtinOrClassName ?? ""),
            hint: hint ?? .none,
            hintStr: hintStr.map { GString($0) } ?? GString(),
            usage: usage ?? .default)
    }
}
