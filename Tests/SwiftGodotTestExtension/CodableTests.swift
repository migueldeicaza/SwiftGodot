//
//  CodableTests.swift
//  SwiftGodotTestExtension
//
//  Tests for Codable round-trips of Variant and Godot builtin types.
//

import Foundation
@testable import SwiftGodot

@SwiftGodotTestSuite
final class CodableTests {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Struct builtins (synthesized Codable)

    @SwiftGodotTest
    public func testVector3Codable() {
        let original = Vector3(x: 1.5, y: 2.5, z: 3.5)
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(Vector3.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    @SwiftGodotTest
    public func testColorCodable() {
        let original = Color(r: 0.1, g: 0.2, b: 0.3, a: 1.0)
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(Color.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    @SwiftGodotTest
    public func testTransform3DCodable() {
        let original = Transform3D()
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(Transform3D.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    // MARK: - String-like types

    @SwiftGodotTest
    public func testStringNameCodable() {
        let original = StringName("TestString")
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(StringName.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    @SwiftGodotTest
    public func testNodePathCodable() {
        let original = NodePath("/root/Node/Child")
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(NodePath.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    @SwiftGodotTest
    public func testGStringCodable() {
        let original = GString("Hello, Godot!")
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(GString.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    // MARK: - Packed arrays

    @SwiftGodotTest
    public func testPackedFloat64ArrayCodable() {
        let original = PackedFloat64Array([1.0, 2.0, 3.0, 4.0, 5.0])
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(PackedFloat64Array.self, from: data)
        XCTAssertEqual(Int(decoded.size()), 5)
        for i in 0..<5 {
            XCTAssertEqual(original[i], decoded[i])
        }
    }

    @SwiftGodotTest
    public func testPackedByteArrayCodable() {
        let original = PackedByteArray([0, 1, 2, 255])
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(PackedByteArray.self, from: data)
        XCTAssertEqual(Int(decoded.size()), 4)
        for i in 0..<4 {
            XCTAssertEqual(original[i], decoded[i])
        }
    }

    @SwiftGodotTest
    public func testPackedStringArrayCodable() {
        let original = PackedStringArray(["hello", "world", "godot"])
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(PackedStringArray.self, from: data)
        XCTAssertEqual(Int(decoded.size()), 3)
        for i in 0..<3 {
            XCTAssertEqual(original[i], decoded[i])
        }
    }

    @SwiftGodotTest
    public func testPackedVector3ArrayCodable() {
        let original = PackedVector3Array([Vector3(x: 1, y: 2, z: 3), Vector3(x: 4, y: 5, z: 6)])
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(PackedVector3Array.self, from: data)
        XCTAssertEqual(Int(decoded.size()), 2)
        for i in 0..<2 {
            XCTAssertEqual(original[i], decoded[i])
        }
    }

    // MARK: - Variant

    @SwiftGodotTest
    public func testVariantCodable() {
        let intVariant = Variant(42 as Int64)
        let data = try! encoder.encode(intVariant)
        let decoded = try! decoder.decode(Variant.self, from: data)
        XCTAssertEqual(Int64(decoded), 42)

        let stringVariant = Variant("hello")
        let data2 = try! encoder.encode(stringVariant)
        let decoded2 = try! decoder.decode(Variant.self, from: data2)
        XCTAssertEqual(String(decoded2), "hello")

        let boolVariant = Variant(true)
        let data3 = try! encoder.encode(boolVariant)
        let decoded3 = try! decoder.decode(Variant.self, from: data3)
        XCTAssertEqual(Bool(decoded3), true)
    }

    @SwiftGodotTest
    public func testVariantWithVector3Codable() {
        let vec = Vector3(x: 10, y: 20, z: 30)
        let variant = Variant(vec)
        let data = try! encoder.encode(variant)
        let decoded = try! decoder.decode(Variant.self, from: data)
        XCTAssertEqual(Vector3(decoded), vec)
    }

    // MARK: - VariantArray

    @SwiftGodotTest
    public func testVariantArrayCodable() {
        let array = VariantArray()
        array.append(Variant(1 as Int64))
        array.append(Variant("two"))
        array.append(Variant(3.0))
        array.append(nil) // nil element

        let data = try! encoder.encode(array)
        let decoded = try! decoder.decode(VariantArray.self, from: data)

        XCTAssertEqual(Int(decoded.size()), 4)
        XCTAssertEqual(Int64(decoded[0]!), 1)
        XCTAssertEqual(String(decoded[1]!), "two")
        XCTAssertEqual(Double(decoded[2]!), 3.0)
        XCTAssertEqual(decoded[3] == nil, true)
    }

    // MARK: - VariantDictionary

    @SwiftGodotTest
    public func testVariantDictionaryCodable() {
        let dict = VariantDictionary()
        dict["key1"] = Variant(42 as Int64)
        dict["key2"] = Variant("value2")

        let data = try! encoder.encode(dict)
        let decoded = try! decoder.decode(VariantDictionary.self, from: data)

        XCTAssertEqual(Int(decoded.size()), 2)
    }

    // MARK: - Non-serializable types

    @SwiftGodotTest
    public func testVariantObjectEncodingThrows() {
        let node = Node()
        let variant = Variant(node)
        var didThrow = false
        do {
            _ = try encoder.encode(variant)
        } catch {
            didThrow = true
        }
        XCTAssertEqual(didThrow, true, "Encoding a Variant containing an Object should throw")
    }

    // MARK: - TypedArray

    @SwiftGodotTest
    public func testTypedArrayCodable() {
        let original: TypedArray<Int> = [10, 20, 30, 40, 50]
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(TypedArray<Int>.self, from: data)
        XCTAssertEqual(decoded.count, 5)
        for i in 0..<5 {
            XCTAssertEqual(original[i], decoded[i])
        }
    }

    @SwiftGodotTest
    public func testTypedArrayVector3Codable() {
        let original: TypedArray<Vector3> = [
            Vector3(x: 1, y: 2, z: 3),
            Vector3(x: 4, y: 5, z: 6)
        ]
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(TypedArray<Vector3>.self, from: data)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(original[0], decoded[0])
        XCTAssertEqual(original[1], decoded[1])
    }

    // MARK: - TypedDictionary

    @SwiftGodotTest
    public func testTypedDictionaryCodable() {
        let original: TypedDictionary<Int, GString> = [1: "one", 2: "two", 3: "three"]
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(TypedDictionary<Int, GString>.self, from: data)
        XCTAssertEqual(Int(decoded.size()), 3)
    }

    // MARK: - CodableTaggedRepresentation

    @SwiftGodotTest
    public func testCodableTaggedRepresentationRoundTrip() {
        let tagged = Variant.CodableTaggedRepresentation.vector3(Vector3(x: 1, y: 2, z: 3))
        let data = try! encoder.encode(tagged)
        let decoded = try! decoder.decode(Variant.CodableTaggedRepresentation.self, from: data)
        XCTAssertEqual(tagged, decoded)
    }

    // MARK: - Complex nested types

    @SwiftGodotTest
    public func testVariantArrayNestedInVariantArray() {
        let inner1 = VariantArray()
        inner1.append(Variant(1 as Int64))
        inner1.append(Variant(2 as Int64))

        let inner2 = VariantArray()
        inner2.append(Variant("a"))
        inner2.append(Variant("b"))
        inner2.append(Variant("c"))

        let outer = VariantArray()
        outer.append(Variant(inner1))
        outer.append(Variant(inner2))
        outer.append(Variant(99 as Int64))

        let data = try! encoder.encode(outer)
        let decoded = try! decoder.decode(VariantArray.self, from: data)

        XCTAssertEqual(Int(decoded.size()), 3)

        let decodedInner1 = VariantArray(decoded[0]!)!
        XCTAssertEqual(Int(decodedInner1.size()), 2)
        XCTAssertEqual(Int64(decodedInner1[0]!), 1)
        XCTAssertEqual(Int64(decodedInner1[1]!), 2)

        let decodedInner2 = VariantArray(decoded[1]!)!
        XCTAssertEqual(Int(decodedInner2.size()), 3)
        XCTAssertEqual(String(decodedInner2[0]!), "a")
        XCTAssertEqual(String(decodedInner2[1]!), "b")
        XCTAssertEqual(String(decodedInner2[2]!), "c")

        XCTAssertEqual(Int64(decoded[2]!), 99)
    }

    @SwiftGodotTest
    public func testVariantDictionaryNestedInVariantArray() {
        let dict = VariantDictionary()
        dict["name"] = Variant("Godot")
        dict["version"] = Variant(4 as Int64)

        let array = VariantArray()
        array.append(Variant(dict))
        array.append(Variant(true))

        let data = try! encoder.encode(array)
        let decoded = try! decoder.decode(VariantArray.self, from: data)

        XCTAssertEqual(Int(decoded.size()), 2)

        let decodedDict = VariantDictionary(decoded[0]!)!
        XCTAssertEqual(Int(decodedDict.size()), 2)
        XCTAssertEqual(String(Variant(takingOver: decodedDict["name"]!)!), "Godot")
        XCTAssertEqual(Int64(Variant(takingOver: decodedDict["version"]!)!), 4)

        XCTAssertEqual(Bool(decoded[1]!), true)
    }

    @SwiftGodotTest
    public func testVariantArrayNestedInVariantDictionary() {
        let colors = VariantArray()
        colors.append(Variant(Color(r: 1, g: 0, b: 0, a: 1)))
        colors.append(Variant(Color(r: 0, g: 1, b: 0, a: 1)))

        let dict = VariantDictionary()
        dict["label"] = Variant("palette")
        dict["colors"] = Variant(colors)
        dict["count"] = Variant(2 as Int64)

        let data = try! encoder.encode(dict)
        let decoded = try! decoder.decode(VariantDictionary.self, from: data)

        XCTAssertEqual(Int(decoded.size()), 3)

        let decodedColors = VariantArray(Variant(takingOver: decoded["colors"]!)!)!
        XCTAssertEqual(Int(decodedColors.size()), 2)
        XCTAssertEqual(Color(decodedColors[0]!), Color(r: 1, g: 0, b: 0, a: 1))
        XCTAssertEqual(Color(decodedColors[1]!), Color(r: 0, g: 1, b: 0, a: 1))
    }

    @SwiftGodotTest
    public func testDeeplyNestedVariantStructure() {
        // Build: { "transform": Transform3D, "children": [ { "pos": Vector3, "tags": ["a","b"] } ] }
        let tags = VariantArray()
        tags.append(Variant("enemy"))
        tags.append(Variant("visible"))

        let child = VariantDictionary()
        child["pos"] = Variant(Vector3(x: 10, y: 20, z: 30))
        child["tags"] = Variant(tags)

        let children = VariantArray()
        children.append(Variant(child))

        let root = VariantDictionary()
        root["transform"] = Variant(Transform3D())
        root["children"] = Variant(children)

        let data = try! encoder.encode(root)
        let decoded = try! decoder.decode(VariantDictionary.self, from: data)

        XCTAssertEqual(Int(decoded.size()), 2)

        let decodedChildren = VariantArray(Variant(takingOver: decoded["children"]!)!)!
        XCTAssertEqual(Int(decodedChildren.size()), 1)

        let decodedChild = VariantDictionary(decodedChildren[0]!)!
        XCTAssertEqual(Vector3(Variant(takingOver: decodedChild["pos"]!)!), Vector3(x: 10, y: 20, z: 30))

        let decodedTags = VariantArray(Variant(takingOver: decodedChild["tags"]!)!)!
        XCTAssertEqual(Int(decodedTags.size()), 2)
        XCTAssertEqual(String(decodedTags[0]!), "enemy")
        XCTAssertEqual(String(decodedTags[1]!), "visible")
    }

    @SwiftGodotTest
    public func testVariantArrayMixedTypesWithNils() {
        let array = VariantArray()
        array.append(Variant(Vector2(x: 1, y: 2)))
        array.append(nil)
        array.append(Variant(Color(r: 1, g: 0, b: 0, a: 1)))
        array.append(nil)
        array.append(Variant(PackedInt64Array([10, 20, 30])))
        array.append(Variant(3.14))

        let data = try! encoder.encode(array)
        let decoded = try! decoder.decode(VariantArray.self, from: data)

        XCTAssertEqual(Int(decoded.size()), 6)
        XCTAssertEqual(Vector2(decoded[0]!), Vector2(x: 1, y: 2))
        XCTAssertEqual(decoded[1] == nil, true)
        XCTAssertEqual(Color(decoded[2]!), Color(r: 1, g: 0, b: 0, a: 1))
        XCTAssertEqual(decoded[3] == nil, true)

        let decodedPacked = PackedInt64Array(decoded[4]!)!
        XCTAssertEqual(Int(decodedPacked.size()), 3)
        XCTAssertEqual(decodedPacked[0], 10)
        XCTAssertEqual(decodedPacked[1], 20)
        XCTAssertEqual(decodedPacked[2], 30)

        XCTAssertEqual(Double(decoded[5]!), 3.14)
    }

    @SwiftGodotTest
    public func testTypedDictionaryWithVector3Values() {
        let original: TypedDictionary<GString, Vector3> = [
            "origin": Vector3(x: 0, y: 0, z: 0),
            "target": Vector3(x: 100, y: 50, z: -30),
            "up": Vector3(x: 0, y: 1, z: 0)
        ]
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(TypedDictionary<GString, Vector3>.self, from: data)

        XCTAssertEqual(Int(decoded.size()), 3)
        XCTAssertEqual(decoded[GString("origin")], Vector3(x: 0, y: 0, z: 0))
        XCTAssertEqual(decoded[GString("target")], Vector3(x: 100, y: 50, z: -30))
        XCTAssertEqual(decoded[GString("up")], Vector3(x: 0, y: 1, z: 0))
    }

    @SwiftGodotTest
    public func testTypedArrayOfColorRoundTrip() {
        let original: TypedArray<Color> = [
            Color(r: 1, g: 0, b: 0, a: 1),
            Color(r: 0, g: 1, b: 0, a: 0.5),
            Color(r: 0, g: 0, b: 1, a: 0),
        ]
        let data = try! encoder.encode(original)
        let decoded = try! decoder.decode(TypedArray<Color>.self, from: data)

        XCTAssertEqual(decoded.count, 3)
        XCTAssertEqual(decoded[0], Color(r: 1, g: 0, b: 0, a: 1))
        XCTAssertEqual(decoded[1], Color(r: 0, g: 1, b: 0, a: 0.5))
        XCTAssertEqual(decoded[2], Color(r: 0, g: 0, b: 1, a: 0))
    }

    @SwiftGodotTest
    public func testVariantDictionaryWithPackedArrayValues() {
        let dict = VariantDictionary()
        dict["vertices"] = Variant(PackedVector3Array([
            Vector3(x: 0, y: 0, z: 0),
            Vector3(x: 1, y: 0, z: 0),
            Vector3(x: 0, y: 1, z: 0),
        ]))
        dict["colors"] = Variant(PackedColorArray([
            Color(r: 1, g: 0, b: 0, a: 1),
            Color(r: 0, g: 1, b: 0, a: 1),
            Color(r: 0, g: 0, b: 1, a: 1),
        ]))
        dict["indices"] = Variant(PackedInt32Array([0, 1, 2]))

        let data = try! encoder.encode(dict)
        let decoded = try! decoder.decode(VariantDictionary.self, from: data)

        XCTAssertEqual(Int(decoded.size()), 3)

        let verts = PackedVector3Array(Variant(takingOver: decoded["vertices"]!)!)!
        XCTAssertEqual(Int(verts.size()), 3)
        XCTAssertEqual(verts[0], Vector3(x: 0, y: 0, z: 0))
        XCTAssertEqual(verts[1], Vector3(x: 1, y: 0, z: 0))
        XCTAssertEqual(verts[2], Vector3(x: 0, y: 1, z: 0))

        let cols = PackedColorArray(Variant(takingOver: decoded["colors"]!)!)!
        XCTAssertEqual(Int(cols.size()), 3)

        let idxs = PackedInt32Array(Variant(takingOver: decoded["indices"]!)!)!
        XCTAssertEqual(Int(idxs.size()), 3)
        XCTAssertEqual(idxs[0], 0)
        XCTAssertEqual(idxs[1], 1)
        XCTAssertEqual(idxs[2], 2)
    }

    @SwiftGodotTest
    public func testVariantContainingNestedArrayOfDictionaries() {
        // Simulate a scene-like structure:
        // Variant wrapping [ {"name": "Player", "pos": Vector2}, {"name": "Enemy", "pos": Vector2} ]
        let entity1 = VariantDictionary()
        entity1["name"] = Variant("Player")
        entity1["pos"] = Variant(Vector2(x: 100, y: 200))
        entity1["health"] = Variant(100 as Int64)

        let entity2 = VariantDictionary()
        entity2["name"] = Variant("Enemy")
        entity2["pos"] = Variant(Vector2(x: 300, y: 400))
        entity2["health"] = Variant(50 as Int64)

        let entities = VariantArray()
        entities.append(Variant(entity1))
        entities.append(Variant(entity2))

        let variant = Variant(entities)
        let data = try! encoder.encode(variant)
        let decoded = try! decoder.decode(Variant.self, from: data)

        let decodedEntities = VariantArray(decoded)!
        XCTAssertEqual(Int(decodedEntities.size()), 2)

        let decodedPlayer = VariantDictionary(decodedEntities[0]!)!
        XCTAssertEqual(String(Variant(takingOver: decodedPlayer["name"]!)!), "Player")
        XCTAssertEqual(Vector2(Variant(takingOver: decodedPlayer["pos"]!)!), Vector2(x: 100, y: 200))
        XCTAssertEqual(Int64(Variant(takingOver: decodedPlayer["health"]!)!), 100)

        let decodedEnemy = VariantDictionary(decodedEntities[1]!)!
        XCTAssertEqual(String(Variant(takingOver: decodedEnemy["name"]!)!), "Enemy")
        XCTAssertEqual(Vector2(Variant(takingOver: decodedEnemy["pos"]!)!), Vector2(x: 300, y: 400))
        XCTAssertEqual(Int64(Variant(takingOver: decodedEnemy["health"]!)!), 50)
    }

    @SwiftGodotTest
    public func testAllStructBuiltinsInVariantArray() {
        let array = VariantArray()
        array.append(Variant(Vector2(x: 1, y: 2)))
        array.append(Variant(Vector2i(x: 3, y: 4)))
        array.append(Variant(Vector3(x: 5, y: 6, z: 7)))
        array.append(Variant(Vector3i(x: 8, y: 9, z: 10)))
        array.append(Variant(Vector4(x: 11, y: 12, z: 13, w: 14)))
        array.append(Variant(Rect2(position: Vector2(x: 0, y: 0), size: Vector2(x: 100, y: 200))))
        array.append(Variant(Plane(normal: Vector3(x: 0, y: 1, z: 0), d: 5)))
        array.append(Variant(Color(r: 0.5, g: 0.6, b: 0.7, a: 0.8)))
        array.append(Variant(Quaternion(x: 0, y: 0, z: 0, w: 1)))
        array.append(Variant(AABB(position: Vector3(x: 0, y: 0, z: 0), size: Vector3(x: 1, y: 1, z: 1))))

        let data = try! encoder.encode(array)
        let decoded = try! decoder.decode(VariantArray.self, from: data)

        XCTAssertEqual(Int(decoded.size()), 10)
        XCTAssertEqual(Vector2(decoded[0]!), Vector2(x: 1, y: 2))
        XCTAssertEqual(Vector2i(decoded[1]!), Vector2i(x: 3, y: 4))
        XCTAssertEqual(Vector3(decoded[2]!), Vector3(x: 5, y: 6, z: 7))
        XCTAssertEqual(Vector3i(decoded[3]!), Vector3i(x: 8, y: 9, z: 10))
        XCTAssertEqual(Vector4(decoded[4]!), Vector4(x: 11, y: 12, z: 13, w: 14))
        XCTAssertEqual(Rect2(decoded[5]!), Rect2(position: Vector2(x: 0, y: 0), size: Vector2(x: 100, y: 200)))
        XCTAssertEqual(Plane(decoded[6]!), Plane(normal: Vector3(x: 0, y: 1, z: 0), d: 5))
        XCTAssertEqual(Color(decoded[7]!), Color(r: 0.5, g: 0.6, b: 0.7, a: 0.8))
        XCTAssertEqual(Quaternion(decoded[8]!), Quaternion(x: 0, y: 0, z: 0, w: 1))
        XCTAssertEqual(AABB(decoded[9]!), AABB(position: Vector3(x: 0, y: 0, z: 0), size: Vector3(x: 1, y: 1, z: 1)))
    }
}
