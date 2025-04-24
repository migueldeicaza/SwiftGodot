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
    
    @_disfavoredOverload
    public static func unexpectedContent<T>(parsing type: T.Type = T.self, from: borrowing FastVariant?) -> Self {
        switch from {
        case .some(let variant):
            return unexpectedContent(
                requestedType: type,
                actualContent: variant.description
            )
        case .none:
            return unexpectedNilContent(parsing: type)
        }
    }
        
    public static func unexpectedContent<T>(parsing type: T.Type = T.self, from: borrowing FastVariant) -> Self {
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
///     public func toFastVariant() -> FastVariant? {
///         timeIntervalSince1970.toFastVariant()
///     }
///
///     public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Date {
///         Date(timeIntervalSince1970: try TimeInterval.fromFastVariantOrThrow(variant))
///     }
/// }
/// ```
///
/// All Godot API types and all the primitive Swift types (such as ``Bool``, ``String``, ``Int``, ``UInt`` of any length, ``Float``, ``Double``) implement it.
/// ``Variant`` and ``FastVariant`` implement it too.
///
/// Where are multiple ways to unwrap and unwrap such types, which are functionally identicaly, just use one that suites you more:
/// ```
/// let variant: Variant? // or `FastVariant?`
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
/// // Note that there is no `Object(variant)` because there can already be an instance of the wrapped object somewhere else in Swift runtime
/// // `init` of class types in Swift can't return another existing instance
///
/// ```
public protocol VariantConvertible {
    /// Extract ``Self`` from a ``Variant``. Throws `VariantConversionError` if it's not possible. Has default implementation. Can be implemented manually to avoid proxying via `FastVariant`
    static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self
    
    /// Extract ``Self`` from a ``FastVariant``. Throws `VariantConversionError` if it's not possible.
    static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self
    
    /// Extract ``Self`` from nil Variant. Throws `VariantConversionError` if it's not possible. Has default implementation.
    static func fromNilOrThrow() throws(VariantConversionError) -> Self
    
    /// Converts the instance to a ``Variant?``. Has default implementation. Can be implemented manually to avoid proxying via `FastVariant`
    func toVariant() -> Variant?
    
    /// Converts the instance to a ``FastVariant?``.
    func toFastVariant() -> FastVariant?
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
    
    /// Default implementation.
    @inline(__always)
    @inlinable
    @_disfavoredOverload // always prefer calling non-nil
    static func fromFastVariantOrThrow(_ variant: borrowing FastVariant?) throws(VariantConversionError) -> Self {
        switch variant {
        case .some(let variant):
            return try fromFastVariantOrThrow(variant)
        case .none:
            return try fromNilOrThrow()
        }        
    }
    
    /// Extract ``Self`` from a ``Variant``. Throws `VariantConversionError` if it's not possible.
    @inline(__always)
    @inlinable
    static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        try fromFastVariantOrThrow(variant.toFastVariant())
    }
    
    /// Converts the instance to a ``Variant?``.
    @inline(__always)
    @inlinable
    func toVariant() -> Variant? {
        Variant(takingOver: toFastVariant())
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
    
    /// Unwrap ``Self`` from a ``FastVariant``. Returns `nil` if it's not possible.
    @inline(__always)
    @inlinable
    static func fromFastVariant(_ variant: borrowing FastVariant) -> Self? {
        try? fromFastVariantOrThrow(variant)
    }
    
    /// Unwrap ``Self`` from a ``FastVariant?``. Returns `nil` if it's not possible.
    @inline(__always)
    @inlinable
    static func fromFastVariant(_ variant: borrowing FastVariant?) -> Self? {
        try? fromFastVariantOrThrow(variant)
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
/// It means being a `_GodotBridgeableBuiltin` also presumes being a `_GodotContainerTypingParameter` so
/// the following declarations are legal:
/// ```
/// let array = TypedArray<Int>()
/// let dictionary = TypedDictionary<String, Vector3>()
/// ```
public protocol _GodotBridgeableBuiltin: _GodotContainerTypingParameter {
}

public extension _GodotBridgeableBuiltin {
    /// Internal API. Required for `TypedArray` implementation.
    typealias _NonOptionalType = Self
    
    /// Internal API. Required for cases where Godot expects an empty `StringName` for builtin types and actual class name for `.object`-types.
    public static var _className: StringName {
        StringName("")
    }
    
    /// Internal API. Returns Godot type name for typed array.
    /// For example `TypedArray<Int>` is Godot `Array[int]`
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
    public typealias TypedArrayElement = Self?
    
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
        var hint = hint
        var hintStr = hintStr
        
        if self is Node.Type && hint == nil && hintStr == nil {
            hint = .nodeType
            hintStr = _builtinOrClassName
        }
        
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
        self?.toVariant()
    }
    
    @inline(__always)
    @inlinable
    func toFastVariant() -> FastVariant? {
        self?.toFastVariant()
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
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        Variant(self)
    }
    
    /// Wrap a ``Int64``  into ``Variant``.
    @inline(__always)
    @inlinable
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Wrap a ``Int64``  into ``FastVariant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toFastVariant() -> FastVariant? {
        FastVariant(self)
    }
    
    /// Wrap a ``Int64``  into ``FastVariant``.
    @inline(__always)
    @inlinable
    public func toFastVariant() -> FastVariant {
        FastVariant(self)
    }
    
    /// Initialze ``Int64`` from ``Variant``. Fails if `variant` doesn't contain ``Int64``
    @inline(__always)
    public init?(_ variant: Variant) {
        guard Self._variantType == variant.gtype else { return nil }
        self.init()
        
        withUnsafeMutablePointer(to: &self) { pPayload in
            variant.constructType(into: pPayload, constructor: VariantGodotInterface.intFromVariant)
        }
    }
    
    /// Initialze ``Int64`` from ``Variant``. Fails if `variant` doesn't contain ``Int64``
    @inline(__always)
    public init?(_ variant: borrowing FastVariant) {
        guard Self._variantType == variant.gtype else { return nil }
        self.init()
        
        withUnsafeMutablePointer(to: &self) { pPayload in
            variant.constructType(into: pPayload, constructor: VariantGodotInterface.intFromVariant)
        }
    }
    
    /// Initialze ``Int64`` from ``Variant``. Fails if `variant` doesn't contain ``Int64`` or is `nil`
    @inline(__always)
    @inlinable
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }
    
    /// Attempt to unwrap a ``Int64`` from a `variant`. Throws `VariantConversionError` if it's not possible.
    @inline(__always)
    @inlinable
    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
        guard let value = Int64(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        
        return value
    }
    
    /// Attempt to unwrap a ``Int64`` from a `variant`. Throws `VariantConversionError` if it's not possible.
    @inline(__always)
    @inlinable
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        guard let value = Int64(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        
        return value
    }
}

public extension BinaryInteger where Self: _GodotBridgeableBuiltin {
    @inline(__always)
    @inlinable
    static var _variantType: Variant.GType {
        .int
    }

    /// Wrap an integer number  into ``Variant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    func toVariant() -> Variant? {
        Int64(self).toVariant()
    }
    
    /// Wrap an integer number  into ``Variant``.
    @inline(__always)
    @inlinable
    func toVariant() -> Variant {
        Int64(self).toVariant()
    }
    
    /// Wrap an integer number  into ``FastVariant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    func toFastVariant() -> FastVariant? {
        Int64(self).toFastVariant()
    }
    
    /// Wrap an integer number  into ``FastVariant``.
    @inline(__always)
    @inlinable
    func toFastVariant() -> FastVariant {
        Int64(self).toFastVariant()
    }
    
    
    /// Initialze ``BinaryInteger`` from ``Variant``. Fails if `variant` doesn't contain ``Int64``, or its value is too large for this ``BinaryInteger``
    @inline(__always)
    @inlinable
    init?(_ variant: Variant) {
        guard Self._variantType == variant.gtype else { return nil }
        guard let value = try? Self.fromVariantOrThrow(variant) else {
            return nil
        }
        
        self = value
    }
    
    /// Initialze ``BinaryInteger`` from ``Variant``. Fails if `variant` doesn't contain ``Int64``, its value is too large for this ``BinaryInteger``, or is `nil`
    @inline(__always)
    @inlinable
    init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }
    
    /// Initialze ``BinaryInteger`` from ``FastVariant``. Fails if `variant` doesn't contain ``Int64``, or its value is too large for this ``BinaryInteger``
    @inline(__always)
    @inlinable
    init?(_ variant: borrowing FastVariant) {
        guard Self._variantType == variant.gtype else { return nil }
        guard let value = try? Self.fromFastVariantOrThrow(variant) else {
            return nil
        }
        
        self = value
    }
    
    /// Initialze ``BinaryInteger`` from ``FastVariant``. Fails if `variant` doesn't contain ``Int64``, its value is too large for this ``BinaryInteger``, or is `nil`
    @inline(__always)
    @inlinable
    init?(_ variant: borrowing FastVariant?) {
        switch variant {
        case .some(let variant):
            self.init(variant)
        case .none:
            return nil
        }
    }
    
    /// Attempt to unwrap an integer number from a `variant`. Throws `VariantConversionError` if it's not possible.
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
    
    /// Attempt to unwrap an integer number from a `variant`. Throws `VariantConversionError` if it's not possible.
    @inline(__always)
    @inlinable
    static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
        let value = try Int64.fromFastVariantOrThrow(variant)
        
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
    @inline(__always)
    @inlinable
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
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        Variant(self)
    }
    
    /// Wrap a ``Bool``  into ``Variant``.
    @inline(__always)
    @inlinable
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Wrap a ``Bool``  into ``FastVariant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toFastVariant() -> FastVariant? {
        FastVariant(self)
    }
    
    /// Wrap a ``Bool``  into ``FastVariant``.
    @inline(__always)
    @inlinable
    public func toFastVariant() -> FastVariant {
        FastVariant(self)
    }
    
    /// Initialze ``Bool`` from ``Variant``. Fails if `variant` doesn't contain ``Bool``
    @inline(__always)
    public init?(_ variant: Variant) {
        guard Self._variantType == variant.gtype else { return nil }
        var payload: GDExtensionBool = 0
        withUnsafeMutablePointer(to: &payload) { pPayload in
            variant.constructType(into: pPayload, constructor: VariantGodotInterface.boolFromVariant)
        }
        
        self = payload != 0
    }
    
    /// Initialze ``Bool`` from ``FastVariant``. Fails if `variant` doesn't contain ``Bool`` or is `nil`
    @inline(__always)
    @inlinable
    public init?(_ variant: borrowing FastVariant?) {
        switch variant {
        case .some(let variant):
            self.init(variant)
        case .none:
            return nil
        }
    }
    
    /// Initialze ``Bool`` from ``FastVariant``. Fails if `variant` doesn't contain ``Bool``
    @inline(__always)
    public init?(_ variant: borrowing FastVariant) {
        guard Self._variantType == variant.gtype else { return nil }
        var payload: GDExtensionBool = 0
        withUnsafeMutablePointer(to: &payload) { pPayload in
            variant.constructType(into: pPayload, constructor: VariantGodotInterface.boolFromVariant)
        }
        
        self = payload != 0
    }
    
    /// Initialze ``Bool`` from ``Variant``. Fails if `variant` doesn't contain ``Bool`` or is `nil`
    @inline(__always)
    @inlinable
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }
    
    /// Attempt to unwrap a ``Bool`` from a `variant`. Throws `VariantConversionError` if it's not possible.
    @inline(__always)
    @inlinable
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        guard let value = Bool(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        return value
    }
    
    /// Attempt to unwrap a ``Bool`` from a `variant`. Throws `VariantConversionError` if it's not possible.
    @inline(__always)
    @inlinable
    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
        guard let value = Bool(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        return value
    }
}

