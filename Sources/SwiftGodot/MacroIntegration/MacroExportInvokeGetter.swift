//
//  MacroExportInvokeGetter.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 09/04/2025.
//

/// Internal API. Optional and non-optional VariantConvertible user types.
@inline(__always)
@inlinable
public func _invokeGetter<T>(_ value: T?) -> FastVariant? where T: VariantConvertible {
    value.toFastVariant()
}

/// Internal API.  OptionSet or enum with _GodotBridgeable RawValue
@inline(__always)
@inlinable
public func _invokeGetter<T>(
    _ value: T
) -> FastVariant? where T: RawRepresentable, T.RawValue: BinaryInteger, T.RawValue: VariantConvertible {
    value.rawValue.toFastVariant()
}

/// Internal API. Closure
@inline(__always)
@inlinable
public func _invokeGetter<each Argument: VariantConvertible, Result: VariantConvertible>(
    _ value: @escaping (repeat each Argument) -> Result
) -> FastVariant? {
    return Callable { arguments in
        do {
            var currentIndex = 0
            
            let result = try value(
                repeat (each Argument).fromArguments(arguments, incrementingIndex: &currentIndex)
            )
            
            return result.toVariant()
        } catch {
            GD.printErr("Couldn't extract arguments to call closure. \(error)")
            return nil
        }
    }.toFastVariant()
}

/// Internal API.  VariantCollection.
@inline(__always)
@inlinable
public func _invokeGetter<T>(
    _ value: VariantCollection<T>
) -> FastVariant? where T: _GodotBridgeableBuiltin {
    value.array.toFastVariant()
}


/// Internal API.  ObjectCollection.
@inline(__always)
@inlinable
public func _invokeGetter<T>(
    _ value: ObjectCollection<T>
) -> FastVariant? where T: Object {
    value.array.toFastVariant()
}

// MARK: Failures with diagnostics

/// Internal API.  Swift Array.
@available(*, unavailable, message: "Swift Array is not supported by @Export macro, use VariantCollection or ObjectCollection")
public func _invokeGetter<T>(
    _ value: [T]?
) -> FastVariant? {
    fatalError("Unreachable")
}

/// Internal API.  Optional VariantCollection.
@available(*, unavailable, message: "Optional VariantCollection is not supported by @Export macro")
public func _invokeGetter<T>(
    _ value: VariantCollection<T>?
) -> FastVariant? where T: _GodotBridgeableBuiltin {
    fatalError("Unreachable")
}

/// Internal API.  Optional ObjectCollection.
@available(*, unavailable, message: "Optional ObjectCollection is not supported by @Export macro")
public func _invokeGetter<T>(
    _ value: ObjectCollection<T>?
) -> FastVariant? where T: Object {
    fatalError("Unreachable")
}


/// Internal API.  Optional CaseIterable enum with BinaryInteger RawValue.
@available(*, unavailable, message: "Optional enums are not supported by @Export macro")
public func _invokeGetter<T>(
    _ value: T?
) -> FastVariant? where T: RawRepresentable, T.RawValue: BinaryInteger, T.RawValue: VariantConvertible {
    fatalError("Unreachable")
}

/// Internal API. Catch-all overload for all unsupported types.
@available(*, unavailable, message: "The type is not supported by @Export macro")
@_disfavoredOverload
public func _invokeGetter(_ value: (any Any)?) -> FastVariant? {
    fatalError("Unreachable")
}
