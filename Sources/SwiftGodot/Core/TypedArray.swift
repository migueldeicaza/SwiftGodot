//
//  TypedArray.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 20/04/2025.
//

@_implementationOnly import GDExtension

enum ArrayTyping {
    case untyped
    case builtin(Variant.GType)
    case object(Object.Type)
}

/// This type represents typed Godot array, such as `Array[int]` or `Array[Object]`.
public struct TypedArray<DeclaredElement>: CustomDebugStringConvertible, RandomAccessCollection where DeclaredElement: _GodotTypedArrayElement {
    public typealias Index = Int
    public typealias Element = DeclaredElement.ActualTypedArrayElement
    
    @usableFromInline
    let wrapped: VariantArray
        
    /// Initialize `TypedArray` from existing `VariantArray`.
    /// If `VariantArray` is typed and its type is compatible with `DeclaredElement` the created instance will reference the same storage.
    /// If not a new Array will be created by following Godot rules of array casting.
    /// If conversion fails - returns `nil`.
    public init?(from array: VariantArray) {
        fatalError()
    }
    
    public var debugDescription: String {
        wrapped.debugDescription
    }
    
    public var startIndex: Int {
        0
    }
    
    public var endIndex: Int {
        wrapped.count
    }
        
    public subscript(position: Int) -> Element {
        get {
            wrapped.withFastVariant(at: position) { variant in
                do {
                    return try Element.fromFastVariantOrThrow(variant)
                } catch {
                    fatalError("Fatal error during unwrapping \(Element.self) from \(wrapped.debugDescription) at index \(position). Type invariant violated. \(error)")
                }
            }
        }
        
        set {
            wrapped.setFastVariant(newValue.toFastVariant(), at: position)
        }
    }
    
    
    /// Con
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        wrapped.toVariant()
    }
    
    @inline(__always)
    @inlinable
    public func toVariant() -> Variant {
        wrapped.toVariant()
    }
    
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toFastVariant() -> FastVariant? {
        wrapped.toFastVariant()
    }
    
    @inline(__always)
    @inlinable
    public func toFastVariant() -> FastVariant {
        wrapped.toFastVariant()
    }
    
    @inline(__always)
    @inlinable
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        let array = try VariantArray.fromVariantOrThrow(variant)

        guard let result = Self(from: array) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        
        return result
    }
    
    @inline(__always)
    @inlinable
    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
        let array = try VariantArray.fromFastVariantOrThrow(variant)
        
        guard let result = Self(from: array) else {
            throw .unexpectedContent(parsing: self, from: variant)
        }
        
        return result
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``VariantCollection`` is used in API visible to Godot
    @inlinable
    @inline(__always)
    public static func _propInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        PropInfo(
            propertyType: .array,
            propertyName: StringName(name),
            className: StringName("Array[\(Element._godotTypeName)]"),
            hint: hint ?? .arrayType,
            hintStr: GString(hintStr ?? "\(Element._godotTypeName)"),
            usage: usage ?? .default
        )
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``VariantCollection`` is used in API visible to Godot
    @inlinable
    @inline(__always)
    public static var _returnValuePropInfo: PropInfo {
        PropInfo(
            propertyType: .array,
            propertyName: "",
            className: "Array[\(Element._godotTypeName)]",
            hint: .arrayType,
            hintStr: "\(Element._godotTypeName)",
            usage: .default
        )
    }
}

/// Internal API. Protocol intended for types that can be an element of typed Godot `Array`.
public protocol _GodotTypedArrayElement: _GodotBridgeable {
    /// Internal API.
    /// Actual element which is contained in the TypedArray.
    /// Godot has special treatment of `Object`-derived types and can't enforce them not being nullable.
    /// So `Array[Object]` is array of nullable objects.    
    associatedtype ActualTypedArrayElement: _GodotBridgeable
}

public extension _GodotTypedArrayElement where Self: _GodotOptionalBridgeable {
    /// Internal API.
    /// Actual collection element of `TypedArray<Element>` where `Element` is `_GodotOptionalBridgeable`, such as `Object`-derived, or `Variant` is `Element?`.
    /// This is merely a translation of Godot semantics into the Swift world.
    typealias ActualTypedArrayElement = Self?
}
