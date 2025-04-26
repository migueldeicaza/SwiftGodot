//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/24/23.
//

@_implementationOnly import GDExtension

/// Variant objects box various Godot Objects, you create them with one of the
/// constructors, and you can retrieve the contents using the various extension
/// constructors that are declared on the various types that are wrapped.
///
/// You can retrieve the type of a variant from the ``gtype`` property.
///
/// A Variant takes up only 24 bytes and can store almost any engine datatype
/// inside of it. Variants are rarely used to hold information for long periods of
/// time. Instead, they are used mainly for communication, editing, serialization and
/// moving data around.
///
/// A Variant:
/// - Can store almost any Godot engine datatype.
/// - Can perform operations between many variants. GDScript uses Variant as its atomic/native datatype.
/// - Can be hashed, so it can be compared to other variants.
/// - Can be used to convert safely between datatypes.
/// - Can be used to abstract calling methods and their arguments. Godot exports all its functions through variants.
/// - Can be used to defer calls or move data between threads.
/// - Can be serialized as binary and stored to disk, or transferred via network.
/// - Can be serialized to text and use it for printing values and editable settings.
/// - Can work as an exported property, so the editor can edit it universally.
/// - Can be used for dictionaries, arrays, parsers, etc.
///
/// > Note: Containers (``VariantArray`` and ``VariantDictionary``): Both are implemented using variants.
/// A ``VariantDictionary`` can match any datatype used as key to any other datatype.  An ``VariantArray``
/// just holds an array of Variants.  A ``Variant`` can also hold a ``VariantDictionary`` and an ``VariantArray``
/// inside.
///
/// Modifications to a container will modify all references to it.

public final class Variant: Hashable, Equatable, CustomDebugStringConvertible, _GodotBridgeable, _GodotNullableBridgeable {
    public typealias TypedArrayElement = Variant?
    
    @usableFromInline
    typealias ContentType = VariantContent
    
    @usableFromInline
    var content = Variant.zero
    
    static var zero: ContentType {
        VariantContent.zero
    }
    
    /// Initializes from the raw contents of another Variant, this will make a copy of the variant contents
    @usableFromInline
    init?(copying otherContent: ContentType) {
        if otherContent == Variant.zero { return nil }
        
        withUnsafePointer(to: otherContent) { src in
            gi.variant_new_copy(&content, src)
        }

        extensionInterface.variantInited(variant: self, content: &content)
    }
    
    /// Initialize with existing `ContentType` assuming this ``Variant`` owns it since now. Fails if `content` represents Godot Nil.
    init?(takingOver otherContent: ContentType) {
        if otherContent == Variant.zero { return nil }
        
        content = otherContent

        extensionInterface.variantInited(variant: self, content: &content)
    }
    
    /// Initialize ``Variant`` by consuming ``FastVariant``
    @inline(__always)
    public init(takingOver fastVariant: consuming FastVariant) {
        content = fastVariant.content
        
        // avoid double destroy after `fastVariant` goes out of scope
        fastVariant.content = .zero
    }
    
    /// Initialize ``Variant`` by consuming ``FastVariant?``. Fails if `fastVariant` is nil.
    @inline(__always)
    @inlinable
    public convenience init?(takingOver fastVariant: consuming FastVariant?) {
        guard let fastVariant else {
            return nil
        }
        
        self.init(takingOver: fastVariant)
    }

    deinit {
        if !extensionInterface.variantShouldDeinit(content: &content) { return }
        gi.variant_destroy (&content)
        extensionInterface.variantDeinited(variant: self, content: &content)
    }
    
    /// Compares two variants, does this by delegating the comparison to Godot
    public static func == (lhs: Variant, rhs: Variant) -> Bool {
        var valid = GDExtensionBool (0)
        let ret = Variant (false)
        
        gi.variant_evaluate (GDEXTENSION_VARIANT_OP_EQUAL, &lhs.content, &rhs.content, &ret.content, &valid)
        return Bool (ret) ?? false
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(gi.variant_hash (&content))
    }
    
