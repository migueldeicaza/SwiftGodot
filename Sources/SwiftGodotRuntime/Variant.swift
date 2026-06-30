//
//  Variant.swift
//  SwiftGodot
//
//  The `Variant` type is a tagged Swift enum that stores a decoded Swift value
//  for every Godot Variant type. Marshaling to and from Godot's 24-byte ABI
//  representation (`VariantContent`) happens automatically and is never visible
//  in the public API: you construct cases with real Swift values and read them
//  back by pattern matching.
//
//  A Godot `nil` Variant is represented in Swift as `Optional<Variant>.none`,
//  so this enum never has a `.nil` case.
//

import GDExtension

/// The raw 24-byte payload of a Godot Variant. This is the ABI representation
/// used when talking to the engine; it is an internal implementation detail of
/// ``Variant`` and the generated marshaling code.
public struct VariantContent: Equatable {
    @inline(__always)
    @usableFromInline
    let w0: UInt64

    @inline(__always)
    @usableFromInline
    let w1: UInt64

    @inline(__always)
    @usableFromInline
    let w2: UInt64

    @inline(__always)
    @inlinable
    init(w0: UInt64, w1: UInt64, w2: UInt64) {
        self.w0 = w0
        self.w1 = w1
        self.w2 = w2
    }

    @inline(__always)
    @inlinable
    public static var zero: VariantContent {
        .init(w0: 0, w1: 0, w2: 0)
    }

    @inline(__always)
    public var isZero: Bool {
        w0 == 0 && w1 == 0 && w2 == 0
    }
}

/// Variant objects box almost any Godot engine datatype. Unlike the engine's
/// opaque representation, SwiftGodot's `Variant` is a tagged enum holding the
/// decoded Swift value directly, so you can switch over it exhaustively.
///
/// A Godot `nil` Variant maps to Swift `nil`, i.e. `Optional<Variant>.none`,
/// which is why there is no `.nil` case here.
public enum Variant {
    case bool(Bool)
    case int(Int)
    case float(Double)
    case string(String)
    case vector2(Vector2)
    case vector2i(Vector2i)
    case rect2(Rect2)
    case rect2i(Rect2i)
    case vector3(Vector3)
    case vector3i(Vector3i)
    case transform2d(Transform2D)
    case vector4(Vector4)
    case vector4i(Vector4i)
    case plane(Plane)
    case quaternion(Quaternion)
    case aabb(AABB)
    case basis(Basis)
    case transform3d(Transform3D)
    case projection(Projection)
    case color(Color)
    case stringName(StringName)
    case nodePath(NodePath)
    case rid(RID)
    case object(Object)
    case callable(Callable)
    case signal(Signal)
    case dictionary(VariantDictionary)
    case array(VariantArray)
    case packedByteArray(PackedByteArray)
    case packedInt32Array(PackedInt32Array)
    case packedInt64Array(PackedInt64Array)
    case packedFloat32Array(PackedFloat32Array)
    case packedFloat64Array(PackedFloat64Array)
    case packedStringArray(PackedStringArray)
    case packedVector2Array(PackedVector2Array)
    case packedVector3Array(PackedVector3Array)
    case packedColorArray(PackedColorArray)
    case packedVector4Array(PackedVector4Array)
}

// MARK: - Scalar and Object constructors

public extension Variant {
    /// Wrap a ``Bool``.
    init(_ value: Bool) { self = .bool(value) }

    /// Wrap any ``BinaryInteger`` (stored as a 64-bit Godot integer).
    init(_ value: some BinaryInteger) { self = .int(Int(value)) }

    /// Wrap any ``BinaryFloatingPoint`` (stored as a 64-bit Godot float).
    init(_ value: some BinaryFloatingPoint) { self = .float(Double(value)) }

    /// Wrap a ``String``.
    init(_ value: String) { self = .string(value) }

    /// Wrap an ``Object``.
    init(_ value: Object) { self = .object(value) }

    /// Wrap a ``Bool?``, fails if it's `nil`.
    init?(_ value: Bool?) { guard let value else { return nil }; self.init(value) }

    /// Wrap a ``BinaryInteger?``, fails if it's `nil`.
    init?(_ value: (some BinaryInteger)?) { guard let value else { return nil }; self.init(value) }

