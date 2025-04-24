//
//  TypedDictionary.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 24/04/2025.
//

/// This type represents typed Godot dictionary, such as `Dictionary[int, String]` or `Dictionary[String, Object]`.
///
/// In Swift it serves as a type-safe view into underlying ``VariantDictionary`` stored in `dictionary` property.
/// It guarantees that only `Key: Value` pairs are possible.
///
/// Both `Key` and `Value` reflect semantics of how Godot treats nullability.
/// Allowed types are:
/// 1. All builtin types such as ``Vector3``, ``VariantArray``,  etc.
/// 2. Optional `Object`-inherited classes. `Object?`, `Node?`, `Camera3D?`, etc.
/// 3. Swift `Variant?`
///
/// # Compilation troubleshooting
///
/// #### ❌ `Type 'YourType' does not conform to protocol '_GodotContainerTypingParameter'`
/// You used `YourType` as `Key` or `Value` generic parameter.
/// You should use `YourType?`.
/// Godot doesn't guarantee non-nullability of `ObjectType` keys or values.
///
/// #### ❌ `'TypedDictionary' requires that 'YourType' conform to '_GodotNullableBridgeable'`
/// You used `YourType?` as `Key` or `Value` generic parameter.
/// You should use `YourType` instead.
/// Godot guarantees non-nullability of `SomeType` when used as `Key` or `Value`.
public struct TypedDictionary<Key: _GodotContainerTypingParameter, Value: _GodotContainerTypingParameter>: CustomDebugStringConvertible, _GodotBridgeableBuiltin {
    public var debugDescription: String {
        dictionary.debugDescription
    }

    /// Reference to underlying `VariantDictionary` which is guaranteed to containing only `Key: Value` pairs.
    public let dictionary: VariantDictionary
    
    /// Check if `dictionary` is compatible with this generic instantiation
    @inline(__always)
    @usableFromInline
    static func isTypingCompatible(with dictionary: VariantDictionary) -> Bool {
        // Check that Key is compatible
        switch dictionary.keyTyping {
        case .builtin(let gtype):
            assert(gtype != .object)
            
            if gtype != Key._variantType {
                return false
            }
        case .object(let objectType):
            if objectType != Key._NonOptionalType.self {
                return false
            }
        }
        
        // Check that Value is compatible
        switch dictionary.valueTyping {
        case .builtin(let gtype):
            assert(gtype != .object)
            
            if gtype != Value._variantType {
                return false
            }
        case .object(let objectType):
            if objectType != Value._NonOptionalType.self {
                return false
            }
        }
        
        return true
    }
    
    init(takingOver content: VariantDictionary.ContentType) {
        self.init(from: VariantDictionary(takingOver: content))
    }
    
    /// Initialize ``TypedDictionary`` from existing ``VariantDictionary``.
    /// If ``VariantDictionary`` is typed and its type is exactly `Key`:`Value` the created instance will reference the same storage.
    /// If not, a new ``VariantDictionary`` to wrap will be created by following Godot rules of dictionary type narrowing:
    /// - If dictionary could be converted successfully - it returns a typed dictionary containing the same records.
    /// - If not - it returns an empty typed dictionary.
    /// See: ``VariantDictionary.init(base:keyType:keyClassName:keyScript:valueType:valueClassName:valueScript:)``
    @inline(__always)
    @inlinable
    public init(from dictionary: VariantDictionary) {
        if Self.isTypingCompatible(with: dictionary) {
            // wrap the existing storage
            self.dictionary = dictionary
        } else {
            self.dictionary = VariantDictionary(
                base: dictionary,
                keyType: Int32(Key._variantType.rawValue),
                keyClassName: Key._className,
                keyScript: nil,
                valueType: Int32(Value._variantType.rawValue),
                valueClassName: Value._className,
                valueScript: nil
            )
        }
    }
    
    // MARK: - _GodotBridgeable
    /// Initialze ``TypedDictionary`` from ``Variant``. Fails if `variant` doesn't contain ``TypedDictionary``
    @inline(__always)
    public init?(_ variant: Variant) {
        guard Self._variantType == variant.gtype else { return nil }
        var content = VariantDictionary.zero
        withUnsafeMutablePointer(to: &content) { pPayload in
            variant.constructType(into: pPayload, constructor: GodotInterfaceForDictionary.selfFromVariant)
        }
        self.init(takingOver: content)
    }
    