    /// Creates a new Variant based on a copy of the reference variant passed in
    public init(_ other: Variant) {
        withUnsafeMutablePointer(to: &content) { selfPtr in
            withUnsafePointer(to: other.content) { ptr in
                gi.variant_new_copy(selfPtr, ptr)
            }
        }
        extensionInterface.variantInited(variant: self, content: &content)
    }
    
    /// Initialize ``Variant`` using inlinable payload or opaque handle managed by Builtin Type or Object.
    @inline(__always)
    @usableFromInline
    init<Payload>(
        payload: Payload,
        constructor: @convention(c) (
            /* pVariantContent */ UnsafeMutableRawPointer?,
            /* pPayload */ UnsafeMutableRawPointer?
        ) -> Void
    ) {
        var payload = payload
        withUnsafeMutablePointer(to: &content) { pVariantContent in
            withUnsafeMutablePointer(to: &payload) { pPayload in
                constructor(pVariantContent, pPayload)
            }
        }
        
        extensionInterface.variantInited(variant: self, content: &content)
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
        withUnsafeMutablePointer(to: &content) { pVariantContent in
            constructor(pPayload, pVariantContent)
        }
    }
    
    /// Initialize ``Variant`` by wrapping ``Object``
    public convenience init(_ from: Object) {
        self.init(payload: from.pNativeObject, constructor: Object.variantFromSelf)
    }
    
    /// Initialize ``Variant`` by wrapping ``Object?``, fails if it's `nil`
    public convenience init?(_ from: Object?) {
        guard let from else {
            return nil
        }
        self.init(from)
    }
    
    /// Initialize ``Variant`` by wrapping ``BinaryInteger``
    public convenience init(_ from: some BinaryInteger) {
        self.init(payload: Int64(from), constructor: VariantGodotInterface.variantFromInt)
    }
    
    /// Initialize ``Variant`` by wrapping ``BinaryInteger?``, fails if it's `nil`
    public convenience init?(_ from: (some BinaryInteger)?) {
        guard let from else {
            return nil
        }
        self.init(from)
    }
    
    /// Initialize ``Variant`` by wrapping ``BinaryFloatingPoint``
    public convenience init(_ from: some BinaryFloatingPoint) {
        self.init(payload: Double(from), constructor: VariantGodotInterface.variantFromDouble)
    }
    
    /// Initialize ``Variant`` by wrapping ``BinaryFloatingPoint?``, fails if it's `nil`
    public convenience init?(_ from: (some BinaryFloatingPoint)?) {
        guard let from else {
            return nil
        }
        self.init(from)
    }
    
    /// Initialize ``Variant`` by wrapping ``Bool``
    public convenience init(_ from: Bool) {
        let payload: GDExtensionBool = from ? 1 : 0
        self.init(payload: payload, constructor: VariantGodotInterface.variantFromBool)
    }
    
    /// Initialize ``Variant`` by wrapping ``Bool?``, fails if it's `nil`
    public convenience init?(_ from: Bool?) {
        guard let from else {
            return nil
        }
        self.init(from)
    }
    
    /// Initialize ``Variant`` by wrapping ``String``
    public convenience init(_ from: String) {
        /// Avoid allocating `GString` wrapper at least
        var stringContent = GString.zero
        gi.string_new_with_utf8_chars(&stringContent, from)
        self.init(payload: stringContent, constructor: GodotInterfaceForString.variantFromSelf)
        GodotInterfaceForString.destructor(&stringContent)
    }
    
    /// Initialize ``Variant`` by wrapping ``String?``, fails if it's `nil`
    public convenience init?(_ from: String?) {
        guard let from else {
            return nil
        }
        self.init(from)
    }
    
    /// This describes the type of the data wrapped by this variant
    public var gtype: GType {
        let rawValue = gi.variant_get_type(&content).rawValue
        
        guard let result = GType(rawValue: Int64(rawValue)) else {
            fatalError("Unknown GType with raw value \(rawValue).")
        }
        
        return result
    }
    
    /// Returns true if the variant is not an object, or the object is missing from the lookup table
    public var isNull: Bool {
        return asObject(Object.self) == nil
    }
    
