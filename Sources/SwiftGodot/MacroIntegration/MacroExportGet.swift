//
//  MacroExportGet.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 09/04/2025.
//

/// Internal API. Builtin type.
@inline(__always)
@inlinable
public func _macroExportGet<T>(_ value: T) -> Variant? where T: _GodotBridgeable {
    return value.toVariant()
}

/// Internal API. Optional builtin type.
@inline(__always)
@inlinable
public func _macroExportGet<T>(_ value: T?) -> Variant? where T: _GodotBridgeable {
    return value.toVariant()
}

/// Internal API. Object.
@inline(__always)
@inlinable
public func _macroExportGet<T>(_ value: T) -> Variant? where T: Object {
    return value.toVariant()
}

/// Internal API. Optional Object.
@inline(__always)
@inlinable
public func _macroExportGet<T>(_ value: T?) -> Variant? where T: Object {
    return value.toVariant()
}

/// Internal API.  CaseIterable enum with BinaryInteger RawValue.
@inline(__always)
@inlinable
public func _macroExportGet<T>(
    _ value: T
) -> Variant? where T: RawRepresentable, T: CaseIterable, T.RawValue: BinaryInteger {
    value.rawValue.toVariant()
}

/// Internal API.  VariantCollection.
@inline(__always)
@inlinable
public func _macroExportGet<T>(
    _ value: VariantCollection<T>
) -> Variant? where T: VariantStorable {
    value.array.toVariant()
}

/// Internal API.  ObjectCollection.
@inline(__always)
@inlinable
public func _macroExportGet<T>(
    _ value: ObjectCollection<T>
) -> Variant? where T: VariantStorable {
    value.array.toVariant()
}

// MARK: Failures with diagnostics

/// Internal API.  Swift Array.
@available(*, unavailable, message: "Swift arrays are not supported by @Export macro, use VariantCollection or ObjectCollection")
public func _macroExportGet<T>(
    _ value: [T]?
) -> Variant? where T: RawRepresentable, T: CaseIterable, T.RawValue: BinaryInteger {
    fatalError("Unreachable")
}

/// Internal API.  Optional VariantCollection.
@available(*, unavailable, message: "Optional VariantCollection is not supported by @Export macro")
public func _macroExportGet<T>(
    _ value: VariantCollection<T>?
) -> Variant? where T: VariantStorable {
    fatalError("Unreachable")
}

/// Internal API.  Optional ObjectCollection.
@available(*, unavailable, message: "Optional ObjectCollection is not supported by @Export macro")
public func _macroExportGet<T>(
    _ value: ObjectCollection<T>?
) -> Variant? where T: VariantStorable {
    fatalError("Unreachable")
}


/// Internal API.  Optional CaseIterable enum with BinaryInteger RawValue.
@available(*, unavailable, message: "Optional enums are not supported by @Export macro")
public func _macroExportGet<T>(
    _ value: T?
) -> Variant? where T: RawRepresentable, T: CaseIterable, T.RawValue: BinaryInteger {
    fatalError("Unreachable")
}

/// Internal API. Catch-all overload for all unsupported types.
@available(*, unavailable, message: "The type is not supported by @Export macro")
@_disfavoredOverload
public func _macroExportGet(_ value: (any Any)?) -> Variant? {
    fatalError("Unreachable")
}
