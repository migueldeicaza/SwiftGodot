//
//  _macroExportSet.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 09/04/2025.
//

/// Internal API. Required for macros.
@inline(__always)
@inlinable
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ name: StaticString,
    _ old: T,
    _ set: (T) -> Void
) -> Variant? where T: _GodotBridgeable {
    guard let variantOrNil = arguments.first else {
        GD.printErr("Unable to set `\(name)`, no arguments")
        return nil
    }

    guard let variant = variantOrNil else {
        GD.printErr("Unable to set `\(name)`, argument is nil")
        return nil
    }

    guard let newValue = T.fromVariant(variant) else {
        GD.printErr("Unable to set `\(name)`, argument is not \(T.self)")
        return nil
    }
    newValue._macroRcRef()
    old._macroRcUnref()
    set(newValue)
    return nil
}

/// Internal API. Required for macros.
@inline(__always)
@inlinable
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ propertyName: StaticString,
    _ old: T?,
    _ set: (T?) -> Void
) -> Variant? where T: _GodotBridgeable {
    guard let variantOrNil = arguments.first else {
        GD.printErr("Unable to set `\(propertyName)`, no arguments")
        return nil
    }

    guard let variant = variantOrNil else {
        old?._macroRcUnref()
        set(nil)
        return nil
    }

    guard let newValue = T.fromVariant(variant) else {
        GD.printErr("Unable to set `\(propertyName)`, argument is not \(T.self)")
        return nil
    }
    newValue._macroRcRef()
    old?._macroRcUnref()
    set(newValue)
    return nil
}

/// Internal API. Required for macros.
@available(*, unavailable, message: "The type is not supported by @Export macro")
@_disfavoredOverload
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ propertyName: StaticString,
    _ old: T?,
    _ set: (T?) -> Void
) -> Variant? {
    fatalError("Unreachable")
}

/// Internal API. Required for macros.
@available(*, unavailable, message: "The type is not supported by @Export macro")
@_disfavoredOverload
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ propertyName: StaticString,
    _ old: T,
    _ set: (T) -> Void
) -> Variant? {
    fatalError("Unreachable")
}
