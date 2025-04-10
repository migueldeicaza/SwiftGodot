//
//  Exportable.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 08/04/2025.
//

/// Protocol for types that can be converted to and from ``Variant``.
/// NOTE: this type is planned to supersede ``VariantStorable`` in the future.
public protocol VariantConvertible {
    /// Converts the instance to a ``Variant``.
    func toVariant() -> Variant
    
    /// Extract ``Self`` from a ``Variant``. Returns `nil` if it's not possible. E.g. another type is stored in the `variant`
    static func fromVariant(_ variant: Variant) -> Self?
}

/// Internal API. Interface for types that contains details on how it interacts with C GDExtension API.
///
/// ### Rationale
///
/// This is more specialized version of `VariantConvertible` for cases where an ability to be converted to and from a `Variant` is not suffucient.
/// At the same time it allows `VariantConvertible` to be implemented by the user for coding arbitary values inside the `Variant`.
/// This class is a base for future changes such as generating relevant `PropInfo` in the context of this type being:
/// 1. A returned value
/// 2. An argument
/// 3. A class property
///
/// This this allow to statically dispatch `PropInfo` generation in the context of macro without relying on Swift syntax analysis.
/// For now this protocol allows to distinguish between a type being merely `VariantConvertible` and being able, for example, to be `@Export`-ed.
/// ```
/// struct SomeUserType: VariantConvertible {
///     // implementation
/// }
/// ```
///
/// While `SomeUserType` can be freely used in the context where `Variant` is accepted as a part of Godot API:
/// ```
/// GD.print(SomeUserType())
/// ```
///
/// It's still prohibited to be used as `@Export`-ed in this case:
/// ```
/// @Godot
/// class SomeClass {
///     @Export var someUsertType: SomeUserType = .init() // How should it be visible on Godot side?
/// }
/// ```
///
/// In future it will alow us to resurface arbitary user types on Godot side via implementing `_GodotBridgeable` requirements as extension of a protocol `CustomGodotBridgeable` intended for users as in:
/// ```
/// public protocol CustomGodotBridgeable: _GodotBridgeable {
///     associatedtype GodotCompatibleRepresentation: _GodotBridgeable
///
///     func to(_ type: GodotCompatibleRepresentation.Type) -> GodotCompatibleRepresentation
///     static func from(_ godotCompatibleInstance: GodotCompatibleRepresentation) -> Self?
///
/// }
/// ```
///
/// Low-level part of `CustomGodotBridgeable` requirements will simply be default-implemented by `GodotCompatibleRepresentation`
///
/// ```
/// public extension CustomGodotBridgeable {
///     static func _propertyPropInfo(hint: String?) -> PropInfo { GodotCompatibleRepresentation._propertyPropInfo(hint: hint) }
/// }
/// ```
///
/// At user side it wil look like:
/// ```
/// struct SomeUserType: CustomGodotBridgeable {
///      func to(_ type: GDictionary.Type = GDictionary.self) -> GDictionary {
///         // encode this instance to GDictionary
///      }
///
///      static func from(_ godotCompatibleInstance: GDictionary) -> Self? {
///         // Try to decode this type from dictionary, print something nasty in `GD.printErr` if things go south,
///         // Perhaps provide some `Godot(Variant/Dictionary)(Encoder/Decoder)` to make things super-straight forward
///         // and make `Codable` work from the box
///      }
/// }
///
/// @Godot
/// class Example: Object {
///     @Export var someUserType: SomeUserType = .init() // Will work fine now
///
///     // Macro expansion
///     // ...
///     // let prop0 = type(at: \Object.someUserType)._propertyPropInfo()
///     // ...
///
/// }
///
/// ```
///
public protocol _GodotBridgeable: VariantConvertible {
    /// Internal API. Return PropInfo when this class is used as an @Exported property.
    static func _macroGodotGetVariablePropInfo<Root>(
        rootType: Root.Type,
        name: String,
        userHint: PropertyHint?,
        userHintStr: String?,
        userUsage: PropertyUsageFlags?
    ) -> PropInfo
    
    /// Internal API. Returns Godot type name for typed array.
    static var _macroGodotGetVariablePropInfoArrayType: String { get }
}

/// Internal API.
/// This is a special case due to Swift type system not allowing default implementation using `Self` for non-final classes.
/// It's needed to allow statically dispatching macro functions in the context of `Object` and its subclasses.
public protocol _GodotBridgeableObject: VariantConvertible {
}

public extension _GodotBridgeableObject where Self: Object {
    /// Internal API. Returns ``PropInfo`` for when any ``Object`` or its subclass instance is used as an `@Exported` variable
    @inline(__always)
    @inlinable
    static func _macroGodotGetVariablePropInfo<Root>(
        rootType: Root.Type,
        name: String,
        userHint: PropertyHint?,
        userHintStr: String?,
        userUsage: PropertyUsageFlags?
    ) -> PropInfo {
        // QoL
        
        return _macroGodotGetVariablePropInfoSimple(
            rootType: rootType,
            propertyType: .object,
            name: name,
            userHint: userHint,
            userHintStr: userHintStr,
            userUsage: userUsage
        )
    }
}


