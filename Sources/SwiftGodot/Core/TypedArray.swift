//
//  TypedArray.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 20/04/2025.
//

@_implementationOnly import GDExtension

/// Descriptor of Godot `Array` or `Dictionary` typing.
@usableFromInline
enum ContainerTypingParameter {
    /// Anything but .object
    case builtin(Variant.GType)
    
    /// Object with metatype
    case object(Object.Type)
}

/// Internal API.
/// Do not conform your types to this protocol.
/// Protocol implemented by types that are allowed to be `TypedArray` `Element`, and `TypedDictionary` `Key` or `Value`.
/// This protocol is implemented by:
/// 1. All builtin types such as ``Vector3``, ``VariantArray``,  etc.
/// 2. Optional `Object`-inherited classes. `Object?`, `Node?`, `Camera3D?`, etc.
/// 3. Swift `Variant?`.
///
/// # Compilation troubleshooting
///
/// #### ❌ `Type 'YourType' does not conform to protocol '_GodotContainerTypingParameter'`
/// You used `TypedArray<YourType>` or `TypedDictionary` with `YourType` `Key` or `Value`.
/// You should use `TypedArray<YourType?>`, `TypedDictionary<YourType?, _>`, `TypedDictionary<_, YourType?>` instead.
/// Godot doesn't guarantee non-nullability of `YourType` elements.
///
/// #### ❌ `'TypedArray' requires that 'YourType' conform to '_GodotNullableBridgeable'`
/// You used `TypedArray<YourType?>` or `TypedDictionary` with `YourType?` `Key` or `Value`.
/// You should use `TypedArray<YourType>`, `TypedDictionary<YourType, _>`, `TypedDictionary<_, YourType>` instead.
/// Godot guarantees non-nullability of `SomeType` elements.
public protocol _GodotContainerTypingParameter: _GodotBridgeable {
    /// Internal API.
    /// Non Optional type of this type:
    /// - for builtin types it's the type itself.
    /// - for `ObjectSubtype?` it's `ObjectSubtype`
    /// - for `Variant?` it's `Variant`
    associatedtype _NonOptionalType: _GodotBridgeable
    
    /// Internal API.
    /// `class_name` for given type as Godot requires it
    /// - for builtin types it's an empty string
    /// - for `ObjectSubtype?` it's the literal name of the `ObjectSubtype`
    /// - for `Variant?` it's an empty string
    static var _className: StringName { get }
}

/// This type represents typed Godot array, such as `Array[int]` or `Array[Object]`.
///
/// In Swift it serves as a type-safe view into underlying ``VariantArray`` stored in `array` property.
/// It guarantees that only `Element` types are in there.
///
/// The `Element` reflects semantics of how Godot treats nullability.
/// Allowed elements are:
/// 1. All builtin types such as ``Vector3``, ``VariantArray``,  etc.
/// 2. Optional `Object`-inherited classes. `Object?`, `Node?`, `Camera3D?`, etc.
/// 3. Swift `Variant?`
///
/// Example:
/// ```
/// var array: TypedArray<Int> = [1, 2, 3, 4, 5]
/// let element = array[1] // It's `Int`, Godot guarantees that Array of builtin type elements doesn't contain `nil` values.
/// array.append(nil) // Illegal.
///
/// let otherArray: TypedArray<Object?> = [nil, nil, Object()]
/// let otherElement = otherArray[2] // It's `Object?`
///
/// let oneMoreArray: TypedArray<Object> // Illegal, Godot can't guarantee that `Array[Object]` contains only non-null `Object`-s, use `TypedArray<Object?>`
/// ```
///
/// # Compilation troubleshooting
///
/// #### ❌ `Type 'YourType' does not conform to protocol '_GodotContainerTypingParameter'`
/// You used `TypedArray<YourType>`.
/// You should use `TypedArray<YourType?>`.
/// Godot doesn't guarantee non-nullability of `Array[YourType]` elements.
///
/// #### ❌ `'TypedArray' requires that 'YourType' conform to '_GodotNullableBridgeable'`
/// You used `TypedArray<YourType?>`.
/// You should use `TypedArray<YourType>` instead.
/// Godot guarantees non-nullability of `Array[YourType]` elements.
public struct TypedArray<Element: _GodotContainerTypingParameter>: CustomDebugStringConvertible, RandomAccessCollection, _GodotBridgeableBuiltin, ExpressibleByArrayLiteral, Hashable {
    public typealias Index = Int
    public typealias ArrayLiteralElement = Element

