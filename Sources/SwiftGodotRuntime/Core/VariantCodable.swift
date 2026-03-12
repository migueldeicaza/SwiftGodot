//
//  VariantCodable.swift
//  SwiftGodot
//
//  Created by Evan Wang on 3/12/26.
//

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