    /// Wrap a ``BinaryFloatingPoint?``, fails if it's `nil`.
    init?(_ value: (some BinaryFloatingPoint)?) { guard let value else { return nil }; self.init(value) }

    /// Wrap a ``String?``, fails if it's `nil`.
    init?(_ value: String?) { guard let value else { return nil }; self.init(value) }

    /// Wrap an ``Object?``, fails if it's `nil`.
    init?(_ value: Object?) { guard let value else { return nil }; self.init(value) }
}

// MARK: - Compatibility aliases

public extension Variant {
    /// The ABI representation type. Retained for compatibility with marshaling code.
    typealias ContentType = VariantContent

    /// A zeroed ``VariantContent``, which the engine interprets as a `nil` Variant.
    @inline(__always)
    static var zero: VariantContent {
        VariantContent.zero
    }
}

// MARK: - Type tag

public extension Variant {
    /// The Godot Variant type tag describing the data wrapped by this variant.
    var gtype: GType {
        switch self {
        case .bool: return .bool
        case .int: return .int
        case .float: return .float
        case .string: return .string
        case .vector2: return .vector2
        case .vector2i: return .vector2i
        case .rect2: return .rect2
        case .rect2i: return .rect2i
        case .vector3: return .vector3
        case .vector3i: return .vector3i
        case .transform2d: return .transform2d
        case .vector4: return .vector4
        case .vector4i: return .vector4i
        case .plane: return .plane
        case .quaternion: return .quaternion
        case .aabb: return .aabb
        case .basis: return .basis
        case .transform3d: return .transform3d
        case .projection: return .projection
        case .color: return .color
        case .stringName: return .stringName
        case .nodePath: return .nodePath
        case .rid: return .rid
        case .object: return .object
        case .callable: return .callable
        case .signal: return .signal
        case .dictionary: return .dictionary
        case .array: return .array
        case .packedByteArray: return .packedByteArray
        case .packedInt32Array: return .packedInt32Array
        case .packedInt64Array: return .packedInt64Array
        case .packedFloat32Array: return .packedFloat32Array
        case .packedFloat64Array: return .packedFloat64Array
        case .packedStringArray: return .packedStringArray
        case .packedVector2Array: return .packedVector2Array
        case .packedVector3Array: return .packedVector3Array
        case .packedColorArray: return .packedColorArray
        case .packedVector4Array: return .packedVector4Array
        }
    }
}

// MARK: - Low-level ABI helpers

/// Build an owned ``VariantContent`` from an inlinable payload or opaque handle
/// using one of Godot's `variant_from_type` constructors. The returned content
/// is owned by the caller and must be released with `gi.variant_destroy`.
@inline(__always)
@usableFromInline
func makeVariantContent<Payload>(
    payload: Payload,
    constructor: @convention(c) (
        /* pVariantContent */ UnsafeMutableRawPointer?,
        /* pPayload */ UnsafeMutableRawPointer?
    ) -> Void
) -> VariantContent {
    var content = VariantContent.zero
    var payload = payload
    withUnsafeMutablePointer(to: &content) { pContent in
        withUnsafeMutablePointer(to: &payload) { pPayload in
            constructor(pContent, pPayload)
        }
    }
    return content
}

// MARK: - Encoding (Swift -> ABI)

