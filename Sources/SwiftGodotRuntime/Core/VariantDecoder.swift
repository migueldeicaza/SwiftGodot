public class VariantDecoder: Decoder {
  public var codingPath: [any CodingKey]
  public var userInfo: [CodingUserInfoKey: Any] = [:]

  let variant: Variant?

  init(_ variant: Variant?, forPath codingPath: [any CodingKey] = []) {
    self.variant = variant
    self.codingPath = codingPath
  }

  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
  where Key: CodingKey {
    guard let variant else {
      throw DecodingError.valueNotFound(
        VariantDictionary.self,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected to decode VariantDictionary but found null instead."))
    }
    guard variant.gtype == .dictionary, let dictionary: VariantDictionary = variant.to() else {
      throw DecodingError.typeMismatch(
        VariantDictionary.self,
        .init(
          codingPath: codingPath,
          debugDescription:
            "Expected to decode VariantDictionary but found \(Variant.typeName(variant.gtype)) instead."
        ))
    }
    return KeyedDecodingContainer(
      VariantKeyedDecodingContainer<Key>(dictionary, forPath: codingPath))
  }

  public func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
    guard let variant else {
      throw DecodingError.valueNotFound(
        VariantArray.self,
        .init(
          codingPath: codingPath,
          debugDescription: "Expected to decode VariantArray but found null instead."))
    }
    guard variant.gtype == .array, let array: VariantArray = variant.to() else {
      throw DecodingError.typeMismatch(
        VariantArray.self,
        .init(
          codingPath: codingPath,
          debugDescription:
            "Expected to decode VariantArray but found \(Variant.typeName(variant.gtype)) instead.")
      )
    }
    return VariantUnkeyedDecodingContainer(array, forPath: codingPath)
  }

  public func singleValueContainer() throws -> any SingleValueDecodingContainer {
    VariantSingleValueDecodingContainer(variant, forPath: codingPath)
  }

  struct VariantKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K

    let dictionary: VariantDictionary
    var codingPath: [any CodingKey]

    var allKeys: [K] {
      let keys = dictionary.keys()
      return (0..<keys.count).compactMap { index in
        guard let string: String = keys[index]?.to() else { return nil }
        return K(stringValue: string)
      }
    }

    init(_ dictionary: VariantDictionary, forPath codingPath: [any CodingKey]) {
      self.dictionary = dictionary
      self.codingPath = codingPath
    }

    func contains(_ key: K) -> Bool {
      dictionary.has(key: Variant(key.stringValue))
    }

    func decodeNil(forKey key: K) throws -> Bool {
      let value = try getValue(forKey: key)
      return value == nil || value?.gtype == .nil
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: K) throws -> T {
      let value = try getValue(forKey: key)
      let decoder = VariantDecoder(value, forPath: codingPath + [key])
      return try T(from: decoder)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws
      -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
    {
      let value = try getValue(forKey: key)
      let decoder = VariantDecoder(value, forPath: codingPath + [key])
      return try decoder.container(keyedBy: type)
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> any UnkeyedDecodingContainer {
      let value = try getValue(forKey: key)
      let decoder = VariantDecoder(value, forPath: codingPath + [key])
      return try decoder.unkeyedContainer()
    }

    func superDecoder() throws -> any Decoder {
      let value = dictionary[_CodingKey.super.stringValue]
      return VariantDecoder(value, forPath: codingPath + [_CodingKey.super])
    }

    func superDecoder(forKey key: K) throws -> any Decoder {
      let value = try getValue(forKey: key)
      return VariantDecoder(value, forPath: codingPath + [key])
    }

    private func getValue(forKey key: K) throws -> Variant? {
      guard contains(key) else {
        throw DecodingError.keyNotFound(
          key,
          .init(
            codingPath: codingPath,
            debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
      }
      return dictionary[key.stringValue]
    }
  }

  class VariantUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [any CodingKey]
    var count: Int? { array.count }
    var isAtEnd: Bool { currentIndex >= array.count }
    var currentIndex: Int = 0

    let array: VariantArray

    init(_ array: VariantArray, forPath codingPath: [any CodingKey] = []) {
      self.array = array
      self.codingPath = codingPath
    }

    func decodeNil() throws -> Bool {
      let variant = try currentValue(ofType: Variant?.self)
      if variant == nil || variant?.gtype == .nil {
        next()
        return true
      }
      return false
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
      let variant = try currentValue(ofType: type)
      let decoder = VariantDecoder(
        variant, forPath: codingPath + [_CodingKey.index(currentIndex)])
      let value = try T(from: decoder)
      next()
      return value
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws
      -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
    {
      let variant = try currentValue(ofType: KeyedDecodingContainer<NestedKey>.self)
      let decoder = VariantDecoder(
        variant, forPath: codingPath + [_CodingKey.index(currentIndex)])
      let value = try decoder.container(keyedBy: type)
      next()
      return value
    }

    func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
      let variant = try currentValue(ofType: UnkeyedDecodingContainer.self)
      let decoder = VariantDecoder(
        variant, forPath: codingPath + [_CodingKey.index(currentIndex)])
      let value = try decoder.unkeyedContainer()
      next()
      return value
    }

    func superDecoder() throws -> any Decoder {
      let variant = try currentValue(ofType: (any Decoder).self)
      let decoder = VariantDecoder(
        variant, forPath: codingPath + [_CodingKey.index(currentIndex)])
      next()
      return decoder
    }

    private func currentValue<T>(ofType type: T.Type) throws -> Variant? {
      guard !isAtEnd else {
        throw DecodingError.valueNotFound(
          type,
          .init(
            codingPath: codingPath + [_CodingKey.index(currentIndex)],
            debugDescription: "Unkeyed container is at end."))
      }
      return array[currentIndex]
    }

    private func next() {
      currentIndex += 1
    }
  }

  struct VariantSingleValueDecodingContainer: SingleValueDecodingContainer {
    let variant: Variant?
    var codingPath: [any CodingKey]

    init(_ variant: Variant?, forPath codingPath: [any CodingKey] = []) {
      self.variant = variant
      self.codingPath = codingPath
    }

    func decodeNil() -> Bool { variant == nil || variant?.gtype == .nil }
    func decode(_ type: Bool.Type) throws -> Bool { try decodeFromVariant() }
    func decode(_ type: String.Type) throws -> String { try decodeFromVariant() }
    func decode(_ type: Double.Type) throws -> Double { try decodeFromVariant() }
    func decode(_ type: Float.Type) throws -> Float { try decodeFromVariant() }
    func decode(_ type: Int.Type) throws -> Int { try decodeFromVariant() }
    func decode(_ type: Int8.Type) throws -> Int8 { try decodeFromVariant() }
    func decode(_ type: Int16.Type) throws -> Int16 { try decodeFromVariant() }
    func decode(_ type: Int32.Type) throws -> Int32 { try decodeFromVariant() }
    func decode(_ type: Int64.Type) throws -> Int64 { try decodeFromVariant() }
    func decode(_ type: UInt.Type) throws -> UInt { try decodeFromVariant() }
    func decode(_ type: UInt8.Type) throws -> UInt8 { try decodeFromVariant() }
    func decode(_ type: UInt16.Type) throws -> UInt16 { try decodeFromVariant() }
    func decode(_ type: UInt32.Type) throws -> UInt32 { try decodeFromVariant() }
    func decode(_ type: UInt64.Type) throws -> UInt64 { try decodeFromVariant() }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
      let decoder = VariantDecoder(variant, forPath: codingPath)
      return try T(from: decoder)
    }

    private func decodeFromVariant<T: _GodotBridgeableBuiltin>() throws -> T {
      guard let variant else {
        throw DecodingError.valueNotFound(
          T.self,
          .init(
            codingPath: codingPath,
            debugDescription: "Expected to decode \(T.self) but found null instead."))
      }
      guard let value = T.fromVariant(variant) else {
        throw DecodingError.typeMismatch(
          T.self,
          .init(
            codingPath: codingPath,
            debugDescription:
              "Expected to decode \(T.self) but found \(Variant.typeName(variant.gtype)) instead."))
      }
      return value
    }
  }

  private enum _CodingKey: CodingKey {
    case string(String)
    case index(Int)

    static let `super` = _CodingKey.string("__super")

    var stringValue: String {
      switch self {
      case .string(let value): value
      case .index(let value): "Index \(value)"
      }
    }

    var intValue: Int? {
      switch self {
      case .string: nil
      case .index(let value): value
      }
    }

    init?(stringValue: String) {
      self = .string(stringValue)
    }

    init?(intValue: Int) {
      self = .index(intValue)
    }
  }
}
