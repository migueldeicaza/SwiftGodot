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
public struct TypedDictionary<Key: _GodotContainerTypingParameter, Value: _GodotContainerTypingParameter>: CustomDebugStringConvertible, _GodotBridgeableBuiltin, Sequence, ExpressibleByDictionaryLiteral {
    
    /// Reference to underlying `VariantDictionary` which is guaranteed to containing only `Key: Value` pairs.
    public let dictionary: VariantDictionary
    
    public var debugDescription: String {
        dictionary.debugDescription
    }
    
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
    
    /// Initialise ``TypedDictionary`` from the Swift dictionary literal.
    /// For example:
    /// ```
    /// let typedDictionary: TypedDictionary = [1: 2, 2: 3, 3: 3, 4: 4, 5: 5]
    /// ```
    ///
    /// This operation is O(n) as it requires full copy of Swift dictionary.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init()
        
        for (key, value) in elements {
            set(key: key, value: value)
        }
    }
    
    /// Initialise an empty ``TypedDictionary``.
    public init() {
        self.dictionary = VariantDictionary(
            base: VariantDictionary(),
            keyType: Int32(Key._variantType.rawValue),
            keyClassName: Key._className,
            keyScript: nil,
            valueType: Int32(Value._variantType.rawValue),
            valueClassName: Value._className,
            valueScript: nil
        )
    }
    
    /// Initialise ``TypedDictionary`` from the Swift `[Key: Value]` dictionary.
    /// For example:
    /// ```
    /// let dictionary: [Int: Int] = [1: 2, 2: 3, 3: 3, 4: 4, 5: 5]
    /// let typedDictionary = TypedDictionary(typedDictionary)
    /// ```
    ///
    /// This operation is O(n) as it requires full copy of Swift dictionary.
    @inline(__always)
    @inlinable
    public init(_ dictionary: [Key: Value]) where Key: Hashable {
        self.init()
        
        for (key, value) in dictionary {
            set(key: key, value: value)
        }
    }
            
    /// Subscript operator for where `Value` is Godot builtin type.
    /// Such dictionaries don't allow `nil` values.
    /// It will erase a value with `key` instead.
    ///
    /// ```
    /// let dictionary: TypedDictionary<Int, String>
    /// dictionay[10] = nil // will erase a value with key `10` if any
    /// ```
    @inline(__always)
    @inlinable
    public subscript(key: Key) -> Value? where Value: _GodotBridgeableBuiltin {
        get {
            let variant = dictionary[key]
            return Value.fromFastVariant(variant)
        }
        
        set {
            if newValue == nil {
                dictionary.erase(fastKey: key.toFastVariant())
            } else {
                dictionary[key] = newValue.toFastVariant()
            }
        }
    }
    
    /// Subscript operator for where `Value` is `Object`, or its subtype, or `Variant?`
    /// Such dictionaries allow `nil` values.
    ///
    /// ```
    /// let dictionary: TypedDictionary<Int, Object?>
    /// dictionay[10] = nil // will store `nil` value
    /// ```
    ///
    /// To erase value from the dictionary use ``erase(key:)``
    @inline(__always)
    @inlinable
    public subscript(key: Key) -> Value where Value._NonOptionalType: _GodotNullableBridgeable {
        get {
            let variant = dictionary[key]
            
            // `Value` is `Object?` or `Variant?`
            // Unwrapping it produces `nil` via `Value?.fromNilOrThrow` call
            // It only throws if incompatible Object type was stored.
            // This is a error which should be fixed if it happens.
            return unwrapOrCrash(variant, at: key)
        }
        
        set {
            dictionary[key] = newValue.toFastVariant()
        }
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
    
    /// Initialze ``TypedDictionary`` from ``Variant?``. Fails if `variant` doesn't contain ``TypedDictionary`` or is `nil`
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
    @inline(__always)
    @inlinable
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
    
    // MARK: - Proxy
    
    /* Methods */
    
    /// Returns the number of entries in the dictionary. Empty dictionaries (`{ }`) always return `0`. See also ``isEmpty()``.
    @inline(__always)
    @inlinable
    public func size() -> Int64 {
        return dictionary.size()
    }
    
    /// Returns `true` if the dictionary is empty (its size is `0`). See also ``size()``.
    @inline(__always)
    @inlinable
    public func isEmpty() -> Bool {
        return dictionary.isEmpty()
    }
    
    /// Clears the dictionary, removing all entries from it.
    @inline(__always)
    @inlinable
    public func clear() {
        dictionary.clear()
    }
    
    /// Assigns elements of another `dictionary` into the dictionary. Resizes the dictionary to match `dictionary`. Performs type conversions if the dictionary is typed.
    @inline(__always)
    @inlinable
    public func assign(dictionary otherDictionary: VariantDictionary) {
        dictionary.assign(dictionary: otherDictionary)
    }
    
    /// Sorts the dictionary in-place by key. This can be used to ensure dictionaries with the same contents produce equivalent results when getting the ``keys()``, getting the ``values()``, and converting to a string. This is also useful when wanting a JSON representation consistent with what is in memory, and useful for storing on a database that requires dictionaries to be sorted.
    @inline(__always)
    @inlinable
    public func sort() {
        dictionary.sort()
    }
    
    /// Adds entries from `dictionary` to this dictionary. By default, duplicate keys are not copied over, unless `overwrite` is `true`.
    ///
    /// > Note: ``merge(dictionary:overwrite:)`` is _not_ recursive. Nested dictionaries are considered as keys that can be overwritten or not depending on the value of `overwrite`, but they will never be merged together.
    @inline(__always)
    @inlinable
    public func merge(dictionary otherDictionary: VariantDictionary, overwrite: Bool = false) {
        dictionary.merge(dictionary: otherDictionary, overwrite: overwrite)
        
    }
    
    /// Returns a copy of this dictionary merged with the other `dictionary`. By default, duplicate keys are not copied over, unless `overwrite` is `true`. See also ``merge(dictionary:overwrite:)``.
    ///
    /// This method is useful for quickly making dictionaries with default values:
    @inline(__always)
    @inlinable
    public func merged(dictionary otherDictionary: VariantDictionary, overwrite: Bool = false) -> VariantDictionary {
        dictionary.merged(dictionary: otherDictionary, overwrite: overwrite)
    }
    
    /// Returns `true` if the dictionary contains an entry with the given `key`.
    ///
    /// In GDScript, this is equivalent to the `in` operator:
    ///
    /// > Note: This method returns `true` as long as the `key` exists, even if its corresponding value is `null`.
    @inline(__always)
    @inlinable
    public func has(key: Key) -> Bool {
        dictionary.has(key: key.toVariant())
    }
    
    /// Returns `true` if the dictionary contains all keys in the given `keys` array.
    @inline(__always)
    @inlinable
    public func hasAll(keys: VariantArray) -> Bool {
        dictionary.hasAll(keys: keys)
    }
    
    /// Finds and returns the first key whose associated value is equal to `value`, or `null` if it is not found.
    ///
    /// > Note: `null` is also a valid key. If inside the dictionary, ``findKey(value:)`` may give misleading results.
    @inline(__always)
    @inlinable
    public func findKey(value: Variant?) -> Variant? {
        return dictionary.findKey(value: value)
    }
    
    /// Removes the dictionary entry by key, if it exists. Returns `true` if the given `key` existed in the dictionary, otherwise `false`.
    ///
    /// > Note: Do not erase entries while iterating over the dictionary. You can iterate over the ``keys()`` array instead.
    @inline(__always)
    @inlinable
    public func erase(key: Key) -> Bool {
        dictionary.erase(key: key.toVariant())
    }
    
    /// Returns the list of keys in the dictionary.
    @inline(__always)
    @inlinable
    public func keys() -> TypedArray<Key> {
        TypedArray(from: dictionary.keys())
    }
    
    /// Returns the list of values in this dictionary.
    @inline(__always)
    @inlinable
    public func values() -> TypedArray<Value> {
        TypedArray(from: dictionary.values())
    }
    
    /// Creates and returns a new copy of the dictionary. If `deep` is `true`, inner ``VariantDictionary`` and ``VariantArray`` keys and values are also copied, recursively.
    @inline(__always)
    @inlinable
    public func duplicate(deep: Bool = false) -> Self {
        Self(from: dictionary.duplicate(deep: deep))
    }
    
    /// Returns `true` if the dictionary is typed the same as `dictionary`.
    @inline(__always)
    @inlinable
    public func isSameTyped(dictionary otherDictionary: VariantDictionary) -> Bool {
        otherDictionary.isSameTyped(dictionary: dictionary)
    }
    
    /// Returns `true` if the dictionary's keys are typed the same as `dictionary`'s keys.
    @inline(__always)
    @inlinable
    public func isSameTypedKey(dictionary otherDictionary: VariantDictionary) -> Bool {
        dictionary.isSameTypedKey(dictionary: otherDictionary)
    }
    
    /// Returns `true` if the dictionary's values are typed the same as `dictionary`'s values.
    @inline(__always)
    @inlinable
    public func isSameTypedValue(dictionary otherDictionary: VariantDictionary) -> Bool {
        dictionary.isSameTypedValue(dictionary: otherDictionary)
    }
    
    /// Returns the ``Script`` instance associated with this typed dictionary's keys, or `null` if it does not exist. See also ``isTypedKey()``.
    @inline(__always)
    @inlinable
    public func getTypedKeyScript() -> Variant? {
        dictionary.getTypedKeyScript()
    }
    
    /// Returns the ``Script`` instance associated with this typed dictionary's values, or `null` if it does not exist. See also ``isTypedValue()``.
    @inline(__always)
    @inlinable
    public func getTypedValueScript() -> Variant? {
        dictionary.getTypedValueScript()
    }
    
    /// Makes the dictionary read-only, i.e. disables modification of the dictionary's contents. Does not apply to nested content, e.g. content of nested dictionaries.
    @inline(__always)
    @inlinable
    public func makeReadOnly() {
        dictionary.makeReadOnly()
    }
    
    /// Returns `true` if the dictionary is read-only. See ``makeReadOnly()``. Dictionaries are automatically read-only if declared with `const` keyword.
    @inline(__always)
    @inlinable
    public func isReadOnly() -> Bool {
        dictionary.isReadOnly()
    }
    
    /// Returns `true` if the two dictionaries contain the same keys and values, inner ``VariantDictionary`` and ``VariantArray`` keys and values are compared recursively.
    @inline(__always)
    @inlinable
    public func recursiveEqual(dictionary otherDictionary: VariantDictionary, recursionCount: Int64) -> Bool {
        dictionary.recursiveEqual(dictionary: otherDictionary, recursionCount: recursionCount)
    }
    
    /// Returns the corresponding value for the given `key` in the dictionary. If the `key` does not exist, returns `default`, or `null` if the parameter is omitted.
    @inline(__always)
    @inlinable
    public func get(key: Key, `default`: Value) -> Value {
        // This should always contain unwrappable value
        unwrapOrCrash(
            dictionary.get(key: key.toVariant(), default: `default`.toVariant()),
            at: key
        )
    }
    
    /// Gets a value and ensures the key is set. If the `key` exists in the dictionary, this behaves like ``get(key:`default`:)``. Otherwise, the `default` value is inserted into the dictionary and returned.
    @inline(__always)
    @inlinable
    public func getOrAdd(key: Key, `default`: Value) -> Value {
        unwrapOrCrash(
            dictionary.getOrAdd(key: key.toVariant(), default: `default`.toVariant()),
            at: key
        )
    }
    
    /// Sets the value of the element at the given `key` to the given `value`.
    @inline(__always)
    @inlinable
    public func set(key: Key, value: Value) -> Bool {
        dictionary.set(key: key.toVariant(), value: value.toVariant())
    }
    
    // MARK: - Invariant enforcing
    /// `Value` is `Object?` or `Variant?` here. Or it's in the context where unwrapping is never expected to fail.
    /// It doesn't throw if it's `nil`, it returns `nil`.
    /// It only throws if the incompatible type was stored which is an invariant violation and a bug that we need to fix.
    @inline(__always)
    @usableFromInline
    func unwrapOrCrash(_ variant: Variant?, invoking function: StaticString = #function, at key: Key? = nil) -> Value {
        do {
            return try Value.fromVariantOrThrow(variant)
        } catch {
            typeInvariantViolation(invoking: function, error: error, at: key)
        }
    }
    
    /// `Value` is `Object?` or `Variant?` here. Or it's in the context where unwrapping is never expected to fail.
    /// It doesn't throw if it's `nil`, it returns `nil`.
    /// It only throws if the incompatible type was stored which is an invariant violation and a bug that we need to fix.
    @inline(__always)
    @usableFromInline
    func unwrapOrCrash(_ variant: borrowing FastVariant?, invoking function: StaticString = #function, at key: Key? = nil) -> Value {
        do {
            return try Value.fromFastVariantOrThrow(variant)
        } catch {
            typeInvariantViolation(invoking: function, error: error, at: key)
        }
    }
        
    @inline(__always)
    @inlinable
    func typeInvariantViolation(invoking function: StaticString, error: VariantConversionError, at key: Key?) -> Never {
        let atKey = key.map { " at key \($0)" } ?? ""
        fatalError("Fatal error during `TypedDictionary<\(Key.self), \(Value.self)>.\(function)` from \(dictionary.debugDescription)\(atKey). Type invariant violated. \(error.description)")
    }
    
    // MARK: - Sequence
    
    public struct Iterator: IteratorProtocol {
        let iterated: TypedDictionary<Key, Value>
        let keys: TypedArray<Key>
        
        init(_ dictionary: TypedDictionary) {
            iterated = dictionary
            keys = dictionary.keys()
        }
        
        var index = 0
        
        public mutating func next() -> (Key, Value)? {
            defer {
                index += 1
            }
            
            if index >= keys.count {
                return nil
            }
            
            let key = keys[index]
            let value = iterated.unwrapOrCrash(
                iterated.dictionary[key],
                at: key
            )
            
            return (key, value)
        }
        
        public typealias Element = (Key, Value)
    }
    
    public func makeIterator() -> Iterator {
        Iterator(self)
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
