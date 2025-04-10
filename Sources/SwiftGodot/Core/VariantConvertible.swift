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
}

public extension Optional where Wrapped: VariantConvertible {
    func toVariant() -> Variant? {
        self?.toVariant()
    }
}

extension _GodotBridgeable {
}

extension Int64: _GodotBridgeable {
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    public static func fromVariant(_ variant: Variant) -> Self? {
        guard let value = Int64(variant) else { return nil }
        return value
    }
}

extension Bool: _GodotBridgeable {
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    public static func fromVariant(_ variant: Variant) -> Self? {
        guard let value = Bool(variant) else { return nil }
        return value
    }
}

extension String: _GodotBridgeable {
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    public static func fromVariant(_ variant: Variant) -> Self? {
        guard let value = String(variant) else { return nil }
        return value
    }
}

extension Double: _GodotBridgeable {
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    public static func fromVariant(_ variant: Variant) -> Self? {
        guard let value = Double(variant) else { return nil }
        return value
    }
}

public extension BinaryFloatingPoint {
    func toVariant() -> Variant {
        Double(self).toVariant()
    }
    
    static func fromVariant(_ variant: Variant) -> Self? {
        Double.fromVariant(variant).map { Self($0) }
    }
}

public extension BinaryInteger {
    func toVariant() -> Variant {
        Int64(self).toVariant()
    }
    
    static func fromVariant(_ variant: Variant) -> Self? {
        Int64.fromVariant(variant).map { Self($0) }
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
