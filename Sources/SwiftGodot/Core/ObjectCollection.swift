//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 4/11/23.
//

@_implementationOnly import GDExtension

/// Protocol implemented by the built-in classes in Godot to allow to be wrapped in a ``Variant``
public protocol GodotObject {
    init (nativeHandle: UnsafeRawPointer)
}

/// This represents a typed array of one of the built-in types from Godot
public class ObjectCollection<Element: Object>: Collection {
    var array: GArray
    
    init (content: Int64) {
        array = GArray (content: content)
        initType()
    }
    
    func initType () {
        let name = StringName()
        let variant = Variant()

        gi.array_set_typed (&array.content, GDExtensionVariantType (GDExtensionVariantType.RawValue(Variant.GType.object.rawValue)), &name.content, &variant.content)
    }
    
    init () {
        array = GArray ()
        initType()
    }
    
    /// Creates a new instance from the given variant if it contains a GArray
    public init? (_ variant: Variant) {
        if let array = GArray (variant) {
            self.array = array
            initType()
        } else {
            return nil
        }
    }
    
    /// Converts a Variant to the strongly typed value T
    func toStrong (_ v: Variant) -> Element {
        var handle = UnsafeMutableRawPointer(bitPattern: 0)
        v.toType(.object, dest: &handle)
        return lookupObject(nativeHandle: handle!)!
    }
    
    // If I make this optional, I am told I need to implement an internal _read method
    /// Accesses the element at the specified position.
    public subscript (index: Index) -> Element {
        get {
            toStrong (array [index])
        }
        set {
            array [index] = Variant (newValue)
        }
    }
    
    // Required nested types, that tell Swift what our collection contains
    public typealias Index = Int
    
    /// The position of the first element in a nonempty collection.
    public var startIndex: Index { 0 }
    /// The collection’s “past the end” position—that is, the position one greater than the last valid subscript argument.
    public var endIndex: Index { Int (array.size()) }
    
    /// Returns the position immediately after the given index.
    public func index(after i: Index) -> Index {
        return i+1
    }
    
    /// Returns the number of elements in the array.
    public final func size ()-> Int64 {
        return array.size ()
    }

    /// Returns `true` if the array is empty.
    public final func isEmpty ()-> Bool {
        array.isEmpty()
    }
    
    /// Clears the array. This is equivalent to using ``resize(size:)`` with a size of `0`.
    public final func clear () {
        array.clear()
    }

    /// Returns a hashed 32-bit integer value representing the array and its contents.
    ///
    /// > Note: ``GArray``s with equal content will always produce identical hash values. However, the reverse is not true. Returning identical hash values does _not_ imply the arrays are equal, because different arrays can have identical hash values due to hash collisions.
    ///
    public final func hash ()-> Int64 {
        array.hash ()
    }
    
    /// Appends an element at the end of the array. See also ``pushFront(value:)``.
    public final func pushBack (value: Element) {
        array.pushBack(value: Variant (value))
    }
    
    /// Adds an element at the beginning of the array. See also ``pushBack(value:)``.
    ///
    /// > Note: On large arrays, this method is much slower than ``pushBack(value:)`` as it will reindex all the array's elements every time it's called. The larger the array, the slower ``pushFront(value:)`` will be.
    ///
    public final func pushFront (value: Element) {
        array.pushFront (value: Variant (value))
    }
    
    /// Appends an element at the end of the array (alias of ``pushBack(value:)``).
    public final func append (value: Element) {
        array.append (value: Variant (value))
    }
    
    /// Resizes the array to contain a different number of elements. If the array size is smaller, elements are cleared, if bigger, new elements are `null`. Returns ``GodotError/ok`` on success, or one of the other ``GodotError`` values if the operation failed.
    ///
    /// > Note: This method acts in-place and doesn't return a modified array.
    ///
    public final func resize (size: Int64)-> Int64 {
        array.resize (size: size)
    }
    
    /// Inserts a new element at a given position in the array. The position must be valid, or at the end of the array (`pos == size()`). Returns ``GodotError/ok`` on success, or one of the other ``GodotError`` values if the operation failed.
    ///
    /// > Note: This method acts in-place and doesn't return a modified array.
    ///
    /// > Note: On large arrays, this method will be slower if the inserted element is close to the beginning of the array (index 0). This is because all elements placed after the newly inserted element have to be reindexed.
    ///
    public final func insert (position: Int64, value: Element)-> Int64 {
        array.insert (position: position, value: Variant (value))
    }
    