public extension Variant {
    /// Construct a freshly owned ``VariantContent`` representing this variant.
    /// The caller takes ownership and is responsible for releasing it with
    /// `gi.variant_destroy`.
    func makeContent() -> VariantContent {
        switch self {
        case .bool(let value):
            let payload: GDExtensionBool = value ? 1 : 0
            return makeVariantContent(payload: payload, constructor: VariantGodotInterface.variantFromBool)
        case .int(let value):
            return makeVariantContent(payload: Int64(value), constructor: VariantGodotInterface.variantFromInt)
        case .float(let value):
            return makeVariantContent(payload: value, constructor: VariantGodotInterface.variantFromDouble)
        case .string(let value):
            var stringContent = GString.zero
            gi.string_new_with_utf8_chars(&stringContent, value)
            let content = makeVariantContent(payload: stringContent, constructor: GodotInterfaceForString.variantFromSelf)
            GodotInterfaceForString.destructor(&stringContent)
            return content
        case .vector2(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForVector2.variantFromSelf)
        case .vector2i(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForVector2i.variantFromSelf)
        case .rect2(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForRect2.variantFromSelf)
        case .rect2i(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForRect2i.variantFromSelf)
        case .vector3(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForVector3.variantFromSelf)
        case .vector3i(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForVector3i.variantFromSelf)
        case .transform2d(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForTransform2D.variantFromSelf)
        case .vector4(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForVector4.variantFromSelf)
        case .vector4i(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForVector4i.variantFromSelf)
        case .plane(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForPlane.variantFromSelf)
        case .quaternion(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForQuaternion.variantFromSelf)
        case .aabb(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForAABB.variantFromSelf)
        case .basis(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForBasis.variantFromSelf)
        case .transform3d(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForTransform3D.variantFromSelf)
        case .projection(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForProjection.variantFromSelf)
        case .color(let value):
            return makeVariantContent(payload: value, constructor: GodotInterfaceForColor.variantFromSelf)
        case .stringName(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForStringName.variantFromSelf)
        case .nodePath(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForNodePath.variantFromSelf)
        case .rid(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForRID.variantFromSelf)
        case .object(let value):
            return makeVariantContent(payload: value.handle, constructor: Object.variantFromSelf)
        case .callable(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForCallable.variantFromSelf)
        case .signal(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForSignal.variantFromSelf)
        case .dictionary(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForDictionary.variantFromSelf)
        case .array(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForArray.variantFromSelf)
        case .packedByteArray(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForPackedByteArray.variantFromSelf)
        case .packedInt32Array(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForPackedInt32Array.variantFromSelf)
        case .packedInt64Array(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForPackedInt64Array.variantFromSelf)
        case .packedFloat32Array(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForPackedFloat32Array.variantFromSelf)
        case .packedFloat64Array(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForPackedFloat64Array.variantFromSelf)
        case .packedStringArray(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForPackedStringArray.variantFromSelf)
        case .packedVector2Array(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForPackedVector2Array.variantFromSelf)
        case .packedVector3Array(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForPackedVector3Array.variantFromSelf)
        case .packedColorArray(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForPackedColorArray.variantFromSelf)
        case .packedVector4Array(let value):
            return makeVariantContent(payload: value.content, constructor: GodotInterfaceForPackedVector4Array.variantFromSelf)
        }
    }

    /// Run `body` with a borrowed pointer to this variant's ABI content. The
    /// content is constructed on entry and destroyed on exit.
    @inline(__always)
    func withUnsafeContent<R>(_ body: (UnsafePointer<VariantContent>) -> R) -> R {
        var content = makeContent()
        defer { gi.variant_destroy(&content) }
        return withUnsafePointer(to: &content) { body($0) }
    }
}

public extension Optional where Wrapped == Variant {
    /// Construct a freshly owned ``VariantContent``; `nil` produces a zeroed
    /// (Godot `nil`) content. The caller owns the result.
    @inline(__always)
    func makeContent() -> VariantContent {
        self?.makeContent() ?? .zero
    }

    /// The ABI representation, where `nil` is a zeroed (Godot `nil`) content.
    @inline(__always)
    var content: VariantContent {
        makeContent()
    }
}

// MARK: - Decoding (ABI -> Swift)

