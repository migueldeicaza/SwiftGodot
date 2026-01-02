//
//  MacroGodotPropertyPropInfo.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 10/04/2025.
//

/// Internal API. Variant.
@inline(__always)
@inlinable
public func _propInfo<Root>(
    at keyPath: KeyPath<Root, Variant>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo {
    return Variant._propInfo(
        name: name,
        hint: userHint,
        hintStr: userHintStr,
        usage: userUsage
    )
}

/// Internal API. Optional Variant.
@inline(__always)
@inlinable
public func _propInfo<Root>(
    at keyPath: KeyPath<Root, Variant?>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo {
    return Variant._propInfo(
        name: name,
        hint: userHint,
        hintStr: userHintStr,
        usage: userUsage
    )
}

/// Internal API. VariantConvertible user type.
@inline(__always)
@inlinable
public func _propInfo<Root, T>(
    at keyPath: KeyPath<Root, T>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: VariantConvertible {
    return Variant._propInfo(
        name: name,
        hint: userHint,
        hintStr: userHintStr,
        usage: userUsage
    )
}

/// Internal API. Optional VariantConvertible user type.
@inline(__always)
@inlinable
public func _propInfo<Root, T>(
    at keyPath: KeyPath<Root, T?>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: VariantConvertible {
    return Variant._propInfo(
        name: name,
        hint: userHint,
        hintStr: userHintStr,
        usage: userUsage
    )
}

/// Internal API. Builtin type.
@inline(__always)
@inlinable
public func _propInfo<Root, T>(
    at keyPath: KeyPath<Root, T>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: _GodotBridgeableBuiltin {
    return T._propInfo(
        name: name,
        hint: userHint,
        hintStr: userHintStr,
        usage: userUsage
    )
}

func makeArrayHint<Element>(_ type: Element.Type) -> String where Element: _GodotContainerTypingParameter {
    let vt = Element._variantType

    switch Element._variantType {
    case .object:
        let className = Element._className
        if ClassDB.isParentClass(className, inherits: "Node") {
            return "\(vt.rawValue)/\(PropertyHint.nodeType.rawValue):\(className)"
        }
        if ClassDB.isParentClass(className, inherits: "Resource") {
            return "\(vt.rawValue)/\(PropertyHint.resourceType.rawValue):\(className)"
        }
        fallthrough
    default:
        // TODO: I would need to determine what kind of
        // thing the Element is: StringName or String could
        // use their own encodings.
        return "\(vt.rawValue)"
    }
}
/// Internal API. TypedArray of nullable (usually objects)
public func _propInfo<Root, Element>(
    at keyPath: KeyPath<Root, TypedArray<Element?>>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where Element: _GodotContainerTypingParameter {
    return TypedArray<Element?>._propInfo(
        name: name,
        hint: userHint ?? .arrayType,
        hintStr: userHintStr ?? makeArrayHint<Element>(Element.self),
        usage: userUsage
    )
}

/// Internal API. TypedArray non-nullablemake
public func _propInfo<Root, Element>(
    at keyPath: KeyPath<Root, TypedArray<Element>>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where Element: _GodotContainerTypingParameter {
    return TypedArray<Element>._propInfo(
        name: name,
        hint: userHint ?? .arrayType,
        hintStr: userHintStr ?? makeArrayHint<Element>(Element.self),
        usage: userUsage,
    )
}

/// Internal API. Optional Builtin type. Facaded as Godot Variant, because Godot builtin types can't be nil, unlike objects.
@inline(__always)
@inlinable

public func _propInfo<Root, T>(
    at keyPath: KeyPath<Root, T?>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: _GodotBridgeableBuiltin {
    return Variant._propInfo(
        name: name,
        hint: userHint,
        hintStr: userHintStr,
        usage: userUsage
    )
}

/// Internal API. Object.
@inline(__always)
@inlinable
public func _propInfo<Root, T>(
    at keyPath: KeyPath<Root, T>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: Object {
    let name = String(describing: T.self)
    if name == "Node" || ClassDB.isParentClass(StringName(name), inherits: "Node") {
        var hint = userHint
        var hintStr = userHintStr

        if hint == nil && hintStr == nil {
            hint = .nodeType
            hintStr = T._builtinOrClassName
        }
        return PropInfo(
            propertyType: T._variantType,
            propertyName: StringName(name),
            className: StringName(T._builtinOrClassName ?? ""),
            hint: hint ?? .none,
            hintStr: hintStr.map { GString($0) } ?? GString(),
            usage: userUsage ?? .default
        )
    } else {
        return T._propInfo(
            name: name,
            hint: userHint,
            hintStr: userHintStr,
            usage: userUsage
        )
    }
}

/// Internal API. Optional Object.
@inline(__always)
@inlinable
public func _propInfo<Root, T>(
    at keyPath: KeyPath<Root, T?>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: Object {
    let name = String(describing: T.self)
    if name == "Node" || ClassDB.isParentClass(StringName(name), inherits: "Node") {
        var hint = userHint
        var hintStr = userHintStr

        if hint == nil && hintStr == nil {
            hint = .nodeType
            hintStr = T._builtinOrClassName
        }
        return PropInfo(
            propertyType: T._variantType,
            propertyName: StringName(name),
            className: StringName(T._builtinOrClassName ?? ""),
            hint: hint ?? .none,
            hintStr: hintStr.map { GString($0) } ?? GString(),
            usage: userUsage ?? .default
        )
    }
    return T._propInfo(
        name: name,
        hint: userHint,
        hintStr: userHintStr,
        usage: userUsage
    )
}

/// Internal API. Closure.
@inline(__always)
@inlinable
public func _propInfo<Root, each Argument: VariantConvertible, Result: VariantConvertible>(
    at keyPath: KeyPath<Root, (repeat each Argument) -> Result>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo {
    Callable._propInfo(name: name, hint: userHint, hintStr: userHintStr, usage: userUsage)
}

@inline(__always)
@usableFromInline
func enumCasesHintStr<T>(_ type: T.Type = T.self) -> String
where T: RawRepresentable, T: CaseIterable, T.RawValue: BinaryInteger {
    type
        .allCases
        .map {
            "\($0):\($0.rawValue)"
        }
        .joined(separator: ",")
}

/// Internal API.  CaseIterable enum with BinaryInteger RawValue.
@inline(__always)
@inlinable
public func _propInfo<Root, T>(
    at keyPath: KeyPath<Root, T>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: RawRepresentable, T: CaseIterable, T.RawValue: BinaryInteger {
    var userHint = userHint
    var userHintStr = userHintStr

    if userHint == nil && userHintStr == nil {
        // QoL add it automatically
        userHint = .enum
        userHintStr = enumCasesHintStr(T.self)
    }
    
    return _propInfoDefault(
        propertyType: .int,
        name: name,
        hint: userHint,
        hintStr: userHintStr,
        usage: userUsage
    )
}

@available(*, unavailable, message: "Type is not supported for @Export")
@_disfavoredOverload
public func _propInfo<Root, T>(
    at keyPath: KeyPath<Root, T>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo {
    fatalError("Unreachable")
}

