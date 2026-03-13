//
//  VariantCodableTests.swift
//  SwiftGodot
//
//  Created by Evan Wang on 3/11/26.
//

@testable import SwiftGodot
@testable import SwiftGodotRuntime

@SwiftGodotTestSuite
final class VariantCodableTests {

  // MARK: - Test Types

  struct SimpleStruct: VariantCodable, Equatable {
    let name: String
    let damage: Int
    let speed: Double
    let equipped: Bool
  }

  struct NestedStruct: Codable, Equatable {
    let label: String
    let inner: SimpleStruct
  }

  struct ArrayStruct: Codable, Equatable {
    let values: [Int]
    let names: [String]
  }

  struct OptionalStruct: Codable, Equatable {
    let required: String
    let optional: Int?
  }

  enum Direction: String, Codable, Equatable {
    case north
    case south
    case east
    case west
  }

  struct WithEnum: Codable, Equatable {
    let name: String
    let direction: Direction
  }

  struct NestedArrays: Codable, Equatable {
    let matrix: [[Int]]
  }

  struct DictionaryStruct: Codable, Equatable {
    let metadata: [String: String]
  }

  class Animal: Codable, Equatable {
    let name: String
    let legs: Int

    init(name: String, legs: Int) {
      self.name = name
      self.legs = legs
    }

    static func == (lhs: Animal, rhs: Animal) -> Bool {
      lhs.name == rhs.name && lhs.legs == rhs.legs
    }
  }

  class Dog: Animal {
    let breed: String

    init(name: String, legs: Int, breed: String) {
      self.breed = breed
      super.init(name: name, legs: legs)
    }

    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.breed = try container.decode(String.self, forKey: .breed)
      let superDecoder = try container.superDecoder()
      try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(breed, forKey: .breed)
      let superEncoder = container.superEncoder()
      try super.encode(to: superEncoder)
    }

    enum CodingKeys: String, CodingKey {
      case breed
    }