    /// Initialze ``TypedDictionary`` from ``Variant``. Fails if `variant` doesn't contain ``TypedDictionary`` or is `nil`
    @inline(__always)
    @inlinable
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }
    
    /// Initialze ``TypedDictionary`` from ``FastVariant``. Fails if `variant` doesn't contain ``TypedDictionary``
    @inline(__always)
    public init?(_ variant: borrowing FastVariant) {
        guard Self._variantType == variant.gtype else { return nil }
        var content = VariantDictionary.zero
        withUnsafeMutablePointer(to: &content) { pPayload in
            variant.constructType(into: pPayload, constructor: GodotInterfaceForDictionary.selfFromVariant)
        }
        self.init(takingOver: content)
    }
        
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        dictionary.toVariant()
    }
    
    @inline(__always)
    @inlinable
    public func toVariant() -> Variant {
        dictionary.toVariant()
    }
    
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toFastVariant() -> FastVariant? {
        dictionary.toFastVariant()
    }
    
    @inline(__always)
    @inlinable
    public func toFastVariant() -> FastVariant {
        dictionary.toFastVariant()
    }
    
    @inline(__always)
    @inlinable
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        let dictionary = try VariantDictionary.fromVariantOrThrow(variant)
        return Self(from: dictionary)
    }
    
    @inline(__always)
    @inlinable
    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
        let dictionary = try VariantDictionary.fromFastVariantOrThrow(variant)
        return Self(from: dictionary)
    }
    
    public static var _variantType: Variant.GType {
        .dictionary
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``TypedDictionary`` is used in API visible to Godot
    @inlinable
    @inline(__always)
    public static func _propInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        if Key._variantType == .nil && Value._variantType == .nil {
            // .nil means `Variant` in Godot in this context.
            // Godot will see `TypedDictionary<Variant?, Variant?>` as `Dictionary`.
            // While `Dictionary[Variant, Variant]` is an allowed GDScript statement,
            // get_property_list() still exposes a property having such type as `Dictionary` without a `DICTIONARY_TYPE` hint.
            PropInfo(
                propertyType: .dictionary,
                propertyName: StringName(name),
                className: "Dictionary",
                hint: hint ?? .none,
                hintStr: GString(hintStr ?? ""),
                usage: usage ?? .default
            )
        } else {
            PropInfo(
                propertyType: .dictionary,
                propertyName: StringName(name),
                className: StringName("Dictionary[\(Key._builtinOrClassName), \(Value._builtinOrClassName)]"),
                hint: hint ?? .dictionaryType,
                hintStr: GString(hintStr ?? "\(Key._builtinOrClassName);\(Value._builtinOrClassName)"),
                usage: usage ?? .default
            )
        }
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``TypedDictionary`` is used as a return value in API visible to Godot
    @inlinable
    @inline(__always)
    public static var _returnValuePropInfo: PropInfo {
        if Key._variantType == .nil && Value._variantType == .nil {
            // .nil means `Variant` in Godot in this context.
            // Godot will see `TypedDictionary<Variant?, Variant?>` as `Dictionary`.
            PropInfo(
                propertyType: .dictionary,
                propertyName: "",
                className: "Dictionary",
                hint: .none,
                hintStr: "",
                usage: .default
            )
        } else {
            PropInfo(
                propertyType: .dictionary,
                propertyName: "",
                className: StringName("Dictionary[\(Key._builtinOrClassName), \(Value._builtinOrClassName)]"),
                hint: .dictionaryType,
                hintStr: "\(Key._builtinOrClassName);\(Value._builtinOrClassName)",
                usage: .default
            )
        }
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``TypedDictionary`` is used as a function argument in API visible to Godot
    public static func _argumentPropInfo(name: String) -> PropInfo {
        if Key._variantType == .nil && Value._variantType == .nil {
            // .nil means `Variant` in Godot in this context.
            // Godot will see `TypedDictionary<Variant?, Variant?>` as `Dictionary`.
            PropInfo(
                propertyType: .dictionary,
                propertyName: StringName(name),
                className: "Dictionary",
                hint: .none,
                hintStr: "",
                usage: .default
            )
        } else {
            PropInfo(
                propertyType: .dictionary,
                propertyName: StringName(name),
                className: StringName("Dictionary[\(Key._builtinOrClassName), \(Value._builtinOrClassName)]"),
                hint: .dictionaryType,
                hintStr: "\(Key._builtinOrClassName);\(Value._builtinOrClassName)",
                usage: .default
            )
        }
    }
}

public extension Variant {
    /// Initialize ``Variant`` by wrapping ``TypedDictionary``
    convenience init<Key, Value>(_ from: TypedDictionary<Key, Value>) where Key: _GodotContainerTypingParameter, Value: _GodotContainerTypingParameter {
        self.init(from.dictionary)
    }
    
    /// Initialize ``Variant`` by wrapping ``TypedDictionary?``, fails if it's `nil`
    convenience init?<Key, Value>(_ from: TypedDictionary<Key, Value>?) where Key: _GodotContainerTypingParameter, Value: _GodotContainerTypingParameter {
        guard let from else {
            return nil
        }
        self.init(from)
    }
}

public extension FastVariant {
    /// Initialize ``FastVariant`` by wrapping ``TypedDictionary``
    init<Key, Value>(_ from: TypedDictionary<Key, Value>) where Key: _GodotContainerTypingParameter, Value: _GodotContainerTypingParameter {
        self.init(from.dictionary)
    }
    
    /// Initialize ``FastVariant`` by wrapping ``TypedDictionary?``, fails if it's `nil`
    init?<Key, Value>(_ from: TypedDictionary<Key, Value>?) where Key: _GodotContainerTypingParameter, Value: _GodotContainerTypingParameter {
        guard let from else {
            return nil
        }
        self.init(from)
    }
}