extension String: _GodotBridgeableBuiltin {
    /// Internal API.
    @inline(__always)
    @inlinable
    public static var _variantType: Variant.GType {
        .string
    }
    
    /// Wrap a ``String``  into ``Variant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        Variant(self)
    }
    
    /// Wrap a ``String``  into ``Variant``.
    @inline(__always)
    @inlinable
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Wrap a ``String``  into ``FastVariant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toFastVariant() -> FastVariant? {
        FastVariant(self)
    }
    
    /// Wrap a ``String``  into ``FastVariant``.
    @inline(__always)
    @inlinable
    public func toFastVariant() -> FastVariant {
        FastVariant(self)
    }
    
    /// Initialze ``String`` from ``Variant``. Fails if `variant` doesn't contain ``String``
    @inline(__always)
    public init?(_ variant: Variant) {
        switch variant.gtype {
        case .string:
            /// Avoid allocating `GString` wrapper at least
            var content = GString.zero
            variant.constructType(into: &content, constructor: GodotInterfaceForString.selfFromVariant)
            self = GString.toString(pContent: &content)
            GodotInterfaceForString.destructor(&content)
        case .stringName:
            /// It's going through the ``PackedByteArray`` already, it's a death from the thousand cuts.
            // TODO: should we print a warning and question feasibility of this?
            guard let string = StringName(variant)?.description else {
                return nil
            }
            
            self = string
        default:
            return nil
        }
    }
    
    /// Initialze ``String`` from ``Variant``. Fails if `variant` doesn't contain ``String`` or is `nil`
    @inline(__always)
    @inlinable
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }
    
    
    /// Initialze ``String`` from ``FastVariant``. Fails if `variant` doesn't contain ``String``
    @inline(__always)
    public init?(_ variant: borrowing FastVariant) {
        switch variant.gtype {
        case .string:
            /// Avoid allocating `GString` wrapper at least
            var content = GString.zero
            variant.constructType(into: &content, constructor: GodotInterfaceForString.selfFromVariant)
            self = GString.toString(pContent: &content)
            GodotInterfaceForString.destructor(&content)
        case .stringName:
            /// It's going through the ``PackedByteArray`` already, it's a death from the thousand cuts.
            // TODO: should we print a warning and question feasibility of this?
            guard let string = StringName(variant)?.description else {
                return nil
            }
            
            self = string
        default:
            return nil
        }
    }
    
    /// Initialze ``String`` from ``FastVariant``. Fails if `variant` doesn't contain ``String`` or is `nil`
    @inline(__always)
    @inlinable
    public init?(_ variant: borrowing FastVariant?) {
        switch variant {
        case .some(let variant):
            self.init(variant)
        case .none:
            return nil
        }
    }
    
    /// Attempt to unwrap a ``String`` from a `variant`. Throws `VariantConversionError` if it's not possible.
    @inline(__always)
    @inlinable
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        guard let value = String(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        
        return value
    }
    
    /// Attempt to unwrap a ``String`` from a `variant`. Throws `VariantConversionError` if it's not possible.
    @inline(__always)
    @inlinable
    public static func fromVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
        guard let value = String(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        
        return value
    }
    
    /// Attempt to unwrap a ``String`` from a `variant`. Throws `VariantConversionError` if it's not possible.
    @inline(__always)
    @inlinable
    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
        guard let value = String(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        
        return value
    }
}