public extension Variant {
    /// Decode a variant from a borrowed ``VariantContent``. The `content` is not
    /// consumed; ownership stays with the caller. Returns `nil` when the content
    /// represents a Godot `nil` Variant (or an Object that could not be surfaced).
    init?(borrowing content: VariantContent) {
        if content.isZero {
            return nil
        }

        var localContent = content
        let rawType = gi.variant_get_type(&localContent).rawValue
        guard let gtype = GType(rawValue: Int64(rawType)) else {
            fatalError("Unknown GType with raw value \(rawType).")
        }

        switch gtype {
        case .nil:
            return nil
        case .bool:
            var raw: GDExtensionBool = 0
            extractVariantContent(into: &raw, from: content, constructor: VariantGodotInterface.boolFromVariant)
            self = .bool(raw != 0)
        case .int:
            var raw: Int64 = 0
            extractVariantContent(into: &raw, from: content, constructor: VariantGodotInterface.intFromVariant)
            self = .int(Int(raw))
        case .float:
            var raw: Double = 0
            extractVariantContent(into: &raw, from: content, constructor: VariantGodotInterface.doubleFromVariant)
            self = .float(raw)
        case .string:
            var stringContent = GString.zero
            extractVariantContent(into: &stringContent, from: content, constructor: GodotInterfaceForString.selfFromVariant)
            let string = GString.toString(pContent: &stringContent)
            GodotInterfaceForString.destructor(&stringContent)
            self = .string(string)
        case .vector2:
            var value = Vector2()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForVector2.selfFromVariant)
            self = .vector2(value)
        case .vector2i:
            var value = Vector2i()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForVector2i.selfFromVariant)
            self = .vector2i(value)
        case .rect2:
            var value = Rect2()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForRect2.selfFromVariant)
            self = .rect2(value)
        case .rect2i:
            var value = Rect2i()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForRect2i.selfFromVariant)
            self = .rect2i(value)
        case .vector3:
            var value = Vector3()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForVector3.selfFromVariant)
            self = .vector3(value)
        case .vector3i:
            var value = Vector3i()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForVector3i.selfFromVariant)
            self = .vector3i(value)
        case .transform2d:
            var value = Transform2D()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForTransform2D.selfFromVariant)
            self = .transform2d(value)
        case .vector4:
            var value = Vector4()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForVector4.selfFromVariant)
            self = .vector4(value)
        case .vector4i:
            var value = Vector4i()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForVector4i.selfFromVariant)
            self = .vector4i(value)
        case .plane:
            var value = Plane()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForPlane.selfFromVariant)
            self = .plane(value)
        case .quaternion:
            var value = Quaternion()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForQuaternion.selfFromVariant)
            self = .quaternion(value)
        case .aabb:
            var value = AABB()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForAABB.selfFromVariant)
            self = .aabb(value)
        case .basis:
            var value = Basis()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForBasis.selfFromVariant)
            self = .basis(value)
        case .transform3d:
            var value = Transform3D()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForTransform3D.selfFromVariant)
            self = .transform3d(value)
        case .projection:
            var value = Projection()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForProjection.selfFromVariant)
            self = .projection(value)
        case .color:
            var value = Color()
            extractVariantContent(into: &value, from: content, constructor: GodotInterfaceForColor.selfFromVariant)
            self = .color(value)
        case .stringName:
            var handle = StringName.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForStringName.selfFromVariant)
            self = .stringName(StringName(takingOver: handle))
        case .nodePath:
            var handle = NodePath.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForNodePath.selfFromVariant)
            self = .nodePath(NodePath(takingOver: handle))
        case .rid:
            var handle = RID.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForRID.selfFromVariant)
            self = .rid(RID(takingOver: handle))
        case .object:
            var handle: GodotNativeObjectPointer? = GodotNativeObjectPointer(bitPattern: 1)!
            extractVariantContent(into: &handle, from: content, constructor: Object.selfFromVariant)
            guard let handle, let object: Object = getOrInitSwiftObject(nativeHandle: handle, ownership: .borrowed) else {
                return nil
            }
            self = .object(object)
        case .callable:
            var handle = Callable.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForCallable.selfFromVariant)
            self = .callable(Callable(takingOver: handle))
        case .signal:
            var handle = Signal.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForSignal.selfFromVariant)
            self = .signal(Signal(takingOver: handle))
        case .dictionary:
            var handle = VariantDictionary.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForDictionary.selfFromVariant)
            self = .dictionary(VariantDictionary(takingOver: handle))
        case .array:
            var handle = VariantArray.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForArray.selfFromVariant)
            self = .array(VariantArray(takingOver: handle))
        case .packedByteArray:
            var handle = PackedByteArray.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForPackedByteArray.selfFromVariant)
            self = .packedByteArray(PackedByteArray(takingOver: handle))
        case .packedInt32Array:
            var handle = PackedInt32Array.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForPackedInt32Array.selfFromVariant)
            self = .packedInt32Array(PackedInt32Array(takingOver: handle))
        case .packedInt64Array:
            var handle = PackedInt64Array.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForPackedInt64Array.selfFromVariant)
            self = .packedInt64Array(PackedInt64Array(takingOver: handle))
        case .packedFloat32Array:
            var handle = PackedFloat32Array.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForPackedFloat32Array.selfFromVariant)
            self = .packedFloat32Array(PackedFloat32Array(takingOver: handle))
        case .packedFloat64Array:
            var handle = PackedFloat64Array.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForPackedFloat64Array.selfFromVariant)
            self = .packedFloat64Array(PackedFloat64Array(takingOver: handle))
        case .packedStringArray:
            var handle = PackedStringArray.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForPackedStringArray.selfFromVariant)
            self = .packedStringArray(PackedStringArray(takingOver: handle))
        case .packedVector2Array:
            var handle = PackedVector2Array.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForPackedVector2Array.selfFromVariant)
            self = .packedVector2Array(PackedVector2Array(takingOver: handle))
        case .packedVector3Array:
            var handle = PackedVector3Array.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForPackedVector3Array.selfFromVariant)
            self = .packedVector3Array(PackedVector3Array(takingOver: handle))
        case .packedColorArray:
            var handle = PackedColorArray.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForPackedColorArray.selfFromVariant)
            self = .packedColorArray(PackedColorArray(takingOver: handle))
        case .packedVector4Array:
            var handle = PackedVector4Array.zero
            extractVariantContent(into: &handle, from: content, constructor: GodotInterfaceForPackedVector4Array.selfFromVariant)
            self = .packedVector4Array(PackedVector4Array(takingOver: handle))
        }
    }

    /// Decode a variant from a ``VariantContent`` that the caller owns, taking
    /// over its lifetime: the content is destroyed once the Swift value has been
    /// extracted. Returns `nil` for a Godot `nil` Variant.
    @_spi(SwiftGodotRuntimePrivate)
    public init?(takingOver content: consuming VariantContent) {
        guard let value = Variant(borrowing: content) else {
            if !content.isZero {
                gi.variant_destroy(&content)
            }
            return nil
        }
        gi.variant_destroy(&content)
        self = value
    }

    /// Decode a variant from a ``VariantContent`` that the caller continues to
    /// own (a copy is made internally). Returns `nil` for a Godot `nil` Variant.
    init?(copying content: borrowing VariantContent) {
        guard let value = Variant(borrowing: content) else {
            return nil
        }
        self = value
    }
}

