//
//  Exportable.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 08/04/2025.
//

@_implementationOnly import GDExtension

/// Error while trying to unwrap Variant
public enum VariantConversionError: Error, CustomStringConvertible {
    public var description: String {
        switch self {
        case .unexpectedContent(let requestedType, let actualContent):
            return "Can't unwrap \(requestedType) from \(actualContent)"
        case .integerOverflow(let requestedType, let value):
            return "\(value) doesn't fit in \(requestedType)"
        case .invalidRawValue(let requestedType, let value):
            return "\(value) is not a valid rawValue for \(requestedType)"
        }
    }
    
    case unexpectedContent(requestedType: Any.Type, actualContent: String)
    case integerOverflow(requestedType: Any.Type, value: Int64)
    case invalidRawValue(requestedType: any RawRepresentable.Type, value: Any)
    
    public static func unexpectedContent<T>(parsing type: T.Type = T.self, from: Variant?) -> Self {
        unexpectedContent(
            requestedType: type,
            actualContent: from?.description ?? "nil"
        )
    }
}

/// Protocol for types that can be converted to and from ``Variant?`` aka `Godot Variant`.
public protocol VariantConvertible {
    /// Extract ``Self`` from a ``Variant``. Throws `VariantConversionError` if it's not possible.    
    static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self
    
    /// Extract ``Self`` from nil Variant. Throws `VariantConversionError` if it's not possible.
    static func fromNilVariantOrThrow() throws(VariantConversionError) -> Self
    
    /// Converts the instance to a ``Variant?``.
    func toVariant() -> Variant?
}

public extension VariantConvertible {
    /// Default implementation for most of the cases where a type cannot be constructed from a nil Variant.
    static func fromNilVariantOrThrow() throws(VariantConversionError) -> Self {
        throw .unexpectedContent(parsing: self, from: nil)
    }
    
    /// Default implementation for most of the cases where a type cannot be constructed from a nil Variant.
    @_disfavoredOverload // always prefer calling non-nil
    static func fromVariantOrThrow(_ variant: Variant?) throws(VariantConversionError) -> Self {
        if let variant {
            return try fromVariantOrThrow(variant)
        } else {
            return try fromNilVariantOrThrow()
        }
    }
    
    /// Unwrap ``Self`` from a ``Variant``. Returns `nil` if it's not possible.
    static func fromVariant(_ variant: Variant) -> Self? {
        do {
            return try fromVariantOrThrow(variant)
        } catch {
            return nil
        }
    }
    
    /// Unwrap ``Self`` from a ``Variant?``. Returns `nil` if it's not possible.
    static func fromVariant(_ variant: Variant?) -> Self? {
        do {
            return try fromVariantOrThrow(variant)
        } catch {
            return nil
        }
    }
}

/// Internal API. Protocol for types that contains details on how it interacts with C GDExtension API.
///
/// Do not conform your types to this protocol.
///
/// Unlike ``VariantConvertible`` that contains information about how to convert specific type from ``Variant`` and back,
/// and is the only required subset of functionality required to interact with Godot API, this protocol and ones that expand it contain information
/// required for low-level interaction with Godot API.
/// You could assume that to be the set of all Builtin Types, Object-derived Types and Swift Variant.
public protocol _GodotBridgeable: VariantConvertible {
    /// Internal API. Variant type tag for this type.
    static var _variantType: Variant.GType { get }
    
    /// Internal API. Name of this type in Godot.  `Int64` -> `int`, `GArray` -> `Array`, `Object` -> `Object`
    static var _godotTypeName: String { get }
}

/// Internal API. Subset protocol for all Builtin Types.
public protocol _GodotBridgeableBuiltin: _GodotBridgeable {
    /// Internal API.
    static func _macroGodotGetPropInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo
}

public extension _GodotBridgeableBuiltin {
    /// Internal API. Returns Godot type name for typed array.
    static var _godotTypeName: String {
        _variantType._godotTypeName
    }
}

