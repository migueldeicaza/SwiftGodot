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
/// This is more specialized version of ``VariantConvertible`` for cases where an ability to be converted to and from a ``Variant`` is not enough.
/// At the same time it allows ``VariantConvertible`` to be implemented by the user for coding arbitary values inside the ``Variant``
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
