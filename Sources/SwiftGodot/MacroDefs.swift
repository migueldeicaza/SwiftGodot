//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 9/25/23.
//

#if !(os(Windows) && swift(<5.9.1))

/// Creates the definition for a Swift class to be surfaced to Godot.
///
/// This macro creates the required constructors that the SwiftGodot framework requires (the `init`, and the
/// `init(nativeHandle:)`) , ensures that both of those initialize the class if required, and registers
/// any `@Export` and `@Callable` methods for the class effectively surfacing properties and
/// methods to godot
///
@attached(member,
          names: named (_initializeClass), named(classInitializer), named (implementedOverrides))
public macro Godot() = #externalMacro(module: "SwiftGodotMacroLibrary", type: "GodotMacro")

/// Exposes the function to the Godot runtime
///
/// When this attribute is applied to a function, the function is exposed to the Godot engine, and it
/// can be called by scripts in other languages.
///
/// The parameters to the function must be parameters that can be wrapped in a ``Variant`` structure
@attached(peer, names: prefixed(_mproxy_))
public macro Callable() = #externalMacro(module: "SwiftGodotMacroLibrary", type: "GodotCallable")

/// Exposes a property or variable to the Godot runtime
///
/// When this attribute is applied to a variable or a computer property in a class, the values can be surfaced to the
/// Godot editor and can participate in Godot's serialization process.
///
/// The attribute can only be applied to properties and variables that can be stored in a Variant.
///
/// - Parameter hint: this is of type ``PropertyHint`` and can be used to tell the Godot editor the
/// kind of user interface experience to provide for this.  For example, a string can be a plain string, or a
/// multi-line property box, or it can represent a file.   This hint drives the experience in the editor
/// - Parameter hintStr: some of the hint types can use an additional configuration option as a string
/// and this is used for this.  For example the `.file` option can have a mask to select files, for example `"*.png"`
///
@attached(peer, names: prefixed(_mproxy_get_), prefixed(_mproxy_set_), arbitrary)
public macro Export(_ hint: PropertyHint = .none, _ hintStr: String? = nil) = #externalMacro(module: "SwiftGodotMacroLibrary", type: "GodotExport")

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
public macro initSwiftExtension(cdecl: String,
                                types: [Wrapped.Type] = []) = #externalMacro(module: "SwiftGodotMacroLibrary",
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


/// Low-level: A macro that automatically implements `init(nativeHandle:)` for nodes.
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

/// Defines a Godot signal on a class.
///
/// The `@Godot` macro will register any #signal defined signals so that they can be used in the editor.
///
/// Usage:
/// ```swift
/// @Godot class MyNode: Node2D {
///     #signal("game_started")
///     #signal("lives_changed", argument: ["new_lives_count", Int.self])
///
///     func startGame() {
///        emit(MyNode.gameStarted)
///        emit(MyNode.livesChanged, 5)
///     }
/// }
/// ```
///
/// - Parameter signalName: The name of the signal as registered to Godot.
/// - Parameter arguments: If the signal has arguments, they should be defined here as a dictionary of argument name to type. For
/// example, ["name" : String.self] declares that the signal takes one argument of string type. The argument name is provided to the godot
/// editor. Argument types are enforced on the `emit(signal:_argument)` method. Argument types must conform to GodotVariant.
@freestanding(declaration, names: arbitrary)
public macro signal(_ signalName: String, arguments: Dictionary<String, Any.Type> = [:]) = #externalMacro(module: "SwiftGodotMacroLibrary", type: "SignalMacro")

#endif