/// Internal API. Subset protocol for all Object-derived types.
/// This is a special case due to Swift type system not allowing default implementation using `Self` for non-final classes.
/// It's needed to allow statically dispatching macro functions in the context of `Object` and its subclasses.
public protocol _GodotBridgeableObject: _GodotBridgeable {
}

public extension _GodotBridgeableObject where Self: Object {
    /// Internal API. Returns Godot type name for typed array.
    static var _godotTypeName: String {
        "\(self)"
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``Object`` or its subclass instance is used in API visible to Godot
    @inline(__always)
    @inlinable
    static func _macroGodotGetPropInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        return _macroGodotGetPropInfoDefault(
            propertyType: .object,
            name: name,
            className: StringName("\(Self.self)"),
            hint: hint,
            hintStr: hintStr,
            usage: usage
        )
    }
}

public extension Optional where Wrapped: VariantConvertible {
    func toVariant() -> Variant? {
        if let self {
            return self.toVariant()
        } else {
            return nil
        }
    }
}

// Default case covering most of the cases, only propertyType is needed
@inline(__always)
@inlinable
func _macroGodotGetPropInfoDefault(
    propertyType: Variant.GType,
    name: String,
    className: StringName? = nil,
    hint: PropertyHint?,
    hintStr: String?,
    usage: PropertyUsageFlags?
) -> PropInfo {
    return PropInfo(
        propertyType: propertyType,
        propertyName: StringName(name),
        className: className ?? "",
        hint: hint ?? .none,
        hintStr: hintStr.map { GString($0) } ?? GString(),
        usage: usage ?? .default
    )
}

extension Int64: _GodotBridgeableBuiltin {
    // _macroGodotGetPropInfo is implemented below for all `BinaryInteger`
    // _gtype is implemented below for all `BinaryInteger`
    
    /// Wrap a ``Int64``  into ``Variant?``.
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        Variant(self)
    }
    
    /// Wrap a ``Int64``  into ``Variant``.
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Attempt to unwrap a ``Int64`` from a `variant`. Throws `VariantConversionError` if it's not possible.
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        guard let value = Int64(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        
        return value
    }
}

public extension BinaryInteger {
    static var _variantType: Variant.GType {
        .int
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``BinaryInteger`` is used in API visible to Godot
    @inline(__always)
    @inlinable
    static func _macroGodotGetPropInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        _macroGodotGetPropInfoDefault(
            propertyType: .int,
            name: name,
            hint: hint,
            hintStr: hintStr,
            usage: usage
        )
    }

    /// Wrap an integer number  into ``Variant?``.
    @_disfavoredOverload
    func toVariant() -> Variant? {
        Int64(self).toVariant()
    }
    
    /// Wrap an integer number  into ``Variant``.
    func toVariant() -> Variant {
        Int64(self).toVariant()
    }
    
    /// Attempt to unwrap an integer number from a `variant`. Throws `VariantConversionError` if it's not possible.
    static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        let value = try Int64.fromVariantOrThrow(variant)
        
        // Fail gracefully if overflow happens
        if let result = Self(exactly: value) {
            return result
        } else {
            throw VariantConversionError.integerOverflow(requestedType: self, value: value)
        }
    }
}

extension Bool: _GodotBridgeableBuiltin {
    /// Internal API.
    public static var _variantType: Variant.GType {
        .bool
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``Bool`` is used in API visible to Godot
    @inline(__always)
    @inlinable
    public static func _macroGodotGetPropInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        _macroGodotGetPropInfoDefault(
            propertyType: _variantType,
            name: name,
            hint: hint,
            hintStr: hintStr,
            usage: usage
        )
    }
    
    /// Wrap a ``Bool``  into ``Variant?``.
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        Variant(self)
    }
    
    /// Wrap a ``Bool``  into ``Variant``.
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Attempt to unwrap a ``Bool`` from a `variant`. Throws `VariantConversionError` if it's not possible.
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        guard let value = Bool(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        return value
    }
}

