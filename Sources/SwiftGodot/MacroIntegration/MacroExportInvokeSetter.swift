//
//  MacroExportInvokeSetter.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 09/04/2025.
//

/// Internal API. VariantConvertible.
@inline(__always)
@inlinable
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ name: StaticString,
    _ old: T,
    _ set: (T) -> Void
) where T: VariantConvertible {
    do {
        set(try arguments.argument(ofType: T.self, at: 0))
    } catch {
        GD.printErr("\(error.description)")
    }
}

/// Internal API. Optional VariantConvertible.
@inline(__always)
@inlinable
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ name: StaticString,
    _ old: T?,
    _ set: (T?) -> Void
) where T: VariantConvertible {
    do {
        let variantOrNil = try arguments.argument(ofType: Variant?.self, at: 0)
        
        guard let variant = variantOrNil else {
            // Expected nil, set to nil
            set(nil)
            return
        }
                
        let value = try T.fromVariantOrThrow(variant)
        set(value)
    } catch let error as ArgumentAccessError {
        GD.printErr(error.description)
    } catch let error as VariantConversionError {
        GD.printErr(error.description)
    } catch {
        GD.printErr("\(error)")
    }
}

/// Internal API. Variant.
@inline(__always)
@inlinable
public func _invokeSetter(
    _ arguments: borrowing Arguments,
    _ name: StaticString,
    _ old: Variant,
    _ set: (Variant) -> Void
) {
    do {
        set(try arguments.argument(ofType: Variant.self, at: 0))
    } catch {
        GD.printErr("\(error.description)")
    }
}

/// Internal API. Variant?.
@inline(__always)
@inlinable
public func _invokeSetter(
    _ arguments: borrowing Arguments,
    _ name: StaticString,
    _ old: Variant?,
    _ set: (Variant?) -> Void
) {
    do {
        set(try arguments.argument(ofType: Variant?.self, at: 0))
    } catch {
        GD.printErr("\(error.description)")
    }
}

/// Internal API. Object.
@inline(__always)
@inlinable
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ name: StaticString,
    _ old: T,
    _ set: (T) -> Void
) where T: Object {
    do {
        let value = try arguments.argument(ofType: T.self, at: 0)
        value._macroRcRef()
        set(value)
        old._macroRcUnref()
    } catch {
        GD.printErr("\(error.description)")
    }
}

/// Internal API. Object?.
@inline(__always)
@inlinable
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ name: StaticString,
    _ old: T?,
    _ set: (T?) -> Void
) where T: Object {
    do {
        let variantOrNil = try arguments.argument(ofType: Variant?.self, at: 0)
        
        guard let variant = variantOrNil else {
            // Expected nil, set to nil
            old?._macroRcUnref()
            set(nil)
            return
        }
                
        let value = try T.fromVariantOrThrow(variant)
        value._macroRcRef()
        set(value)
        old?._macroRcUnref()
    } catch let error as ArgumentAccessError {
        GD.printErr(error.description)
    } catch let error as VariantConversionError {
        GD.printErr(error.description)
    } catch {
        GD.printErr("\(error)")
    }
}



@inline(__always)
@inlinable
func proxyClosureViaCallable<each Argument: VariantConvertible, Result: VariantConvertible>(
    _ callable: Callable
) -> (repeat each Argument) -> Result {
    return { (arguments: repeat each Argument) -> Result in
        let array = GArray()
            
        repeat array.append((each arguments).toVariant())
        
        do {
            return try Result.fromVariantOrThrow(callable.callv(arguments: array))
        } catch {
            // TODO: consider adding some API to construct fallback value for VariantConvertible for cases like this
            fatalError("Failed to proxy Callable: \(error). Unable to convert resulting Variant back to expected Swift type '\(Result.self)'.")
        }
    }
}