    /// Removes an element from the array by index. If the index does not exist in the array, nothing happens. To remove an element by searching for its value, use ``erase(value:)`` instead.
    ///
    /// > Note: This method acts in-place and doesn't return a modified array.
    ///
    /// > Note: On large arrays, this method will be slower if the removed element is close to the beginning of the array (index 0). This is because all elements placed after the removed element have to be reindexed.
    ///
    /// > Note: `position` cannot be negative. To remove an element relative to the end of the array, use `arr.remove_at(arr.size() - (i + 1))`. To remove the last element from the array without returning the value, use `arr.resize(arr.size() - 1)`.
    ///
    public final func removeAt (position: Int64) {
        array.removeAt (position: position)
    }

    /// Removes the first occurrence of a value from the array. If the value does not exist in the array, nothing happens. To remove an element by index, use ``removeAt(position:)`` instead.
    ///
    /// > Note: This method acts in-place and doesn't return a modified array.
    ///
    /// > Note: On large arrays, this method will be slower if the removed element is close to the beginning of the array (index 0). This is because all elements placed after the removed element have to be reindexed.
    ///
    /// > Note: Do not erase entries while iterating over the array.
    ///
    public final func erase (value: Element) {
        array.erase (value: Variant (value))
    }
    
    /// Returns the first element of the array. Prints an error and returns `null` if the array is empty.
    ///
    /// > Note: Calling this function is not the same as writing `array[0]`. If the array is empty, accessing by index will pause project execution when running from the editor.
    ///
    public final func front ()-> Element {
        toStrong (array.front ())
    }
    
    /// Returns the last element of the array. Prints an error and returns `null` if the array is empty.
    ///
    /// > Note: Calling this function is not the same as writing `array[-1]`. If the array is empty, accessing by index will pause project execution when running from the editor.
    ///
    public final func back ()-> Element {
        toStrong (array.back ())
    }
    
    /// Returns a random value from the target array. Prints an error and returns `null` if the array is empty.
    ///
    public final func pickRandom ()-> Element {
        toStrong (array.pickRandom())
    }

    
    /// Searches the array for a value and returns its index or `-1` if not found. Optionally, the initial search index can be passed.
    public final func find (what: Element, from: Int64 = 0)-> Int64 {
        array.find (what: Variant (what), from: from)
    }
    
    /// Searches the array in reverse order. Optionally, a start search index can be passed. If negative, the start index is considered relative to the end of the array.
    public final func rfind (what: Element, from: Int64 = -1)-> Int64 {
        array.rfind (what: Variant (what), from: from)
    }
    
    /// Returns the number of times an element is in the array.
    public final func count (value: Element)-> Int64 {
        array.count (value: Variant (value))
    }
    
    /// Returns `true` if the array contains the given value.
    ///
    /// > Note: This is equivalent to using the `in` operator as follows:
    ///
    public final func has (value: Element)-> Bool {
        array.has (value: Variant (value))
    }
    
    /// Removes and returns the last element of the array. Returns `null` if the array is empty, without printing an error message. See also ``popFront()``.
    public final func popBack ()-> Element {
        toStrong (array.popBack())
    }
    
    /// Removes and returns the first element of the array. Returns `null` if the array is empty, without printing an error message. See also ``popBack()``.
    ///
    /// > Note: On large arrays, this method is much slower than ``popBack()`` as it will reindex all the array's elements every time it's called. The larger the array, the slower ``popFront()`` will be.
    ///
    public final func popFront ()-> Element {
        toStrong (array.popFront())
    }
    
    /// Removes and returns the element of the array at index `position`. If negative, `position` is considered relative to the end of the array. Leaves the array untouched and returns `null` if the array is empty or if it's accessed out of bounds. An error message is printed when the array is accessed out of bounds, but not when the array is empty.
    ///
    /// > Note: On large arrays, this method can be slower than ``popBack()`` as it will reindex the array's elements that are located after the removed element. The larger the array and the lower the index of the removed element, the slower ``popAt(position:)`` will be.
    ///
    public final func popAt (position: Int64)-> Element {
        toStrong (array.popAt (position: position))
    }
    