extension Double: _GodotBridgeableBuiltin {
    /// Wrap a ``Double``  into ``Variant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        Variant(self)
    }
    
    /// Wrap a ``Double``  into ``Variant``.
    @inline(__always)
    @inlinable
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Wrap a ``Double``  into ``FastVariant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toFastVariant() -> FastVariant? {
        FastVariant(self)
    }
    
    /// Wrap a ``Double``  into ``FastVariant``.
    @inline(__always)
    @inlinable
    public func toFastVariant() -> FastVariant {
        FastVariant(self)
    }
    
    /// Initialze ``Double`` from ``Variant``. Fails if `variant` doesn't contain ``Double``
    @inline(__always)
    public init?(_ variant: Variant) {
        guard Self._variantType == variant.gtype else { return nil }
        self.init()
        
        withUnsafeMutablePointer(to: &self) { pPayload in
            variant.constructType(into: pPayload, constructor: VariantGodotInterface.doubleFromVariant)
        }
    }
    
    /// Initialze ``Double`` from ``Variant``. Fails if `variant` doesn't contain ``Double`` or is `nil`
    @inline(__always)
    @inlinable
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }
    
    /// Initialze ``Double`` from ``FastVariant``. Fails if `variant` doesn't contain ``Double``
    @inline(__always)
    public init?(_ variant: borrowing FastVariant) {
        guard Self._variantType == variant.gtype else { return nil }
        self.init()
        
        withUnsafeMutablePointer(to: &self) { pPayload in
            variant.constructType(into: pPayload, constructor: VariantGodotInterface.doubleFromVariant)
        }
    }
    
    /// Initialze ``Double`` from ``FastVariant``. Fails if `variant` doesn't contain ``Double`` or is `nil`
    @inline(__always)
    @inlinable
    public init?(_ variant: borrowing FastVariant?) {        
        switch variant {
        case .some(let variant):
            self.init(variant)
        case .none:
            return nil
        }
    }
    
    /// Attempt to unwrap a ``Double`` from a `variant`. Throws `VariantConversionError` if it's not possible.
    @inline(__always)
    @inlinable
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        guard let value = Double(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        return value
    }
    
    @inline(__always)
    @inlinable
    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Double {
        guard let value = Double(variant) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        return value
    }
}