    ///
    /// Attempts to cast the Variant into a SwiftGodot.Object, if the variant contains a value of type `.object`, then
    // this will return the object.  If the variant contains the nil value, or the content of the variant is not
    /// a `.object, the value `nil` is returned.
    ///
    /// - Parameter type: the desired type eg. `.asObject(Node.self)`
    /// - Returns: nil on error, or the type on success
    @inline(__always)
    public func asObject<T: Object> (_ type: T.Type = T.self) -> T? {
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
    
    public var description: String {
        var ret = GDExtensionStringPtr (bitPattern: 0xdeaddead)
        gi.variant_stringify (&content, &ret)
        
        let str = stringFromGodotString(&ret)
        GodotInterfaceForString.destructor(&ret)
        return str ?? ""
    }
    
    public var debugDescription: String {
        "\(gtype) [\(description)]"
    }

    public enum VariantErrorType: Error {
        case notFound
    }
    
    /// Identity function. Needed for static dispatch for certain features.
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Variant {
        variant
    }
    
    /// Identity function. Needed for static dispatch for certain features.
    public func toVariant() -> Variant {
        return self
    }
    
    /// Identity function. Needed for static dispatch for certain features.
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        self
    }

    /// Gets the value of a named key from a Variant.
    /// - Parameter key: a Variant representing the key.
    /// - Returns: Result with the value on success
    public func getNamed(key: StringName) -> Result<Variant?, VariantErrorType> {
        var newContent: ContentType = Variant.zero
        var valid: GDExtensionBool = 0

        gi.variant_get_named(&content, &key.content, &newContent, &valid)
        if valid != 0 {
            return .success(Variant(takingOver: newContent))
        } else {
            return .failure(.notFound)
        }
    }

    /// Invokes a variant's method by name.
    /// - Parameters:
    ///  - method: name of the method to invoke
    ///  - arguments: variable list of arguments to pass to the method
    /// - Returns: on success, the variant result, on error, the reason
    public func call(method: StringName, _ arguments: Variant?...) -> Result<Variant?, CallErrorType> {
        var result = Variant.zero
        
        // Shadow self.content, we just need a copy of it locally
        var content = content
        
        var err = GDExtensionCallError()
        
        if arguments.count == 1 {
            var argContent = arguments.first!.content
            withUnsafePointer(to: &argContent) { ptr in
                gi.variant_call(&content, &method.content, ptr, 1, &result, &err)
            }
        } else if arguments.count > 1 {
            // A temporary allocation containing pointers to `Variant.ContentType` of marshaled arguments
            withUnsafeTemporaryAllocation(of: UnsafeRawPointer?.self, capacity: arguments.count) { pArgsBuffer in
                // We use entire buffer so can initialize every element in the end. It's not
                // necessary for UnsafeRawPointer and other POD types (which Variant.ContentType also is)
                // but we'll do it for the sake of correctness
                defer { pArgsBuffer.deinitialize() }
                guard let pArgs = pArgsBuffer.baseAddress else {
                    fatalError("pargsBuffer.baseAddress is nil")
                }
                             
                // A temporary allocation containing `Variant.ContentType` of marshaled arguments
                withUnsafeTemporaryAllocation(of: Variant.ContentType.self, capacity: arguments.count) { contentsBuffer in
                    defer { contentsBuffer.deinitialize() }
                    guard let contentsPtr = contentsBuffer.baseAddress else {
                        fatalError("contentsBuffer.baseAddress is nil")
                    }
                    
                    for i in 0..<arguments.count {
                        // Copy `content`s of the variadic `Variant`s into `contentBuffer`
                        contentsBuffer.initializeElement(at: i, to: arguments[i].content)
                        
                        // Initialize `pArgs` elements to point at respective contents of `contentsBuffer`
                        pArgsBuffer.initializeElement(at: i, to: contentsPtr + i)
                    }
                    
                    gi.variant_call(&content, &method.content, pArgs, Int64(arguments.count), &result, &err)
                }
            }
        } else {
            gi.variant_call(&content, &method.content, nil, 0, &result, &err)
        }
        
        if err.error != GDEXTENSION_CALL_OK {
            return .failure(toCallErrorType(err.error))
        }
        
        return .success(Variant(takingOver: result))
    }

