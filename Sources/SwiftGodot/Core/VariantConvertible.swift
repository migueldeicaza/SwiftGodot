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
    
    /// Internal API. PropInfo for this type when it's used as an argument.
    static func _argumentPropInfo(
        name: String
    ) -> PropInfo
    
    /// Internal API.  PropInfo for this type when it's used as a returned value.
    static var _returnValuePropInfo: PropInfo { get }
    
    /// Internal API. PropInfo for this type when it's as an exported variable.
    static func _propInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo
}

/// Internal API. Subset protocol for all Builtin Types.
public protocol _GodotBridgeableBuiltin: _GodotBridgeable {
}

public extension _GodotBridgeableBuiltin {
    /// Internal API. Returns Godot type name for typed array.
    @inline(__always)
    @inlinable
    static var _godotTypeName: String {
        _variantType._godotTypeName
    }
    
    /// Internal API. Default implementation.
    @inline(__always)
    @inlinable
    static func _propInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        _propInfoDefault(
            propertyType: _variantType,
            name: name,
            hint: hint,
            hintStr: hintStr,
            usage: usage
        )
    }
    
    /// Internal API. Default implementation.
    @inline(__always)
    @inlinable
    static func _argumentPropInfo(
        name: String
    ) -> PropInfo {
        _propInfoDefault(
            propertyType: _variantType,
            name: name
        )
    }
    
    /// Internal API. Default implementation.
    @inline(__always)
    @inlinable
    static var _returnValuePropInfo: PropInfo {
        _propInfoDefault(
            propertyType: _variantType,
            name: ""
        )
    }
}

/// Internal API. Subset protocol for all Object-derived types.
/// This is a special case due to Swift type system not allowing default implementation using `Self` for non-final classes.
/// It's needed to allow statically dispatching macro functions in the context of `Object` and its subclasses.
public protocol _GodotBridgeableObject: _GodotBridgeable {
}

public extension _GodotBridgeableObject where Self: Object {
    /// Internal API. Default implementation.
    @inline(__always)
    @inlinable
    static var _variantType: Variant.GType { .object }
    
    /// Internal API. Default implementation.
    @inline(__always)
    @inlinable
    static var _godotTypeName: String {
        "\(self)"
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``Object`` or its subclass instance is used in API visible to Godot
    @inline(__always)
    @inlinable
    static func _propInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        return _propInfoDefault(
            propertyType: _variantType,
            name: name,
            className: StringName(_godotTypeName),
            hint: hint,
            hintStr: hintStr,
            usage: usage
        )
    }
    
    /// Internal API.
    @inline(__always)
    @inlinable
    static func _argumentPropInfo(
        name: String
    ) -> PropInfo {
        _propInfoDefault(
            propertyType: _variantType,
            name: name,
            className: StringName(_godotTypeName)
        )
    }
    
    /// Internal API.
    @inline(__always)
    @inlinable
    static var _returnValuePropInfo: PropInfo {
        _propInfoDefault(
            propertyType: _variantType,
            name: "",
            className: StringName(_godotTypeName)
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
func _propInfoDefault(
    propertyType: Variant.GType,
    name: String,
    className: StringName? = nil,
    hint: PropertyHint? = nil,
    hintStr: String? = nil,
    usage: PropertyUsageFlags? = nil
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
    /// Wrap a ``Int64``  into ``Variant?``.
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        Variant(self)
    }
    
    /// Wrap a ``Int64``  into ``Variant``.
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Initialze ``Int64`` from ``Variant``. Fails if `variant` doesn't contain ``Int64``
    public init?(_ variant: Variant) {
        guard Self._variantType == variant.gtype else { return nil }
        self.init()
        
        withUnsafeMutablePointer(to: &self) { pPayload in
            variant.constructType(into: pPayload, constructor: Variant.intFromVariant)
        }
    }
    
    /// Initialze ``Int64`` from ``Variant``. Fails if `variant` doesn't contain ``Int64`` or is `nil`
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
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

    /// Wrap an integer number  into ``Variant?``.
    @_disfavoredOverload
    func toVariant() -> Variant? {
        Int64(self).toVariant()
    }
    
    /// Wrap an integer number  into ``Variant``.
    func toVariant() -> Variant {
        Int64(self).toVariant()
    }
    
    
    /// Initialze ``BinaryInteger`` from ``Variant``. Fails if `variant` doesn't contain ``Int64``, or its value is too large for this ``BinaryInteger``
    init?(_ variant: Variant) {
        guard Self._variantType == variant.gtype else { return nil }
        guard let value = try? Self.fromVariantOrThrow(variant) else {
            return nil
        }
        
        self = value
    }
    
    /// Initialze ``BinaryInteger`` from ``Variant``. Fails if `variant` doesn't contain ``Int64``, its value is too large for this ``BinaryInteger``, or is `nil`
    init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
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
    public static func _propInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        _propInfoDefault(
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
    
    /// Initialze ``Bool`` from ``Variant``. Fails if `variant` doesn't contain ``Bool``
    public init?(_ variant: Variant) {
        guard Self._variantType == variant.gtype else { return nil }
        var payload: GDExtensionBool = 0
        withUnsafeMutablePointer(to: &payload) { pPayload in
            variant.constructType(into: pPayload, constructor: Variant.boolFromVariant)
        }
        
        self = payload != 0
    }
    
    /// Initialze ``Bool`` from ``Variant``. Fails if `variant` doesn't contain ``Bool`` or is `nil`
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
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
    
    /// Wrap a ``String``  into ``Variant?``.
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        Variant(self)
    }
    
    /// Wrap a ``String``  into ``Variant``.
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Initialze ``String`` from ``Variant``. Fails if `variant` doesn't contain ``String``
    public init?(_ variant: Variant) {
        guard let string = GString(variant) else {
            return nil
        }
        
        self = string.description
    }
    
    /// Initialze ``String`` from ``Variant``. Fails if `variant` doesn't contain ``String`` or is `nil`
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
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
    /// Wrap a ``Double``  into ``Variant?``.
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        Variant(self)
    }
    
    /// Wrap a ``Double``  into ``Variant``.
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Initialze ``Double`` from ``Variant``. Fails if `variant` doesn't contain ``Double``
    public init?(_ variant: Variant) {
        guard Self._variantType == variant.gtype else { return nil }
        self.init()
        
        withUnsafeMutablePointer(to: &self) { pPayload in
            variant.constructType(into: pPayload, constructor: Variant.doubleFromVariant)
        }
    }
    
    /// Initialze ``Double`` from ``Variant``. Fails if `variant` doesn't contain ``Double`` or is `nil`
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
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
    
    /// Wrap a floating point number into ``Variant?``.
    @_disfavoredOverload
    func toVariant() -> Variant? {
        Double(self).toVariant()
    }
    
    /// Wrap a floating point number into ``Variant``.
    func toVariant() -> Variant {
        Double(self).toVariant()
    }
    
    /// Initialze ``BinaryFloatingPoint`` from ``Variant``. Fails if `variant` doesn't contain ``Double``
    init?(_ variant: Variant) {
        guard let value = Double(variant) else { return nil }
        self = Self(value)
    }
    
    /// Initialze ``BinaryFloatingPoint`` from ``Variant``. Fails if `variant` doesn't contain ``Double``, or is `nil`
    init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
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
