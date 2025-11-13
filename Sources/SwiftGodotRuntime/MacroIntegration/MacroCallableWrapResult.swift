//
//  MacroCallableWrapResult.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 11/04/2025.
//

/// Internal API. VariantConvertible.
@inline(__always)
@inlinable
public func _wrapCallableResult<T>(_ value: T) -> FastVariant? where T: VariantConvertible {
    value.toFastVariant()
}

/// Internal API. VariantConvertible?.
@inline(__always)
@inlinable
public func _wrapCallableResult<T>(_ value: T?) -> FastVariant? where T: VariantConvertible {
    value.toFastVariant()
}

/// Internal API. Object.
@inline(__always)
@inlinable
public func _wrapCallableResult<T>(_ value: T) -> FastVariant? where T: Object {
    value.toFastVariant()
}

/// Internal API. Object?.
@inline(__always)
@inlinable
public func _wrapCallableResult<T>(_ value: T?) -> FastVariant? where T: Object {
    value.toFastVariant()
}

/// Internal API. Variant
@inline(__always)
@inlinable
public func _wrapCallableResult(_ value: Variant) -> FastVariant? {
    return value.toFastVariant()
}

/// Internal API. Variant?
@inline(__always)
@inlinable
public func _wrapCallableResult(_ value: Variant?) -> FastVariant? {
    return value.toFastVariant()
}

/// Internal API. [Object]. It's the only case where non-optional object array can be used.
@inline(__always)
@inlinable
public func _wrapCallableResult<T>(_ value: [T]) -> FastVariant? where T: Object {
    (value as [T?]).toFastVariant()
}

/// Internal API. Void.
@inline(__always)
@inlinable
public func _wrapCallableResult(_ value: Void) -> FastVariant? {
    return nil
}

@available(*, unavailable, message: "Type cannot be returned from @Callable")
@_disfavoredOverload
public func _wrapCallableResult<T>(_ value: T?) -> FastVariant? {
    fatalError("Unreachable")
}
