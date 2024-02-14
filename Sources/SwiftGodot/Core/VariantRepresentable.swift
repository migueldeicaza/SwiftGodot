//
//  VariantRepresentable.swift
//
//
//  Created by Padraig O Cinneide on 2023-10-22.
//


/// Types that conform to VariantRepresentable can be stored directly in `Variant`
/// with no conversion.  These include all of the Variant types from Godot (for
/// example `GString`, `Rect`, `Plane`), Godot objects (those that subclass
/// SwiftGodot.Object) as well as the built-in Swift types UInt8, Int64 and Double.
/// 
/// They each map to a specific Variant.GType value.
///
/// If you want to make an additional type work with Variants that does not have a direct
/// GType, you should instead conform that type to `VariantStorable`.
public protocol VariantRepresentable: VariantStorable {
    /// The raw godot storage type
    static var godotType: Variant.GType { get }
    
    associatedtype VariantContent
    var content: VariantContent { get }
    
    /// Initializes a new instance
    init()
}

extension VariantRepresentable {
    public func toVariantRepresentable() -> Self { self }
}

extension VariantRepresentable where Self: Object {
    public init? (_ variant: Variant) {
        GD.printErr ("Attempted to initialize a new `\(Self.self)` with \(variant.description) but it is not possible to initialize a GodotObject in a Swift initializer. Instead, use `\(Self.self).makeOrUnwrap(variant)`.")
        return nil
    }
}

/// Structs and scalar types use their own layout for storage.
public protocol SelfVariantRepresentable: VariantRepresentable where VariantContent == Self {}

extension SelfVariantRepresentable {
    public var content: VariantContent { self }
    
    public init? (_ variant: Variant) {
        guard Self.godotType == variant.gtype else { return nil }
        self.init()
        
        withUnsafeMutablePointer(to: &self) { ptr in
            variant.toType(Self.godotType, dest: ptr)
        }
    }
}

/// Some of Godot's build-in classes use ContentType for storage.
/// This needs to be public because it affects their initialization, but
/// SwiftGodot users should never need to conform their types
/// to`ContentVariantRepresentable`.
public protocol ContentVariantRepresentable: VariantRepresentable {
    static var zero: VariantContent { get }
    
    init (content: VariantContent)
}

extension ContentVariantRepresentable {
    public init? (_ variant: Variant) {
        guard Self.godotType == variant.gtype else { return nil }
        
        var content = Self.zero
        withUnsafeMutablePointer(to: &content) { ptr in
            variant.toType(Self.godotType, dest: ptr)
        }
        
        self.init(content: content)
    }
}

extension UInt8: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .bool }
}

extension Int64: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .int }
}

extension Double: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .float }
}

extension Vector2: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .vector2 }
}

extension Vector2i: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .vector2i }
}

extension Rect2: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .rect2 }
}

extension Rect2i: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .rect2i }
}

extension Vector3: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .vector3 }
}

extension Vector3i: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .vector3i }
}

extension Transform2D: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .transform2d }
}

extension Vector4: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .vector4 }
}

extension Vector4i: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .vector4i }
}

extension Plane: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .plane }
}

extension Quaternion: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .quaternion }
}

extension AABB: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .aabb }
}

extension Basis: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .basis }
}

extension Transform3D: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .transform3d }
}

extension Projection: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .projection }
}

extension Color: SelfVariantRepresentable {
    public static var godotType: Variant.GType { .color }
}

extension GString: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .string }
}

extension NodePath: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .nodePath }
}

extension StringName: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .stringName }
}

extension RID: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .rid }
}

extension Callable: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .callable }
}

extension Signal: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .signal }
}

extension GDictionary: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .dictionary }
}

extension GArray: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .array }
}

extension PackedByteArray: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .packedByteArray }
}

extension PackedInt32Array: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .packedInt32Array }
}

extension PackedInt64Array: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .packedInt64Array }
}

extension PackedFloat32Array: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .packedFloat32Array }
}

extension PackedFloat64Array: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .packedFloat64Array }
}

extension PackedStringArray: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .packedStringArray }
}

extension PackedVector2Array: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .packedVector2Array }
}

extension PackedVector3Array: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .packedVector3Array }
}

extension PackedColorArray: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .packedColorArray }
}

extension Nil: ContentVariantRepresentable {
    public static var godotType: Variant.GType { .nil }
}

extension Object: VariantRepresentable {
    public typealias VariantContent = UnsafeRawPointer
    public static var godotType: Variant.GType { .object }
    public var content: UnsafeRawPointer { handle }
}