/// Returns the metatype of the `Value` at given key path.
///
/// For example:
/// ```
/// struct A {
///  let a = 10
///  static func foo() {
///    type(at: \A.a).max // returns Int.max
///  }
/// }
/// ```
/// This can be used for accessing static members of the type of the property from the static context of the containing type without relying on explicit type of `Value`.
/// See how in example above `Int` is not mentioned anywhere in the code explicitly.
@inline(__always)
@inlinable
public func valueType<Root, Value>(at keyPath: KeyPath<Root, Value>) -> Value.Type {
    Value.self
}

public extension KeyPath {
    /// Returns the metatype of the `Value` of the ``KeyPath``
    ///
    /// For example:
    /// ```
    /// struct A {
    ///  let a = 10
    ///  static func foo() {
    ///    (\A.a).valueType // returns Int.max
    ///  }
    /// }
    /// ```
    /// This can be used for accessing static members of the type of the property from the static context of the containing type without relying on explicit type of `Value`.
    /// See how in example above `Int` is not mentioned anywhere in the code explicitly.
    @inline(__always)
    @inlinable
    var valueType: Value.Type {
        Value.self
    }
}

public extension Optional where Wrapped: VariantConvertible {
    func toVariant() -> Variant? {
        self?.toVariant()
    }
}

// Simple common case for most of the bridged types
@inline(__always)
@inlinable
func _macroGodotGetVariablePropInfoSimple<T>(
    rootType: T.Type,
    propertyType: Variant.GType,
    name: String,
    userHint: PropertyHint?,
    userHintStr: String?,
    userUsage: PropertyUsageFlags?
) -> PropInfo {
    return PropInfo(
        propertyType: propertyType,
        propertyName: StringName(name),
        className: "\(rootType)",
        hint: userHint ?? .none,
        hintStr: userHintStr.map { GString($0) } ?? GString(),
        usage: userUsage ?? .default
    )
}

extension Int64: _GodotBridgeable {
    // _macroGodotGetVariablePropInfo is implemented below for all `BinaryInteger`
    // _macroGodotGetVariablePropInfoArrayType is implemented below for all `BinaryInteger`
    
    /// Wrap a ``Int64``  into ``Variant``.
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Attempt to unwrap a ``Int64`` from a `variant`. Returns `nil` if it's impossible. For example, other type is stored inside a `variant`.
    public static func fromVariant(_ variant: Variant) -> Self? {
        guard let value = Int64(variant) else { return nil }
        return value
    }
}

public extension BinaryInteger {
    /// Internal API. Returns ``PropInfo`` for when any ``BinaryInteger`` is used as an `@Exported` variable
    @inline(__always)
    @inlinable
    static func _macroGodotGetVariablePropInfo<Root>(
        rootType: Root.Type,
        name: String,
        userHint: PropertyHint?,
        userHintStr: String?,
        userUsage: PropertyUsageFlags?
    ) -> PropInfo {
        _macroGodotGetVariablePropInfoSimple(
            rootType: rootType,
            propertyType: .int,
            name: name,
            userHint: userHint,
            userHintStr: userHintStr,
            userUsage: userUsage
        )
    }
    
    /// Internal API. For indicating that Godot` Array` of ``BinaryInteger`` has type `Array[int]`
    @inline(__always)
    @inlinable
    static var _macroGodotGetVariablePropInfoArrayType: String { "int" }
    
    /// Wrap an integer number  into ``Variant``.
    func toVariant() -> Variant {
        Int64(self).toVariant()
    }
    
    /// Attempt to unwrap an integer number from a `variant`. Returns `nil` if it's impossible. For example, other type is stored inside a `variant`, or wrapped number doesn't fit the integer size.
    static func fromVariant(_ variant: Variant) -> Self? {
        guard let int = Int64.fromVariant(variant) else {
            return nil
        }
        
        // Fail gracefully if overflow happens
        let result = Self(exactly: int)
        
        guard let result else {
            GD.printErr("\(self) can't contain the value '\(int)'.")
            return nil
        }
        
        return result
    }
}

extension Bool: _GodotBridgeable {
    /// Internal API. Returns ``PropInfo`` for when any ``Bool`` is used as an `@Exported` variable
    @inline(__always)
    @inlinable
    public static func _macroGodotGetVariablePropInfo<Root>(
        rootType: Root.Type,
        name: String,
        userHint: PropertyHint?,
        userHintStr: String?,
        userUsage: PropertyUsageFlags?
    ) -> PropInfo {
        _macroGodotGetVariablePropInfoSimple(
            rootType: rootType,
            propertyType: .bool,
            name: name,
            userHint: userHint,
            userHintStr: userHintStr,
            userUsage: userUsage
        )
    }
    
