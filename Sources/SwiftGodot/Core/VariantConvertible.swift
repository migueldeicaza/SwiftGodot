//
//  Exportable.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 08/04/2025.
//

/// Protocol for types that can be converted to and from ``Variant``.
/// NOTE: this type is planned to supersede ``VariantStorable`` in the future.
public protocol VariantConvertible {
    /// Extract ``Self`` from a ``Variant``. Returns `nil` if it's not possible. E.g. another type is stored in the `variant`
    static func fromVariant(_ variant: Variant) -> Self?
    
    /// Converts the instance to a ``Variant``.
    func toVariant() -> Variant
}

/// Internal API. Protocol for types that contains details on how it interacts with C GDExtension API.
/// You could assume that to be the set of all Builtin Types and Object-derived Types. `Variant` is not included and processed in a special overload of functions where `_GodotBridgeable` shows up.
public protocol _GodotBridgeable: VariantConvertible, _ArgumentConvertible {
}

/// Internal API. Subset protocol for all Builtin Types.
public protocol _GodotBridgeableBuiltin: _GodotBridgeable {
    /// Internal API. Return PropInfo when this class is used as an @Exported property.
    static func _macroGodotGetPropInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo
    
    /// Internal API. Returns Godot type name for typed array.
    static var _macroGodotGetPropInfoArrayType: String { get }
}

/// Internal API. Subset protocol for all Object-derived types.
/// This is a special case due to Swift type system not allowing default implementation using `Self` for non-final classes.
/// It's needed to allow statically dispatching macro functions in the context of `Object` and its subclasses.
public protocol _GodotBridgeableObject: _GodotBridgeable {
}

public extension _GodotBridgeableObject where Self: Object {
    /// Internal API. Returns ``PropInfo`` for when any ``Object`` or its subclass instance is used as an `@Exported` variable
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
        self?.toVariant()
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
    // _macroGodotGetPropInfoArrayType is implemented below for all `BinaryInteger`
    
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
    
    /// Internal API. For indicating that Godot` Array` of ``BinaryInteger`` has type `Array[int]`
    @inline(__always)
    @inlinable
    static var _macroGodotGetPropInfoArrayType: String { "int" }
    
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

extension Bool: _GodotBridgeableBuiltin {
    /// Internal API. Returns ``PropInfo`` for when any ``Bool`` is used as an `@Exported` variable
    @inline(__always)
    @inlinable
    public static func _macroGodotGetPropInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        _macroGodotGetPropInfoDefault(
            propertyType: .bool,
            name: name,
            hint: hint,
            hintStr: hintStr,
            usage: usage
        )
    }
    
    /// Internal API. For indicating that Godot` Array` of ``Bool`` has type `Array[bool]`
    @inline(__always)
    @inlinable
    public static var _macroGodotGetPropInfoArrayType: String { "bool" }
    
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

extension String: _GodotBridgeableBuiltin {
    /// Internal API. Returns ``PropInfo`` for when any ``String`` is used as an `@Exported` variable
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
    
    /// Internal API. For indicating that Godot` Array` of ``BinaryInteger`` has type `Array[int]`
    @inline(__always)
    @inlinable
    public static var _macroGodotGetPropInfoArrayType: String { "String" }
    
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

extension Double: _GodotBridgeableBuiltin {
    // _macroGodotGetPropInfo is implemented below for all `BinaryFloatingPoint`
    // _macroGodotGetPropInfoArrayType is implemented below for all `BinaryFloatingPoint`
    
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
    
    /// Internal API. For indicating that Godot` Array` of ``BinaryFloatingPoint`` has type `Array[float]`
    @inline(__always)
    @inlinable
    static var _macroGodotGetPropInfoArrayType: String { "float" }
    
    /// Wrap a floating point number into ``Variant``.
    func toVariant() -> Variant {
        Double(self).toVariant()
    }

    /// Attempt to unwrap a floating point number from a `variant`. Returns `nil` if it's impossible. For example, other type is stored inside a `variant`
    static func fromVariant(_ variant: Variant) -> Self? {
        Double.fromVariant(variant).map { Self($0) }
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
