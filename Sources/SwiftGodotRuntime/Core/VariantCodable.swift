//
//  VariantCodable.swift
//  SwiftGodot
//
//  Created by Evan Wang on 3/12/26.
//

import Foundation

// MARK: - VariantCodable

public protocol VariantCodable: Codable, VariantConvertible {}

public extension VariantCodable {
  func toVariant() -> Variant? {
    let encoder = VariantEncoder()
    do {
      try self.encode(to: encoder)
      return encoder.value
    } catch {
      return nil
    }
  }

  func toFastVariant() -> FastVariant? {
    toVariant()?.toFastVariant()
  }

  static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
    let decoder = VariantDecoder(variant)
    do {
      return try Self(from: decoder)
    } catch let error as DecodingError {
      switch error {
      case .typeMismatch(let type, _):
        throw .unexpectedContent(requestedType: type, actualContent: variant.description)
      case .valueNotFound(let type, _):
        throw .unexpectedContent(requestedType: type, actualContent: "nil")
      case .keyNotFound(_, _):
        throw .custom(error: error)
      case .dataCorrupted(_):
        throw .custom(error: error)
      @unknown default:
        throw .custom(error: error)
      }
    } catch {
      throw .custom(error: error)
    }
  }

  static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
    try fromVariantOrThrow(Variant(takingOver: variant.copy()))
  }
}

// MARK: - VariantEncoder

public class VariantEncoder: Encoder {
  public var codingPath: [any CodingKey]
  public var userInfo: [CodingUserInfoKey: Any] = [:]

  public enum KeyEncodingStrategy {
    case useDefaultKeys
    case convertToSnakeCase
  }

  protocol VariantEncodingContainer {
    var value: Variant? { get }
  }

  var container: VariantEncodingContainer? = nil

  var value: Variant? {
    container?.value
  }

  private var writeBack: ((Variant?) -> Void)?
  let keyEncodingStrategy: KeyEncodingStrategy

  init(forPath: [any CodingKey] = [], keyEncodingStrategy: KeyEncodingStrategy = .convertToSnakeCase) {
    self.codingPath = forPath
    self.keyEncodingStrategy = keyEncodingStrategy
  }

  deinit {
    writeBack?(value)
  }

  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
  where Key: CodingKey {
    let container = VariantKeyedContainer<Key>(forPath: codingPath, keyEncodingStrategy: keyEncodingStrategy)
    self.container = container
    return KeyedEncodingContainer(container)
  }

  public func unkeyedContainer() -> any UnkeyedEncodingContainer {
    let container = VariantUnkeyedContainer(forPath: codingPath, keyEncodingStrategy: keyEncodingStrategy)
    self.container = container
    return container
  }

  public func singleValueContainer() -> any SingleValueEncodingContainer {
    let container = VariantSingleValueContainer(forPath: codingPath, keyEncodingStrategy: keyEncodingStrategy)
    self.container = container
    return container
  }

