//
//  Exportable.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 08/04/2025.
//

/// Protocol for types that can be converted to and from ``Variant``.
/// It is implicitly used in places where Godot bridges with Swift world, such as:
///
/// 1. @Export macro.
///
/// TBD
/// NOTE: this type is planned to supersede ``VariantStorable`` in the future.
public protocol VariantConvertible {
    /// Converts the instance to a ``Variant``.
    func toVariant() -> Variant
    
    /// Extract ``Self`` from a ``Variant``. Returns `nil` if it's not possible. E.g. another type is stored in the `variant`
    static func fromVariant(_ variant: Variant) -> Self?
    
    /// Internal API. Required for macros to properly handle reference counting. Do not implement this method.
    func _macroRcRef()
    
    /// Internal API. Required for macros to properly handle reference counting. Do not implement this method.
    func _macroRcUnref()
}

public extension Optional where Wrapped: VariantConvertible {
    func toVariant() -> Variant? {
        self?.toVariant()
    }
}

extension VariantConvertible {
    public func _macroRcRef() {
        // No-op default implementation
    }
    
    public func _macroRcUnref() {
        // No-op default implementation
    }
}

extension Int64: VariantConvertible {
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    public static func fromVariant(_ variant: Variant) -> Self? {
        guard let value = Int64(variant) else { return nil }
        return value
    }
}

extension Bool: VariantConvertible {
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    public static func fromVariant(_ variant: Variant) -> Self? {
        guard let value = Bool(variant) else { return nil }
        return value
    }
}

extension String: VariantConvertible {
    public func toVariant() -> Variant {
        Variant(self)
    }
    
    public static func fromVariant(_ variant: Variant) -> Self? {
        guard let value = String(variant) else { return nil }
        return value
    }
}

extension Double: VariantConvertible {
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

extension Int: VariantConvertible {}
extension Int32: VariantConvertible {}
extension Int16: VariantConvertible {}
extension Int8: VariantConvertible {}

extension UInt: VariantConvertible {}
extension UInt64: VariantConvertible {}
extension UInt32: VariantConvertible {}
extension UInt16: VariantConvertible {}
extension UInt8: VariantConvertible {}
    
extension Float: VariantConvertible {}

public extension RawRepresentable where RawValue: BinaryInteger {
    func toVariant() -> Variant {
        Int64(rawValue).toVariant()
    }
    
    static func fromVariant(_ variant: Variant) -> Self? {
        guard let rawValue = Int64.fromVariant(variant).map({ RawValue($0) }) else { return nil }
        guard let value = Self(rawValue: rawValue) else { return nil }
        return value
    }
}

/// Internal API. Required for macros.
/// Overload for types that do conform to`` VariantConvertible`` to avoid having fancy error diagnostic messages.
/// Ideally this function will be optimized away by the compiler and needed strictly for `static_assert`-like purposes.
@inline(__always)
public func _macroExportGet<T>(_ value: T) -> Variant? where T: VariantConvertible {
    return value.toVariant()
}

/// Internal API. Required for macros.
/// Overload for Optional wrapping types that do conform to`` VariantConvertible`` to avoid having fancy error diagnostic messages.
/// Ideally this function will be optimized away by the compiler and needed strictly for `static_assert`-like purposes.
@inline(__always)
public func _macroExportGet<T>(_ value: T?) -> Variant? where T: VariantConvertible {
    return value.toVariant()
}

/// Internal API. Required for macros. Setter for @Export macro on non-Optional value.
@inline(__always)
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ propertyName: StaticString,
    _ property: inout T
) where T: VariantConvertible {
    guard let variantOrNil = arguments.first else {
        GD.printErr("Unable to set `\(propertyName)`, no arguments")
        return
    }

    guard let variant = variantOrNil else {
        GD.printErr("Unable to set `\(propertyName)`, argument is nil")
        return
    }

    guard let newValue = T.fromVariant(variant) else {
        GD.printErr("Unable to set `\(propertyName)`, argument is not \(T.self)")
        return
    }
    newValue._macroRcRef()
    property._macroRcUnref()
    property = newValue
}

/// Internal API. Required for macros. Setter for @Export macro on Optional value.
@inline(__always)
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ propertyName: StaticString,
    _ property: inout T?
) where T: VariantConvertible {
    guard let variantOrNil = arguments.first else {
        GD.printErr("Unable to set `\(propertyName)`, no arguments")
        return
    }

    guard let variant = variantOrNil else {
        property?._macroRcUnref()
        property = nil
        return
    }

    guard let newValue = T.fromVariant(variant) else {
        GD.printErr("Unable to set `\(propertyName)`, argument is not \(T.self)")
        return
    }
    newValue._macroRcRef()
    property?._macroRcUnref()
    property = newValue
}