    /// Constructs a new variant of the specified type, with the given array of types
    public static func construct(type: Variant.GType) -> Result<Variant?,CallErrorType> {
        var newContent: ContentType = Variant.zero
        var err = GDExtensionCallError()
        gi.variant_construct(GDExtensionVariantType(rawValue: GDExtensionVariantType.RawValue(type.rawValue)), &newContent, nil, 0, &err)
        if err.error != GDEXTENSION_CALL_OK {
            return .failure(toCallErrorType(err.error))
        }
        return .success(Variant(takingOver: newContent))
    }
    /// Errors raised by the variant subscript
    ///
    /// There are two possible error conditions, an attempt to use an indexer on a variant that is not
    /// an array, or an attempt to access an element out bounds.
    public enum VariantIndexerError: Error, CustomDebugStringConvertible {
        case ok
        /// The variant is not an array
        case invalidOperation
        /// The index is out of bounds
        case outOfBounds
        
        public var debugDescription: String {
            switch self {
            case .ok:
                return "Success"
            case .invalidOperation:
                return "Attempt to use indexer methods in a variant that does not support it"
            case .outOfBounds:
                return "Index value was out of bounds"
            }
        }
    }
    
    /// Variants that represent arrays can be indexed, this subscript allows you to fetch the individual elements of those arrays
    ///
    public subscript (index: Int) -> Variant? {
        get {
            var copy_content = content
            var _result: Variant.ContentType = Variant.zero
            var valid: GDExtensionBool = 0
            var oob: GDExtensionBool = 0
            
            gi.variant_get_indexed(&copy_content, Int64(index), &_result, &valid, &oob)
            if valid == 0 || oob != 0 {
                return nil
            }
                        
            return Variant(takingOver: _result)
        }
        set {
            guard let newValue else {
                return
            }
            var copy_content = content
            var newV = newValue.content
            var valid: GDExtensionBool = 0
            var oob: GDExtensionBool = 0

            gi.variant_set_indexed (&copy_content, Int64(index), &newV, &valid, &oob)
        }
    }

    /// Provides keyed access to the variant using a variant as an index
    public subscript(index: Variant) -> Variant? {
        get {
            var newContent: ContentType = Variant.zero
            var valid: GDExtensionBool = 0

            gi.variant_get(&content, &index.content, &newContent, &valid)
            if valid != 0 {
                return Variant(takingOver: newContent)
            } else {
                return nil
            }
        }
        set {
            var copyValue: Variant.ContentType = newValue.content
            var valid: GDExtensionBool = 0
            gi.variant_set(&content, &index.content, &copyValue, &valid)            
        }
    }
    /// Gets the name of a Variant type.
    public static func typeName(_ type: GType) -> String {
        let res = GString()
        gi.variant_get_type_name (GDExtensionVariantType (GDExtensionVariantType.RawValue(type.rawValue)), &res.content)
        let ret = GString.stringFromGStringPtr(ptr: &res.content)
        return ret ?? ""
    }
    
    /// Extract `T` from this ``Variant`` or return nil if unsucessful.
    public func to<T>(_ type: T.Type = T.self) -> T? where T: VariantConvertible {
        type.fromVariant(self)
    }
    
    /// Extract `T: Object` from this ``Variant`` or return nil if unsucessful.
    public func to<T>(_ type: T.Type = T.self) -> T? where T: Object {
        type.fromVariant(self)
    }    
    
    /// Internal API.
    public static var _variantType: GType {
        .nil
    }
    
    /// Internal API.
    public static var _builtinOrClassName: String {
        "Variant"
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``Variant`` or ``Variant?`` is used in API visible to Godot
    @inline(__always)
    @inlinable
    public static func _propInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        _propInfoDefault(
            propertyType: .nil, // Godot treats .nil as Godot Variant
            name: name,
            hint: hint,
            hintStr: hintStr,
            usage: usage ?? .nilIsVariant
        )
    }
    