  class VariantKeyedContainer<K: CodingKey>: KeyedEncodingContainerProtocol,
    VariantEncodingContainer
  {
    typealias Key = K

    var dictionary: VariantDictionary
    var codingPath: [any CodingKey]
    let keyEncodingStrategy: KeyEncodingStrategy

    var value: Variant? {
      Variant(dictionary)
    }

    init(
      _ dictionary: VariantDictionary = VariantDictionary(),
      forPath codingPath: [any CodingKey] = [],
      keyEncodingStrategy: KeyEncodingStrategy = .convertToSnakeCase
    ) {
      self.dictionary = dictionary
      self.codingPath = codingPath
      self.keyEncodingStrategy = keyEncodingStrategy
    }

    func encodeNil(forKey key: K) throws {
      dictionary[encodeKey(key.stringValue)] = nil
    }

    func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
      let encoder = VariantEncoder(forPath: self.codingPath + [key], keyEncodingStrategy: keyEncodingStrategy)
      try value.encode(to: encoder)
      dictionary[encodeKey(key.stringValue)] = encoder.value
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K)
      -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
      let nestedDictionary = VariantDictionary()
      dictionary[encodeKey(key.stringValue)] = Variant(nestedDictionary)
      return KeyedEncodingContainer(
        VariantKeyedContainer<NestedKey>(
          nestedDictionary, forPath: self.codingPath + [key], keyEncodingStrategy: keyEncodingStrategy))
    }

    func nestedUnkeyedContainer(forKey key: K) -> any UnkeyedEncodingContainer {
      let nestedArray = VariantArray()
      dictionary[encodeKey(key.stringValue)] = Variant(nestedArray)
      return VariantUnkeyedContainer(nestedArray, forPath: self.codingPath + [key], keyEncodingStrategy: keyEncodingStrategy)
    }

    func superEncoder(forKey key: K) -> any Encoder {
      let encodedKey = encodeKey(key.stringValue)
      let encoder = VariantEncoder(forPath: codingPath + [key], keyEncodingStrategy: keyEncodingStrategy)
      encoder.writeBack = { [dictionary] in dictionary[encodedKey] = $0 }
      return encoder
    }

    func superEncoder() -> any Encoder {
      let encoder = VariantEncoder(forPath: codingPath + [_CodingKey.super], keyEncodingStrategy: keyEncodingStrategy)
      encoder.writeBack = { [dictionary] in dictionary[_CodingKey.super.stringValue] = $0 }
      return encoder
    }

    private func encodeKey(_ key: String) -> String {
      switch keyEncodingStrategy {
      case .useDefaultKeys:
        key
      case .convertToSnakeCase:
        key.camelCaseToSnakeCase()
      }
    }
  }

  class VariantUnkeyedContainer: UnkeyedEncodingContainer, VariantEncodingContainer {
    var array: VariantArray
    var codingPath: [any CodingKey]
    let keyEncodingStrategy: KeyEncodingStrategy

    var count: Int { array.count }

    var value: Variant? {
      Variant(array)
    }

    init(
      _ array: VariantArray = VariantArray(),
      forPath codingPath: [any CodingKey] = [],
      keyEncodingStrategy: KeyEncodingStrategy = .convertToSnakeCase
    ) {
      self.array = array
      self.codingPath = codingPath
      self.keyEncodingStrategy = keyEncodingStrategy
    }

    func encodeNil() throws {
      array.append(nil)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
      let encoder = VariantEncoder(forPath: codingPath + [_CodingKey.index(count)], keyEncodingStrategy: keyEncodingStrategy)
      try value.encode(to: encoder)
      array.append(encoder.value)
    }

    func nestedContainer<NestedKey>(
      keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
      let nestedDictionary = VariantDictionary()
      array.append(Variant(nestedDictionary))
      return KeyedEncodingContainer(
        VariantKeyedContainer<NestedKey>(nestedDictionary, forPath: self.codingPath, keyEncodingStrategy: keyEncodingStrategy))
    }

    func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
      let nestedArray = VariantArray()
      array.append(Variant(nestedArray))
      return VariantUnkeyedContainer(nestedArray, forPath: self.codingPath, keyEncodingStrategy: keyEncodingStrategy)
    }

    func superEncoder() -> any Encoder {
      let index = array.count
      array.append(nil)
      let encoder = VariantEncoder(forPath: codingPath + [_CodingKey.index(index)], keyEncodingStrategy: keyEncodingStrategy)
      encoder.writeBack = { [array] in array[index] = $0 }
      return encoder
    }
  }

  class VariantSingleValueContainer: SingleValueEncodingContainer, VariantEncodingContainer {
    var value: Variant?
    var codingPath: [any CodingKey]
    let keyEncodingStrategy: KeyEncodingStrategy

    init(forPath codingPath: [any CodingKey] = [], keyEncodingStrategy: KeyEncodingStrategy = .convertToSnakeCase) {
      self.codingPath = codingPath
      self.keyEncodingStrategy = keyEncodingStrategy
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
      let encoder = VariantEncoder(forPath: codingPath, keyEncodingStrategy: keyEncodingStrategy)
      try value.encode(to: encoder)
      self.value = encoder.value
    }
  }

}

