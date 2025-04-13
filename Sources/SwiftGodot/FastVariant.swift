//
//  FastVariant.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 13/04/2025.
//

@_implementationOnly import GDExtension

/// 24-bytes payload of Godot Variant
@usableFromInline
struct VariantContent: Equatable {
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
    static var zero: VariantContent {
        .init(w0: 0, w1: 0, w2: 0)
    }
    
    @inline(__always)
    @inlinable
    var isZero: Bool {
        self == Self.zero
    }
}

/// Sibling of ``Variant`` for cases where performance is critical.
/// It's a zero-memory-overhead wrapper around actual 24-bytes `Variant` payload with added construction and cleanup semantics
/// It doesn't require heap allocation but it's a move-only type so it's more cumbersome.
/// This type is guaranteed to contain a non-nil Godot Variant payload in the context accessible to users of this type.
public struct FastVariant: ~Copyable {
    @usableFromInline
    var content: VariantContent
    
    /// Initialize ``FastVariant`` using inlinable payload or opaque handle managed by Builtin Type or Object.
    @inline(__always)
    @usableFromInline
    init<Payload>(
        payload: Payload,
        constructor: @convention(c) (
            /* pVariantContent */ UnsafeMutableRawPointer?,
            /* pPayload */ UnsafeMutableRawPointer?
        ) -> Void
    ) {
        var content = VariantContent.zero
        
        var payload = payload
        withUnsafeMutablePointer(to: &content) { pVariantContent in
            withUnsafeMutablePointer(to: &payload) { pPayload in
                constructor(pVariantContent, pPayload)
            }
        }
        
        self.content = content
    }
    
    /// Initialize `FastVariant` with raw `VariantContent`, assuming ownership over it. Fails if `VariantContent` represents Godot nil.
    /// Unlike `init(unsafeTakingOver: VariantContent)` this function can be safely executed in the context where `VariantContent` has
    /// external origin and can represent Godot nil.
    @inline(__always)
    @usableFromInline
    init?(takingOver content: VariantContent) {
        guard !content.isZero else {
            return nil
        }
        
        self.content = content
    }
    
    /// Initialize ``FastVariant`` with raw `VariantContent`, assuming ownership over it. Assumes `VariantContent` doesn't represent Godot nil.
    @inline(__always)
    @usableFromInline
    init(unsafeTakingOver content: VariantContent) {
        self.content = content
    }
    
    /// Create a copy of this ``FastVariant`` with a separate lifetime.
    @inline(__always)
    @inlinable
    public func copy() -> FastVariant {
        var newContent = VariantContent.zero
        
        withUnsafePointer(to: content) { src in
            gi.variant_new_copy(&newContent, src)
        }
        
        return FastVariant(unsafeTakingOver: newContent)
    }
    
    @inline(__always)
    @inlinable
    deinit {
        if content.isZero {
            // Was consumed
            return
        }
        
        var content = content
        if !extensionInterface.variantShouldDeinit(content: &content) { return }
        gi.variant_destroy(&content)
    }
    
    /// Initialize ``FastVariant`` by wrapping ``Object``
    @inline(__always)
    public init(_ from: Object) {
        self.init(payload: from.handle, constructor: Variant.variantFromObject)
    }
    
    /// Initialize ``FastVariant`` by wrapping ``Object?``, fails if it's `nil`
    @inline(__always)
    public init?(_ from: Object?) {
        guard let from else {
            return nil
        }
        self.init(from)
    }
    
    /// Initialize ``FastVariant`` by wrapping ``BinaryInteger``
    @inline(__always)
    public init(_ from: some BinaryInteger) {
        self.init(payload: Int64(from), constructor: Variant.variantFromInt)
    }
    
    /// Initialize ``FastVariant`` by wrapping ``BinaryInteger?``, fails if it's `nil`
    @inline(__always)
    @inlinable
    public init?(_ from: (some BinaryInteger)?) {
        guard let from else {
            return nil
        }
        self.init(from)
    }
    
    /// Initialize ``FastVariant`` by wrapping ``BinaryFloatingPoint``
    @inline(__always)
    public init(_ from: some BinaryFloatingPoint) {
        self.init(payload: Double(from), constructor: Variant.variantFromDouble)
    }
    
    /// Initialize ``FastVariant`` by wrapping ``BinaryFloatingPoint?``, fails if it's `nil`
    @inline(__always)
    @inlinable
    public init?(_ from: (some BinaryFloatingPoint)?) {
        guard let from else {
            return nil
        }
        self.init(from)
    }
    
    /// Initialize ``FastVariant`` by wrapping ``Bool``
    @inline(__always)
    public init(_ from: Bool) {
        let payload: GDExtensionBool = from ? 1 : 0
        self.init(payload: payload, constructor: Variant.variantFromBool)
    }
    
    /// Initialize ``FastVariant`` by wrapping ``Bool?``, fails if it's `nil`
    @inline(__always)
    @inlinable
    public init?(_ from: Bool?) {
        guard let from else {
            return nil
        }
        self.init(from)
    }
    
    /// Initialize ``FastVariant`` by wrapping ``String``
    @inline(__always)
    @inlinable
    public init(_ from: String) {
        self.init(GString(from))
    }
    
    /// Initialize ``FastVariant`` by wrapping ``String?``, fails if it's `nil`
    @inline(__always)
    @inlinable
    public init?(_ from: String?) {
        guard let from else {
            return nil
        }
        self.init(from)
    }
    
    /// This describes the type of the data wrapped by this variant
    public var gtype: Variant.GType {
        var content = content
        let rawValue = gi.variant_get_type(&content).rawValue
        
        guard let result = Variant.GType(rawValue: Int64(rawValue)) else {
            fatalError("Unknown GType with raw value \(rawValue).")
        }
        
        return result
    }
    
    /// String description of this ``FastVariant``
    public var description: String {
        var content = content
        var ret = GDExtensionStringPtr (bitPattern: 0xdeaddead)
        gi.variant_stringify (&content, &ret)
        
        let str = stringFromGodotString(&ret)
        GString.destructor (&ret)
        return str ?? ""
    }
    
    ///
    /// Attempts to cast the Variant into a SwiftGodot.Object, if the variant contains a value of type `.object`, then
    // this will return the object.  If the variant contains the nil value, or the content of the variant is not
    /// a `.object, the value `nil` is returned.
    ///
    /// - Parameter type: the desired type eg. `.asObject(Node.self)`
    /// - Returns: nil on error, or the type on success
    ///
    @inline(__always)
    public func to<T>(_ type: T.Type = T.self) -> T? where T: Object {
        guard gtype == .object else {
            return nil
        }

        var objectHandle: UnsafeRawPointer? = UnsafeRawPointer(bitPattern: 1)!
        constructType(into: &objectHandle, constructor: Variant.objectFromVariant)
        guard let objectHandle else {
            return nil
        }
        let ret: T? = lookupObject(nativeHandle: objectHandle, ownsRef: false)
        return ret
    }
    
    @inline(__always)
    @usableFromInline
    func constructType(
        into pPayload: UnsafeMutableRawPointer,
        constructor: @convention(c) (
            /* pPayload */ UnsafeMutableRawPointer?,
            /* pVariantContent */ UnsafeMutableRawPointer?
        ) -> Void
    ) {
        var content = content
        withUnsafeMutablePointer(to: &content) { pVariantContent in
            constructor(pPayload, pVariantContent)
        }
    }
}