    /// Internal API.
    /// According to:
    /// - https://github.com/godotengine/godot/issues/67544#issuecomment-1382229216
    /// - https://github.com/godotengine/godot/blob/b6e06038f8a373f7fb8d26e92d5f06887e459598/core/doc_data.cpp#L85
    /// It's `.nil` with hint = `.nilIsVariant` in returned value prop info
    /// And `.nil` with hint = `.none` in argument prop info
    public static func _argumentPropInfo(name: String) -> PropInfo {
        _propInfoDefault(propertyType: _variantType, name: name)
    }
    
    /// Internal API.
    public static var _returnValuePropInfo: PropInfo {
        _propInfoDefault(propertyType: _variantType, name: "", usage: .nilIsVariant)
    }
    
    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Variant {
        Variant(takingOver: variant.copy())
    }
    
    public func toFastVariant() -> FastVariant {
        var newContent = VariantContent.zero
        
        withUnsafeMutablePointer(to: &newContent) { pNewContent in
            withUnsafePointer(to: &content) { pCopiedContent in
                gi.variant_new_copy(pNewContent, pCopiedContent)
            }
        }
        
        return FastVariant(unsafeTakingOver: newContent)
    }
    
    @_disfavoredOverload
    public func toFastVariant() -> FastVariant? {
        toFastVariant()
    }
}

extension Variant? {
    /// Extract `T` from this ``Variant?`` or return nil if unsucessful.
    @inline(__always)
    @inlinable
    public func to<T>(_ type: T.Type = T.self) -> T? where T: VariantConvertible {
        type.fromVariant(self)
    }
    
    /// Extract `T: Object` from this ``Variant?`` or return nil if unsucessful.
    @inline(__always)
    @inlinable
    public func to<T>(_ type: T.Type = T.self) -> T? where T: Object {
        type.fromVariant(self)
    }
    
    var content: Variant.ContentType {
        if let wrapped = self {
            return wrapped.content
        } else {
            return Variant.zero
        }
    }
}

public extension Variant.GType {
    /// Internal API. Godot type name of the type with this variant tag.
    var _builtinOrClassName: String {
        switch self {
        case .nil:
            fatalError("Unreachable")
        case .bool:
            return "bool"
        case .int:
            return "int"
        case .float:
            return "float"
        case .string:
            return "String"
        case .vector2:
            return "Vector2"
        case .vector2i:
            return "Vector2i"
        case .rect2:
            return "Rect2"
        case .rect2i:
            return "Rect2i"
        case .vector3:
            return "Vector3"
        case .vector3i:
            return "Vector3i"
        case .transform2d:
            return "Transform2D"
        case .vector4:
            return "Vector4"
        case .vector4i:
            return "Vector4i"
        case .plane:
            return "Plane"
        case .quaternion:
            return "Quaternion"
        case .aabb:
            return "AABB"
        case .basis:
            return "Basis"
        case .transform3d:
            return "Transform3D"
        case .projection:
            return "Projection"
        case .color:
            return "Color"
        case .stringName:
            return "StringName"
        case .nodePath:
            return "NodePath"
        case .rid:
            return "RID"
        case .object:
            fatalError("Unreachable")
        case .callable:
            return "Callable"
        case .signal:
            return "Signal"
        case .dictionary:
            return "Dictionary"
        case .array:
            return "Array"
        case .packedByteArray:
            return "PackedByteArray"
        case .packedInt32Array:
            return "PackedInt32Array"
        case .packedInt64Array:
            return "PackedInt64Array"
        case .packedFloat32Array:
            return "PackedFloat32Array"
        case .packedFloat64Array:
            return "PackedFloat64Array"
        case .packedStringArray:
            return "PackedStringArray"
        case .packedVector2Array:
            return "PackedVector2Array"
        case .packedVector3Array:
            return "PackedVector3Array"
        case .packedColorArray:
            return "PackedColorArray"
        case .packedVector4Array:
            return "PackedVector4Array"
        }
    }
}