public extension BinaryFloatingPoint where Self: VariantConvertible  {
    /// Internal API.
    @inline(__always)
    @inlinable
    static var _variantType: Variant.GType {
        .float
    }
    
    /// Wrap a floating point number into ``Variant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    func toVariant() -> Variant? {
        Double(self).toVariant()
    }
    
    /// Wrap a floating point number into ``Variant``.
    @inline(__always)
    @inlinable
    func toVariant() -> Variant {
        Double(self).toVariant()
    }
    
    /// Wrap a floating point number into ``FastVariant?``.
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    func toFastVariant() -> FastVariant? {
        Double(self).toFastVariant()
    }
    
    /// Wrap a floating point number into ``FastVariant``.
    @inline(__always)
    @inlinable
    func toFastVariant() -> FastVariant {
        Double(self).toFastVariant()
    }
    
    /// Initialze ``BinaryFloatingPoint`` from ``Variant``. Fails if `variant` doesn't contain ``Double``
    @inline(__always)
    @inlinable
    init?(_ variant: Variant) {
        guard let value = Double(variant) else { return nil }
        self = Self(value)
    }
    
    /// Initialze ``BinaryFloatingPoint`` from ``Variant``. Fails if `variant` doesn't contain ``Double``, or is `nil`
    @inline(__always)
    @inlinable
    init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }

    /// Attempt to unwrap a floating point number from a `variant`. Throws `VariantConversionError` if it's not possible.
    @inline(__always)
    @inlinable
    static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        Self(try Double.fromVariantOrThrow(variant))
    }
    
    @inline(__always)
    @inlinable
    static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
        Self(try Double.fromFastVariantOrThrow(variant))
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
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    func toVariant() -> Variant? {
        rawValue.toVariant()
    }
    
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    func toFastVariant() -> FastVariant? {
        rawValue.toFastVariant()
    }
    
    static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        let rawValue = try RawValue.fromVariantOrThrow(variant)
        guard let value = Self(rawValue: rawValue) else {
            throw .invalidRawValue(requestedType: self, value: rawValue)
        }
        return value
    }
    
    static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
        let rawValue = try RawValue.fromFastVariantOrThrow(variant)
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
    
    @inline(__always)
    @inlinable
    func toFastVariant() -> FastVariant {
        rawValue.toFastVariant()
    }
}

public extension RawRepresentable where RawValue: BinaryInteger, RawValue: _GodotBridgeableBuiltin {
    @inline(__always)
    @inlinable
    func toVariant() -> Variant {
        rawValue.toVariant()
    }
    
    @inline(__always)
    @inlinable
    func toFastVariant() -> FastVariant {
        rawValue.toFastVariant()
    }
}

public extension RawRepresentable where RawValue: BinaryFloatingPoint, RawValue: _GodotBridgeableBuiltin  {
    @inline(__always)
    @inlinable
    func toVariant() -> Variant {
        rawValue.toVariant()
    }
    
    @inline(__always)
    @inlinable
    func toFastVariant() -> FastVariant {
        rawValue.toFastVariant()
    }
}
