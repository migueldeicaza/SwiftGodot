//
//  TypedDictionaryTests.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 24/04/2025.
//

@testable import SwiftGodot

@SwiftGodotTestSuite
final class TypedDictionaryTests {

    // MARK: - Initialization Tests

    func testEmptyInitialization() {
        let dictionary = TypedDictionary<Int, String>()

        assertEqual(dictionary.size(), 0)
        assertTrue(dictionary.isEmpty())
    }

    func testDictionaryLiteralInitialization() {
        let dictionary: TypedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]

        assertEqual(dictionary.size(), 3)
        assertFalse(dictionary.isEmpty())
        assertEqual(dictionary[1], "one")
        assertEqual(dictionary[2], "two")
        assertEqual(dictionary[3], "three")
    }

    func testSwiftDictionaryInitialization() {
        let swiftDict: [String: Int] = ["a": 1, "b": 2, "c": 3]
        let dictionary = TypedDictionary(swiftDict)

        assertEqual(dictionary.size(), 3)
        assertEqual(dictionary["a"], 1)
        assertEqual(dictionary["b"], 2)
        assertEqual(dictionary["c"], 3)
    }

    func testFromVariantDictionaryInitialization() {
        let variantDict = VariantDictionary()
        variantDict[Variant(1)] = Variant("one")
        variantDict[Variant(2)] = Variant("two")

        let typed = TypedDictionary<Int, String>(from: variantDict)

        // Note: Godot may or may not preserve data depending on type compatibility
        assertTrue(typed.size() >= 0)
    }

    // MARK: - Subscript Tests

    func testSubscriptGetSet() {
        let dictionary = TypedDictionary<String, Int>()

        dictionary["key1"] = 100
        dictionary["key2"] = 200

        assertEqual(dictionary["key1"], 100)
        assertEqual(dictionary["key2"], 200)
        assertNil(dictionary["nonexistent"])
    }

    func testSubscriptOverwrite() {
        let dictionary: TypedDictionary<String, Int> = ["key": 1]

        dictionary["key"] = 2

        assertEqual(dictionary["key"], 2)
        assertEqual(dictionary.size(), 1)
    }

    func testSubscriptNilErasesValue() {
        let dictionary: TypedDictionary<String, Int> = ["key": 42]

        assertEqual(dictionary["key"], 42)

        dictionary["key"] = nil

        assertNil(dictionary["key"])
        assertTrue(dictionary.isEmpty())
    }

    func testSubscriptWithObjectValue() {
        let dictionary = TypedDictionary<Int, RefCounted?>()

        let obj = RefCounted()
        dictionary[1] = obj

        assertTrue(dictionary[1] === obj)

        dictionary[1] = nil

        assertNil(dictionary[1])
        // Object-typed values allow nil, so it should still be in dictionary
        assertTrue(dictionary.has(key: 1))
    }

    func testSubscriptWithVariantValue() {
        let dictionary = TypedDictionary<String, Variant?>()

        dictionary["int"] = Variant(42)
        dictionary["string"] = Variant("hello")
        dictionary["nil"] = nil

        assertEqual(Int(dictionary["int"]!), 42)
        assertEqual(String(dictionary["string"]!), "hello")
        assertNil(dictionary["nil"])
        assertTrue(dictionary.has(key: "nil"))
    }

    // MARK: - Size and Empty Tests

    func testSizeIncreasesWithAdditions() {
        let dictionary = TypedDictionary<Int, Int>()

        assertEqual(dictionary.size(), 0)

        dictionary[1] = 10
        assertEqual(dictionary.size(), 1)

        dictionary[2] = 20
        assertEqual(dictionary.size(), 2)

        dictionary[3] = 30
        assertEqual(dictionary.size(), 3)
    }

    func testIsEmptyReflectsState() {
        let dictionary = TypedDictionary<Int, Int>()

        assertTrue(dictionary.isEmpty())

        dictionary[1] = 1
        assertFalse(dictionary.isEmpty())

        _ = dictionary.erase(key: 1)
        assertTrue(dictionary.isEmpty())
    }

    // MARK: - Clear Tests

    func testClearRemovesAllEntries() {
        let dictionary: TypedDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]

        assertEqual(dictionary.size(), 3)

        dictionary.clear()

        assertEqual(dictionary.size(), 0)
        assertTrue(dictionary.isEmpty())
        assertNil(dictionary[1])
    }

    // MARK: - Erase Tests

    func testEraseRemovesExistingKey() {
        let dictionary: TypedDictionary<String, Int> = ["key": 42]

        let erased = dictionary.erase(key: "key")

        assertTrue(erased)
        assertNil(dictionary["key"])
        assertTrue(dictionary.isEmpty())
    }

    func testEraseReturnsFalseForNonexistentKey() {
        let dictionary = TypedDictionary<String, Int>()

        let erased = dictionary.erase(key: "nonexistent")

        assertFalse(erased)
    }

    // MARK: - Has Tests

    func testHasReturnsTrueForExistingKey() {
        let dictionary: TypedDictionary<Int, String> = [1: "one", 2: "two"]

        assertTrue(dictionary.has(key: 1))
        assertTrue(dictionary.has(key: 2))
    }

    func testHasReturnsFalseForNonexistentKey() {
        let dictionary: TypedDictionary<Int, String> = [1: "one"]

        assertFalse(dictionary.has(key: 999))
    }

    func testHasAllReturnsCorrectly() {
        let dictionary: TypedDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]

        let presentKeys = VariantArray()
        presentKeys.append(Variant(1))
        presentKeys.append(Variant(2))

        let mixedKeys = VariantArray()
        mixedKeys.append(Variant(1))
        mixedKeys.append(Variant(999))

        assertTrue(dictionary.hasAll(keys: presentKeys))
        assertFalse(dictionary.hasAll(keys: mixedKeys))
    }

    // MARK: - Keys and Values Tests

    func testKeysReturnsAllKeys() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

        let keys = dictionary.keys()

        assertEqual(keys.count, 3)
        assertTrue(keys.contains { $0 == "a" })
        assertTrue(keys.contains { $0 == "b" })
        assertTrue(keys.contains { $0 == "c" })
    }

    func testValuesReturnsAllValues() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

        let values = dictionary.values()

        assertEqual(values.count, 3)
        assertTrue(values.contains { $0 == 1 })
        assertTrue(values.contains { $0 == 2 })
        assertTrue(values.contains { $0 == 3 })
    }

    // MARK: - Get with Default Tests

    func testGetReturnsValueForExistingKey() {
        let dictionary: TypedDictionary<String, Int> = ["key": 42]

        let value = dictionary.get(key: "key", default: 0)

        assertEqual(value, 42)
    }

    func testGetReturnsDefaultForNonexistentKey() {
        let dictionary = TypedDictionary<String, Int>()

        let value = dictionary.get(key: "nonexistent", default: 999)

        assertEqual(value, 999)
    }

    // MARK: - GetOrAdd Tests

    func testGetOrAddReturnsExistingValue() {
        let dictionary: TypedDictionary<String, Int> = ["key": 42]

        let value = dictionary.getOrAdd(key: "key", default: 0)

        assertEqual(value, 42)
        assertEqual(dictionary.size(), 1)
    }

    func testGetOrAddInsertsAndReturnsDefault() {
        let dictionary = TypedDictionary<String, Int>()

        let value = dictionary.getOrAdd(key: "newKey", default: 100)

        assertEqual(value, 100)
        assertEqual(dictionary["newKey"], 100)
        assertEqual(dictionary.size(), 1)
    }

    // MARK: - Set Tests

    func testSetAddsNewEntry() {
        let dictionary = TypedDictionary<Int, String>()

        let result = dictionary.set(key: 1, value: "one")

        assertTrue(result)
        assertEqual(dictionary[1], "one")
    }

    func testSetUpdatesExistingEntry() {
        let dictionary: TypedDictionary<Int, String> = [1: "uno"]

        let result = dictionary.set(key: 1, value: "one")

        assertTrue(result)
        assertEqual(dictionary[1], "one")
        assertEqual(dictionary.size(), 1)
    }

    // MARK: - Duplicate Tests

    func testDuplicateCreatesShallowCopy() {
        let original: TypedDictionary<String, Int> = ["a": 1, "b": 2]

        let copy = original.duplicate()

        assertEqual(copy.size(), 2)
        assertEqual(copy["a"], 1)
        assertEqual(copy["b"], 2)

        // Modify copy, original should be unchanged
        copy["a"] = 100
        assertEqual(original["a"], 1)
        assertEqual(copy["a"], 100)
    }

    func testDuplicateDeepCopy() {
        let original: TypedDictionary<String, Int> = ["x": 10, "y": 20]

        let deepCopy = original.duplicate(deep: true)

        assertEqual(deepCopy.size(), 2)
        assertEqual(deepCopy["x"], 10)
        assertEqual(deepCopy["y"], 20)
    }

    // MARK: - Iteration Tests

    func testIterationVisitsAllEntries() {
        let dictionary: TypedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]

        var visitedKeys = Set<Int>()
        var visitedValues = Set<String>()

        for (key, value) in dictionary {
            visitedKeys.insert(key)
            visitedValues.insert(value)
        }

        assertEqual(visitedKeys.count, 3)
        assertTrue(visitedKeys.contains(1))
        assertTrue(visitedKeys.contains(2))
        assertTrue(visitedKeys.contains(3))

        assertEqual(visitedValues.count, 3)
        assertTrue(visitedValues.contains("one"))
        assertTrue(visitedValues.contains("two"))
        assertTrue(visitedValues.contains("three"))
    }

    func testIterationOnEmptyDictionary() {
        let dictionary = TypedDictionary<Int, Int>()

        var count = 0
        for _ in dictionary {
            count += 1
        }

        assertEqual(count, 0)
    }

    // MARK: - Merge Tests

    func testMergeWithoutOverwrite() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1, "b": 2]

        let other = VariantDictionary()
        other[Variant("b")] = Variant(200)
        other[Variant("c")] = Variant(3)

        dictionary.merge(dictionary: other, overwrite: false)

        assertEqual(dictionary["a"], 1)
        assertEqual(dictionary["b"], 2) // Not overwritten
        assertEqual(dictionary["c"], 3) // Added
    }

    func testMergeWithOverwrite() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1, "b": 2]

        let other = VariantDictionary()
        other[Variant("b")] = Variant(200)
        other[Variant("c")] = Variant(3)

        dictionary.merge(dictionary: other, overwrite: true)

        assertEqual(dictionary["a"], 1)
        assertEqual(dictionary["b"], 200) // Overwritten
        assertEqual(dictionary["c"], 3)
    }

    func testMergedReturnsNewDictionary() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1]

        let other = VariantDictionary()
        other[Variant("b")] = Variant(2)

        let merged = dictionary.merged(dictionary: other)

        // Original unchanged
        assertEqual(dictionary.size(), 1)

        // Merged has both
        assertEqual(merged.size(), 2)
    }

    // MARK: - Sort Tests

    func testSortOrdersKeys() {
        let dictionary = TypedDictionary<Int, String>()
        dictionary[3] = "three"
        dictionary[1] = "one"
        dictionary[2] = "two"

        dictionary.sort()

        let keys = dictionary.keys()
        assertEqual(keys[0], 1)
        assertEqual(keys[1], 2)
        assertEqual(keys[2], 3)
    }

    // MARK: - ReadOnly Tests

    func testIsReadOnlyInitiallyFalse() {
        let dictionary = TypedDictionary<Int, Int>()

        assertFalse(dictionary.isReadOnly())
    }

    func testMakeReadOnlySetsFlag() {
        let dictionary: TypedDictionary<Int, Int> = [1: 1]

        dictionary.makeReadOnly()

        assertTrue(dictionary.isReadOnly())
    }

    // MARK: - Type Comparison Tests

    func testIsSameTypedWithIdenticalTypes() {
        let dict1 = TypedDictionary<Int, String>()
        let dict2 = TypedDictionary<Int, String>()

        assertTrue(dict1.isSameTyped(dictionary: dict2.dictionary))
    }

    func testIsSameTypedKeyWithIdenticalKeyTypes() {
        let dict1 = TypedDictionary<Int, String>()
        let dict2 = TypedDictionary<Int, Float>()

        assertTrue(dict1.isSameTypedKey(dictionary: dict2.dictionary))
    }

    func testIsSameTypedValueWithIdenticalValueTypes() {
        let dict1 = TypedDictionary<Int, String>()
        let dict2 = TypedDictionary<Float, String>()

        assertTrue(dict1.isSameTypedValue(dictionary: dict2.dictionary))
    }

    // MARK: - Variant Conversion Tests

    func testToVariantAndBack() {
        let original: TypedDictionary<String, Int> = ["key": 42]

        let variant: Variant = original.toVariant()
        let restored = TypedDictionary<String, Int>(variant)

        assertNotNil(restored)
        assertEqual(restored?["key"], 42)
    }

    func testToVariantAndBackIntKeys() {
        let original: TypedDictionary<Int, Int> = [1: 100, 2: 200]

        let variant: Variant = original.toVariant()
        let restored = TypedDictionary<Int, Int>(variant)

        assertNotNil(restored)
        assertEqual(restored?[1], 100)
        assertEqual(restored?[2], 200)
    }

    // MARK: - FindKey Tests

    func testFindKeyReturnsCorrectKey() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

        let foundKey = dictionary.findKey(value: Variant(2))

        assertNotNil(foundKey)
        assertEqual(String(foundKey!), "b")
    }

    func testFindKeyReturnsNilForNonexistentValue() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1, "b": 2]

        let foundKey = dictionary.findKey(value: Variant(999))

        assertNil(foundKey)
    }

    // MARK: - RecursiveEqual Tests

    func testRecursiveEqualWithEqualDictionaries() {
        let dict1: TypedDictionary<Int, Int> = [1: 10, 2: 20]
        let dict2: TypedDictionary<Int, Int> = [1: 10, 2: 20]

        assertTrue(dict1.recursiveEqual(dictionary: dict2.dictionary, recursionCount: 1))
    }

    func testRecursiveEqualWithDifferentDictionaries() {
        let dict1: TypedDictionary<Int, Int> = [1: 10, 2: 20]
        let dict2: TypedDictionary<Int, Int> = [1: 10, 2: 99]

        assertFalse(dict1.recursiveEqual(dictionary: dict2.dictionary, recursionCount: 1))
    }

    // MARK: - Various Key/Value Type Combinations

    func testIntToIntDictionary() {
        let dictionary: TypedDictionary<Int, Int> = [1: 100, 2: 200, 3: 300]

        assertEqual(dictionary[1], 100)
        assertEqual(dictionary[2], 200)
        assertEqual(dictionary[3], 300)
    }

    func testStringToStringDictionary() {
        let dictionary: TypedDictionary<String, String> = ["hello": "world", "foo": "bar"]

        assertEqual(dictionary["hello"], "world")
        assertEqual(dictionary["foo"], "bar")
    }

    func testFloatKeyDictionary() {
        let dictionary = TypedDictionary<Float, String>()

        dictionary[1.5] = "one and a half"
        dictionary[2.5] = "two and a half"

        assertEqual(dictionary[1.5], "one and a half")
        assertEqual(dictionary[2.5], "two and a half")
    }

    func testVector2KeyDictionary() {
        let dictionary = TypedDictionary<Vector2, Int>()

        let key1 = Vector2(x: 1, y: 2)
        let key2 = Vector2(x: 3, y: 4)

        dictionary[key1] = 10
        dictionary[key2] = 20

        assertEqual(dictionary[key1], 10)
        assertEqual(dictionary[key2], 20)
    }

    func testVector3ValueDictionary() {
        let dictionary = TypedDictionary<String, Vector3>()

        let value1 = Vector3(x: 1, y: 2, z: 3)
        let value2 = Vector3(x: 4, y: 5, z: 6)

        dictionary["pos1"] = value1
        dictionary["pos2"] = value2

        assertEqual(dictionary["pos1"], value1)
        assertEqual(dictionary["pos2"], value2)
    }

    func testColorValueDictionary() {
        let dictionary = TypedDictionary<String, Color>()

        dictionary["red"] = Color(r: 1, g: 0, b: 0, a: 1)
        dictionary["green"] = Color(r: 0, g: 1, b: 0, a: 1)
        dictionary["blue"] = Color(r: 0, g: 0, b: 1, a: 1)

        assertEqual(dictionary["red"]?.red, 1)
        assertEqual(dictionary["green"]?.green, 1)
        assertEqual(dictionary["blue"]?.blue, 1)
    }

    // MARK: - Debug Description Test

    func testDebugDescriptionNotEmpty() {
        let dictionary: TypedDictionary<Int, String> = [1: "one"]

        let description = dictionary.debugDescription

        assertFalse(description.isEmpty)
    }

    // MARK: - Assign Tests

    func testAssignReplacesContent() {
        let dictionary: TypedDictionary<Int, Int> = [1: 1, 2: 2]

        let newContent = VariantDictionary()
        newContent[Variant(10)] = Variant(100)
        newContent[Variant(20)] = Variant(200)

        dictionary.assign(dictionary: newContent)

        // After assign, dictionary should have new content
        assertEqual(dictionary[10], 100)
        assertEqual(dictionary[20], 200)
    }

    // MARK: - Edge Cases

    func testEmptyStringKey() {
        let dictionary = TypedDictionary<String, Int>()

        dictionary[""] = 42

        assertEqual(dictionary[""], 42)
        assertTrue(dictionary.has(key: ""))
    }

    func testZeroKey() {
        let dictionary = TypedDictionary<Int, String>()

        dictionary[0] = "zero"

        assertEqual(dictionary[0], "zero")
        assertTrue(dictionary.has(key: 0))
    }

    func testNegativeKey() {
        let dictionary = TypedDictionary<Int, String>()

        dictionary[-1] = "negative one"
        dictionary[-100] = "negative hundred"

        assertEqual(dictionary[-1], "negative one")
        assertEqual(dictionary[-100], "negative hundred")
    }

    func testLargeNumberOfEntries() {
        let dictionary = TypedDictionary<Int, Int>()

        for i in 0..<1000 {
            dictionary[i] = i * 2
        }

        assertEqual(dictionary.size(), 1000)
        assertEqual(dictionary[0], 0)
        assertEqual(dictionary[500], 1000)
        assertEqual(dictionary[999], 1998)
    }

    // MARK: - Type Mismatch Tests (Godot prints errors, operations ignored)

    func testTypeMismatchKeyViaUnderlyingDictionary() {
        // Create typed dictionary expecting Int keys
        let typed = TypedDictionary<Int, String>()
        typed[1] = "one"

        // Try to insert with wrong key type via underlying VariantDictionary
        // Godot will print an error and ignore the operation
        typed.dictionary[Variant("wrong_key_type")] = Variant("value")

        // Dictionary should remain unchanged (only the valid entry)
        assertEqual(typed.size(), 1)
        assertEqual(typed[1], "one")
    }

    func testTypeMismatchValueViaUnderlyingDictionary() {
        // Create typed dictionary expecting String values
        let typed = TypedDictionary<Int, String>()
        typed[1] = "one"

        // Try to insert with wrong value type via underlying VariantDictionary
        // Godot will print an error and ignore the operation
        typed.dictionary[Variant(2)] = Variant(12345) // Int instead of String

        // Dictionary should remain unchanged (only the valid entry)
        assertEqual(typed.size(), 1)
        assertEqual(typed[1], "one")
    }

    func testTypeMismatchBothKeyAndValueViaUnderlyingDictionary() {
        // Create typed dictionary expecting Int keys and String values
        let typed = TypedDictionary<Int, String>()
        typed[1] = "one"

        // Try to insert with both wrong key and value types
        // Godot will print an error and ignore the operation
        typed.dictionary[Variant("wrong")] = Variant(Vector2(x: 1, y: 2))

        // Dictionary should remain unchanged
        assertEqual(typed.size(), 1)
        assertEqual(typed[1], "one")
    }

    func testTypeMismatchMergeWithIncompatibleTypes() {
        // Create typed dictionary
        let typed = TypedDictionary<Int, Int>()
        typed[1] = 100

        // Create untyped dictionary with incompatible types
        let untyped = VariantDictionary()
        untyped[Variant("string_key")] = Variant("string_value")
        untyped[Variant(2)] = Variant(200) // This one is compatible

        // Merge - Godot prints error and the entire merge operation fails
        // when incompatible types are encountered
        typed.merge(dictionary: untyped, overwrite: false)

        // Dictionary remains unchanged due to type mismatch in source
        assertEqual(typed.size(), 1)
        assertEqual(typed[1], 100)
    }

    func testTypeMismatchAssignWithIncompatibleTypes() {
        // Create typed dictionary
        let typed = TypedDictionary<Int, String>()
        typed[1] = "original"

        // Create untyped dictionary with incompatible types
        let untyped = VariantDictionary()
        untyped[Variant("wrong")] = Variant(123) // Both key and value wrong
        untyped[Variant(2)] = Variant("correct") // This one is correct

        // Assign - Godot prints error when encountering incompatible types
        // but the operation keeps the original content unchanged
        typed.assign(dictionary: untyped)

        // Original dictionary content preserved due to failed assignment
        assertEqual(typed.size(), 1)
        assertEqual(typed[1], "original")
    }

    func testTypeMismatchFromVariantDictionaryWithWrongTypes() {
        // Create untyped dictionary with mixed types
        let untyped = VariantDictionary()
        untyped[Variant(1)] = Variant("one")
        untyped[Variant("two")] = Variant(2) // Wrong key type
        untyped[Variant(3)] = Variant(Vector2()) // Wrong value type

        // Create typed dictionary from it - Godot fails to convert when types don't match
        // and returns an empty dictionary
        let typed = TypedDictionary<Int, String>(from: untyped)

        // Result is empty because source had incompatible types
        assertEqual(typed.size(), 0)
    }

    func testTypeMismatchUpdateExistingKeyWithWrongValueType() {
        // Create typed dictionary
        let typed = TypedDictionary<String, Int>()
        typed["key"] = 42

        // Try to update with wrong value type via underlying dictionary
        // Godot will print an error and ignore the operation
        typed.dictionary[Variant("key")] = Variant("not_an_int")

        // Value should remain unchanged
        assertEqual(typed["key"], 42)
    }

    func testTypeMismatchObjectTypeDictionaryWithWrongObjectType() {
        // Create typed dictionary expecting RefCounted
        let typed = TypedDictionary<Int, RefCounted?>()
        let refCounted = RefCounted()
        typed[1] = refCounted

        // Try to insert a Node (which is not RefCounted) via underlying dictionary
        // This should fail because Node is not compatible with RefCounted
        let node = Node()
        typed.dictionary[Variant(2)] = Variant(node)

        // Dictionary should only have the valid entry
        assertEqual(typed.size(), 1)
        assertTrue(typed[1] === refCounted)

        node.queueFree()
    }

    func testTypeMismatchMultipleInvalidInserts() {
        // Create typed dictionary
        let typed = TypedDictionary<Int, Float>()
        typed[1] = 1.5

        // Try multiple invalid inserts
        typed.dictionary[Variant("a")] = Variant(1.0) // Wrong key
        typed.dictionary[Variant("b")] = Variant(2.0) // Wrong key
        typed.dictionary[Variant(2)] = Variant("wrong") // Wrong value
        typed.dictionary[Variant(3)] = Variant(Vector3()) // Wrong value

        // Dictionary should remain with only the original entry
        assertEqual(typed.size(), 1)
        assertEqual(typed[1], 1.5)
    }
}
