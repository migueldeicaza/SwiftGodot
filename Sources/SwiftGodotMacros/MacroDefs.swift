//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 9/25/23.
//

import Foundation
import SwiftGodot

// MARK: - Freestanding Macros

/// A macro used to write an entrypoint for a Godot extension.
///
/// For example, to initialize a Swift extension to Godot with custom types:
/// ```swift
/// class MySprite: Sprite2D { ... }
/// class MyControl: Control { ... }
///
/// #initSwiftExtension(cdecl: "myextension_entry_point",
///                     types: [MySprite.self, MyControl.self])
/// ```
///
/// - Parameter cdecl: The name of the entrypoint exposed to C.
/// - Parameter types: The node types that should be registered with Godot.
@freestanding(declaration, names: named(enterExtension), named(setupExtension))
public macro initSwiftExtension<T: Wrapped>(cdecl: String,
                                            types: [T.Type]) = #externalMacro(module: "SwiftGodotMacroLibrary",
                                                                              type: "InitSwiftExtensionMacro")

/// A macro that instantiates a `Texture2D` from a specified resource path. If the texture cannot be created, a
/// `preconditionFailure` will be thrown.
///
/// Use this to quickly instantiate a `Texture2D`:
/// ```swift
/// func makeSprite() -> Sprite2D {
///     let sprite = Sprite2D()
///     sprite.texture = #texture2DLiteral("res://assets/playersprite.png")
/// }
/// ```
@freestanding(expression)
public macro texture2DLiteral(_ path: String) -> Texture2D = #externalMacro(module: "SwiftGodotMacroLibrary",
                                                                            type: "Texture2DLiteralMacro")

// MARK: - Attached Macros

/// A macro that enables an enumeration to be visible to the Godot editor.
///
/// Use this macro with `ClassInfo.registerEnum` to register this enumeration's visibility in the Godot editor.
///
/// ```swift
/// @PickerNameProvider
/// enum PlayerClass: Int {
///     case barbarian
///     case mage
///     case wizard
/// }
/// ```
///
/// - Important: The enumeration should have an `Int` backing to allow being represented as an integer value by Godot.
@attached(extension, conformances: CaseIterable, Nameable, names: named(name))
//@attached(member, names: named(name))
public macro PickerNameProvider() = #externalMacro(module: "SwiftGodotMacroLibrary", type: "PickerNameProviderMacro")


/// A macro that automatically implements `init(nativeHandle:)` for nodes.
///
/// Use this for a class that has a required initializer with an `UnsafeRawPointer`.
///
/// ```swift
/// @NativeHandleDiscarding
/// class MySprite: Sprite2D {
///     ...
/// }
/// ```
@attached(member, names: named(init(nativeHandle:)))
public macro NativeHandleDiscarding() = #externalMacro(module: "SwiftGodotMacroLibrary",
                                                       type: "NativeHandleDiscardingMacro")

/// A macro that finds and assigns a node from the scene tree to a stored property.
///
/// Use this to quickly assign a stored property to a node in the scene tree.
/// ```swift
/// class MyNode: Node2D {
///     @SceneTree(path: "Entities/Player")
///     var player: CharacterBody2D?
/// }
/// ```
///
/// - Important: This property will become a computed property, and it cannot be reassigned later.
@attached(accessor)
public macro SceneTree(path: String) = #externalMacro(module: "SwiftGodotMacroLibrary", type: "SceneTreeMacro")

// TODO: Add doc comments for these macros

@attached(member,
          names: named (init(nativeHandle:)), named (init()), named(_initClass), arbitrary)
public macro Godot() = #externalMacro(module: "SwiftGodotMacroLibrary", type: "GodotMacro")

@attached(peer, names: prefixed(_mproxy_))
public macro Callable() = #externalMacro(module: "SwiftGodotMacroLibrary", type: "GodotCallable")

@attached(peer, names: prefixed(_mproxy_get_), prefixed(_mproxy_set_), arbitrary)
public macro Export(_ hint: PropertyHint = .none, _ hintStr: String? = nil) = #externalMacro(module: "SwiftGodotMacroLibrary", type: "GodotExport")
