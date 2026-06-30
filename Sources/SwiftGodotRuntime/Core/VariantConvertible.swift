//
//  VariantConvertible.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 08/04/2025.
//

import GDExtension

/// Error while trying to unwrap Variant
public enum VariantConversionError: Error, CustomStringConvertible, @unchecked Sendable {
    public var description: String {
        switch self {
        case .unexpectedContent(let requestedType, let actualContent):
            return "Can't unwrap \(requestedType) from \(actualContent)"
        case .integerOverflow(let requestedType, let value):
            return "\(value) doesn't fit in \(requestedType)"
        case .invalidRawValue(let requestedType, let value):
            return "\(value) is not a valid rawValue for \(requestedType)"
        case .custom(let error):
            if let error {
                return "Custom type conversion error: \(error)"
            } else {
                return "Custom type conversion error."
            }
        }
    }

    case unexpectedContent(requestedType: Any.Type, actualContent: String)
    case integerOverflow(requestedType: Any.Type, value: Int64)
    case invalidRawValue(requestedType: any RawRepresentable.Type, value: Any)

    /// Intended for ``GodotBuiltinConvertible`` and ``VariantConvertible`` implementations of user.
    case custom(error: (any Error)?)

    @_disfavoredOverload
    public static func unexpectedContent<T>(parsing type: T.Type = T.self, from: Variant?) -> Self {
        unexpectedContent(
            requestedType: type,
            actualContent: from?.description ?? "nil"
        )
    }

    public static func unexpectedContent<T>(parsing type: T.Type = T.self, from: Variant) -> Self {
        unexpectedContent(
            requestedType: type,
            actualContent: from.description
        )
    }

    public static func unexpectedNilContent<T>(parsing type: T.Type = T.self) -> Self {
        unexpectedContent(
            requestedType: type,
            actualContent: "nil"
        )
    }
}

/// Protocol for types that can be converted to and from ``Variant?`` aka `Godot Variant`.
/// Default implementations are provided for most of the functions.
/// Example of implementation:
/// ```
/// extension Date: VariantConvertible {
///     public func toVariant() -> Variant? {
///         timeIntervalSince1970.toVariant()
///     }
///
///     public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Date {
///         Date(timeIntervalSince1970: try TimeInterval.fromVariantOrThrow(variant))
///     }
/// }
/// ```
///
/// All Godot API types and all the primitive Swift types (such as ``Bool``, ``String``, ``Int``, ``UInt`` of any length, ``Float``, ``Double``) implement it.
/// ``Variant`` implements it too.
///
/// There are multiple ways to wrap and unwrap such types, which are functionally identical, just use one that suits you more:
/// ```
/// let variant: Variant?
///
/// // To Int:
/// variant.to(Int.self)
/// Int.fromVariant(variant)
///
/// // From Int:
/// Variant(42)
/// 42.toVariant()
///
/// // To Object:
/// variant.to(Object.self)
/// Object.fromVariant(variant)
///
/// // From Object:
/// Variant(Object())
/// ```
public protocol VariantConvertible {
    /// Extract ``Self`` from a ``Variant``. Throws `VariantConversionError` if it's not possible.
    static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self

    /// Extract ``Self`` from nil Variant. Throws `VariantConversionError` if it's not possible. Has default implementation.
    static func fromNilOrThrow() throws(VariantConversionError) -> Self

    /// Converts the instance to a ``Variant?``.
    func toVariant() -> Variant?
}

public extension VariantConvertible {
    /// Default implementation for most of the cases where a type cannot be constructed from a nil Variant.
    @inline(__always)
    @inlinable
    static func fromNilOrThrow() throws(VariantConversionError) -> Self {
        throw .unexpectedNilContent(parsing: self)
    }

    /// Default implementation.
    @inline(__always)
    @inlinable
    @_disfavoredOverload // always prefer calling non-nil
    static func fromVariantOrThrow(_ variant: Variant?) throws(VariantConversionError) -> Self {
        if let variant {
            return try fromVariantOrThrow(variant)
        } else {
            return try fromNilOrThrow()
        }
    }

