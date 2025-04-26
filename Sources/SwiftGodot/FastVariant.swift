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
/// It doesn't require heap allocation but it's a move-only type so it's more cumbersome to work with.
/// This type is guaranteed to contain a non-nil Godot Variant payload.
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
    
    /// ### WARNING
    /// Delicate API
    ///
    /// Zero the `content` to avoid `variant_destroy` during `deinit`.
    ///
    /// Assumes that this ``FastVariant`` was either
    /// 1. constructed by ``init(unsafelyBorrowing:)``
    /// 2. has its ownership passed to Godot, for example in ``VariantArray.setFastVariant(_:at:)``
    @inline(__always)
    @inlinable
    consuming func unsafelyForget() {
        content = .zero
    }
    
    /// Initialize by requested an owned copy of the `VariantContent`. Fails if `VariantContent` represents Godot nil, or copied variant is a `nil` Variant for some reason.
    @inline(__always)
    @usableFromInline
    init?(copying copiedContent: VariantContent) {
        guard !copiedContent.isZero else {
            return nil
        }
        
        var content = VariantContent.zero
        withUnsafePointer(to: copiedContent) { pCopiedContent in
            gi.variant_new_copy(&content, pCopiedContent)
        }
        
        guard !content.isZero else {
            return nil
        }
        
        self.content = content
    }
        
    /// ### WARNING
    /// Delicate API.
    ///
    /// Temporarily borrows `VariantContent` owned by Godot
    /// to provide convenient API for extracting something from it.
    /// Fails if `VariantContent` represents Godot nil, or copied variant is a `nil` Variant for some reason.
    ///
    /// Only `borrowing` instance initalized this way is allowed in user world!
    /// Used in:
    /// ``Arguments``, ``VariantArray.withFastVariant(at:)``
    ///
    /// Call ``unsafelyForget()`` after you are done.
    @inline(__always)
    @usableFromInline
    init?(unsafelyBorrowing borrowedContent: VariantContent) {
        guard !borrowedContent.isZero else {
            return nil
        }
                
        content = borrowedContent
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
    
    /// Consumes ``FastVariant`` triggering its immediate destruction.
    public consuming func drop() {
        // `deinit` happens in the end of this scope due to `consuming`
    }
        
    deinit {
        var content = content
        if content.isZero {
            // Was consumed, or cleaned-up explicitly
            return
        }
                
        if !extensionInterface.variantShouldDeinit(content: &content) { return }
        gi.variant_destroy(&content)
    }
    
    /// Initialize ``FastVariant`` by wrapping ``Object``
    @inline(__always)
    public init(_ from: Object) {
        self.init(payload: from.pNativeObject, constructor: Object.variantFromSelf)
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
        self.init(payload: Int64(from), constructor: VariantGodotInterface.variantFromInt)
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
        self.init(payload: Double(from), constructor: VariantGodotInterface.variantFromDouble)
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
        self.init(payload: payload, constructor: VariantGodotInterface.variantFromBool)
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
    public init(_ from: String) {
        /// Avoid allocating `GString` wrapper at least
        var stringContent = GString.zero
        gi.string_new_with_utf8_chars(&stringContent, from)
        self.init(payload: stringContent, constructor: GodotInterfaceForString.variantFromSelf)
        GodotInterfaceForString.destructor(&stringContent)
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
        var ret = GDExtensionStringPtr(bitPattern: 0xdeaddead)
        gi.variant_stringify(&content, &ret)
        
        let str = stringFromGodotString(&ret)
        GodotInterfaceForString.destructor(&ret)
        return str ?? ""
    }
    
    /// Extract `T: Object` from this ``FastVariant?`` or return nil if unsucessful.
    @inline(__always)
    public func to<T>(_ type: T.Type = T.self) -> T? where T: Object {
        guard gtype == .object else {
            return nil
        }

        var pNativeObject: GDExtensionObjectPtr? = GDExtensionObjectPtr(bitPattern: 1)!
        constructType(into: &pNativeObject, constructor: Object.selfFromVariant)
        guard let pNativeObject else {
            return nil
        }
        let ret: T? = getOrInitSwiftObject(boundTo: pNativeObject, ownsRef: false)
        return ret
    }
    
    /// Extract `T` from this ``FastVariant`` or return nil if unsucessful.
    @inline(__always)
    @inlinable
    public func to<T>(_ type: T.Type = T.self) -> T? where T: VariantConvertible {
        type.fromFastVariant(self)
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

extension Optional where Wrapped == FastVariant, Wrapped: ~Copyable {
    /// Extract `T` from this ``FastVariant?`` or return nil if unsucessful.
    @inline(__always)
    @inlinable
    public func to<T>(_ type: T.Type = T.self) -> T? where T: VariantConvertible {
        type.fromFastVariant(self)
    }
    
    /// Extract `T: Object` from this ``FastVariant?`` or return nil if unsucessful.
    @inline(__always)
    @inlinable
    public func to<T>(_ type: T.Type = T.self) -> T? where T: Object {
        type.fromFastVariant(self)
    }
}
