//
//  MacroCallableWrapResult.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 11/04/2025.
//

/// Internal API. VariantConvertible.
@inline(__always)
@inlinable
public func _wrapCallableResult<T>(_ value: T) -> Variant? where T: VariantConvertible {
    value.toVariant()
}

/// Internal API. VariantConvertible?.
@inline(__always)
@inlinable
public func _wrapCallableResult<T>(_ value: T?) -> Variant? where T: VariantConvertible {
    value.toVariant()
}

@inline(__always)
@inlinable
public func _wrapCallableResult<T>(_ value: T) -> Variant? where T: RawRepresentable, T.RawValue == Int {
    value.toVariant()
}

@inline(__always)
@inlinable
public func _wrapCallableResult<T>(_ value: T) -> Variant? where T: RawRepresentable, T.RawValue == Int64 {
    value.toVariant()
}

/// Internal API. Object.
@inline(__always)
@inlinable
public func _wrapCallableResult<T>(_ value: T) -> Variant? where T: Object {
    value.toVariant()
}

/// Internal API. Object?.
@inline(__always)
@inlinable
public func _wrapCallableResult<T>(_ value: T?) -> Variant? where T: Object {
    value.toVariant()
}

/// Internal API. Variant
@inline(__always)
@inlinable
public func _wrapCallableResult(_ value: Variant) -> Variant? {
    value
}

/// Internal API. Variant?
@inline(__always)
@inlinable
public func _wrapCallableResult(_ value: Variant?) -> Variant? {
    value
}

/// Internal API. [Object]. It's the only case where non-optional object array can be used.
@inline(__always)
@inlinable
public func _wrapCallableResult<T>(_ value: [T]) -> Variant? where T: Object {
    (value as [T?]).toVariant()
}

/// Internal API. Void.
@inline(__always)
@inlinable
public func _wrapCallableResult(_ value: Void) -> Variant? {
    return nil
}

@available(*, unavailable, message: "Type cannot be returned from @Callable")
@_disfavoredOverload
public func _wrapCallableResult<T>(_ value: T?) -> Variant? {
    fatalError("Unreachable")
}

/// Internal API. Wraps a `@Callable` parameter's default value into a `Variant?` suitable for
/// method registration. A `nil` result represents a Godot `nil` default argument.
@inline(__always)
@inlinable
public func _wrapDefaultArgument(_ value: Variant?) -> Variant? {
    value
}
