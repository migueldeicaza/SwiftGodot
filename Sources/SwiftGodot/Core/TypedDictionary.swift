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
public struct TypedDictionary<Key: _GodotContainerTypingParameter, Value: _GodotContainerTypingParameter> {
    public let dictionary: VariantDictionary
    
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
}
