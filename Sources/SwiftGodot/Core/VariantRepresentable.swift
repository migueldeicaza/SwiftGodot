////
////  VariantRepresentable.swift
////
////
////  Created by Padraig O Cinneide on 2023-10-22.
////
//
//
///// Types that conform to VariantRepresentable can be stored directly in `Variant`
///// with no conversion.  These include all of the Variant types from Godot (for
///// example `GString`, `Rect`, `Plane`), Godot objects (those that subclass
///// SwiftGodot.Object) as well as the built-in Swift types UInt8, Int64 and Double.
///// 
///// They each map to a specific Variant.GType value.
/////
///// If you want to make an additional type work with Variants that does not have a direct
///// GType, you should instead conform that type to `VariantStorable`.
//public protocol VariantRepresentable: VariantStorable {
//    /// The raw godot storage type
//    static var godotType: Variant.GType { get }
//    
//    associatedtype VariantContent
//    var content: VariantContent { get }
//    
//    /// Initializes a new instance
//    init()
//}
//
//extension VariantRepresentable {
//    public func toVariantRepresentable() -> Self { self }
//}
//
//extension VariantRepresentable where Self: Object {
//    public init? (_ variant: Variant) {
//        GD.printErr ("Attempted to initialize a new `\(Self.self)` with \(variant.description) but it is not possible to initialize a SwiftGodot.Object in a Swift initializer. Instead, use `\(Self.self).unwrap(from: variant)`.")
//        return nil
//    }
//}
//
///// Structs and scalar types use their own layout for storage.
//public protocol SelfVariantRepresentable: VariantRepresentable where VariantContent == Self {}
//
//extension SelfVariantRepresentable {
//    public var content: VariantContent { self }
//    
//    public init? (_ variant: Variant) {
//        guard Self.godotType == variant.gtype else { return nil }
//        self.init()
//        
//        withUnsafeMutablePointer(to: &self) { ptr in
//            variant.toType(Self.godotType, dest: ptr)
//        }
//    }
//}
//
///// Some of Godot's builtin classes use ContentType for storage.
///// This needs to be public because it affects their initialization, but
///// SwiftGodot users should never need to conform their types
///// to`ContentVariantRepresentable`.
//public protocol ContentVariantRepresentable: VariantRepresentable {
//    static var zero: VariantContent { get }
//    
//    init (takingOver: VariantContent)
//}
//
//extension ContentVariantRepresentable {
//    public init? (_ variant: Variant) {
//        guard Self.godotType == variant.gtype else { return nil }
//        
//        var content = Self.zero
//        withUnsafeMutablePointer(to: &content) { ptr in
//            // This copies the builtin's content out of the Variant and increments its internal retain count (if it has one).
//            variant.toType(Self.godotType, dest: ptr)
//        }
//        
//        self.init(takingOver: content)
//    }
//}
//
//extension UInt8: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .bool }
//}
//
//extension Int64: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .int }
//}
//
//extension Double: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .float }
//}
//
//extension Vector2: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .vector2 }
//    /// Attempts to initialize a Vector2 from the provided optional Variant, fails if the Variant is nil or not a Vector2.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Vector2(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Vector2i: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .vector2i }
//    /// Attempts to initialize a Vector2i from the provided optional Variant, fails if the Variant is nil or not a Vector2i.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Vector2i(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Rect2: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .rect2 }
//    /// Attempts to initialize a Rect2 from the provided optional Variant, fails if the Variant is nil or not a Rect2.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Rect2(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Rect2i: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .rect2i }
//    /// Attempts to initialize a Rect2i from the provided optional Variant, fails if the Variant is nil or not a Rect2i.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Rect2i(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Vector3: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .vector3 }
//    /// Attempts to initialize a Vector3 from the provided optional Variant, fails if the Variant is nil or not a Vector3.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Vector3(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Vector3i: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .vector3i }
//    /// Attempts to initialize a Vector3i from the provided optional Variant, fails if the Variant is nil or not a Vector3i.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Vector3i(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Transform2D: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .transform2d }
//    /// Attempts to initialize a Transform2D from the provided optional Variant, fails if the Variant is nil or not a Transform2D.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Transform2D(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Vector4: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .vector4 }
//    /// Attempts to initialize a Vector4 from the provided optional Variant, fails if the Variant is nil or not a Vector4.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Vector4(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Vector4i: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .vector4i }
//    /// Attempts to initialize a Vector4i from the provided optional Variant, fails if the Variant is nil or not a Vector4i.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Vector4i(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Plane: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .plane }
//    /// Attempts to initialize a Plane from the provided optional Variant, fails if the Variant is nil or not a Plane.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Plane(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Quaternion: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .quaternion }
//    /// Attempts to initialize a Quaternion from the provided optional Variant, fails if the Variant is nil or not a Quaternion.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Quaternion(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension AABB: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .aabb }
//    /// Attempts to initialize a AABB from the provided optional Variant, fails if the Variant is nil or not a AABB.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = AABB(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Basis: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .basis }
//    /// Attempts to initialize a Basis from the provided optional Variant, fails if the Variant is nil or not a Basis.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Basis(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Transform3D: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .transform3d }
//    /// Attempts to initialize a Transform3D from the provided optional Variant, fails if the Variant is nil or not a Transform3D.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Transform3D(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Projection: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .projection }
//    /// Attempts to initialize a Projection from the provided optional Variant, fails if the Variant is nil or not a Projection.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Projection(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Color: SelfVariantRepresentable {
//    public static var godotType: Variant.GType { .color }
//    /// Attempts to initialize a Color from the provided optional Variant, fails if the Variant is nil or not a Color.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Color(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension GString: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .string }
//    /// Attempts to initialize a GString from the provided optional Variant, fails if the Variant is nil or not a GString.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = GString(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension NodePath: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .nodePath }
//    /// Attempts to initialize a NodePath from the provided optional Variant, fails if the Variant is nil or not a NodePath.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = NodePath(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension StringName: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .stringName }
//    /// Attempts to initialize a StringName from the provided optional Variant, fails if the Variant is nil or not a StringName.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = StringName(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension RID: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .rid }
//    /// Attempts to initialize a RID from the provided optional Variant, fails if the Variant is nil or not a RID.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = RID(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Callable: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .callable }
//    /// Attempts to initialize a Callable from the provided optional Variant, fails if the Variant is nil or not a Callable.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Callable(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Signal: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .signal }
//    /// Attempts to initialize a Signal from the provided optional Variant, fails if the Variant is nil or not a Signal.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = Signal(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension GDictionary: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .dictionary }
//    /// Attempts to initialize a GDictionary from the provided optional Variant, fails if the Variant is nil or not a GDictionary.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = GDictionary(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension GArray: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .array }
//    /// Attempts to initialize a GArray from the provided optional Variant, fails if the Variant is nil or not a GArray.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = GArray(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension PackedByteArray: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .packedByteArray }
//    /// Attempts to initialize a PackedByteArray from the provided optional Variant, fails if the Variant is nil or not a PackedByteArray.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = PackedByteArray(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension PackedInt32Array: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .packedInt32Array }
//    /// Attempts to initialize a PackedInt32Array from the provided optional Variant, fails if the Variant is nil or not a PackedInt32Array.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = PackedInt32Array(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension PackedInt64Array: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .packedInt64Array }
//    /// Attempts to initialize a PackedInt64Array from the provided optional Variant, fails if the Variant is nil or not a PackedInt64Array.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = PackedInt64Array(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension PackedFloat32Array: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .packedFloat32Array }
//    /// Attempts to initialize a PackedFloat32Array from the provided optional Variant, fails if the Variant is nil or not a PackedFloat32Array.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = PackedFloat32Array(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension PackedFloat64Array: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .packedFloat64Array }
//    /// Attempts to initialize a PackedFloat64Array from the provided optional Variant, fails if the Variant is nil or not a PackedFloat64Array.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = PackedFloat64Array(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension PackedStringArray: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .packedStringArray }
//    /// Attempts to initialize a PackedStringArray from the provided optional Variant, fails if the Variant is nil or not a PackedStringArray.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = PackedStringArray(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension PackedVector2Array: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .packedVector2Array }
//    /// Attempts to initialize a PackedVector2Array from the provided optional Variant, fails if the Variant is nil or not a PackedVector2Array.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = PackedVector2Array(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension PackedVector3Array: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .packedVector3Array }
//    /// Attempts to initialize a PackedVector3Array from the provided optional Variant, fails if the Variant is nil or not a PackedVector3Array.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = PackedVector3Array(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension PackedVector4Array: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .packedVector4Array }
//    /// Attempts to initialize a PackedVector4Array from the provided optional Variant, fails if the Variant is nil or not a PackedVector4Array.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = PackedVector4Array(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension PackedColorArray: ContentVariantRepresentable {
//    public static var godotType: Variant.GType { .packedColorArray }
//    /// Attempts to initialize a PackedColorArray from the provided optional Variant, fails if the Variant is nil or not a PackedColorArray.
//    ///
//    /// Useful when you want to initialize a type from what could be a nil value, for example:
//    /// ```
//    /// func tryMe(_ args: [Variant?]) {
//    ///    for arg in args {
//    ///          guard let myvalue = PackedColorArray(args[0]) else { return }
//    ///          // Operate on `myvalue`
//    /// }
//    /// ```
//    public convenience init? (_ variant: Variant?) {
//        guard let variant else { return nil }
//        self.init(variant)
//    }
//}
//
//extension Object: VariantRepresentable {
//    public typealias VariantContent = UnsafeRawPointer?
//    public static var godotType: Variant.GType { .object }
//    public var content: UnsafeRawPointer? { handle }
//}