    /// Reference to underlying `VariantArray` which is guaranteed to containing only `Element`s and nothing else.
    public let array: VariantArray
        
    /// Initialize ``TypedArray`` from existing ``VariantArray``.
    /// If ``VariantArray`` is typed and its type is exactly the same as ``Element`` the created instance will reference the same storage.
    /// If not, a new ``VariantArray`` to wrap will be created by following Godot rules of array type narrowing:
    /// - If array could be converted successfully - it returns a typed array containing the same elements.
    /// - If not - it returns an empty typed array.
    /// See: ``VariantArray.init(base:type:className:script:)``
    @inline(__always)
    @inlinable
    public init(from array: VariantArray) {
        switch array.typing {
        case .builtin(let gtype):
            assert(gtype != .object)
            
            if gtype != Element._variantType {
                self.array = VariantArray(
                    base: array,
                    type: Int32(Element._variantType.rawValue),
                    className: Element._className,
                    script: nil
                )
            } else {
                self.array = array
            }
        case .object(let objectType):
            if objectType == Element._NonOptionalType.self {
                // Wrap the existing storage
                self.array = array
            } else {
                self.array = VariantArray(
                    base: array,
                    type: Int32(Element._variantType.rawValue),
                    className: Element._className,
                    script: nil
                )
            }
        }
    }
    
    init(takingOver content: VariantArray.ContentType) {
        self.init(from: VariantArray(takingOver: content))
    }
    
    /// Initialise ``TypedArray`` from the array literal.
    /// For example:
    /// ```
    /// func foo(_ array: TypedArray<Int>) {
    /// }
    ///
    /// foo([1, 2, 3, 4, 5])
    /// ```
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
    
    /// Initialise ``TypedArray`` from the Swift ``Sequence``.
    /// For example:
    /// ```
    /// let array: [Int] = [1, 2, 3, 4, 5]
    /// let typedArray = TypedArray(array)
    /// ```
    ///
    /// This operation is O(n) as it requires allocating a new ``TypedArray`` and copying contents of Swift ``Sequence``.
    public init<S>(_ sequence: S) where S: Sequence, S.Element == Element {
        self.init(Element.self)
        
        for element in sequence {
            append(element)
        }
    }
    