/// Extract a content handle (the `ContentType` of a reference-backed builtin)
/// from a borrowed ``VariantContent`` into an already-allocated destination.
@inline(__always)
@usableFromInline
func extractVariantContent<T>(
    into destination: inout T,
    from content: VariantContent,
    constructor: @convention(c) (
        /* pPayload */ UnsafeMutableRawPointer?,
        /* pVariantContent */ UnsafeMutableRawPointer?
    ) -> Void
) {
    var content = content
    withUnsafeMutablePointer(to: &destination) { pDestination in
        withUnsafeMutablePointer(to: &content) { pContent in
            constructor(pDestination, pContent)
        }
    }
}

// MARK: - Object access

public extension Variant {
    /// Attempts to cast the variant into a `SwiftGodot.Object` of the requested
    /// type. Returns `nil` if the variant does not wrap an object, or wraps an
    /// object of an incompatible type.
    @inline(__always)
    func asObject<T: Object>(_ type: T.Type = T.self) -> T? {
        guard case .object(let object) = self else {
            return nil
        }
        return object as? T
    }
}

// MARK: - Equatable, Hashable, Description (native Swift)

extension Variant: Equatable {
    public static func == (lhs: Variant, rhs: Variant) -> Bool {
        switch (lhs, rhs) {
        case let (.bool(a), .bool(b)): return a == b
        case let (.int(a), .int(b)): return a == b
        case let (.float(a), .float(b)): return a == b
        case let (.string(a), .string(b)): return a == b
        case let (.vector2(a), .vector2(b)): return a == b
        case let (.vector2i(a), .vector2i(b)): return a == b
        case let (.rect2(a), .rect2(b)): return a == b
        case let (.rect2i(a), .rect2i(b)): return a == b
        case let (.vector3(a), .vector3(b)): return a == b
        case let (.vector3i(a), .vector3i(b)): return a == b
        case let (.transform2d(a), .transform2d(b)): return a == b
        case let (.vector4(a), .vector4(b)): return a == b
        case let (.vector4i(a), .vector4i(b)): return a == b
        case let (.plane(a), .plane(b)): return a == b
        case let (.quaternion(a), .quaternion(b)): return a == b
        case let (.aabb(a), .aabb(b)): return a == b
        case let (.basis(a), .basis(b)): return a == b
        case let (.transform3d(a), .transform3d(b)): return a == b
        case let (.projection(a), .projection(b)): return a == b
        case let (.color(a), .color(b)): return a == b
        case let (.stringName(a), .stringName(b)): return a == b
        case let (.nodePath(a), .nodePath(b)): return a == b
        case let (.rid(a), .rid(b)): return a == b
        case let (.object(a), .object(b)): return a === b
        case let (.callable(a), .callable(b)): return a == b
        case let (.signal(a), .signal(b)): return a == b
        case let (.dictionary(a), .dictionary(b)): return a == b
        case let (.array(a), .array(b)): return a == b
        case let (.packedByteArray(a), .packedByteArray(b)): return a == b
        case let (.packedInt32Array(a), .packedInt32Array(b)): return a == b
        case let (.packedInt64Array(a), .packedInt64Array(b)): return a == b
        case let (.packedFloat32Array(a), .packedFloat32Array(b)): return a == b
        case let (.packedFloat64Array(a), .packedFloat64Array(b)): return a == b
        case let (.packedStringArray(a), .packedStringArray(b)): return a == b
        case let (.packedVector2Array(a), .packedVector2Array(b)): return a == b
        case let (.packedVector3Array(a), .packedVector3Array(b)): return a == b
        case let (.packedColorArray(a), .packedColorArray(b)): return a == b
        case let (.packedVector4Array(a), .packedVector4Array(b)): return a == b
        default: return false
        }
    }
}