extension String: _GodotBridgeableBuiltin {
    /// Internal API.
    public static var _variantType: Variant.GType {
        .string
    }
    /// Internal API. Returns ``PropInfo`` for when any ``String`` is used in API visible to Godot
    @inline(__always)
    @inlinable
    public static func _macroGodotGetPropInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        _macroGodotGetPropInfoDefault(
            propertyType: .string,
            name: name,
            hint: hint,
            hintStr: hintStr,
            usage: usage
        )
    }
    
    /// Wrap a ``String``  into ``Variant?``.
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        Variant(self)
    }
    
    /// Wrap a ``String``  into ``Variant``.
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Attempt to unwrap a ``String`` from a `variant`. Throws `VariantConversionError` if it's not possible.
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        guard let value = String(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        
        return value
    }
}

extension Double: _GodotBridgeableBuiltin {
    // _macroGodotGetPropInfo is implemented below for all `BinaryFloatingPoint`
    // _gtype is implemented below for all `BinaryFloatingPoint`
    
    /// Wrap a ``Double``  into ``Variant?``.
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        Variant(self)
    }
    
    /// Wrap a ``Double``  into ``Variant``.
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Attempt to unwrap a ``Double`` from a `variant`. Throws `VariantConversionError` if it's not possible.
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        guard let value = Double(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        return value
    }
}

public extension BinaryFloatingPoint {
    /// Internal API.
    static var _variantType: Variant.GType {
        .float
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``BinaryFloatingPoint`` is used in API visible to Godot
    @inline(__always)
    @inlinable
    static func _macroGodotGetPropInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        _macroGodotGetPropInfoDefault(
            propertyType: .float,
            name: name,
            hint: hint,
            hintStr: hintStr,
            usage: usage
        )
    }
    
    /// Wrap a floating point number into ``Variant?``.
    @_disfavoredOverload
    func toVariant() -> Variant? {
        Double(self).toVariant()
    }
    
    /// Wrap a floating point number into ``Variant``.
    func toVariant() -> Variant {
        Double(self).toVariant()
    }

    /// Attempt to unwrap a floating point number from a `variant`. Throws `VariantConversionError` if it's not possible.
    static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        Self(try Double.fromVariantOrThrow(variant))
    }
}

extension Int: _GodotBridgeableBuiltin {}
extension Int32: _GodotBridgeableBuiltin {}
extension Int16: _GodotBridgeableBuiltin {}
extension Int8: _GodotBridgeableBuiltin {}

extension UInt: _GodotBridgeableBuiltin {}
extension UInt64: _GodotBridgeableBuiltin {}
extension UInt32: _GodotBridgeableBuiltin {}
extension UInt16: _GodotBridgeableBuiltin {}
extension UInt8: _GodotBridgeableBuiltin {}
    
extension Float: _GodotBridgeableBuiltin {}

public extension RawRepresentable where RawValue: VariantConvertible {
    @_disfavoredOverload
    func toVariant() -> Variant? {
        rawValue.toVariant()
    }
    
    static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        let rawValue = try RawValue.fromVariantOrThrow(variant)
        guard let value = Self(rawValue: rawValue) else {
            throw .invalidRawValue(requestedType: self, value: rawValue)
        }
        return value
    }
}

public extension RawRepresentable where RawValue == String {
    func toVariant() -> Variant {
        rawValue.toVariant()
    }
}

public extension RawRepresentable where RawValue: BinaryInteger {
    func toVariant() -> Variant {
        rawValue.toVariant()
    }
}

public extension RawRepresentable where RawValue: BinaryFloatingPoint {
    func toVariant() -> Variant {
        rawValue.toVariant()
    }
}

public extension Object {
    static var _variantType: Variant.GType { .object }
}