    /// Unwrap ``Self`` from a ``Variant``. Returns `nil` if it's not possible.
    @inline(__always)
    @inlinable
    static func fromVariant(_ variant: Variant) -> Self? {
        try? fromVariantOrThrow(variant)
    }

    /// Unwrap ``Self`` from a ``Variant?``. Returns `nil` if it's not possible.
    @inline(__always)
    @inlinable
    static func fromVariant(_ variant: Variant?) -> Self? {
        try? fromVariantOrThrow(variant)
    }
}

/// Internal API. Protocol for types that contains details on how it interacts with C GDExtension API.
///
/// Do not conform your types to this protocol.
public protocol _GodotBridgeable: VariantConvertible {
    /// Internal API. Variant type tag for this type.
    static var _variantType: Variant.GType { get }

    /// Internal API. Name of this type in Godot.  `Int64` -> `int`, `VariantArray` -> `Array`, `Object` -> `Object`
    static var _builtinOrClassName: String { get }

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
/// All builtin types can be used as typing parameter for `TypedArray` and `TypedDictionary` key and/or value.
public protocol _GodotBridgeableBuiltin: _GodotContainerTypingParameter where _NonOptionalType == Self {
    /// Internal API. Reads this type from a raw argument pointer passed by Godot.
    static func _fromRawArgument(_ ptr: UnsafeRawPointer) throws(ArgumentAccessError) -> Self
}

public extension _GodotBridgeableBuiltin {
    /// Internal API. Required for cases where Godot expects an empty `StringName` for builtin types and actual class name for `.object`-types.
    static var _className: StringName {
        StringName("")
    }

    /// Internal API. Returns Godot type name for typed array.
    @inline(__always)
    @inlinable
    static var _builtinOrClassName: String {
        _variantType._builtinOrClassName
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

public extension _GodotBridgeable where Self: Object {
    typealias TypedArrayElement = Self?

    /// Internal API. Default implementation.
    @inline(__always)
    @inlinable
    static var _variantType: Variant.GType { .object }

    /// Internal API. Default implementation.
    @inline(__always)
    @inlinable
    static var _builtinOrClassName: String {
        "\(self)"
    }

    /// Internal API. Returns ``PropInfo`` for when any ``Object`` or its subclass instance is used as a property in API visible to Godot
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
            className: StringName(_builtinOrClassName),
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
            className: StringName(_builtinOrClassName)
        )
    }

    /// Internal API.
    @inline(__always)
    @inlinable
    static var _returnValuePropInfo: PropInfo {
        _propInfoDefault(
            propertyType: _variantType,
            name: "",
            className: StringName(_builtinOrClassName)
        )
    }
}

public extension Optional where Wrapped: VariantConvertible {
    @inline(__always)
    @inlinable
    func toVariant() -> Variant? {
        flatMap { $0.toVariant() }
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

// MARK: - Variant identity conformance

extension Variant: _GodotBridgeable, _GodotNullableBridgeable {
    /// Identity function. Needed for static dispatch for certain features.
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Variant {
        variant
    }

    /// Identity function. Needed for static dispatch for certain features.
    public func toVariant() -> Variant? {
        self
    }

    /// Identity function. Needed for static dispatch for certain features.
    @_disfavoredOverload
    public func toVariant() -> Variant {
        self
    }

    /// Internal API.
    public static var _variantType: GType { .nil }

    /// Internal API.
    public static var _builtinOrClassName: String { "Variant" }

    /// Internal API. Returns ``PropInfo`` for when any ``Variant`` or ``Variant?`` is used in API visible to Godot
    @inline(__always)
    @inlinable
    public static func _propInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        _propInfoDefault(
            propertyType: .nil, // Godot treats .nil as Godot Variant
            name: name,
            hint: hint,
            hintStr: hintStr,
            usage: usage ?? [.nilIsVariant, .default]
        )
    }

    /// Internal API.
    public static func _argumentPropInfo(name: String) -> PropInfo {
        _propInfoDefault(propertyType: _variantType, name: name)
    }

    /// Internal API.
    public static var _returnValuePropInfo: PropInfo {
        _propInfoDefault(propertyType: _variantType, name: "", usage: .nilIsVariant)
    }
}

public extension Variant {
    /// Extract `T` from this ``Variant`` or return nil if unsuccessful.
    @inline(__always)
    func to<T>(_ type: T.Type = T.self) -> T? where T: VariantConvertible {
        type.fromVariant(self)
    }

