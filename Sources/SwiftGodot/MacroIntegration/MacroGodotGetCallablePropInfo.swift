//
//  MacroGodotGetCallablePropInfo.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 11/04/2025.
//

/// This file contains the overloads for generating PropInfo in the context, where functions callable by Godot
/// are registered
/// `name` is optional in all overloads. If it's nil - the function is called for returned value `PropInfo`, if not - for argument and it contains argument name.


/// Internal API. Variant
@inline(__always)
@inlinable
public func _macroGodotGetCallablePropInfo(
    _ type: Variant.Type = Variant.self,
    name: String?
) {
    fatalError()
//    Variant._macroGodotGetPropInfo(
//        name: name,
//        userHint: nil,
//        userHintStr: nil,
//        userUsage: nil
//    )
}
