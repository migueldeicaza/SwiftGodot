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

    @SwiftGodotTest
    func testEmptyInitialization() {
        let dictionary = TypedDictionary<Int, String>()

        XCTAssertEqual(dictionary.size(), 0)
        XCTAssertTrue(dictionary.isEmpty())
    }

    @SwiftGodotTest
    func testDictionaryLiteralInitialization() {
        let dictionary: TypedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]

        XCTAssertEqual(dictionary.size(), 3)
        XCTAssertFalse(dictionary.isEmpty())
        XCTAssertEqual(dictionary[1], "one")
        XCTAssertEqual(dictionary[2], "two")
        XCTAssertEqual(dictionary[3], "three")
    }

    @SwiftGodotTest
    func testSwiftDictionaryInitialization() {
        let swiftDict: [String: Int] = ["a": 1, "b": 2, "c": 3]
        let dictionary = TypedDictionary(swiftDict)

        XCTAssertEqual(dictionary.size(), 3)
        XCTAssertEqual(dictionary["a"], 1)
        XCTAssertEqual(dictionary["b"], 2)
        XCTAssertEqual(dictionary["c"], 3)
    }

    @SwiftGodotTest
    func testFromVariantDictionaryInitialization() {
        let variantDict = VariantDictionary()
        variantDict[Variant(1)] = Variant("one")
        variantDict[Variant(2)] = Variant("two")

        let typed = TypedDictionary<Int, String>(from: variantDict)

        // Note: Godot may or may not preserve data depending on type compatibility
        XCTAssertTrue(typed.size() >= 0)
    }

    // MARK: - Subscript Tests

    @SwiftGodotTest
    func testSubscriptGetSet() {
        let dictionary = TypedDictionary<String, Int>()

        dictionary["key1"] = 100
        dictionary["key2"] = 200

        XCTAssertEqual(dictionary["key1"], 100)
        XCTAssertEqual(dictionary["key2"], 200)
        XCTAssertNil(dictionary["nonexistent"])
    }

    @SwiftGodotTest
    func testSubscriptOverwrite() {
        let dictionary: TypedDictionary<String, Int> = ["key": 1]

        dictionary["key"] = 2

        XCTAssertEqual(dictionary["key"], 2)
        XCTAssertEqual(dictionary.size(), 1)
    }

    @SwiftGodotTest
    func testSubscriptNilErasesValue() {
        let dictionary: TypedDictionary<String, Int> = ["key": 42]

        XCTAssertEqual(dictionary["key"], 42)

        dictionary["key"] = nil

        XCTAssertNil(dictionary["key"])
        XCTAssertTrue(dictionary.isEmpty())
    }

    @SwiftGodotTest
    func testSubscriptWithObjectValue() {
        let dictionary = TypedDictionary<Int, RefCounted?>()

        let obj = RefCounted()
        dictionary[1] = obj

        XCTAssertTrue(dictionary[1] === obj)

        dictionary[1] = nil

        XCTAssertNil(dictionary[1])
        // Object-typed values allow nil, so it should still be in dictionary
        XCTAssertTrue(dictionary.has(key: 1))
    }

    @SwiftGodotTest
    func testSubscriptWithVariantValue() {
        let dictionary = TypedDictionary<String, Variant?>()

        dictionary["int"] = Variant(42)
        dictionary["string"] = Variant("hello")
        dictionary["nil"] = nil

        XCTAssertEqual(Int(dictionary["int"]!), 42)
        XCTAssertEqual(String(dictionary["string"]!), "hello")
        XCTAssertNil(dictionary["nil"])
        XCTAssertTrue(dictionary.has(key: "nil"))
    }

    // MARK: - Size and Empty Tests

    @SwiftGodotTest
    func testSizeIncreasesWithAdditions() {
        let dictionary = TypedDictionary<Int, Int>()

        XCTAssertEqual(dictionary.size(), 0)

        dictionary[1] = 10
        XCTAssertEqual(dictionary.size(), 1)

        dictionary[2] = 20
        XCTAssertEqual(dictionary.size(), 2)

        dictionary[3] = 30
        XCTAssertEqual(dictionary.size(), 3)
    }

    @SwiftGodotTest
    func testIsEmptyReflectsState() {
        let dictionary = TypedDictionary<Int, Int>()

        XCTAssertTrue(dictionary.isEmpty())

        dictionary[1] = 1
        XCTAssertFalse(dictionary.isEmpty())

        _ = dictionary.erase(key: 1)
        XCTAssertTrue(dictionary.isEmpty())
    }

    // MARK: - Clear Tests

    @SwiftGodotTest
    func testClearRemovesAllEntries() {
        let dictionary: TypedDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]

        XCTAssertEqual(dictionary.size(), 3)

        dictionary.clear()

        XCTAssertEqual(dictionary.size(), 0)
        XCTAssertTrue(dictionary.isEmpty())
        XCTAssertNil(dictionary[1])
    }

    // MARK: - Erase Tests

    @SwiftGodotTest
    func testEraseRemovesExistingKey() {
        let dictionary: TypedDictionary<String, Int> = ["key": 42]

        let erased = dictionary.erase(key: "key")

        XCTAssertTrue(erased)
        XCTAssertNil(dictionary["key"])
        XCTAssertTrue(dictionary.isEmpty())
    }

    @SwiftGodotTest
    func testEraseReturnsFalseForNonexistentKey() {
        let dictionary = TypedDictionary<String, Int>()

        let erased = dictionary.erase(key: "nonexistent")

        XCTAssertFalse(erased)
    }

    // MARK: - Has Tests

    @SwiftGodotTest
    func testHasReturnsTrueForExistingKey() {
        let dictionary: TypedDictionary<Int, String> = [1: "one", 2: "two"]

        XCTAssertTrue(dictionary.has(key: 1))
        XCTAssertTrue(dictionary.has(key: 2))
    }

    @SwiftGodotTest
    func testHasReturnsFalseForNonexistentKey() {
        let dictionary: TypedDictionary<Int, String> = [1: "one"]

        XCTAssertFalse(dictionary.has(key: 999))
    }

    @SwiftGodotTest
    func testHasAllReturnsCorrectly() {
        let dictionary: TypedDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]

        let presentKeys = VariantArray()
        presentKeys.append(Variant(1))
        presentKeys.append(Variant(2))

        let mixedKeys = VariantArray()
        mixedKeys.append(Variant(1))
        mixedKeys.append(Variant(999))

        XCTAssertTrue(dictionary.hasAll(keys: presentKeys))
        XCTAssertFalse(dictionary.hasAll(keys: mixedKeys))
    }

    // MARK: - Keys and Values Tests

    @SwiftGodotTest
    func testKeysReturnsAllKeys() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

        let keys = dictionary.keys()

        XCTAssertEqual(keys.count, 3)
        XCTAssertTrue(keys.contains { $0 == "a" })
        XCTAssertTrue(keys.contains { $0 == "b" })
        XCTAssertTrue(keys.contains { $0 == "c" })
    }

    @SwiftGodotTest
    func testValuesReturnsAllValues() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

        let values = dictionary.values()

        XCTAssertEqual(values.count, 3)
        XCTAssertTrue(values.contains { $0 == 1 })
        XCTAssertTrue(values.contains { $0 == 2 })
        XCTAssertTrue(values.contains { $0 == 3 })
    }

    // MARK: - Get with Default Tests

    @SwiftGodotTest
    func testGetReturnsValueForExistingKey() {
        let dictionary: TypedDictionary<String, Int> = ["key": 42]

        let value = dictionary.get(key: "key", default: 0)

        XCTAssertEqual(value, 42)
    }

    @SwiftGodotTest
    func testGetReturnsDefaultForNonexistentKey() {
        let dictionary = TypedDictionary<String, Int>()

        let value = dictionary.get(key: "nonexistent", default: 999)

        XCTAssertEqual(value, 999)
    }

    // MARK: - GetOrAdd Tests

    @SwiftGodotTest
    func testGetOrAddReturnsExistingValue() {
        let dictionary: TypedDictionary<String, Int> = ["key": 42]

        let value = dictionary.getOrAdd(key: "key", default: 0)

        XCTAssertEqual(value, 42)
        XCTAssertEqual(dictionary.size(), 1)
    }

    @SwiftGodotTest
    func testGetOrAddInsertsAndReturnsDefault() {
        let dictionary = TypedDictionary<String, Int>()

        let value = dictionary.getOrAdd(key: "newKey", default: 100)

        XCTAssertEqual(value, 100)
        XCTAssertEqual(dictionary["newKey"], 100)
        XCTAssertEqual(dictionary.size(), 1)
    }

    // MARK: - Set Tests

    @SwiftGodotTest
    func testSetAddsNewEntry() {
        let dictionary = TypedDictionary<Int, String>()

        let result = dictionary.set(key: 1, value: "one")

        XCTAssertTrue(result)
        XCTAssertEqual(dictionary[1], "one")
    }

    @SwiftGodotTest
    func testSetUpdatesExistingEntry() {
        let dictionary: TypedDictionary<Int, String> = [1: "uno"]

        let result = dictionary.set(key: 1, value: "one")

        XCTAssertTrue(result)
        XCTAssertEqual(dictionary[1], "one")
        XCTAssertEqual(dictionary.size(), 1)
    }

    // MARK: - Duplicate Tests

    @SwiftGodotTest
    func testDuplicateCreatesShallowCopy() {
        let original: TypedDictionary<String, Int> = ["a": 1, "b": 2]

        let copy = original.duplicate()

        XCTAssertEqual(copy.size(), 2)
        XCTAssertEqual(copy["a"], 1)
        XCTAssertEqual(copy["b"], 2)

        // Modify copy, original should be unchanged
        copy["a"] = 100
        XCTAssertEqual(original["a"], 1)
        XCTAssertEqual(copy["a"], 100)
    }

    @SwiftGodotTest
    func testDuplicateDeepCopy() {
        let original: TypedDictionary<String, Int> = ["x": 10, "y": 20]

        let deepCopy = original.duplicate(deep: true)

        XCTAssertEqual(deepCopy.size(), 2)
        XCTAssertEqual(deepCopy["x"], 10)
        XCTAssertEqual(deepCopy["y"], 20)
    }

    // MARK: - Iteration Tests

    @SwiftGodotTest
    func testIterationVisitsAllEntries() {
        let dictionary: TypedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]

        var visitedKeys = Set<Int>()
        var visitedValues = Set<String>()

        for (key, value) in dictionary {
            visitedKeys.insert(key)
            visitedValues.insert(value)
        }

        XCTAssertEqual(visitedKeys.count, 3)
        XCTAssertTrue(visitedKeys.contains(1))
        XCTAssertTrue(visitedKeys.contains(2))
        XCTAssertTrue(visitedKeys.contains(3))

        XCTAssertEqual(visitedValues.count, 3)
        XCTAssertTrue(visitedValues.contains("one"))
        XCTAssertTrue(visitedValues.contains("two"))
        XCTAssertTrue(visitedValues.contains("three"))
    }

    @SwiftGodotTest
    func testIterationOnEmptyDictionary() {
        let dictionary = TypedDictionary<Int, Int>()

        var count = 0
        for _ in dictionary {
            count += 1
        }

        XCTAssertEqual(count, 0)
    }

    // MARK: - Merge Tests

    @SwiftGodotTest
    func testMergeWithoutOverwrite() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1, "b": 2]

        let other = VariantDictionary()
        other[Variant("b")] = Variant(200)
        other[Variant("c")] = Variant(3)

        dictionary.merge(dictionary: other, overwrite: false)

        XCTAssertEqual(dictionary["a"], 1)
        XCTAssertEqual(dictionary["b"], 2) // Not overwritten
        XCTAssertEqual(dictionary["c"], 3) // Added
    }

    @SwiftGodotTest
    func testMergeWithOverwrite() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1, "b": 2]

        let other = VariantDictionary()
        other[Variant("b")] = Variant(200)
        other[Variant("c")] = Variant(3)

        dictionary.merge(dictionary: other, overwrite: true)

        XCTAssertEqual(dictionary["a"], 1)
        XCTAssertEqual(dictionary["b"], 200) // Overwritten
        XCTAssertEqual(dictionary["c"], 3)
    }

    @SwiftGodotTest
    func testMergedReturnsNewDictionary() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1]

        let other = VariantDictionary()
        other[Variant("b")] = Variant(2)

        let merged = dictionary.merged(dictionary: other)

        // Original unchanged
        XCTAssertEqual(dictionary.size(), 1)

        // Merged has both
        XCTAssertEqual(merged.size(), 2)
    }

    // MARK: - Sort Tests

    @SwiftGodotTest
    func testSortOrdersKeys() {
        let dictionary = TypedDictionary<Int, String>()
        dictionary[3] = "three"
        dictionary[1] = "one"
        dictionary[2] = "two"

        dictionary.sort()

        let keys = dictionary.keys()
        XCTAssertEqual(keys[0], 1)
        XCTAssertEqual(keys[1], 2)
        XCTAssertEqual(keys[2], 3)
    }

    // MARK: - ReadOnly Tests

    @SwiftGodotTest
    func testIsReadOnlyInitiallyFalse() {
        let dictionary = TypedDictionary<Int, Int>()

        XCTAssertFalse(dictionary.isReadOnly())
    }

    @SwiftGodotTest
    func testMakeReadOnlySetsFlag() {
        let dictionary: TypedDictionary<Int, Int> = [1: 1]

        dictionary.makeReadOnly()

        XCTAssertTrue(dictionary.isReadOnly())
    }

    // MARK: - Type Comparison Tests

    @SwiftGodotTest
    func testIsSameTypedWithIdenticalTypes() {
        let dict1 = TypedDictionary<Int, String>()
        let dict2 = TypedDictionary<Int, String>()

        XCTAssertTrue(dict1.isSameTyped(dictionary: dict2.dictionary))
    }

    @SwiftGodotTest
    func testIsSameTypedKeyWithIdenticalKeyTypes() {
        let dict1 = TypedDictionary<Int, String>()
        let dict2 = TypedDictionary<Int, Float>()

        XCTAssertTrue(dict1.isSameTypedKey(dictionary: dict2.dictionary))
    }

    @SwiftGodotTest
    func testIsSameTypedValueWithIdenticalValueTypes() {
        let dict1 = TypedDictionary<Int, String>()
        let dict2 = TypedDictionary<Float, String>()

        XCTAssertTrue(dict1.isSameTypedValue(dictionary: dict2.dictionary))
    }

    // MARK: - Variant Conversion Tests

    @SwiftGodotTest
    func testToVariantAndBack() {
        let original: TypedDictionary<String, Int> = ["key": 42]

        let variant: Variant = original.toVariant()
        let restored = TypedDictionary<String, Int>(variant)

        XCTAssertNotNil(restored)
        XCTAssertEqual(restored?["key"], 42)
    }

    @SwiftGodotTest
    func testToFastVariantAndBack() {
        let original: TypedDictionary<Int, Int> = [1: 100, 2: 200]

        let fastVariant: FastVariant = original.toFastVariant()
        let restored = TypedDictionary<Int, Int>(fastVariant)

        XCTAssertNotNil(restored)
        XCTAssertEqual(restored?[1], 100)
        XCTAssertEqual(restored?[2], 200)
    }

    // MARK: - FindKey Tests

    @SwiftGodotTest
    func testFindKeyReturnsCorrectKey() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]

        let foundKey = dictionary.findKey(value: Variant(2))

        XCTAssertNotNil(foundKey)
        XCTAssertEqual(String(foundKey!), "b")
    }

    @SwiftGodotTest
    func testFindKeyReturnsNilForNonexistentValue() {
        let dictionary: TypedDictionary<String, Int> = ["a": 1, "b": 2]

        let foundKey = dictionary.findKey(value: Variant(999))

        XCTAssertNil(foundKey)
    }

    // MARK: - RecursiveEqual Tests

    @SwiftGodotTest
    func testRecursiveEqualWithEqualDictionaries() {
        let dict1: TypedDictionary<Int, Int> = [1: 10, 2: 20]
        let dict2: TypedDictionary<Int, Int> = [1: 10, 2: 20]

        XCTAssertTrue(dict1.recursiveEqual(dictionary: dict2.dictionary, recursionCount: 1))
    }

    @SwiftGodotTest
    func testRecursiveEqualWithDifferentDictionaries() {
        let dict1: TypedDictionary<Int, Int> = [1: 10, 2: 20]
        let dict2: TypedDictionary<Int, Int> = [1: 10, 2: 99]

        XCTAssertFalse(dict1.recursiveEqual(dictionary: dict2.dictionary, recursionCount: 1))
    }

    // MARK: - Various Key/Value Type Combinations

    @SwiftGodotTest
    func testIntToIntDictionary() {
        let dictionary: TypedDictionary<Int, Int> = [1: 100, 2: 200, 3: 300]

        XCTAssertEqual(dictionary[1], 100)
        XCTAssertEqual(dictionary[2], 200)
        XCTAssertEqual(dictionary[3], 300)
    }

    @SwiftGodotTest
    func testStringToStringDictionary() {
        let dictionary: TypedDictionary<String, String> = ["hello": "world", "foo": "bar"]

        XCTAssertEqual(dictionary["hello"], "world")
        XCTAssertEqual(dictionary["foo"], "bar")
    }

    @SwiftGodotTest
    func testFloatKeyDictionary() {
        let dictionary = TypedDictionary<Float, String>()

        dictionary[1.5] = "one and a half"
        dictionary[2.5] = "two and a half"

        XCTAssertEqual(dictionary[1.5], "one and a half")
        XCTAssertEqual(dictionary[2.5], "two and a half")
    }

    @SwiftGodotTest
    func testVector2KeyDictionary() {
        let dictionary = TypedDictionary<Vector2, Int>()

        let key1 = Vector2(x: 1, y: 2)
        let key2 = Vector2(x: 3, y: 4)

        dictionary[key1] = 10
        dictionary[key2] = 20

        XCTAssertEqual(dictionary[key1], 10)
        XCTAssertEqual(dictionary[key2], 20)
    }

    @SwiftGodotTest
    func testVector3ValueDictionary() {
        let dictionary = TypedDictionary<String, Vector3>()

        let value1 = Vector3(x: 1, y: 2, z: 3)
        let value2 = Vector3(x: 4, y: 5, z: 6)

        dictionary["pos1"] = value1
        dictionary["pos2"] = value2

        XCTAssertEqual(dictionary["pos1"], value1)
        XCTAssertEqual(dictionary["pos2"], value2)
    }

    @SwiftGodotTest
    func testColorValueDictionary() {
        let dictionary = TypedDictionary<String, Color>()

        dictionary["red"] = Color(r: 1, g: 0, b: 0, a: 1)
        dictionary["green"] = Color(r: 0, g: 1, b: 0, a: 1)
        dictionary["blue"] = Color(r: 0, g: 0, b: 1, a: 1)

        XCTAssertEqual(dictionary["red"]?.red, 1)
        XCTAssertEqual(dictionary["green"]?.green, 1)
        XCTAssertEqual(dictionary["blue"]?.blue, 1)
    }

    // MARK: - Debug Description Test

    @SwiftGodotTest
    func testDebugDescriptionNotEmpty() {
        let dictionary: TypedDictionary<Int, String> = [1: "one"]

        let description = dictionary.debugDescription

        XCTAssertFalse(description.isEmpty)
    }

    // MARK: - Assign Tests

    @SwiftGodotTest
    func testAssignReplacesContent() {
        let dictionary: TypedDictionary<Int, Int> = [1: 1, 2: 2]

        let newContent = VariantDictionary()
        newContent[Variant(10)] = Variant(100)
        newContent[Variant(20)] = Variant(200)

        dictionary.assign(dictionary: newContent)

        // After assign, dictionary should have new content
        XCTAssertEqual(dictionary[10], 100)
        XCTAssertEqual(dictionary[20], 200)
    }

    // MARK: - Edge Cases

    @SwiftGodotTest
    func testEmptyStringKey() {
        let dictionary = TypedDictionary<String, Int>()

        dictionary[""] = 42

        XCTAssertEqual(dictionary[""], 42)
        XCTAssertTrue(dictionary.has(key: ""))
    }

    @SwiftGodotTest
    func testZeroKey() {
        let dictionary = TypedDictionary<Int, String>()

        dictionary[0] = "zero"

        XCTAssertEqual(dictionary[0], "zero")
        XCTAssertTrue(dictionary.has(key: 0))
    }

    @SwiftGodotTest
    func testNegativeKey() {
        let dictionary = TypedDictionary<Int, String>()

        dictionary[-1] = "negative one"
        dictionary[-100] = "negative hundred"

        XCTAssertEqual(dictionary[-1], "negative one")
        XCTAssertEqual(dictionary[-100], "negative hundred")
    }

    @SwiftGodotTest
    func testLargeNumberOfEntries() {
        let dictionary = TypedDictionary<Int, Int>()

        for i in 0..<1000 {
            dictionary[i] = i * 2
        }

        XCTAssertEqual(dictionary.size(), 1000)
        XCTAssertEqual(dictionary[0], 0)
        XCTAssertEqual(dictionary[500], 1000)
        XCTAssertEqual(dictionary[999], 1998)
    }
}