extension Variant: Hashable {
    public func hash(into hasher: inout Hasher) {
        // Combining `gtype` first keeps the hash consistent with `==`: equal
        // values always share a case, hence a tag, hence this prefix. Every
        // payload then contributes its real contents, each in the same terms its
        // `==` uses, so the hash is well distributed and stays consistent.
        hasher.combine(gtype)
        switch self {
        case .bool(let v): hasher.combine(v)
        case .int(let v): hasher.combine(v)
        case .float(let v): hasher.combine(v)
        case .string(let v): hasher.combine(v)
        case .vector2(let v): hasher.combine(v)
        case .vector2i(let v): hasher.combine(v)
        case .rect2(let v): hasher.combine(v)
        case .rect2i(let v): hasher.combine(v)
        case .vector3(let v): hasher.combine(v)
        case .vector3i(let v): hasher.combine(v)
        case .transform2d(let v): hasher.combine(v)
        case .vector4(let v): hasher.combine(v)
        case .vector4i(let v): hasher.combine(v)
        case .plane(let v): hasher.combine(v)
        case .quaternion(let v): hasher.combine(v)
        case .aabb(let v): hasher.combine(v)
        case .basis(let v): hasher.combine(v)
        case .transform3d(let v): hasher.combine(v)
        case .projection(let v): hasher.combine(v)
        case .color(let v): hasher.combine(v)
        case .stringName(let v): hasher.combine(v)
        case .nodePath(let v): hasher.combine(v)
        case .object(let v): hasher.combine(ObjectIdentifier(v))
        case .callable(let v): hasher.combine(v)
        case .dictionary(let v): hasher.combine(v)
        case .array(let v): hasher.combine(v)
        // `RID`'s content is its integer id — exactly what its `==` compares.
        case .rid(let v): hasher.combine(v.content)
        // `Signal`'s content is (objectId, internedName) — the pair its `==` compares.
        case .signal(let v):
            hasher.combine(v.content.0)
            hasher.combine(v.content.1)
        // Packed arrays compare element-wise. Hashing each element in Swift would
        // marshal every element across the boundary, so hash the buffer with
        // Godot's own variant hash instead — it runs in-engine and is consistent
        // with that equality.
        case .packedByteArray, .packedInt32Array, .packedInt64Array,
             .packedFloat32Array, .packedFloat64Array, .packedStringArray,
             .packedVector2Array, .packedVector3Array, .packedColorArray,
             .packedVector4Array:
            var content = makeContent()
            defer { gi.variant_destroy(&content) }
            hasher.combine(gi.variant_hash(&content))
        }
    }
}

