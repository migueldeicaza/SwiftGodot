//
//  TypedArray.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 15/04/2025.
//

/// Do not conform your type to this protocol.
/// This is a protocol for marking types that allow being an element of ``TypedArray``
///
/// This protocol is implemented by
/// 1. All Godot builtin types, such as `Vector3`, `GArray`, `AABB`, `Int` etc.
/// 2. All `Object`-derived types.
///
/// Note, that for `Object`-derived type all APIs will assume nullability of elements, Godot doesn't have a mechanism to enforce them being not null.
public protocol _GodotTypedArrayElement: _GodotBridgeable {
    associatedtype _ActualElement: _GodotBridgeable
    
    /// Internal API.
    static var _arrayClassName: String { get }
}

public protocol TypedArrayActualElement {
}

public extension _GodotTypedArrayElement where Self: Object {
    typealias _ActualElement = Self? // Possible due to _GodotOptionalBridgeable
    
    static var _arrayClassName: String { "\(self)" }
}

public extension _GodotTypedArrayElement where Self: _GodotBridgeableBuiltin {
    typealias _ActualElement = Self
    
    static var _arrayClassName: String { "" }
}

extension Bool: _GodotTypedArrayElement {}
extension String: _GodotTypedArrayElement {}

extension Int: _GodotTypedArrayElement {}
extension Int64: _GodotTypedArrayElement {}
extension Int32: _GodotTypedArrayElement {}
extension Int16: _GodotTypedArrayElement {}
extension Int8: _GodotTypedArrayElement {}

extension UInt: _GodotTypedArrayElement {}
extension UInt64: _GodotTypedArrayElement {}
extension UInt32: _GodotTypedArrayElement {}
extension UInt16: _GodotTypedArrayElement {}
extension UInt8: _GodotTypedArrayElement {}

extension Double: _GodotTypedArrayElement {}

/// TypedArray reflecting Godot syntax like `Array[int]`
/// This type follows semantics of Godot in terms on nullability, for example:
/// `TypedArray<Int>[0]` is `Int`
/// `TypedArray<Object>[0]` is `Object?`
public final class TypedArray<DeclaredElement>: GArray where DeclaredElement: _GodotTypedArrayElement {
    /// Alias for reflecting Godot nullability treatment
    /// `TypedArray<Int>[0]` is `Int`
    /// `TypedArray<Object>[0]` is `Object?`
    public typealias ActualElement = DeclaredElement._ActualElement
    
    /// Construct an empty ``TypedArray``.
    public convenience init(_ type: DeclaredElement.Type = DeclaredElement.self) {
        let baseArray = GArray()
        let type = Int32(DeclaredElement._variantType.rawValue)
        let className = StringName(DeclaredElement._arrayClassName)
        let scriptContent = Variant.zero
        
        var content = ContentType.zero
        withUnsafePointer(to: baseArray.content) { pArg0 in
            withUnsafePointer(to: type) { pArg1 in
                withUnsafePointer(to: className.content) { pArg2 in
                    withUnsafePointer(to: scriptContent) { pArg3 in
                        withUnsafePointer(to: UnsafeRawPointersN4(pArg0, pArg1, pArg2, pArg3)) { pArgs in
                            pArgs.withMemoryRebound(to: UnsafeRawPointer?.self, capacity: 4) { pArgs in
                                GArray.constructor2(&content, pArgs)
                            }
                        }
                    }
                }
            }
        }
        
        self.init(takingOver: content)
    }
    
