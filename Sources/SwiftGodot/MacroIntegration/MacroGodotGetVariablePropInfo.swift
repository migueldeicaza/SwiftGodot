//
//  MacroGodotGet.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 10/04/2025.
//

/// Internal API. Builtin type.
@inline(__always)
@inlinable
public func _macroGodotGetVariablePropInfo<Root, T>(
    at keyPath: KeyPath<Root, T>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: _GodotBridgeable {
    T._macroGodotGetVariablePropInfo(
        name: name,
        userHint: userHint,
        userHintStr: userHintStr,
        userUsage: userUsage
    )
}

/// Internal API. Optional Builtin type. Facaded as Godot Variant, because Godot builtin types can't be nil, unlike objects.
@inline(__always)
@inlinable
public func _macroGodotGetVariablePropInfo<Root, T>(
    at keyPath: KeyPath<Root, T?>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: _GodotBridgeable {
    Variant._macroGodotGetVariablePropInfo(
        name: name,
        userHint: userHint,
        userHintStr: userHintStr,
        userUsage: userUsage
    )
}

// Add sane defaults if no explicit arguments were passed
@inline(__always)
@usableFromInline
func improveObjectVariablePropInfo<T>(
    objectType: T.Type = T.self,
    userHint: inout PropertyHint?,
    userHintStr: inout String?
) where T: Object {
    if objectType is Node.Type && userHint == nil && userHintStr == nil {
        userHint = .nodeType
        userHintStr = "\(T.self)"
    }
}

/// Internal API. Object.
@inline(__always)
@inlinable
public func _macroGodotGetVariablePropInfo<Root, T>(
    at keyPath: KeyPath<Root, T>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: Object {
    var userHint = userHint
    var userHintStr = userHintStr
    improveObjectVariablePropInfo(objectType: T.self, userHint: &userHint, userHintStr: &userHintStr)
    return T._macroGodotGetVariablePropInfo(
        name: name,
        userHint: userHint,
        userHintStr: userHintStr,
        userUsage: userUsage
    )
}

/// Internal API. Optional Object.
@inline(__always)
@inlinable
public func _macroGodotGetVariablePropInfo<Root, T>(
    at keyPath: KeyPath<Root, T?>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: Object {
    var userHint = userHint
    var userHintStr = userHintStr
    improveObjectVariablePropInfo(objectType: T.self, userHint: &userHint, userHintStr: &userHintStr)
    return T._macroGodotGetVariablePropInfo(        
        name: name,
        userHint: userHint,
        userHintStr: userHintStr,
        userUsage: userUsage
    )
}

/// Internal API. VariantCollection.
@inline(__always)
@inlinable
public func _macroGodotGetVariablePropInfo<Root, T>(
    at keyPath: KeyPath<Root, VariantCollection<T>>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: VariantStorable, T: _GodotBridgeable {
    VariantCollection<T>._macroGodotGetVariablePropInfo(
        name: name,
        userHint: userHint,
        userHintStr: userHintStr,
        userUsage: userUsage
    )
}

/// Internal API. ObjectCollection.
@inline(__always)
@inlinable
public func _macroGodotGetVariablePropInfo<Root, T>(
    at keyPath: KeyPath<Root, ObjectCollection<T>>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo where T: Object {
    ObjectCollection<T>._macroGodotGetVariablePropInfo(        
        name: name,
        userHint: userHint,
        userHintStr: userHintStr,
        userUsage: userUsage
    )
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
public func _macroGodotGetVariablePropInfo<Root, T>(
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
    
    return _macroGodotGetVariablePropInfoSimple(
        propertyType: .int,
        name: name,
        userHint: userHint,
        userHintStr: userHintStr,
        userUsage: userUsage
    )
}

@available(*, unavailable, message: "Type is not supported for @Export")
@_disfavoredOverload
public func _macroGodotGetVariablePropInfo<Root, T>(
    at keyPath: KeyPath<Root, T>,
    name: String,
    userHint: PropertyHint? = nil,
    userHintStr: String? = nil,
    userUsage: PropertyUsageFlags? = nil
) -> PropInfo {
    fatalError("Unreachable")
}