extension Variant: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        // Delegate to Godot's `variant_stringify` so the textual form matches the
        // engine exactly (e.g. `(x, y, z)` for vectors, `[...]` for arrays).
        var content = makeContent()
        defer { gi.variant_destroy(&content) }
        var ret = GDExtensionStringPtr(bitPattern: 0xdeaddead)
        gi.variant_stringify(&content, &ret)
        let str = stringFromGodotString(&ret)
        GodotInterfaceForString.destructor(&ret)
        return str ?? ""
    }

    public var debugDescription: String {
        "\(gtype) [\(description)]"
    }
}

// MARK: - Engine operations (call, subscript, named access)

public extension Variant {
    enum VariantErrorType: Error {
        case notFound
    }

    /// Gets the value of a named key from a Variant.
    func getNamed(key: StringName) -> Result<Variant?, VariantErrorType> {
        var newContent = VariantContent.zero
        var valid: GDExtensionBool = 0

        withUnsafeContent { pSelf in
            var selfContent = pSelf.pointee
            gi.variant_get_named(&selfContent, &key.content, &newContent, &valid)
        }

        if valid != 0 {
            return .success(Variant(takingOver: newContent))
        } else {
            return .failure(.notFound)
        }
    }

    /// Invokes a variant's method by name.
    func call(method: StringName, _ arguments: Variant?...) -> Result<Variant?, CallErrorType> {
        var result = VariantContent.zero
        var selfContent = makeContent()
        defer { gi.variant_destroy(&selfContent) }
        var err = GDExtensionCallError()

        // Build owned contents for each argument, plus a pointer array into them.
        let argContents = arguments.map { $0.makeContent() }
        defer {
            for var content in argContents where !content.isZero {
                gi.variant_destroy(&content)
            }
        }

        argContents.withUnsafeBufferPointer { contentsBuffer in
            withUnsafeTemporaryAllocation(of: UnsafeRawPointer?.self, capacity: arguments.count) { pArgsBuffer in
                for i in 0..<arguments.count {
                    pArgsBuffer[i] = UnsafeRawPointer(contentsBuffer.baseAddress! + i)
                }
                gi.variant_call(&selfContent, &method.content, pArgsBuffer.baseAddress, Int64(arguments.count), &result, &err)
            }
        }

        if err.error != GDEXTENSION_CALL_OK {
            return .failure(toCallErrorType(err.error))
        }

        return .success(Variant(takingOver: result))
    }

    /// Constructs a new variant of the specified type using its default value.
    static func construct(type: Variant.GType) -> Result<Variant?, CallErrorType> {
        var newContent = VariantContent.zero
        var err = GDExtensionCallError()
        gi.variant_construct(GDExtensionVariantType(rawValue: GDExtensionVariantType.RawValue(type.rawValue)), &newContent, nil, 0, &err)
        if err.error != GDEXTENSION_CALL_OK {
            return .failure(toCallErrorType(err.error))
        }
        return .success(Variant(takingOver: newContent))
    }

    /// Gets the name of a Variant type.
    static func typeName(_ type: GType) -> String {
        let res = GString()
        gi.variant_get_type_name(GDExtensionVariantType(GDExtensionVariantType.RawValue(type.rawValue)), &res.content)
        let ret = GString.stringFromGStringPtr(ptr: &res.content)
        return ret ?? ""
    }

    /// Errors raised by the variant subscript.
    enum VariantIndexerError: Error, CustomDebugStringConvertible {
        case ok
        /// The variant is not an array.
        case invalidOperation
        /// The index is out of bounds.
        case outOfBounds

