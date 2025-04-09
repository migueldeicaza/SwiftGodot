//
//  _macroExportSet.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 09/04/2025.
//

/// Internal API.  Builtin types.
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
    
    set(newValue)
    return nil
}

/// Internal API.  Optional builtin types.
@inline(__always)
@inlinable
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ name: StaticString,
    _ old: T?,
    _ set: (T?) -> Void
) -> Variant? where T: _GodotBridgeable {
    guard let variantOrNil = arguments.first else {
        GD.printErr("Unable to set `\(name)`, no arguments")
        return nil
    }

    guard let variant = variantOrNil else {
        set(nil)
        return nil
    }

    guard let newValue = T.fromVariant(variant) else {
        GD.printErr("Unable to set `\(name)`, argument is not \(T.self)")
        return nil
    }
    
    set(newValue)
    return nil
}

/// Internal API. Objects.
@inline(__always)
@inlinable
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ name: StaticString,
    _ old: T,
    _ set: (T) -> Void
) -> Variant? where T: Object {
    guard let variantOrNil = arguments.first else {
        GD.printErr("Unable to set `\(name)`, no arguments")
        return nil
    }

    guard let variant = variantOrNil else {
        GD.printErr("Unable to set `\(name)`, argument is nil")
        return nil
    }

    guard let newValue = T.fromVariant(variant) else {
        GD.printErr("Unable to set `\(name)`, can't unwrap \(T.self) from Variant")
        return nil
    }
    newValue._macroRcRef()
    old._macroRcUnref()
    set(newValue)
    return nil
}

/// Internal API. Optional Objects.
@inline(__always)
@inlinable
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ name: StaticString,
    _ old: T?,
    _ set: (T?) -> Void
) -> Variant? where T: Object {
    guard let variantOrNil = arguments.first else {
        GD.printErr("Unable to set `\(name)`, no arguments")
        return nil
    }

    guard let variant = variantOrNil else {
        GD.printErr("Unable to set `\(name)`, argument is nil")
        old?._macroRcUnref()
        set(nil)
        return nil
    }

    guard let newValue = T.fromVariant(variant) else {
        GD.printErr("Unable to set `\(name)`, can't unwrap \(T.self) from Variant")
        return nil
    }
    newValue._macroRcRef()
    old?._macroRcUnref()
    set(newValue)
    return nil
}

/// Internal API. VariantCollections.
@inline(__always)
@inlinable
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: VariantCollection<T>,
    _: (VariantCollection<T>) -> Void // ignored, old.array is reassigned
) -> Variant? where T: VariantStorable {
    _macroExportSetGArrayCollection(arguments, variableName, old)
}

/// Internal API. ObjectCollections.
@inline(__always)
@inlinable
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: ObjectCollection<T>,
    _: (ObjectCollection<T>) -> Void // ignored, old.array is reassigned
) -> Variant? where T: Object {
    _macroExportSetGArrayCollection(arguments, variableName, old)
}

@inline(__always)
@inlinable
func _macroExportSetGArrayCollection<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: T,
) -> Variant? where T: GArrayCollection {
    guard let variantOrNil = arguments.first else {
        GD.printErr("Unable to set `\(variableName)`, no arguments")
        return nil
    }

    guard let variant = variantOrNil else {
        GD.printErr("Unable to set `\(variableName)`, argument is `nil`")
        return nil
    }
    guard let newArray = GArray(variant) else {
        GD.printErr("Unable to set `\(variableName)`, argument is not Array. ")
        return nil
    }
    
    guard newArray.isSameTyped(array: old.array) else {
        let oldType = Variant.GType(rawValue: old.array.getTypedBuiltin()) ?? .nil
        let newType = Variant.GType(rawValue: newArray.getTypedBuiltin()) ?? .nil
        GD.printErr("Unable to set `\(variableName)`, incompatible types: old - \(oldType), new - \(newType)")
        return nil
    }
    
    old.array = newArray
    
    return nil
}

/// Internal API. Catch-all-overload for optional unsupported types.
@available(*, unavailable, message: "The type is not supported by @Export macro")
@_disfavoredOverload
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: T?,
    _ set: (T?) -> Void
) -> Variant? {
    fatalError("Unreachable")
}

/// Internal API. Catch-all-overload for unsupported types.
@available(*, unavailable, message: "The type is not supported by @Export macro")
@_disfavoredOverload
public func _macroExportSet<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: T,
    _ set: (T) -> Void
) -> Variant? {
    fatalError("Unreachable")
}