    /// Internal API. For indicating that Godot` Array` of ``Bool`` has type `Array[bool]`
    @inline(__always)
    @inlinable
    public static var _macroGodotGetVariablePropInfoArrayType: String { "bool" }
    
    /// Wrap a ``Bool``  into ``Variant``.
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Attempt to unwrap a ``Bool`` from a `variant`. Returns `nil` if it's impossible. For example, other type is stored inside a `variant`.
    public static func fromVariant(_ variant: Variant) -> Self? {
        guard let value = Bool(variant) else { return nil }
        return value
    }
}

extension String: _GodotBridgeable {
    /// Internal API. Returns ``PropInfo`` for when any ``String`` is used as an `@Exported` variable
    @inline(__always)
    @inlinable
    public static func _macroGodotGetVariablePropInfo<Root>(
        rootType: Root.Type,
        name: String,
        userHint: PropertyHint?,
        userHintStr: String?,
        userUsage: PropertyUsageFlags?
    ) -> PropInfo {
        _macroGodotGetVariablePropInfoSimple(
            rootType: rootType,
            propertyType: .string,
            name: name,
            userHint: userHint,
            userHintStr: userHintStr,
            userUsage: userUsage
        )
    }
    
    /// Internal API. For indicating that Godot` Array` of ``BinaryInteger`` has type `Array[int]`
    @inline(__always)
    @inlinable
    public static var _macroGodotGetVariablePropInfoArrayType: String { "String" }
    
    /// Wrap a ``String``  into ``Variant``.
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Attempt to unwrap a ``String`` from a `variant`. Returns `nil` if it's impossible. For example, other type is stored inside a `variant`.
    public static func fromVariant(_ variant: Variant) -> Self? {
        guard let value = String(variant) else { return nil }
        return value
    }
}

extension Double: _GodotBridgeable {
    // _macroGodotGetVariablePropInfo is implemented below for all `BinaryFloatingPoint`
    // _macroGodotGetVariablePropInfoArrayType is implemented below for all `BinaryFloatingPoint`
    
    /// Wrap a ``Double``  into ``Variant``.
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    /// Attempt to unwrap a ``Double`` from a `variant`. Returns `nil` if it's impossible. For example, other type is stored inside a `variant`.
    public static func fromVariant(_ variant: Variant) -> Self? {
        guard let value = Double(variant) else { return nil }
        return value
    }
}

public extension BinaryFloatingPoint {
    /// Internal API. Returns ``PropInfo`` for when any ``BinaryFloatingPoint`` is used as an `@Exported` variable
    @inline(__always)
    @inlinable
    static func _macroGodotGetVariablePropInfo<Root>(
        rootType: Root.Type,
        name: String,
        userHint: PropertyHint?,
        userHintStr: String?,
        userUsage: PropertyUsageFlags?
    ) -> PropInfo {
        _macroGodotGetVariablePropInfoSimple(
            rootType: rootType,
            propertyType: .float,
            name: name,
            userHint: userHint,
            userHintStr: userHintStr,
            userUsage: userUsage
        )
    }
    
    /// Internal API. For indicating that Godot` Array` of ``BinaryFloatingPoint`` has type `Array[float]`
    @inline(__always)
    @inlinable
    static var _macroGodotGetVariablePropInfoArrayType: String { "float" }
    
    /// Wrap a floating point number into ``Variant``.
    func toVariant() -> Variant {
        Double(self).toVariant()
    }

    /// Attempt to unwrap a floating point number from a `variant`. Returns `nil` if it's impossible. For example, other type is stored inside a `variant`
    static func fromVariant(_ variant: Variant) -> Self? {
        Double.fromVariant(variant).map { Self($0) }
    }
}

extension Int: _GodotBridgeable {}
extension Int32: _GodotBridgeable {}
extension Int16: _GodotBridgeable {}
extension Int8: _GodotBridgeable {}

extension UInt: _GodotBridgeable {}
extension UInt64: _GodotBridgeable {}
extension UInt32: _GodotBridgeable {}
extension UInt16: _GodotBridgeable {}
extension UInt8: _GodotBridgeable {}
    
extension Float: _GodotBridgeable {}

public extension RawRepresentable where RawValue: BinaryInteger {
    func toVariant() -> Variant {
        Int64(rawValue).toVariant()
    }
    
    static func fromVariant(_ variant: Variant) -> Self? {
        guard let rawValue = Int64.fromVariant(variant) else {
            GD.printErr("Variant doesn't store `int`")
            return nil
        }
        
        guard let value = Self(rawValue: RawValue(rawValue)) else {
            GD.printErr("\(rawValue) is not a valid `rawValue` for \(Self.self)")
            return nil
        }
        return value
    }
}