        public var debugDescription: String {
            switch self {
            case .ok: return "Success"
            case .invalidOperation: return "Attempt to use indexer methods in a variant that does not support it"
            case .outOfBounds: return "Index value was out of bounds"
            }
        }
    }

    /// Indexed access for variants that wrap arrays.
    ///
    /// The setter only has an observable effect for reference-backed variants
    /// (arrays, dictionaries, packed arrays), which share storage with the
    /// wrapped Swift value.
    subscript(index: Int) -> Variant? {
        get {
            var selfContent = makeContent()
            defer { gi.variant_destroy(&selfContent) }
            var result = VariantContent.zero
            var valid: GDExtensionBool = 0
            var oob: GDExtensionBool = 0

            gi.variant_get_indexed(&selfContent, Int64(index), &result, &valid, &oob)
            if valid == 0 || oob != 0 {
                return nil
            }
            return Variant(takingOver: result)
        }
        nonmutating set {
            guard let newValue else { return }
            var selfContent = makeContent()
            defer { gi.variant_destroy(&selfContent) }
            var valueContent = newValue.makeContent()
            defer { gi.variant_destroy(&valueContent) }
            var valid: GDExtensionBool = 0
            var oob: GDExtensionBool = 0
            gi.variant_set_indexed(&selfContent, Int64(index), &valueContent, &valid, &oob)
        }
    }

    /// Keyed access using a variant as the index.
    ///
    /// The setter only has an observable effect for reference-backed variants
    /// (arrays, dictionaries), which share storage with the wrapped Swift value.
    subscript(index: Variant) -> Variant? {
        get {
            var selfContent = makeContent()
            defer { gi.variant_destroy(&selfContent) }
            var newContent = VariantContent.zero
            var valid: GDExtensionBool = 0

            index.withUnsafeContent { pIndex in
                var indexContent = pIndex.pointee
                gi.variant_get(&selfContent, &indexContent, &newContent, &valid)
            }

            if valid != 0 {
                return Variant(takingOver: newContent)
            } else {
                return nil
            }
        }
        nonmutating set {
            var selfContent = makeContent()
            defer { gi.variant_destroy(&selfContent) }
            var indexContent = index.makeContent()
            defer { gi.variant_destroy(&indexContent) }
            var valueContent = newValue.makeContent()
            defer { gi.variant_destroy(&valueContent) }
            var valid: GDExtensionBool = 0
            gi.variant_set(&selfContent, &indexContent, &valueContent, &valid)
        }
    }
}

// MARK: - GType helpers

public extension Variant.GType {
    /// Internal API. Godot type name of the type with this variant tag.
    var _builtinOrClassName: String {
        switch self {
        case .nil:
            fatalError("Unreachable")
        case .bool: return "bool"
        case .int: return "int"
        case .float: return "float"
        case .string: return "String"
        case .vector2: return "Vector2"
        case .vector2i: return "Vector2i"
        case .rect2: return "Rect2"
        case .rect2i: return "Rect2i"
        case .vector3: return "Vector3"
        case .vector3i: return "Vector3i"
        case .transform2d: return "Transform2D"
        case .vector4: return "Vector4"
        case .vector4i: return "Vector4i"
        case .plane: return "Plane"
        case .quaternion: return "Quaternion"
        case .aabb: return "AABB"
        case .basis: return "Basis"
        case .transform3d: return "Transform3D"
        case .projection: return "Projection"
        case .color: return "Color"
        case .stringName: return "StringName"
        case .nodePath: return "NodePath"
        case .rid: return "RID"
        case .object:
            fatalError("Unreachable")
        case .callable: return "Callable"
        case .signal: return "Signal"
        case .dictionary: return "Dictionary"
        case .array: return "Array"
        case .packedByteArray: return "PackedByteArray"
        case .packedInt32Array: return "PackedInt32Array"
        case .packedInt64Array: return "PackedInt64Array"
        case .packedFloat32Array: return "PackedFloat32Array"
        case .packedFloat64Array: return "PackedFloat64Array"
        case .packedStringArray: return "PackedStringArray"
        case .packedVector2Array: return "PackedVector2Array"
        case .packedVector3Array: return "PackedVector3Array"
        case .packedColorArray: return "PackedColorArray"
        case .packedVector4Array: return "PackedVector4Array"
        }
    }
}