    /// Extract `T: Object` from this ``Variant`` or return nil if unsuccessful.
    @inline(__always)
    func to<T>(_ type: T.Type = T.self) -> T? where T: Object {
        type.fromVariant(self)
    }
}

public extension Optional where Wrapped == Variant {
    /// Extract `T` from this ``Variant?`` or return nil if unsuccessful.
    @inline(__always)
    @inlinable
    func to<T>(_ type: T.Type = T.self) -> T? where T: VariantConvertible {
        type.fromVariant(self)
    }

    /// Extract `T: Object` from this ``Variant?`` or return nil if unsuccessful.
    @inline(__always)
    @inlinable
    func to<T>(_ type: T.Type = T.self) -> T? where T: Object {
        type.fromVariant(self)
    }
}

// MARK: - Scalar conformances

extension Int64: _GodotBridgeableBuiltin {
    @inline(__always)
    public static func _fromRawArgument(_ ptr: UnsafeRawPointer) throws(ArgumentAccessError) -> Self {
        Int64(ptr.assumingMemoryBound(to: Int.self).pointee)
    }

    /// Wrap a ``Int64``  into ``Variant``.
    @inline(__always)
    @inlinable
    public func toVariant() -> Variant {
        .int(Int(self))
    }

    /// Wrap a ``Int64``  into ``Variant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        .int(Int(self))
    }

    /// Initialize ``Int64`` from ``Variant``. Fails if `variant` doesn't contain an integer.
    @inline(__always)
    public init?(_ variant: Variant) {
        guard case .int(let value) = variant else { return nil }
        self = Int64(value)
    }

    /// Initialize ``Int64`` from ``Variant?``. Fails if `variant` doesn't contain an integer or is `nil`.
    @inline(__always)
    @inlinable
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }

    @inline(__always)
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        guard case .int(let value) = variant else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        return Int64(value)
    }
}

public extension BinaryInteger where Self: _GodotBridgeableBuiltin {
    @inline(__always)
    @inlinable
    static func _fromRawArgument(_ ptr: UnsafeRawPointer) throws(ArgumentAccessError) -> Self {
        Self(ptr.assumingMemoryBound(to: Int.self).pointee)
    }

    @inline(__always)
    @inlinable
    static var _variantType: Variant.GType {
        .int
    }

    /// Wrap an integer number into ``Variant``.
    @inline(__always)
    @inlinable
    func toVariant() -> Variant {
        Int64(self).toVariant()
    }

    /// Wrap an integer number into ``Variant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    func toVariant() -> Variant? {
        Int64(self).toVariant()
    }

    /// Initialize from ``Variant``. Fails if `variant` doesn't contain an integer, or its value is too large.
    @inline(__always)
    @inlinable
    init?(_ variant: Variant) {
        guard let value = try? Self.fromVariantOrThrow(variant) else {
            return nil
        }
        self = value
    }

    /// Initialize from ``Variant?``. Fails if `variant` doesn't contain an integer, is too large, or is `nil`.
    @inline(__always)
    @inlinable
    init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }

    @inline(__always)
    @inlinable
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
    @inline(__always)
    public static func _fromRawArgument(_ ptr: UnsafeRawPointer) throws(ArgumentAccessError) -> Self {
        ptr.assumingMemoryBound(to: Int.self).pointee != 0
    }

    /// Internal API.
    @inline(__always)
    @inlinable
    public static var _variantType: Variant.GType {
        .bool
    }

    /// Wrap a ``Bool``  into ``Variant``.
    @inline(__always)
    @inlinable
    public func toVariant() -> Variant {
        .bool(self)
    }

    /// Wrap a ``Bool``  into ``Variant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        .bool(self)
    }

    /// Initialize ``Bool`` from ``Variant``. Fails if `variant` doesn't contain a boolean.
    @inline(__always)
    public init?(_ variant: Variant) {
        guard case .bool(let value) = variant else { return nil }
        self = value
    }

    /// Initialize ``Bool`` from ``Variant?``. Fails if `variant` doesn't contain a boolean or is `nil`.
    @inline(__always)
    @inlinable
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }

    @inline(__always)
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        guard case .bool(let value) = variant else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        return value
    }
}