    /// Initialize an empty ``TypedArray`` of given `type`.
    ///
    /// For example:
    /// ```
    /// let array = TypedArray(Node?.self)
    /// // same as
    /// let anotherArray = TypedArray<Node?>()
    /// ```
    public init(_ type: Element.Type = Element.self) {
        // TODO: we can minimize amount of allocations here, but let's name the constructors first
        array = VariantArray(
            base: VariantArray(),
            type: Int32(Element._variantType.rawValue),
            className: Element._className,
            script: nil
        )
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash())
    }
    
    public static func ==(lhs: Self, rhs: Self) {
        lhs.array == rhs.array
    }
    
    /// Provides debug description of this instance:
    /// ```
    /// print(TypedArray([1, 2, 3, 4, 5, 6, 7]) // prints [1, 2, 3, 4, 5, 6, 7]
    /// ```
    public var debugDescription: String {
        array.debugDescription
    }
    
    public var startIndex: Int {
        0
    }
    
    public var endIndex: Int {
        array.count
    }
        
    public subscript(position: Int) -> Element {
        get {
            // Workaround for Swift compiler bug.
            // Keeping this inside `withFastVariant` breaks `throws(VariantConversionError)` inference
            func subscriptGetUnwrap(_ variant: borrowing FastVariant?, at position: Int) -> Element {
                do {
                    return try Element.fromFastVariantOrThrow(variant)
                } catch {
                    fatalError("Fatal error during subscript/get `TypedArray<\(Element.self)>[\(position)]` wrapping \(array.debugDescription) at index \(position). Type invariant violated. \(error.description)")
                }
            }
            
            return array.withFastVariant(at: position) { variant in
                subscriptGetUnwrap(variant, at: position)
            }
        }
        
        set {
            array.setFastVariant(newValue.toFastVariant(), at: position)
        }
    }
    
    /// Initialze ``TypedArray`` from ``Variant``. Fails if `variant` doesn't contain ``VariantArray``
    @inline(__always)
    public init?(_ variant: Variant) {
        guard Self._variantType == variant.gtype else { return nil }
        var content = VariantArray.zero
        withUnsafeMutablePointer(to: &content) { pPayload in
            variant.constructType(into: pPayload, constructor: GodotInterfaceForArray.selfFromVariant)
        }
        self.init(takingOver: content)
    }
    
    /// Initialze ``TypedArray`` from ``Variant``. Fails if `variant` doesn't contain ``VariantArray`` or is `nil`
    @inline(__always)
    @inlinable
    public init?(_ variant: Variant?) {
        guard let variant else { return nil }
        self.init(variant)
    }
    
    /// Initialze ``TypedArray`` from ``FastVariant``. Fails if `variant` doesn't contain ``VariantArray``
    @inline(__always)
    public init?(_ variant: borrowing FastVariant) {
        guard Self._variantType == variant.gtype else { return nil }
        var content = VariantArray.zero
        withUnsafeMutablePointer(to: &content) { pPayload in
            variant.constructType(into: pPayload, constructor: GodotInterfaceForArray.selfFromVariant)
        }
        self.init(takingOver: content)
    }
        
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toVariant() -> Variant? {
        array.toVariant()
    }
    
    @inline(__always)
    @inlinable
    public func toVariant() -> Variant {
        array.toVariant()
    }
    
    @inline(__always)
    @inlinable
    @_disfavoredOverload
    public func toFastVariant() -> FastVariant? {
        array.toFastVariant()
    }
    
    @inline(__always)
    @inlinable
    public func toFastVariant() -> FastVariant {
        array.toFastVariant()
    }
    
    @inline(__always)
    @inlinable
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        let array = try VariantArray.fromVariantOrThrow(variant)
        return Self(from: array)
    }
    
    @inline(__always)
    @inlinable
    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
        let array = try VariantArray.fromFastVariantOrThrow(variant)
        return Self(from: array)
    }
    
    public static var _variantType: Variant.GType {
        .array
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``TypedArray`` is used in API visible to Godot
    @inlinable
    @inline(__always)
    public static func _propInfo(
        name: String,
        hint: PropertyHint?,
        hintStr: String?,
        usage: PropertyUsageFlags?
    ) -> PropInfo {
        if Element._variantType == .nil {
            // .nil means `Variant` in Godot in this context.
            // Godot will see `TypedArray<Variant?>` as `Array`.
            // While `Array[Variant]` is an allowed GDScript statement,
            // get_property_list() still exposes a property having such type as `Array` without an `ARRAY_TYPE` hint.
            PropInfo(
                propertyType: .array,
                propertyName: StringName(name),
                className: "Array",
                hint: hint ?? .none,
                hintStr: GString(hintStr ?? ""),
                usage: usage ?? .default
            )
        } else {
            PropInfo(
                propertyType: .array,
                propertyName: StringName(name),
                className: StringName("Array[\(Element._builtinOrClassName)]"),
                hint: hint ?? .arrayType,
                hintStr: GString(hintStr ?? "\(Element._builtinOrClassName)"),
                usage: usage ?? .default
            )
        }
    }
    
    /// Internal API. Returns ``PropInfo`` for when any ``TypedArray`` is used in API visible to Godot
    @inlinable
    @inline(__always)
    public static var _returnValuePropInfo: PropInfo {
        if Element._variantType == .nil {
            // .nil means `Variant` in Godot in this context.
            // Godot will see `TypedArray<Variant?>` as `Array`.
            PropInfo(
                propertyType: .array,
                propertyName: "",
                className: "Array",
                hint: .none,
                hintStr: "",
                usage: .default
            )
        } else {
            PropInfo(
                propertyType: .array,
                propertyName: "",
                className: "Array[\(Element._builtinOrClassName)]",
                hint: .arrayType,
                hintStr: "\(Element._builtinOrClassName)",
                usage: .default
            )
        }
    }
    
    public static func _argumentPropInfo(name: String) -> PropInfo {
        if Element._variantType == .nil {
            // .nil means `Variant` in Godot in this context.
            // Godot will see `TypedArray<Variant?>` as `Array`.
            PropInfo(
                propertyType: .array,
                propertyName: StringName(name),
                className: "Array",
                hint: .none,
                hintStr: "",
                usage: .default
            )
        } else {
            PropInfo(
                propertyType: .array,
                propertyName: StringName(name),
                className: "Array[\(Element._builtinOrClassName)]",
                hint: .arrayType,
                hintStr: "\(Element._builtinOrClassName)",
                usage: .default
            )
        }
    }
    
    // MARK: - VariantArray proxying
    
    /// Returns the number of elements in the array.
    @inline(__always)
    @inlinable
    public func size() -> Int64 {
        return array.size()
    }

    /// Returns `true` if the array is empty.
    @inline(__always)
    @inlinable
    public func isEmpty() -> Bool {
        array.isEmpty()
    }
    
    /// Clears the array. This is equivalent to using ``resize(size:)`` with a size of `0`.
    @inline(__always)
    @inlinable
    public func clear() {
        array.clear()
    }

    /// Returns a hashed 32-bit integer value representing the array and its contents.
    ///
    /// > Note: ``VariantArray``s with equal content will always produce identical hash values. However, the reverse is not true. Returning identical hash values does _not_ imply the arrays are equal, because different arrays can have identical hash values due to hash collisions.
    ///
    @inline(__always)
    @inlinable
    public func hash() -> Int64 {
        array.hash()
    }
    
    /// Adds an element at the beginning of the array. See also ``pushBack(value:)``.
    ///
    /// > Note: On large arrays, this method is much slower than ``pushBack(value:)`` as it will reindex all the array's elements every time it's called. The larger the array, the slower ``pushFront(value:)`` will be.
    ///
    @inline(__always)
    @inlinable
    public func pushFront(value: Element) {
        array.pushFront(value: value.toVariant())
    }
    
    /// Appends an element at the end of the array (alias of ``pushBack(value:)``).
    @inline(__always)
    @inlinable
    public func append(_ value: Element) {
        array.append(value.toVariant())
    }
    
    /// Resizes the array to contain a different number of elements. If the array size is smaller, elements are cleared, if bigger, new elements are `null`. Returns ``GodotError/ok`` on success, or one of the other ``GodotError`` values if the operation failed.
    ///
    /// > Note: This method acts in-place and doesn't return a modified array.
    ///
    @inline(__always)
    @inlinable
    public func resize(size: Int64) -> Int64 {
        array.resize(size: size)
    }
    
    /// Inserts a new element at a given position in the array. The position must be valid, or at the end of the array (`pos == size()`). Returns ``GodotError/ok`` on success, or one of the other ``GodotError`` values if the operation failed.
    ///
    /// > Note: This method acts in-place and doesn't return a modified array.
    ///
    /// > Note: On large arrays, this method will be slower if the inserted element is close to the beginning of the array (index 0). This is because all elements placed after the newly inserted element have to be reindexed.
    ///
    @inline(__always)
    @inlinable
    public func insert(position: Int64, value: Element) -> Int64 {
        array.insert(position: position, value: value.toVariant())
    }
    
    /// Removes an element from the array by index. If the index does not exist in the array, nothing happens. To remove an element by searching for its value, use ``erase(value:)`` instead.
    ///
    /// > Note: This method acts in-place and doesn't return a modified array.
    ///
    /// > Note: On large arrays, this method will be slower if the removed element is close to the beginning of the array (index 0). This is because all elements placed after the removed element have to be reindexed.
    ///
    /// > Note: `position` cannot be negative. To remove an element relative to the end of the array, use `arr.remove_at(arr.size() - (i + 1))`. To remove the last element from the array without returning the value, use `arr.resize(arr.size() - 1)`.
    ///
    @inline(__always)
    @inlinable
    public func removeAt(position: Int64) {
        array.removeAt(position: position)
    }

    /// Removes the first occurrence of a value from the array. If the value does not exist in the array, nothing happens. To remove an element by index, use ``removeAt(position:)`` instead.
    ///
    /// > Note: This method acts in-place and doesn't return a modified array.
    ///
    /// > Note: On large arrays, this method will be slower if the removed element is close to the beginning of the array (index 0). This is because all elements placed after the removed element have to be reindexed.
    ///
    /// > Note: Do not erase entries while iterating over the array.
    ///
    @inline(__always)
    @inlinable
    public func erase(value: Element) {
        array.erase(value: value.toVariant())
    }
    
    /// Returns the first element of the array. Prints an error and returns `null` if the array is empty.
    ///
    /// > Note: Calling this function is not the same as writing `array[0]`. If the array is empty, accessing by index will pause project execution when running from the editor.
    ///
    @inline(__always)
    @inlinable
    public func front() -> Element? where Element: _GodotBridgeableBuiltin {
        array.front().to()
    }
    
    /// Returns the first element of the array. Prints an error and returns `null` if the array is empty.
    ///
    /// > Note: Calling this function is not the same as writing `array[0]`. If the array is empty, accessing by index will pause project execution when running from the editor.
    ///
    @inline(__always)
    @inlinable
    public func front() -> Element where Element._NonOptionalType: _GodotNullableBridgeable {
        unwrapOrCrash(
            array.front().to()
        )
    }
    
    /// Returns the last element of the array. Prints an error and returns `null` if the array is empty.
    ///
    /// > Note: Calling this function is not the same as writing `array[-1]`. If the array is empty, accessing by index will pause project execution when running from the editor.
    @inline(__always)
    @inlinable
    public func back() -> Element? where Element: _GodotBridgeableBuiltin {
        array.back().to()
    }
    
    /// Returns the last element of the array. Prints an error and returns `null` if the array is empty.
    ///
    /// > Note: Calling this function is not the same as writing `array[-1]`. If the array is empty, accessing by index will pause project execution when running from the editor.
    ///
    @inline(__always)
    @inlinable
    public func back() -> Element where Element._NonOptionalType: _GodotNullableBridgeable {
        unwrapOrCrash(
            array.back()
        )
    }
    
    /// Returns a random value from the target array. Prints an error and returns `null` if the array is empty.
    @inline(__always)
    @inlinable
    public func pickRandom() -> Element? where Element: _GodotBridgeableBuiltin {
        array.pickRandom().to()
    }
    
    /// Returns a random value from the target array. Prints an error and returns `null` if the array is empty.
    @inline(__always)
    @inlinable
    public func pickRandom() -> Element where Element._NonOptionalType: _GodotNullableBridgeable {
        unwrapOrCrash(
            array.pickRandom()
        )
    }
    
    /// Searches the array for a value and returns its index or `-1` if not found. Optionally, the initial search index can be passed.
    @inline(__always)
    @inlinable
    public func find(what: Element, from: Int64 = 0) -> Int64 {
        array.find(what: what.toVariant(), from: from)
    }
    
    /// Searches the array in reverse order. Optionally, a start search index can be passed. If negative, the start index is considered relative to the end of the array.
    @inline(__always)
    @inlinable
    public func rfind(what: Element, from: Int64 = -1) -> Int64 {
        array.rfind(what: what.toVariant(), from: from)
    }
    
    /// Returns the number of times an element is in the array.
    @inline(__always)
    @inlinable
    public func count(value: Element) -> Int64 {
        array.count(value: value.toVariant())
    }
    
    /// Returns `true` if the array contains the given value.
    ///
    /// > Note: This is equivalent to using the `in` operator as follows:
    ///
    @inline(__always)
    @inlinable
    public func has(value: Element) -> Bool {
        array.has(value: value.toVariant())
    }
    
    /// Removes and returns the last element of the array. Returns `null` if the array is empty, without printing an error message. See also ``popFront()``.
    @inline(__always)
    @inlinable
    public func popBack() -> Element? where Element: _GodotBridgeableBuiltin {
        array.popBack().to()
    }
    
    /// Removes and returns the last element of the array. Returns `null` if the array is empty, without printing an error message. See also ``popFront()``.
    @inline(__always)
    @inlinable
    public func popBack() -> Element where Element._NonOptionalType: _GodotNullableBridgeable {
        unwrapOrCrash(array.popBack().to())
    }
    
    /// Removes and returns the first element of the array. Returns `null` if the array is empty, without printing an error message. See also ``popBack()``.
    ///
    /// > Note: On large arrays, this method is much slower than ``popBack()`` as it will reindex all the array's elements every time it's called. The larger the array, the slower ``popFront()`` will be.
    @inline(__always)
    @inlinable
    public func popFront() -> Element? where Element: _GodotBridgeableBuiltin {
        array.popFront().to()
    }
    
    /// Removes and returns the first element of the array. Returns `null` if the array is empty, without printing an error message. See also ``popBack()``.
    ///
    /// > Note: On large arrays, this method is much slower than ``popBack()`` as it will reindex all the array's elements every time it's called. The larger the array, the slower ``popFront()`` will be.
    ///
    @inline(__always)
    @inlinable
    public func popFront() -> Element where Element._NonOptionalType: _GodotNullableBridgeable {
        unwrapOrCrash(
            array.popFront()
        )
    }
    
    /// Removes and returns the element of the array at index `position`. If negative, `position` is considered relative to the end of the array. Leaves the array untouched and returns `null` if the array is empty or if it's accessed out of bounds. An error message is printed when the array is accessed out of bounds, but not when the array is empty.
    ///
    /// > Note: On large arrays, this method can be slower than ``popBack()`` as it will reindex the array's elements that are located after the removed element. The larger the array and the lower the index of the removed element, the slower ``popAt(position:)`` will be.
    @inline(__always)
    @inlinable
    public func popAt(position: Int64) -> Element? where Element: _GodotBridgeableBuiltin {
        array.popAt(position: position).to()
    }
    
    /// Removes and returns the element of the array at index `position`. If negative, `position` is considered relative to the end of the array. Leaves the array untouched and returns `null` if the array is empty or if it's accessed out of bounds. An error message is printed when the array is accessed out of bounds, but not when the array is empty.
    ///
    /// > Note: On large arrays, this method can be slower than ``popBack()`` as it will reindex the array's elements that are located after the removed element. The larger the array and the lower the index of the removed element, the slower ``popAt(position:)`` will be.
    @inline(__always)
    @inlinable
    public func popAt(position: Int64) -> Element where Element._NonOptionalType: _GodotNullableBridgeable {
        unwrapOrCrash(
            array.popAt(position: position),
            at: position
        )
    }
    
    /// `Element` is `Object?` here.
    /// It doesn't throw if it's `nil`, it returns `nil`.
    /// It only throws if the incompatible type was stored which is an invariant violation and a bug that we need to fix.
    @inline(__always)
    @usableFromInline
    func unwrapOrCrash(_ variant: Variant?, invoking function: StaticString = #function, at index: Int64? = nil) -> Element {
        do {
            return try Element.fromVariantOrThrow(variant)
        } catch {
            typeInvariantViolation(invoking: function, error: error, at: index)
        }
    }
    
    /// `Element` is `Object?` here.
    /// It doesn't throw if it's `nil`, it returns `nil`.
    /// It only throws if the incompatible type was stored which is an invariant violation and a bug that we need to fix.
    @inline(__always)
    @usableFromInline
    func unwrapOrCrash(_ variant: borrowing FastVariant?, invoking function: StaticString = #function, at index: Int64? = nil) -> Element {
        do {
            return try Element.fromFastVariantOrThrow(variant)
        } catch {
            typeInvariantViolation(invoking: function, error: error, at: index)
        }
    }
        
    @inline(__always)
    @inlinable
    func typeInvariantViolation(invoking function: StaticString, error: VariantConversionError, at index: Int64?) -> Never {
        let atIndex = index.map { " at index \($0)" } ?? ""
        fatalError("Fatal error during `TypedArray<\(Element.self)>.\(function)` from \(array.debugDescription)\(atIndex). Type invariant violated. \(error.description)")
    }
    
    /// Sorts the array.
    ///
    /// > Note: The sorting algorithm used is not [url=https://en.wikipedia.org/wiki/Sorting_algorithm#Stability]stable[/url]. This means that values considered equal may have their order changed when using ``sort()``.
    ///
    /// > Note: Strings are sorted in alphabetical order (as opposed to natural order). This may lead to unexpected behavior when sorting an array of strings ending with a sequence of numbers. Consider the following example:
    ///
    /// To perform natural order sorting, you can use ``sortCustom(`func`:)`` with ``String/naturalnocasecmpTo(to:)`` as follows:
    ///
    @inline(__always)
    @inlinable
    public func sort() {
        array.sort()
    }
    
    /// Sorts the array using a custom method. The custom method receives two arguments (a pair of elements from the array) and must return either `true` or `false`. For two elements `a` and `b`, if the given method returns `true`, element `b` will be after element `a` in the array.
    ///
    /// > Note: The sorting algorithm used is not [url=https://en.wikipedia.org/wiki/Sorting_algorithm#Stability]stable[/url]. This means that values considered equal may have their order changed when using ``sortCustom(`func`:)``.
    ///
    /// > Note: You cannot randomize the return value as the heapsort algorithm expects a deterministic result. Randomizing the return value will result in unexpected behavior.
    ///
    @inline(__always)
    @inlinable
    public func sortCustom(`func`: Callable) {
        array.sortCustom(func: `func`)
    }
    
    /// Shuffles the array such that the items will have a random order. This method uses the global random number generator common to methods such as ``@GlobalScope.randi``. Call ``@GlobalScope.randomize`` to ensure that a new seed will be used each time if you want non-reproducible shuffling.
    @inline(__always)
    @inlinable
    public func shuffle() {
        array.shuffle()
    }
        
    /// Finds the index of an existing value (or the insertion index that maintains sorting order, if the value is not yet present in the array) using binary search. Optionally, a `before` specifier can be passed. If `false`, the returned index comes after all existing entries of the value in the array.
    ///
    /// > Note: Calling ``bsearch(value:before:)`` on an unsorted array results in unexpected behavior.
    ///
    @inline(__always)
    @inlinable
    public func bsearch(value: Element, before: Bool = true) -> Int64 {
        array.bsearch(value: value.toVariant(), before: before)
    }
    
    /// Finds the index of an existing value (or the insertion index that maintains sorting order, if the value is not yet present in the array) using binary search and a custom comparison method. Optionally, a `before` specifier can be passed. If `false`, the returned index comes after all existing entries of the value in the array. The custom method receives two arguments (an element from the array and the value searched for) and must return `true` if the first argument is less than the second, and return `false` otherwise.
    ///
    /// > Note: Calling ``bsearchCustom(value:`func`:before:)`` on an unsorted array results in unexpected behavior.
    ///
    @inline(__always)
    @inlinable
    public func bsearchCustom(value: Element, `func`: Callable, before: Bool = true) -> Int64 {
        array.bsearchCustom(value: value.toVariant(), func: `func`, before: before)
    }
    
    /// Reverses the order of the elements in the array.
    @inline(__always)
    @inlinable
    public func reverse() {
        array.reverse()
    }
    
    /// Returns `true` if the array is typed the same as `array`.
    @inline(__always)
    @inlinable
    public func isSameTyped(array: VariantArray) -> Bool {
        return array.isSameTyped(array: array)
    }
    
    /// Returns the ``Variant.GType`` constant for a typed array.
    @inline(__always)
    @inlinable
    public func getTypedBuiltin() -> Int64 {
        Element._variantType.rawValue
    }
    
    /// Returns a class name  if ``DeclaredElement`` is derived from ``Object``, otherwise return an empty ``StringName``.
    @inline(__always)
    @inlinable
    public func getTypedClassName() -> StringName {
        if let type = Element.self as? Object.Type {
            return type.godotClassName
        } else {
            return ""
        }
    }
    
    /// Returns the script associated with a typed array tied to a class name.
    @inline(__always)
    @inlinable
    public func getTypedScript() -> Variant? {
        array.getTypedScript()
    }
        
    /// Makes the array read-only, i.e. disabled modifying of the array's elements. Does not apply to nested content, e.g. content of nested arrays.
    @inline(__always)
    @inlinable
    public func makeReadOnly() {
        array.makeReadOnly()
    }
        
    /// Returns `true` if the array is read-only. See ``makeReadOnly()``. Arrays are automatically read-only if declared with `const` keyword.
    @inline(__always)
    @inlinable
    public func isReadOnly()-> Bool {
        array.isReadOnly()
    }
}

public extension Variant {
    /// Initialize ``Variant`` by wrapping ``TypedArray``
    convenience init<T>(_ from: TypedArray<T>) where T: _GodotContainerTypingParameter {
        self.init(from.array)
    }
    
    /// Initialize ``Variant`` by wrapping ``TypedArray?``, fails if it's `nil`
    convenience init?<T>(_ from: TypedArray<T>?) where T: _GodotContainerTypingParameter {
        guard let from else {
            return nil
        }
        self.init(from)
    }
}

public extension FastVariant {
    /// Initialize ``FastVariant`` by wrapping ``TypedArray``
    init<T>(_ from: TypedArray<T>) where T: _GodotContainerTypingParameter {
        self.init(from.array)
    }
    
    /// Initialize ``FastVariant`` by wrapping ``TypedArray?``, fails if it's `nil`
    init?<T>(_ from: TypedArray<T>?) where T: _GodotContainerTypingParameter {
        guard let from else {
            return nil
        }
        self.init(from)
    }
}

