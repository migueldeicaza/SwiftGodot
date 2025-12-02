public class VariantEncoder: Encoder {
  public var codingPath: [any CodingKey]
  public var userInfo: [CodingUserInfoKey: Any] = [:]

  protocol VariantEncodingContainer {
    var value: Variant? { get }
  }

  var container: VariantEncodingContainer? = nil

  var value: Variant? {
    container?.value
  }

  init(forPath: [any CodingKey] = []) {
    self.codingPath = forPath
  }

  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
  where Key: CodingKey {
    let container = VariantKeyedContainer<Key>(forPath: codingPath)
    self.container = container
    return KeyedEncodingContainer(container)
  }

  public func unkeyedContainer() -> any UnkeyedEncodingContainer {
    let container = VariantUnkeyedContainer(forPath: codingPath)
    self.container = container
    return container
  }

  public func singleValueContainer() -> any SingleValueEncodingContainer {
    let container = VariantSingleValueContainer(forPath: codingPath)
    self.container = container
    return container
  }

  class VariantKeyedContainer<K: CodingKey>: KeyedEncodingContainerProtocol,
    VariantEncodingContainer
  {
    typealias Key = K

    var dictionary: VariantDictionary
    var codingPath: [any CodingKey]

    var value: Variant? {
      Variant(dictionary)
    }

    init(
      _ dictionary: VariantDictionary = VariantDictionary(),
      forPath codingPath: [any CodingKey] = []
    ) {
      self.dictionary = dictionary
      self.codingPath = codingPath
    }

    func encodeNil(forKey key: K) throws {
      dictionary[key.stringValue] = nil
    }

    func encode<T: Encodable>(_ value: T, forKey key: K) throws {
      let encoder = VariantEncoder(forPath: self.codingPath + [key])
      try value.encode(to: encoder)
      dictionary[key.stringValue] = encoder.value
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K)
      -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
      let nestedDictionary = VariantDictionary()
      dictionary[key.stringValue] = Variant(nestedDictionary)
      return KeyedEncodingContainer(
        VariantKeyedContainer<NestedKey>(nestedDictionary, forPath: self.codingPath + [key]))
    }

    func nestedUnkeyedContainer(forKey key: K) -> any UnkeyedEncodingContainer {
      let nestedArray = VariantArray()
      dictionary[key.stringValue] = Variant(nestedArray)
      return VariantUnkeyedContainer(nestedArray, forPath: self.codingPath + [key])
    }

    func superEncoder(forKey key: K) -> any Encoder {
      let encoder = VariantEncoder()
      dictionary[key.stringValue] = encoder.value
      return encoder
    }

    func superEncoder() -> any Encoder {
      let encoder = VariantEncoder()
      dictionary["__super"] = encoder.value
      return encoder
    }
  }

  class VariantUnkeyedContainer: UnkeyedEncodingContainer, VariantEncodingContainer {
    var array: VariantArray
    var codingPath: [any CodingKey]

    var count: Int { array.count }

    var value: Variant? {
      Variant(array)
    }

    init(_ array: VariantArray = VariantArray(), forPath codingPath: [any CodingKey] = []) {
      self.array = array
      self.codingPath = codingPath
    }

    func encodeNil() throws {
      array.append(nil)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
      let encoder = VariantEncoder()
      try value.encode(to: encoder)
      array.append(encoder.value)
    }

    func nestedContainer<NestedKey>(
      keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
      let nestedDictionary = VariantDictionary()
      array.append(Variant(nestedDictionary))
      return KeyedEncodingContainer(
        VariantKeyedContainer<NestedKey>(nestedDictionary, forPath: self.codingPath))
    }

    func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
      let nestedArray = VariantArray()
      array.append(Variant(nestedArray))
      return VariantUnkeyedContainer(nestedArray, forPath: self.codingPath)
    }

    func superEncoder() -> any Encoder {
      let encoder = VariantEncoder()
      array.append(encoder.value)
      return encoder
    }
  }

  class VariantSingleValueContainer: SingleValueEncodingContainer, VariantEncodingContainer {
    var value: Variant?
    var codingPath: [any CodingKey]

    init(forPath codingPath: [any CodingKey] = []) {
      self.codingPath = codingPath
    }

    func encodeNil() throws {
      self.value = nil
    }

    func encode(_ value: Bool) throws {
      self.value = Variant(value)
    }

    func encode(_ value: String) throws {
      self.value = Variant(value)
    }

    func encode(_ value: Double) throws {
      self.value = Variant(value)
    }

    func encode(_ value: Float) throws {
      self.value = Variant(value)
    }

    func encode(_ value: Int) throws {
      self.value = Variant(value)
    }

    func encode(_ value: Int8) throws {
      self.value = Variant(value)
    }

    func encode(_ value: Int16) throws {
      self.value = Variant(value)
    }

    func encode(_ value: Int32) throws {
      self.value = Variant(value)
    }

    func encode(_ value: Int64) throws {
      self.value = Variant(value)
    }

    func encode(_ value: UInt) throws {
      self.value = Variant(value)
    }

    func encode(_ value: UInt8) throws {
      self.value = Variant(value)
    }

    func encode(_ value: UInt16) throws {
      self.value = Variant(value)
    }

    func encode(_ value: UInt32) throws {
      self.value = Variant(value)
    }

    func encode(_ value: UInt64) throws {
      self.value = Variant(value)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
      let encoder = VariantEncoder()
      try value.encode(to: encoder)
      self.value = encoder.value
    }
  }
}