/// Internal API.  Closure.
@inline(__always)
@inlinable
public func _invokeSetter<each Argument: VariantConvertible, Result: VariantConvertible>(
    _ arguments: borrowing Arguments,
    _ name: StaticString,
    _ old: @escaping (repeat each Argument) -> Result,
    _ set: (@escaping (repeat each Argument) -> Result) -> Void
) {
    do {
        let newCallable = try arguments.argument(ofType: Callable.self, at: 0)
        
        set(proxyClosureViaCallable(newCallable))
    } catch {
        GD.printErr(error.description)
    }
}

/// Internal API. VariantCollections.
@inline(__always)
@inlinable
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: VariantCollection<T>,
    _: (VariantCollection<T>) -> Void // ignored, old.array is reassigned
) where T: _GodotBridgeableBuiltin {
    _invokeSetterGArrayCollection(arguments, variableName, old)
}

/// Internal API. ObjectCollections.
@inline(__always)
@inlinable
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: ObjectCollection<T>,
    _: (ObjectCollection<T>) -> Void // ignored, old.array is reassigned
) where T: Object {
    _invokeSetterGArrayCollection(arguments, variableName, old)
}

@inline(__always)
@inlinable
func _invokeSetterGArrayCollection<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ collection: T
) where T: GArrayCollection, T.Element: _GodotBridgeable {
    do {
        let newArray = try arguments.argument(ofType: GArray.self, at: 0)
        guard newArray.isSameTyped(array: collection.array) else {
            let oldType = Variant.GType(rawValue: collection.array.getTypedBuiltin()) ?? .nil
            let newType = Variant.GType(rawValue: newArray.getTypedBuiltin()) ?? .nil
            GD.printErr("Unable to set `\(variableName)`, incompatible types: old - \(oldType), new - \(newType)")
            return
        }
        collection.array = newArray
        return
    } catch {
        GD.printErr(error.description)
    }
}

/// Internal API. RawRepresentable with VariantConvertible RawValue
@inline(__always)
@inlinable
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ name: StaticString,
    _ old: T,
    _ set: (T) -> Void
) where T: RawRepresentable, T.RawValue: VariantConvertible {
    do {
        let value = try arguments.argument(ofType: T.self, at: 0)
        set(value)
    } catch {
        GD.printErr(error.description)
    }
}

// MARK: Failures with diagnostics

/// Internal API. Optional VariantCollection.
@available(*, unavailable, message: "The Optional VariantCollection is not supported by @Export macro")
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: VariantCollection<T>?,
    _: (VariantCollection<T>?) -> Void // ignored, old.array is reassigned
) where T: _GodotBridgeableBuiltin {
    fatalError("Unreachable")
}

/// Internal API. Optional ObjectCollection.
@available(*, unavailable, message: "The Optional ObjectCollection is not supported by @Export macro")
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: ObjectCollection<T>?,
    _: (ObjectCollection<T>?) -> Void // ignored, old.array is reassigned
) where T: Object {
    fatalError("Unreachable")
}

/// Internal API. Swift Array.
@available(*, unavailable, message: "Swift Array is not supported by @Export macro, use VariantCollection or ObjectCollection")
@_disfavoredOverload
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: [T]?,
    _ set: ([T]?) -> Void
) {
    fatalError("Unreachable")
}

/// Internal API. Swift Array.
@available(*, unavailable, message: "Swift Array is not supported by @Export macro, use VariantCollection or ObjectCollection")
@_disfavoredOverload
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: [T],
    _ set: ([T]) -> Void
) {
    fatalError("Unreachable")
}

/// Internal API. Catch-all-overload for optional unsupported types.
@available(*, unavailable, message: "The type is not supported by @Export macro")
@_disfavoredOverload
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: T?,
    _ set: (T?) -> Void
) {
    fatalError("Unreachable")
}

/// Internal API. Catch-all-overload for unsupported types.
@available(*, unavailable, message: "The type is not supported by @Export macro")
@_disfavoredOverload
public func _invokeSetter<T>(
    _ arguments: borrowing Arguments,
    _ variableName: StaticString,
    _ old: T,
    _ set: (T) -> Void
) {
    fatalError("Unreachable")
}