    /// Sorts the array.
    ///
    /// > Note: The sorting algorithm used is not [url=https://en.wikipedia.org/wiki/Sorting_algorithm#Stability]stable[/url]. This means that values considered equal may have their order changed when using ``sort()``.
    ///
    /// > Note: Strings are sorted in alphabetical order (as opposed to natural order). This may lead to unexpected behavior when sorting an array of strings ending with a sequence of numbers. Consider the following example:
    ///
    /// To perform natural order sorting, you can use ``sortCustom(`func`:)`` with ``String/naturalnocasecmpTo(to:)`` as follows:
    ///
    public final func sort () {
        array.sort ()
    }
    
    /// Sorts the array using a custom method. The custom method receives two arguments (a pair of elements from the array) and must return either `true` or `false`. For two elements `a` and `b`, if the given method returns `true`, element `b` will be after element `a` in the array.
    ///
    /// > Note: The sorting algorithm used is not [url=https://en.wikipedia.org/wiki/Sorting_algorithm#Stability]stable[/url]. This means that values considered equal may have their order changed when using ``sortCustom(`func`:)``.
    ///
    /// > Note: You cannot randomize the return value as the heapsort algorithm expects a deterministic result. Randomizing the return value will result in unexpected behavior.
    ///
    public final func sortCustom (`func`: Callable) {
        array.sortCustom(func: `func`)
    }
    
    /// Shuffles the array such that the items will have a random order. This method uses the global random number generator common to methods such as ``@GlobalScope.randi``. Call ``@GlobalScope.randomize`` to ensure that a new seed will be used each time if you want non-reproducible shuffling.
    public final func shuffle () {
        array.shuffle()
    }
        
    /// Finds the index of an existing value (or the insertion index that maintains sorting order, if the value is not yet present in the array) using binary search. Optionally, a `before` specifier can be passed. If `false`, the returned index comes after all existing entries of the value in the array.
    ///
    /// > Note: Calling ``bsearch(value:before:)`` on an unsorted array results in unexpected behavior.
    ///
    public final func bsearch (value: Element, before: Bool = true)-> Int64 {
        array.bsearch(value: Variant (value), before: before)
    }
    
    /// Finds the index of an existing value (or the insertion index that maintains sorting order, if the value is not yet present in the array) using binary search and a custom comparison method. Optionally, a `before` specifier can be passed. If `false`, the returned index comes after all existing entries of the value in the array. The custom method receives two arguments (an element from the array and the value searched for) and must return `true` if the first argument is less than the second, and return `false` otherwise.
    ///
    /// > Note: Calling ``bsearchCustom(value:`func`:before:)`` on an unsorted array results in unexpected behavior.
    ///
    public final func bsearchCustom (value: Element, `func`: Callable, before: Bool = true)-> Int64 {
        array.bsearchCustom(value: Variant(value), func: `func`, before: before)
    }
    
    /// Reverses the order of the elements in the array.
    public final func reverse () {
        array.reverse ()
    }
    
    /// Returns `true` if the array is typed. Typed arrays can only store elements of their associated type and provide type safety for the `[]` operator. Methods of typed array still return ``Variant``.
    public final func isTyped ()-> Bool {
        array.isTyped()
    }
    
    /// Returns `true` if the array is typed the same as `array`.
    public final func isSameTyped (array: GArray)-> Bool {
        return array.isSameTyped(array: array)
    }
    
    /// Returns the ``Variant.GType`` constant for a typed array. If the ``GArray`` is not typed, returns ``Variant.GType/`nil```.
    public final func getTypedBuiltin ()-> Int64 {
        array.getTypedBuiltin()
    }
    
    /// Returns a class name of a typed ``GArray`` of type ``Variant.GType/object``.
    public final func getTypedClassName ()-> StringName {
        array.getTypedClassName()
    }
    
    /// Returns the script associated with a typed array tied to a class name.
    public final func getTypedScript ()-> Variant {
        array.getTypedScript()
    }
        
    /// Makes the array read-only, i.e. disabled modifying of the array's elements. Does not apply to nested content, e.g. content of nested arrays.
    public final func makeReadOnly () {
        array.makeReadOnly()
    }
        
    /// Returns `true` if the array is read-only. See ``makeReadOnly()``. Arrays are automatically read-only if declared with `const` keyword.
    public final func isReadOnly ()-> Bool {
        array.isReadOnly()
    }
}
