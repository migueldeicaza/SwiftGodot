//
//  MacroCallableToVariant.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 11/04/2025.
//

/// Internal API. Bridgeable.
@inline(__always)
@inlinable
public func _macroCallableToVariant<T>(_ value: T) -> Variant? where T: VariantConvertible {
    value.toVariant()
}

/// Internal API. Optional Bridgeable.
@inline(__always)
@inlinable
public func _macroCallableToVariant<T>(_ value: T?) -> Variant? where T: VariantConvertible {
    value.toVariant()
}

/// Internal API. Variant or Variant?
@inline(__always)
@inlinable
public func _macroCallableToVariant(_ value: Variant?) -> Variant? {
    return value
}

/// Internal API. Swift Array.
@inline(__always)
@inlinable
public func _macroCallableToVariant<T>(_ value: [T]) -> Variant? where T: _GodotBridgeable {
    let array = GArray(T.self)
    for element in value {
        array.append(element.toVariant())
    }
    
    return array.toVariant()
}

/// Internal API. ObjectCollection.
@inline(__always)
@inlinable
public func _macroCallableToVariant<T>(_ value: ObjectCollection<T>) -> Variant? where T: _GodotBridgeable {
    value.array.toVariant()
}

/// Internal API. VariantCollection.
@inline(__always)
@inlinable
public func _macroCallableToVariant<T>(_ value: VariantCollection<T>) -> Variant? where T: _GodotBridgeable {
    value.array.toVariant()
}

/// Internal API. Void.
@inline(__always)
@inlinable
public func _macroCallableToVariant(_ value: Void) -> Variant? {
    return nil
}

@available(*, unavailable, message: "Type cannot be returned from @Callable")
@_disfavoredOverload
public func _macroCallableToVariant<T>(_ value: T?) -> Variant? {
    fatalError("Unreachable")
}
