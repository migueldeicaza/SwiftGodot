//
//  VariantCodable.swift
//  SwiftGodot
//
//  Codable conformance for Variant via CodableTaggedRepresentation.
//

extension Variant: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(CodableTaggedRepresentation(self))
    }
}

extension Variant: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let tagged = try container.decode(CodableTaggedRepresentation.self)
        self.init(tagged.toVariant())
    }
}