extension String: _GodotBridgeableBuiltin {
    @inline(__always)
    public static func _fromRawArgument(_ ptr: UnsafeRawPointer) throws(ArgumentAccessError) -> Self {
        GString.toString(pContent: ptr)
    }

    /// Internal API.
    @inline(__always)
    @inlinable
    public static var _variantType: Variant.GType {
        .string
    }

    /// Wrap a ``String``  into ``Variant``.
    @inline(__always)
    @inlinable
    public func toVariant() -> Variant {
        .string(self)
    }

    /// Wrap a ``String``  into ``Variant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        .string(self)
    }

    /// Initialize ``String`` from ``Variant``. Accepts both `String` and `StringName` variants.
    @inline(__always)
    public init?(_ variant: Variant) {
        switch variant {
        case .string(let value):
            self = value
        case .stringName(let value):
            self = value.description
        default:
            return nil
        }
    }

    /// Initialize ``String`` from ``Variant?``. Fails if it's `nil` or an incompatible type.
    @inline(__always)
    @inlinable
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }

    @inline(__always)
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        guard let value = String(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        return value
    }
}

extension Double: _GodotBridgeableBuiltin {
    @inline(__always)
    public static func _fromRawArgument(_ ptr: UnsafeRawPointer) throws(ArgumentAccessError) -> Self {
        ptr.assumingMemoryBound(to: Double.self).pointee
    }

    /// Wrap a ``Double``  into ``Variant``.
    @inline(__always)
    @inlinable
    public func toVariant() -> Variant {
        .float(self)
    }

    /// Wrap a ``Double``  into ``Variant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        .float(self)
    }

    /// Initialize ``Double`` from ``Variant``. Fails if `variant` doesn't contain a float.
    @inline(__always)
    public init?(_ variant: Variant) {
        guard case .float(let value) = variant else { return nil }
        self = value
    }

    /// Initialize ``Double`` from ``Variant?``. Fails if `variant` doesn't contain a float or is `nil`.
    @inline(__always)
    @inlinable
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }

    @inline(__always)
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Double {
        guard case .float(let value) = variant else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        return value
    }
}

public extension BinaryFloatingPoint where Self: VariantConvertible {
    /// Internal API.
    @inline(__always)
    @inlinable
    static var _variantType: Variant.GType {
        .float
    }

    /// Wrap a floating point number into ``Variant``.
    @inline(__always)
    @inlinable
    func toVariant() -> Variant {
        Double(self).toVariant()
    }

    /// Wrap a floating point number into ``Variant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    func toVariant() -> Variant? {
        Double(self).toVariant()
    }

    /// Initialize from ``Variant``. Fails if `variant` doesn't contain a float.
    @inline(__always)
    @inlinable
    init?(_ variant: Variant) {
        guard let value = Double(variant) else { return nil }
        self = Self(value)
    }

    /// Initialize from ``Variant?``. Fails if `variant` doesn't contain a float, or is `nil`.
    @inline(__always)
    @inlinable
    init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }

    @inline(__always)
    @inlinable
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

extension Float: _GodotBridgeableBuiltin {
    @inline(__always)
    public static func _fromRawArgument(_ ptr: UnsafeRawPointer) throws(ArgumentAccessError) -> Self {
        Float(ptr.assumingMemoryBound(to: Double.self).pointee)
    }
}

public extension RawRepresentable where RawValue: VariantConvertible {
    @inline(__always)
    @inlinable
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
    @inline(__always)
    @inlinable
    func toVariant() -> Variant {
        rawValue.toVariant()
    }
}

public extension RawRepresentable where RawValue: BinaryInteger, RawValue: _GodotBridgeableBuiltin {
    @inline(__always)
    @inlinable
    func toVariant() -> Variant {
        rawValue.toVariant()
    }
}

public extension RawRepresentable where RawValue: BinaryFloatingPoint, RawValue: _GodotBridgeableBuiltin {
    @inline(__always)
    @inlinable
    func toVariant() -> Variant {
        rawValue.toVariant()
    }
}