    /// Construct a ``TypedArray``  from existing `array`.
    /// If it's already properly typed, the initialized instance will share the storage with `array`
    /// If it's not typed, the `array` will be converted on per-element basis as in
    /// `Array Array(base: Array, type: int, class_name: StringName, script: Variant)` from
    ///  https://docs.godotengine.org/en/stable/classes/class_array.html#constructor-descriptions
    public convenience init?(_ type: DeclaredElement.Type = DeclaredElement.self, from array: GArray) {
        if array.isTyped() {
            guard array.getTypedBuiltin() == type._variantType.rawValue else {
                return nil
            }
            
            guard array.getTypedClassName() == type._arrayClassName else {
                return nil
            }
            
            var content = ContentType.zero
            withUnsafePointer(to: array.content) { pArg0 in
                withUnsafePointer(to: UnsafeRawPointersN1(pArg0)) { pArgs in
                    pArgs.withMemoryRebound(to: UnsafeRawPointer?.self, capacity: 1) { pArgs in
                        GArray.constructor1(&content, pArgs)
                    }
                }
            }
            self.init(takingOver: content)
        } else {
            // see https://docs.godotengine.org/en/stable/classes/class_array.html#constructor-descriptions
            let type = Int32(DeclaredElement._variantType.rawValue)
            let className = StringName(DeclaredElement._arrayClassName)
            let scriptContent = Variant.zero
            
            var content = ContentType.zero
            withUnsafePointer(to: array.content) { pArg0 in
                withUnsafePointer(to: type) { pArg1 in
                    withUnsafePointer(to: className.content) { pArg2 in
                        withUnsafePointer(to: scriptContent) { pArg3 in
                            withUnsafePointer(to: UnsafeRawPointersN4(pArg0, pArg1, pArg2, pArg3)) { pArgs in
                                pArgs.withMemoryRebound(to: UnsafeRawPointer?.self, capacity: 4) { pArgs in
                                    GArray.constructor2(&content, pArgs)
                                }
                            }
                        }
                    }
                }
            }
            
            self.init(takingOver: content)
            
            /// Godot failed the conversion and returned an empty array as promised in doc, fail.
            if !array.isEmpty() && isEmpty() {
                return nil
            }
        }
    }
    
    override init(takingOver content: GArray.ContentType) {
        super.init(takingOver: content)
    }
    
    /// Initialze ``TypedArray`` from ``FastVariant``. Fails if `variant` doesn't contain compatible ``GArray``.
    @inline(__always)
    public required convenience init?(_ variant: borrowing FastVariant) {
        guard let array = GArray(variant) else {
            return nil
        }
        
        self.init(from: array)
    }
    
    /// Initialze ``TypedArray`` from ``Variant``. Fails if `variant` doesn't contain compatible ``GArray``.
    @inline(__always)
    @inlinable public required convenience init?(_ variant: Variant?) {
        guard let variant else {
            return nil
        }
        
        self.init(variant)
    }
    
    public required init(content proxyContent: ContentType) {
        super.init(content: proxyContent)
    }
    
    /// Initialze ``TypedArray`` from ``Variant``. Fails if `variant` doesn't contain compatible ``GArray``.
    @inline(__always)
    public required convenience init?(_ variant: Variant) {
        guard let array = GArray(variant) else {
            return nil
        }
        
        self.init(from: array)
    }
    
    /// Initialze ``TypedArray`` from ``FastVariant``. Fails if `variant` doesn't contain compatible ``GArray``.
    @inline(__always)
    @inlinable public required convenience init?(_ variant: borrowing FastVariant?) {
        switch variant {
        case .some(let variant):
            self.init(variant)
        case .none:
            return nil
        }
    }
}

public extension TypedArray where DeclaredElement: Object {
    /// ```
    /// let array: TypedArray<Node>
    /// array[0] // -> Node?
    /// ```
    subscript(index: Int) -> ActualElement {
        get {
            withFastVariant(at: index) { fastVariant in
                fastVariant.to(DeclaredElement.self)
            }
        }
        
        set {
            setFastVariant(newValue.toFastVariant(), at: index)
        }
    }
}

public extension TypedArray where DeclaredElement: VariantConvertible {
    /// ```
    /// let array: TypedArray<String>
    /// array[0] // -> String
    /// ```
    subscript(index: Int) -> DeclaredElement {
        get {
            let result = withFastVariant(at: index) { fastVariant in
                fastVariant.to(DeclaredElement.self)
            }
            
            guard let result else {
                let variant: Variant? = self[0]
                let description = variant?.description ?? "nil"
                fatalError("Couldn't unwrap \(DeclaredElement.self) from \(description) at index \(index) in TypedArray. Please, report it, it should never happen.")
            }
            
            return result
        }
        
        set {
            setFastVariant(newValue.toFastVariant(), at: index)
        }
    }
}