// MARK: - VariantDecoder

public class VariantDecoder: Decoder {
  public var codingPath: [any CodingKey]
  public var userInfo: [CodingUserInfoKey: Any] = [:]

  public enum KeyDecodingStrategy {
    case useDefaultKeys
    case convertFromSnakeCase
  }

  let variant: Variant?
  let keyDecodingStrategy: KeyDecodingStrategy

  init(
    _ variant: Variant?,
    forPath codingPath: [any CodingKey] = [],
    keyDecodingStrategy: KeyDecodingStrategy = .convertFromSnakeCase
  ) {
    self.variant = variant
    self.codingPath = codingPath
    self.keyDecodingStrategy = keyDecodingStrategy
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
      VariantKeyedDecodingContainer<Key>(
        dictionary, forPath: codingPath, keyDecodingStrategy: keyDecodingStrategy))
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
    return VariantUnkeyedDecodingContainer(array, forPath: codingPath, keyDecodingStrategy: keyDecodingStrategy)
  }

  public func singleValueContainer() throws -> any SingleValueDecodingContainer {
    VariantSingleValueDecodingContainer(variant, forPath: codingPath, keyDecodingStrategy: keyDecodingStrategy)
  }

  struct VariantKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K

    let dictionary: VariantDictionary
    var codingPath: [any CodingKey]
    let keyDecodingStrategy: KeyDecodingStrategy

    var allKeys: [K] {
      let keys = dictionary.keys()
      return (0..<keys.count).compactMap { index in
        guard let string: String = keys[index]?.to() else { return nil }
        return K(stringValue: decodeKey(string))
      }
    }

    init(
      _ dictionary: VariantDictionary,
      forPath codingPath: [any CodingKey],
      keyDecodingStrategy: KeyDecodingStrategy = .convertFromSnakeCase
    ) {
      self.dictionary = dictionary
      self.codingPath = codingPath
      self.keyDecodingStrategy = keyDecodingStrategy
    }

    func contains(_ key: K) -> Bool {
      dictionary.has(key: Variant(encodeKey(key.stringValue)))
    }

    func decodeNil(forKey key: K) throws -> Bool {
      let value = try getValue(forKey: key)
      return value == nil || value?.gtype == .nil
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: K) throws -> T {
      let value = try getValue(forKey: key)
      let decoder = VariantDecoder(
        value, forPath: codingPath + [key], keyDecodingStrategy: keyDecodingStrategy)
      return try T(from: decoder)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws
      -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
    {
      let value = try getValue(forKey: key)
      let decoder = VariantDecoder(
        value, forPath: codingPath + [key], keyDecodingStrategy: keyDecodingStrategy)
      return try decoder.container(keyedBy: type)
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> any UnkeyedDecodingContainer {
      let value = try getValue(forKey: key)
      let decoder = VariantDecoder(
        value, forPath: codingPath + [key], keyDecodingStrategy: keyDecodingStrategy)
      return try decoder.unkeyedContainer()
    }

    func superDecoder() throws -> any Decoder {
      let value = dictionary[_CodingKey.super.stringValue]
      return VariantDecoder(
        value, forPath: codingPath + [_CodingKey.super], keyDecodingStrategy: keyDecodingStrategy)
    }

    func superDecoder(forKey key: K) throws -> any Decoder {
      let value = try getValue(forKey: key)
      return VariantDecoder(
        value, forPath: codingPath + [key], keyDecodingStrategy: keyDecodingStrategy)
    }

    private func encodeKey(_ key: String) -> String {
      switch keyDecodingStrategy {
      case .useDefaultKeys:
        key
      case .convertFromSnakeCase:
        key.camelCaseToSnakeCase()
      }
    }

    private func decodeKey(_ key: String) -> String {
      switch keyDecodingStrategy {
      case .useDefaultKeys:
        key
      case .convertFromSnakeCase:
        key.snakeCaseToCamelCase()
      }
    }

    private func getValue(forKey key: K) throws -> Variant? {
      let encodedKey = encodeKey(key.stringValue)
      guard dictionary.has(key: Variant(encodedKey)) else {
        throw DecodingError.keyNotFound(
          key,
          .init(
            codingPath: codingPath,
            debugDescription: "No value associated with key \(key) (\"\(encodedKey)\")."))
      }
      return dictionary[encodedKey]
    }
  }

  class VariantUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [any CodingKey]
    var count: Int? { array.count }
    var isAtEnd: Bool { currentIndex >= array.count }
    var currentIndex: Int = 0

    let array: VariantArray
    let keyDecodingStrategy: KeyDecodingStrategy

    init(
      _ array: VariantArray,
      forPath codingPath: [any CodingKey] = [],
      keyDecodingStrategy: KeyDecodingStrategy = .convertFromSnakeCase
    ) {
      self.array = array
      self.codingPath = codingPath
      self.keyDecodingStrategy = keyDecodingStrategy
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
        variant, forPath: codingPath + [_CodingKey.index(currentIndex)], keyDecodingStrategy: keyDecodingStrategy)
      let value = try T(from: decoder)
      next()
      return value
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws
      -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
    {
      let variant = try currentValue(ofType: KeyedDecodingContainer<NestedKey>.self)
      let decoder = VariantDecoder(
        variant, forPath: codingPath + [_CodingKey.index(currentIndex)], keyDecodingStrategy: keyDecodingStrategy)
      let value = try decoder.container(keyedBy: type)
      next()
      return value
    }

    func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
      let variant = try currentValue(ofType: UnkeyedDecodingContainer.self)
      let decoder = VariantDecoder(
        variant, forPath: codingPath + [_CodingKey.index(currentIndex)], keyDecodingStrategy: keyDecodingStrategy)
      let value = try decoder.unkeyedContainer()
      next()
      return value
    }

    func superDecoder() throws -> any Decoder {
      let variant = try currentValue(ofType: (any Decoder).self)
      let decoder = VariantDecoder(
        variant, forPath: codingPath + [_CodingKey.index(currentIndex)], keyDecodingStrategy: keyDecodingStrategy)
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
    let keyDecodingStrategy: KeyDecodingStrategy

    init(
      _ variant: Variant?,
      forPath codingPath: [any CodingKey] = [],
      keyDecodingStrategy: KeyDecodingStrategy = .convertFromSnakeCase
    ) {
      self.variant = variant
      self.codingPath = codingPath
      self.keyDecodingStrategy = keyDecodingStrategy
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
      let decoder = VariantDecoder(variant, forPath: codingPath, keyDecodingStrategy: keyDecodingStrategy)
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

}

// MARK: - _CodingKey

fileprivate enum _CodingKey: CodingKey {
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

// MARK: - String Case Conversion

fileprivate extension String {
  func snakeCaseToCamelCase() -> String {
    let parts = split(separator: "_")
    let r = parts[0].lowercased() + parts.dropFirst().map { x in x.prefix(1).capitalized + String(x.dropFirst()).cleverLowercase() }.joined()
    if first == "_" {
      return "_" + r
    }
    return r
  }

  func camelCaseToSnakeCase() -> String {
    let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
    let normalPattern = "([a-z0-9])([A-Z])"
    let result = processCamelCaseRegex(pattern: acronymPattern)?
      .processCamelCaseRegex(pattern: normalPattern)?.lowercased() ?? lowercased()
    return result
      .replacingOccurrences(of: "2_d", with: "2d")
      .replacingOccurrences(of: "3_d", with: "3d")
  }

  private func cleverLowercase() -> String {
    var upper = false
    var lower = false

    for x in self {
      upper = upper || x.isUppercase
      lower = lower || x.isLowercase
    }
    if upper && lower {
      return self
    }
    return lowercased()
  }

  private func processCamelCaseRegex(pattern: String) -> String? {
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: count)
    return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
  }
}