    static func == (lhs: Dog, rhs: Dog) -> Bool {
      lhs.name == rhs.name && lhs.legs == rhs.legs && lhs.breed == rhs.breed
    }
  }

  struct ManualNestedStruct: Codable, Equatable {
    let key: String
    let nestedKey: String
    let nestedValue: Int
    let items: [Int]

    enum OuterKeys: String, CodingKey {
      case key, nested, items
    }

    enum NestedKeys: String, CodingKey {
      case nestedKey, nestedValue
    }

    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: OuterKeys.self)
      try container.encode(key, forKey: .key)
      var nested = container.nestedContainer(keyedBy: NestedKeys.self, forKey: .nested)
      try nested.encode(nestedKey, forKey: .nestedKey)
      try nested.encode(nestedValue, forKey: .nestedValue)
      var unkeyed = container.nestedUnkeyedContainer(forKey: .items)
      for item in items {
        try unkeyed.encode(item)
      }
    }

    init(key: String, nestedKey: String, nestedValue: Int, items: [Int]) {
      self.key = key
      self.nestedKey = nestedKey
      self.nestedValue = nestedValue
      self.items = items
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: OuterKeys.self)
      key = try container.decode(String.self, forKey: .key)
      let nested = try container.nestedContainer(keyedBy: NestedKeys.self, forKey: .nested)
      nestedKey = try nested.decode(String.self, forKey: .nestedKey)
      nestedValue = try nested.decode(Int.self, forKey: .nestedValue)
      var unkeyed = try container.nestedUnkeyedContainer(forKey: .items)
      var itemsArray: [Int] = []
      while !unkeyed.isAtEnd {
        itemsArray.append(try unkeyed.decode(Int.self))
      }
      items = itemsArray
    }
  }

  class Cat: Animal {
    let indoor: Bool

    init(name: String, legs: Int, indoor: Bool) {
      self.indoor = indoor
      super.init(name: name, legs: legs)
    }

    enum CodingKeys: String, CodingKey {
      case indoor, parentData
    }

    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      indoor = try container.decode(Bool.self, forKey: .indoor)
      let superDecoder = try container.superDecoder(forKey: .parentData)
      try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(indoor, forKey: .indoor)
      let superEncoder = container.superEncoder(forKey: .parentData)
      try super.encode(to: superEncoder)
    }

    static func == (lhs: Cat, rhs: Cat) -> Bool {
      lhs.name == rhs.name && lhs.legs == rhs.legs && lhs.indoor == rhs.indoor
    }
  }

  struct NullableArray: Codable, Equatable {
    let values: [Int?]

    func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for value in values {
        if let value {
          try container.encode(value)
        } else {
          try container.encodeNil()
        }
      }
    }

    init(_ values: [Int?]) { self.values = values }

    init(from decoder: Decoder) throws {
      var container = try decoder.unkeyedContainer()
      var result: [Int?] = []
      while !container.isAtEnd {
        if try container.decodeNil() {
          result.append(nil)
        } else {
          result.append(try container.decode(Int.self))
        }
      }
      values = result
    }
  }

  struct CamelCaseStruct: Codable, Equatable {
    let maxHealth: Int
    let attackSpeed: Double
    let isPlayerControlled: Bool
  }

  struct CamelCaseWrapper: Codable, Equatable {
    let inner: CamelCaseStruct

    func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(inner)
    }

    init(inner: CamelCaseStruct) {
      self.inner = inner
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      inner = try container.decode(CamelCaseStruct.self)
    }
  }

  struct CamelCaseArrayHolder: Codable, Equatable {
    let playerName: String
    let statBlocks: [CamelCaseStruct]
  }

  struct UnkeyedNestedStruct: Codable, Equatable {
    let name: String
    let value: Int

    enum InnerKeys: String, CodingKey {
      case name, value
    }

    func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      var keyed = container.nestedContainer(keyedBy: InnerKeys.self)
      try keyed.encode(name, forKey: .name)
      try keyed.encode(value, forKey: .value)
    }

    init(name: String, value: Int) {
      self.name = name
      self.value = value
    }

    init(from decoder: Decoder) throws {
      var container = try decoder.unkeyedContainer()
      let keyed = try container.nestedContainer(keyedBy: InnerKeys.self)
      name = try keyed.decode(String.self, forKey: .name)
      value = try keyed.decode(Int.self, forKey: .value)
    }
  }

  class UnkeyedBase: Codable, Equatable {
    let species: String

    init(species: String) {
      self.species = species
    }

    static func == (lhs: UnkeyedBase, rhs: UnkeyedBase) -> Bool {
      lhs.species == rhs.species
    }

    func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      try container.encode(species)
    }

    required init(from decoder: Decoder) throws {
      var container = try decoder.unkeyedContainer()
      species = try container.decode(String.self)
    }
  }

  class UnkeyedDerived: UnkeyedBase {
    let petName: String

    init(species: String, petName: String) {
      self.petName = petName
      super.init(species: species)
    }

    override func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      try container.encode(petName)
      let superEncoder = container.superEncoder()
      try super.encode(to: superEncoder)
    }

    required init(from decoder: Decoder) throws {
      var container = try decoder.unkeyedContainer()
      petName = try container.decode(String.self)
      let superDecoder = try container.superDecoder()
      try super.init(from: superDecoder)
    }

    static func == (lhs: UnkeyedDerived, rhs: UnkeyedDerived) -> Bool {
      lhs.species == rhs.species && lhs.petName == rhs.petName
    }
  }

  // MARK: - Encoder Tests

  @SwiftGodotTest
  public func testEncodeSimpleStruct() {
    do {
      let value = SimpleStruct(name: "Sword", damage: 42, speed: 1.5, equipped: true)
      let encoder = VariantEncoder()
      try value.encode(to: encoder)

      guard let variant = encoder.value else {
        XCTFail("Encoder produced nil value")
        return
      }

      XCTAssertEqual(variant.gtype, .dictionary)
      guard let dictionary: VariantDictionary = variant.to() else {
        XCTFail("Could not convert to VariantDictionary")
        return
      }

      guard let name = dictionary["name"] else {
        XCTFail("Missing key 'name'")
        return
      }
      XCTAssertEqual(String(name), "Sword")

      guard let damage = dictionary["damage"] else {
        XCTFail("Missing key 'damage'")
        return
      }
      XCTAssertEqual(Int(damage), 42)

      guard let speed = dictionary["speed"] else {
        XCTFail("Missing key 'speed'")
        return
      }
      XCTAssertEqual(Double(speed), 1.5)

      guard let equipped = dictionary["equipped"] else {
        XCTFail("Missing key 'equipped'")
        return
      }
      XCTAssertEqual(Bool(equipped), true)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testEncodeNestedStruct() {
    do {
      let value = NestedStruct(
        label: "test",
        inner: SimpleStruct(name: "Shield", damage: 5, speed: 0.8, equipped: false))
      let encoder = VariantEncoder()
      try value.encode(to: encoder)

      guard let variant = encoder.value else {
        XCTFail("Encoder produced nil value")
        return
      }
      XCTAssertEqual(variant.gtype, .dictionary)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testEncodeArray() {
    do {
      let value = ArrayStruct(values: [1, 2, 3], names: ["a", "b"])
      let encoder = VariantEncoder()
      try value.encode(to: encoder)

      guard let variant = encoder.value else {
        XCTFail("Encoder produced nil value")
        return
      }
      XCTAssertEqual(variant.gtype, .dictionary)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testEncodeOptionalPresent() {
    do {
      let value = OptionalStruct(required: "hello", optional: 42)
      let encoder = VariantEncoder()
      try value.encode(to: encoder)

      guard let variant = encoder.value,
            let dictionary: VariantDictionary = variant.to() else {
        XCTFail("Encoder produced nil or non-dictionary value")
        return
      }

      guard let optional = dictionary["optional"] else {
        XCTFail("Missing key 'optional'")
        return
      }
      XCTAssertEqual(Int(optional), 42)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testEncodeOptionalNil() {
    do {
      let value = OptionalStruct(required: "hello", optional: nil)
      let encoder = VariantEncoder()
      try value.encode(to: encoder)

      guard let variant = encoder.value,
            let dictionary: VariantDictionary = variant.to() else {
        XCTFail("Encoder produced nil or non-dictionary value")
        return
      }

      guard let required = dictionary["required"] else {
        XCTFail("Missing key 'required'")
        return
      }
      XCTAssertEqual(String(required), "hello")
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testEncodeEnum() {
    do {
      let value = WithEnum(name: "compass", direction: .north)
      let encoder = VariantEncoder()
      try value.encode(to: encoder)

      guard let variant = encoder.value,
            let dictionary: VariantDictionary = variant.to() else {
        XCTFail("Encoder produced nil or non-dictionary value")
        return
      }

      guard let name = dictionary["name"] else {
        XCTFail("Missing key 'name'")
        return
      }
      XCTAssertEqual(String(name), "compass")

      guard let direction = dictionary["direction"] else {
        XCTFail("Missing key 'direction'")
        return
      }
      XCTAssertEqual(String(direction), "north")
    } catch {
      XCTFail("\(error)")
    }
  }

  // MARK: - Decoder Tests

  @SwiftGodotTest
  public func testDecodeSimpleStruct() {
    do {
      let dictionary = VariantDictionary()
      dictionary["name"] = Variant("Bow")
      dictionary["damage"] = Variant(25)
      dictionary["speed"] = Variant(2.0)
      dictionary["equipped"] = Variant(true)

      let decoder = VariantDecoder(Variant(dictionary))
      let result = try SimpleStruct(from: decoder)

      XCTAssertEqual(result.name, "Bow")
      XCTAssertEqual(result.damage, 25)
      XCTAssertEqual(result.speed, 2.0)
      XCTAssertEqual(result.equipped, true)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testDecodeNestedStruct() {
    do {
      let inner = VariantDictionary()
      inner["name"] = Variant("Dagger")
      inner["damage"] = Variant(15)
      inner["speed"] = Variant(3.0)
      inner["equipped"] = Variant(false)

      let outer = VariantDictionary()
      outer["label"] = Variant("test")
      outer["inner"] = Variant(inner)

      let decoder = VariantDecoder(Variant(outer))
      let result = try NestedStruct(from: decoder)

      XCTAssertEqual(result.label, "test")
      XCTAssertEqual(result.inner.name, "Dagger")
      XCTAssertEqual(result.inner.damage, 15)
      XCTAssertEqual(result.inner.speed, 3.0)
      XCTAssertEqual(result.inner.equipped, false)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testDecodeArray() {
    do {
      let values = VariantArray()
      values.append(Variant(1))
      values.append(Variant(2))
      values.append(Variant(3))

      let names = VariantArray()
      names.append(Variant("a"))
      names.append(Variant("b"))

      let dictionary = VariantDictionary()
      dictionary["values"] = Variant(values)
      dictionary["names"] = Variant(names)

      let decoder = VariantDecoder(Variant(dictionary))
      let result = try ArrayStruct(from: decoder)

      XCTAssertEqual(result.values, [1, 2, 3])
      XCTAssertEqual(result.names, ["a", "b"])
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testDecodeOptionalPresent() {
    do {
      let dictionary = VariantDictionary()
      dictionary["required"] = Variant("hello")
      dictionary["optional"] = Variant(42)

      let decoder = VariantDecoder(Variant(dictionary))
      let result = try OptionalStruct(from: decoder)

      XCTAssertEqual(result.required, "hello")
      XCTAssertEqual(result.optional, 42)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testDecodeOptionalMissing() {
    do {
      let dictionary = VariantDictionary()
      dictionary["required"] = Variant("hello")

      let decoder = VariantDecoder(Variant(dictionary))
      let result = try OptionalStruct(from: decoder)

      XCTAssertEqual(result.required, "hello")
      XCTAssertEqual(result.optional, nil)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testDecodeEnum() {
    do {
      let dictionary = VariantDictionary()
      dictionary["name"] = Variant("compass")
      dictionary["direction"] = Variant("south")

      let decoder = VariantDecoder(Variant(dictionary))
      let result = try WithEnum(from: decoder)

      XCTAssertEqual(result.name, "compass")
      XCTAssertEqual(result.direction, .south)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testDecodeMissingKeyThrows() {
    let dictionary = VariantDictionary()
    dictionary["name"] = Variant("Axe")
    // Missing "damage", "speed", "equipped"

    let decoder = VariantDecoder(Variant(dictionary))
    do {
      let _ = try SimpleStruct(from: decoder)
      XCTFail("Expected DecodingError.keyNotFound")
    } catch {
      // Expected
    }
  }

  @SwiftGodotTest
  public func testDecodeTypeMismatchThrows() {
    let dictionary = VariantDictionary()
    dictionary["name"] = Variant("Mace")
    dictionary["damage"] = Variant("not a number")
    dictionary["speed"] = Variant(1.2)
    dictionary["equipped"] = Variant(true)

    let decoder = VariantDecoder(Variant(dictionary))
    do {
      let _ = try SimpleStruct(from: decoder)
      XCTFail("Expected DecodingError.typeMismatch")
    } catch {
      // Expected
    }
  }

  @SwiftGodotTest
  public func testDecodeNilVariantThrows() {
    let decoder = VariantDecoder(nil)
    do {
      let _ = try SimpleStruct(from: decoder)
      XCTFail("Expected DecodingError.valueNotFound")
    } catch {
      // Expected
    }
  }

  // MARK: - Round-Trip Tests

  @SwiftGodotTest
  public func testRoundTripSimpleStruct() {
    do {
      let original = SimpleStruct(name: "Spear", damage: 30, speed: 1.8, equipped: true)

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try SimpleStruct(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripNestedStruct() {
    do {
      let original = NestedStruct(
        label: "test",
        inner: SimpleStruct(name: "Shield", damage: 5, speed: 0.8, equipped: false))

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try NestedStruct(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripArray() {
    do {
      let original = ArrayStruct(values: [10, 20, 30], names: ["x", "y", "z"])

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try ArrayStruct(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripOptionalPresent() {
    do {
      let original = OptionalStruct(required: "hello", optional: 42)

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try OptionalStruct(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripOptionalNil() {
    do {
      let original = OptionalStruct(required: "hello", optional: nil)

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try OptionalStruct(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripEnum() {
    do {
      let original = WithEnum(name: "compass", direction: .north)

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try WithEnum(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripNestedArrays() {
    do {
      let original = NestedArrays(matrix: [[1, 2], [3, 4], [5, 6]])

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try NestedArrays(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripDictionary() {
    do {
      let original = DictionaryStruct(metadata: ["key1": "value1", "key2": "value2"])

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try DictionaryStruct(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  // MARK: - Primitive Type Tests

  @SwiftGodotTest
  public func testRoundTripAllPrimitives() {
    struct AllPrimitives: Codable, Equatable {
      let boolValue: Bool
      let stringValue: String
      let doubleValue: Double
      let floatValue: Float
      let intValue: Int
      let int8Value: Int8
      let int16Value: Int16
      let int32Value: Int32
      let int64Value: Int64
      let uintValue: UInt
      let uint8Value: UInt8
      let uint16Value: UInt16
      let uint32Value: UInt32
      let uint64Value: UInt64
    }

    do {
      let original = AllPrimitives(
        boolValue: true,
        stringValue: "test",
        doubleValue: 3.14,
        floatValue: 2.71,
        intValue: -42,
        int8Value: -8,
        int16Value: -16,
        int32Value: -32,
        int64Value: -64,
        uintValue: 42,
        uint8Value: 8,
        uint16Value: 16,
        uint32Value: 32,
        uint64Value: 64)

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try AllPrimitives(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  // MARK: - Super Encoder/Decoder Tests

  @SwiftGodotTest
  public func testRoundTripSuperEncoder() {
    do {
      let original = Dog(name: "Rex", legs: 4, breed: "Labrador")

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      guard let variant = encoder.value else {
        XCTFail("Encoder produced nil value")
        return
      }
      XCTAssertEqual(variant.gtype, .dictionary)

      let decoder = VariantDecoder(variant)
      let decoded = try Dog(from: decoder)

      XCTAssertEqual(decoded.name, "Rex")
      XCTAssertEqual(decoded.legs, 4)
      XCTAssertEqual(decoded.breed, "Labrador")
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testSuperEncoderStructure() {
    do {
      let dog = Dog(name: "Rex", legs: 4, breed: "Labrador")

      let encoder = VariantEncoder()
      try dog.encode(to: encoder)

      guard let variant = encoder.value,
            let dictionary: VariantDictionary = variant.to() else {
        XCTFail("Encoder produced nil or non-dictionary value")
        return
      }

      // breed should be at the top level
      guard let breed = dictionary["breed"] else {
        XCTFail("Missing key 'breed'")
        return
      }
      XCTAssertEqual(String(breed), "Labrador")

      // super properties should be nested under "__super"
      guard let superVariant = dictionary["__super"] else {
        XCTFail("Missing key '__super'")
        return
      }
      XCTAssertEqual(superVariant.gtype, .dictionary)

      guard let superDict: VariantDictionary = superVariant.to() else {
        XCTFail("Could not convert __super to VariantDictionary")
        return
      }

      guard let name = superDict["name"] else {
        XCTFail("Missing key 'name' in __super")
        return
      }
      XCTAssertEqual(String(name), "Rex")

      guard let legs = superDict["legs"] else {
        XCTFail("Missing key 'legs' in __super")
        return
      }
      XCTAssertEqual(Int(legs), 4)
    } catch {
      XCTFail("\(error)")
    }
  }

  // MARK: - Keyed Nested Container Tests

  @SwiftGodotTest
  public func testRoundTripKeyedNestedContainers() {
    do {
      let original = ManualNestedStruct(
        key: "outer", nestedKey: "inner", nestedValue: 99, items: [1, 2, 3])

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try ManualNestedStruct(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripSuperEncoderForKey() {
    do {
      let original = Cat(name: "Whiskers", legs: 4, indoor: true)

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      guard let variant = encoder.value,
            let dictionary: VariantDictionary = variant.to() else {
        XCTFail("Encoder produced nil or non-dictionary value")
        return
      }

      guard let parentData = dictionary["parent_data"] else {
        XCTFail("Missing key 'parent_data'")
        return
      }
      XCTAssertEqual(parentData.gtype, .dictionary)

      let decoder = VariantDecoder(variant)
      let decoded = try Cat(from: decoder)

      XCTAssertEqual(decoded.name, "Whiskers")
      XCTAssertEqual(decoded.legs, 4)
      XCTAssertEqual(decoded.indoor, true)
    } catch {
      XCTFail("\(error)")
    }
  }

  // MARK: - Unkeyed Container Tests

  @SwiftGodotTest
  public func testRoundTripUnkeyedNil() {
    do {
      let original = NullableArray([1, nil, 3, nil, 5])

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try NullableArray(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripUnkeyedNestedKeyed() {
    do {
      let original = UnkeyedNestedStruct(name: "test", value: 42)

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try UnkeyedNestedStruct(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripUnkeyedSuperEncoder() {
    do {
      let original = UnkeyedDerived(species: "Cat", petName: "Mittens")

      let encoder = VariantEncoder()
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value)
      let decoded = try UnkeyedDerived(from: decoder)

      XCTAssertEqual(decoded.species, "Cat")
      XCTAssertEqual(decoded.petName, "Mittens")
    } catch {
      XCTFail("\(error)")
    }
  }

  // MARK: - Single Value Container Tests

  @SwiftGodotTest
  public func testEncodeSingleValueNil() {
    do {
      let value: Int? = nil
      let encoder = VariantEncoder()
      try value.encode(to: encoder)

      let result = encoder.value
      if let result {
        XCTAssertEqual(result.gtype, .nil)
      }
    } catch {
      XCTFail("\(error)")
    }
  }

  // MARK: - Error Path Tests

  @SwiftGodotTest
  public func testDecodeKeyedFromNonDictionary() {
    let decoder = VariantDecoder(Variant(42))
    do {
      let _ = try SimpleStruct(from: decoder)
      XCTFail("Expected DecodingError.typeMismatch")
    } catch {
      // Expected
    }
  }

  @SwiftGodotTest
  public func testDecodeUnkeyedFromNil() {
    let decoder = VariantDecoder(nil)
    do {
      let _ = try [Int](from: decoder)
      XCTFail("Expected DecodingError.valueNotFound")
    } catch {
      // Expected
    }
  }

  @SwiftGodotTest
  public func testDecodeUnkeyedFromNonArray() {
    let decoder = VariantDecoder(Variant("not an array"))
    do {
      let _ = try [Int](from: decoder)
      XCTFail("Expected DecodingError.typeMismatch")
    } catch {
      // Expected
    }
  }

  @SwiftGodotTest
  public func testDecodeUnkeyedPastEnd() {
    struct TooManyFields: Decodable {
      let first: Int
      let second: Int

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        first = try container.decode(Int.self)
        second = try container.decode(Int.self)
      }
    }

    let array = VariantArray()
    array.append(Variant(1))

    let decoder = VariantDecoder(Variant(array))
    do {
      let _ = try TooManyFields(from: decoder)
      XCTFail("Expected DecodingError.valueNotFound")
    } catch {
      // Expected
    }
  }

  @SwiftGodotTest
  public func testDecodePrimitiveFromNil() {
    let decoder = VariantDecoder(nil)
    do {
      let _ = try Int(from: decoder)
      XCTFail("Expected DecodingError.valueNotFound")
    } catch {
    }
  }

  // MARK: - VariantCodable Tests

  @SwiftGodotTest
  public func testVariantCodableToVariant() {
    let value = SimpleStruct(name: "Sword", damage: 42, speed: 1.5, equipped: true)
    let variant = value.toVariant()

    guard let variant else {
      XCTFail("toVariant returned nil")
      return
    }

    XCTAssertEqual(variant.gtype, .dictionary)

    guard let dictionary: VariantDictionary = variant.to() else {
      XCTFail("Could not convert to VariantDictionary")
      return
    }

    guard let name = dictionary["name"] else {
      XCTFail("Missing key 'name'")
      return
    }
    XCTAssertEqual(String(name), "Sword")

    guard let damage = dictionary["damage"] else {
      XCTFail("Missing key 'damage'")
      return
    }
    XCTAssertEqual(Int(damage), 42)

    guard let speed = dictionary["speed"] else {
      XCTFail("Missing key 'speed'")
      return
    }
    XCTAssertEqual(Double(speed), 1.5)

    guard let equipped = dictionary["equipped"] else {
      XCTFail("Missing key 'equipped'")
      return
    }
    XCTAssertEqual(Bool(equipped), true)
  }

  @SwiftGodotTest
  public func testVariantCodableToFastVariant() {
    let value = SimpleStruct(name: "Bow", damage: 10, speed: 2.0, equipped: false)
    guard let fastVariant = value.toFastVariant() else {
      XCTFail("toFastVariant returned nil")
      return
    }
    let variant = Variant(takingOver: fastVariant)
    XCTAssertEqual(variant.gtype, .dictionary)
  }

  @SwiftGodotTest
  public func testVariantCodableFromVariantOrThrow() {
    do {
      let dictionary = VariantDictionary()
      dictionary["name"] = Variant("Axe")
      dictionary["damage"] = Variant(30)
      dictionary["speed"] = Variant(1.2)
      dictionary["equipped"] = Variant(true)

      let result = try SimpleStruct.fromVariantOrThrow(Variant(dictionary))

      XCTAssertEqual(result.name, "Axe")
      XCTAssertEqual(result.damage, 30)
      XCTAssertEqual(result.speed, 1.2)
      XCTAssertEqual(result.equipped, true)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testVariantCodableRoundTrip() {
    do {
      let original = SimpleStruct(name: "Spear", damage: 30, speed: 1.8, equipped: true)

      guard let variant = original.toVariant() else {
        XCTFail("toVariant returned nil")
        return
      }

      let decoded = try SimpleStruct.fromVariantOrThrow(variant)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testVariantCodableTypeMismatchThrows() {
    do {
      let _ = try SimpleStruct.fromVariantOrThrow(Variant(42))
      XCTFail("Expected VariantConversionError")
    } catch {
      // Expected VariantConversionError
    }
  }

  @SwiftGodotTest
  public func testVariantCodableMissingKeyThrows() {
    let dictionary = VariantDictionary()
    dictionary["name"] = Variant("Axe")

    do {
      let _ = try SimpleStruct.fromVariantOrThrow(Variant(dictionary))
      XCTFail("Expected VariantConversionError")
    } catch {
      // Expected VariantConversionError
    }
  }

  @SwiftGodotTest
  public func testVariantCodableFromFastVariantOrThrow() {
    do {
      let original = SimpleStruct(name: "Dagger", damage: 15, speed: 3.0, equipped: false)

      guard let fastVariant = original.toFastVariant() else {
        XCTFail("toFastVariant returned nil")
        return
      }

      let decoded = try SimpleStruct.fromFastVariantOrThrow(fastVariant)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  // MARK: - Key Strategy Tests

  @SwiftGodotTest
  public func testEncodeConvertToSnakeCase() {
    do {
      let value = CamelCaseStruct(maxHealth: 100, attackSpeed: 1.5, isPlayerControlled: true)
      let encoder = VariantEncoder(keyEncodingStrategy: .convertToSnakeCase)
      try value.encode(to: encoder)

      guard let variant = encoder.value,
            let dictionary: VariantDictionary = variant.to() else {
        XCTFail("Encoder produced nil or non-dictionary value")
        return
      }

      XCTAssertTrue(dictionary.has(key: Variant("max_health")))
      XCTAssertTrue(dictionary.has(key: Variant("attack_speed")))
      XCTAssertTrue(dictionary.has(key: Variant("is_player_controlled")))

      XCTAssertFalse(dictionary.has(key: Variant("maxHealth")))
      XCTAssertFalse(dictionary.has(key: Variant("attackSpeed")))
      XCTAssertFalse(dictionary.has(key: Variant("isPlayerControlled")))
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testEncodeUseDefaultKeys() {
    do {
      let value = CamelCaseStruct(maxHealth: 100, attackSpeed: 1.5, isPlayerControlled: true)
      let encoder = VariantEncoder(keyEncodingStrategy: .useDefaultKeys)
      try value.encode(to: encoder)

      guard let variant = encoder.value,
            let dictionary: VariantDictionary = variant.to() else {
        XCTFail("Encoder produced nil or non-dictionary value")
        return
      }

      XCTAssertTrue(dictionary.has(key: Variant("maxHealth")))
      XCTAssertTrue(dictionary.has(key: Variant("attackSpeed")))
      XCTAssertTrue(dictionary.has(key: Variant("isPlayerControlled")))

      XCTAssertFalse(dictionary.has(key: Variant("max_health")))
      XCTAssertFalse(dictionary.has(key: Variant("attack_speed")))
      XCTAssertFalse(dictionary.has(key: Variant("is_player_controlled")))
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testDecodeConvertFromSnakeCase() {
    do {
      let dictionary = VariantDictionary()
      dictionary["max_health"] = Variant(100)
      dictionary["attack_speed"] = Variant(1.5)
      dictionary["is_player_controlled"] = Variant(true)

      let decoder = VariantDecoder(Variant(dictionary), keyDecodingStrategy: .convertFromSnakeCase)
      let result = try CamelCaseStruct(from: decoder)

      XCTAssertEqual(result.maxHealth, 100)
      XCTAssertEqual(result.attackSpeed, 1.5)
      XCTAssertEqual(result.isPlayerControlled, true)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testDecodeUseDefaultKeys() {
    do {
      let dictionary = VariantDictionary()
      dictionary["maxHealth"] = Variant(100)
      dictionary["attackSpeed"] = Variant(1.5)
      dictionary["isPlayerControlled"] = Variant(true)

      let decoder = VariantDecoder(Variant(dictionary), keyDecodingStrategy: .useDefaultKeys)
      let result = try CamelCaseStruct(from: decoder)

      XCTAssertEqual(result.maxHealth, 100)
      XCTAssertEqual(result.attackSpeed, 1.5)
      XCTAssertEqual(result.isPlayerControlled, true)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripConvertSnakeCase() {
    do {
      let original = CamelCaseStruct(maxHealth: 200, attackSpeed: 2.5, isPlayerControlled: false)

      let encoder = VariantEncoder(keyEncodingStrategy: .convertToSnakeCase)
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value, keyDecodingStrategy: .convertFromSnakeCase)
      let decoded = try CamelCaseStruct(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripUseDefaultKeys() {
    do {
      let original = CamelCaseStruct(maxHealth: 200, attackSpeed: 2.5, isPlayerControlled: false)

      let encoder = VariantEncoder(keyEncodingStrategy: .useDefaultKeys)
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value, keyDecodingStrategy: .useDefaultKeys)
      let decoded = try CamelCaseStruct(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  // MARK: - Key Strategy Propagation Tests

  @SwiftGodotTest
  public func testStrategyPropagatesThroughUnkeyedContainer() {
    do {
      let values = [
        CamelCaseStruct(maxHealth: 100, attackSpeed: 1.5, isPlayerControlled: true),
        CamelCaseStruct(maxHealth: 200, attackSpeed: 2.5, isPlayerControlled: false),
      ]

      let encoder = VariantEncoder(keyEncodingStrategy: .convertToSnakeCase)
      try values.encode(to: encoder)

      guard let variant = encoder.value,
            let array: VariantArray = variant.to() else {
        XCTFail("Encoder produced nil or non-array value")
        return
      }

      // Check that keys inside elements (which go through unkeyed -> keyed) are snake_case
      guard let firstElement = array[0],
            let firstDict: VariantDictionary = firstElement.to() else {
        XCTFail("First element is not a dictionary")
        return
      }

      XCTAssertTrue(firstDict.has(key: Variant("max_health")))
      XCTAssertTrue(firstDict.has(key: Variant("attack_speed")))
      XCTAssertTrue(firstDict.has(key: Variant("is_player_controlled")))
      XCTAssertFalse(firstDict.has(key: Variant("maxHealth")))
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testStrategyPropagatesThroughSingleValueContainer() {
    do {
      let value = CamelCaseWrapper(
        inner: CamelCaseStruct(maxHealth: 100, attackSpeed: 1.5, isPlayerControlled: true))

      let encoder = VariantEncoder(keyEncodingStrategy: .convertToSnakeCase)
      try value.encode(to: encoder)

      guard let variant = encoder.value,
            let dictionary: VariantDictionary = variant.to() else {
        XCTFail("Encoder produced nil or non-dictionary value")
        return
      }

      // Keys should be snake_case despite going through single-value container
      XCTAssertTrue(dictionary.has(key: Variant("max_health")))
      XCTAssertTrue(dictionary.has(key: Variant("attack_speed")))
      XCTAssertTrue(dictionary.has(key: Variant("is_player_controlled")))
      XCTAssertFalse(dictionary.has(key: Variant("maxHealth")))
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testStrategyPropagatesThroughKeyedToUnkeyedToKeyed() {
    do {
      let value = CamelCaseArrayHolder(
        playerName: "Hero",
        statBlocks: [
          CamelCaseStruct(maxHealth: 100, attackSpeed: 1.5, isPlayerControlled: true),
          CamelCaseStruct(maxHealth: 200, attackSpeed: 2.5, isPlayerControlled: false),
        ])

      let encoder = VariantEncoder(keyEncodingStrategy: .convertToSnakeCase)
      try value.encode(to: encoder)

      guard let variant = encoder.value,
            let dictionary: VariantDictionary = variant.to() else {
        XCTFail("Encoder produced nil or non-dictionary value")
        return
      }

      // Top-level keys should be snake_case
      XCTAssertTrue(dictionary.has(key: Variant("player_name")))
      XCTAssertTrue(dictionary.has(key: Variant("stat_blocks")))
      XCTAssertFalse(dictionary.has(key: Variant("playerName")))
      XCTAssertFalse(dictionary.has(key: Variant("statBlocks")))

      // Keys inside nested array elements should also be snake_case
      guard let statBlocksVariant = dictionary["stat_blocks"],
            let statBlocks: VariantArray = statBlocksVariant.to(),
            let firstElement = statBlocks[0],
            let firstDict: VariantDictionary = firstElement.to() else {
        XCTFail("Could not read stat_blocks array")
        return
      }

      XCTAssertTrue(firstDict.has(key: Variant("max_health")))
      XCTAssertTrue(firstDict.has(key: Variant("attack_speed")))
      XCTAssertFalse(firstDict.has(key: Variant("maxHealth")))
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripStrategyThroughUnkeyedContainer() {
    do {
      let original = [
        CamelCaseStruct(maxHealth: 100, attackSpeed: 1.5, isPlayerControlled: true),
        CamelCaseStruct(maxHealth: 200, attackSpeed: 2.5, isPlayerControlled: false),
      ]

      let encoder = VariantEncoder(keyEncodingStrategy: .convertToSnakeCase)
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value, keyDecodingStrategy: .convertFromSnakeCase)
      let decoded = try [CamelCaseStruct](from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripStrategyThroughSingleValueContainer() {
    do {
      let original = CamelCaseWrapper(
        inner: CamelCaseStruct(maxHealth: 100, attackSpeed: 1.5, isPlayerControlled: true))

      let encoder = VariantEncoder(keyEncodingStrategy: .convertToSnakeCase)
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value, keyDecodingStrategy: .convertFromSnakeCase)
      let decoded = try CamelCaseWrapper(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testRoundTripStrategyThroughKeyedToUnkeyedToKeyed() {
    do {
      let original = CamelCaseArrayHolder(
        playerName: "Hero",
        statBlocks: [
          CamelCaseStruct(maxHealth: 100, attackSpeed: 1.5, isPlayerControlled: true),
          CamelCaseStruct(maxHealth: 200, attackSpeed: 2.5, isPlayerControlled: false),
        ])

      let encoder = VariantEncoder(keyEncodingStrategy: .convertToSnakeCase)
      try original.encode(to: encoder)

      let decoder = VariantDecoder(encoder.value, keyDecodingStrategy: .convertFromSnakeCase)
      let decoded = try CamelCaseArrayHolder(from: decoder)

      XCTAssertEqual(original, decoded)
    } catch {
      XCTFail("\(error)")
    }
  }

  @SwiftGodotTest
  public func testUseDefaultKeysPropagatesThroughUnkeyedContainer() {
    do {
      let values = [
        CamelCaseStruct(maxHealth: 100, attackSpeed: 1.5, isPlayerControlled: true),
      ]

      let encoder = VariantEncoder(keyEncodingStrategy: .useDefaultKeys)
      try values.encode(to: encoder)

      guard let variant = encoder.value,
            let array: VariantArray = variant.to(),
            let firstElement = array[0],
            let firstDict: VariantDictionary = firstElement.to() else {
        XCTFail("Could not read encoded array")
        return
      }

      // With useDefaultKeys, keys should remain camelCase
      XCTAssertTrue(firstDict.has(key: Variant("maxHealth")))
      XCTAssertTrue(firstDict.has(key: Variant("attackSpeed")))
      XCTAssertTrue(firstDict.has(key: Variant("isPlayerControlled")))
      XCTAssertFalse(firstDict.has(key: Variant("max_health")))
    } catch {
      XCTFail("\(error)")
    }
  }
}
