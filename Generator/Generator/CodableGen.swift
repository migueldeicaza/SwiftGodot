//
//  CodableGen.swift
//  Generator
//
//  Generates Variant.CodableTaggedRepresentation enum for Codable support
//

/// Mapping of GType case name → Swift type for codable cases.
/// `variantExtraction` describes how to extract the value from a Variant.
private struct CodableGTypeEntry {
    let caseName: String
    let swiftType: String
    let variantExtraction: String
    let variantConstruction: String
}

private let codableGTypeCases: [CodableGTypeEntry] = [
    .init(caseName: "bool",               swiftType: "Bool",               variantExtraction: "Bool(variant)!",               variantConstruction: "Variant(v)"),
    .init(caseName: "int",                swiftType: "Int64",              variantExtraction: "Int64(variant)!",              variantConstruction: "Variant(v)"),
    .init(caseName: "float",              swiftType: "Double",             variantExtraction: "Double(variant)!",             variantConstruction: "Variant(v)"),
    .init(caseName: "string",             swiftType: "String",             variantExtraction: "GString(variant)!.description", variantConstruction: "Variant(v)"),
    .init(caseName: "vector2",            swiftType: "Vector2",            variantExtraction: "Vector2(variant)!",            variantConstruction: "Variant(v)"),
    .init(caseName: "vector2i",           swiftType: "Vector2i",           variantExtraction: "Vector2i(variant)!",           variantConstruction: "Variant(v)"),
    .init(caseName: "rect2",              swiftType: "Rect2",              variantExtraction: "Rect2(variant)!",              variantConstruction: "Variant(v)"),
    .init(caseName: "rect2i",             swiftType: "Rect2i",             variantExtraction: "Rect2i(variant)!",             variantConstruction: "Variant(v)"),
    .init(caseName: "vector3",            swiftType: "Vector3",            variantExtraction: "Vector3(variant)!",            variantConstruction: "Variant(v)"),
    .init(caseName: "vector3i",           swiftType: "Vector3i",           variantExtraction: "Vector3i(variant)!",           variantConstruction: "Variant(v)"),
    .init(caseName: "transform2d",        swiftType: "Transform2D",        variantExtraction: "Transform2D(variant)!",        variantConstruction: "Variant(v)"),
    .init(caseName: "vector4",            swiftType: "Vector4",            variantExtraction: "Vector4(variant)!",            variantConstruction: "Variant(v)"),
    .init(caseName: "vector4i",           swiftType: "Vector4i",           variantExtraction: "Vector4i(variant)!",           variantConstruction: "Variant(v)"),
    .init(caseName: "plane",              swiftType: "Plane",              variantExtraction: "Plane(variant)!",              variantConstruction: "Variant(v)"),
    .init(caseName: "quaternion",         swiftType: "Quaternion",         variantExtraction: "Quaternion(variant)!",         variantConstruction: "Variant(v)"),
    .init(caseName: "aabb",               swiftType: "AABB",               variantExtraction: "AABB(variant)!",               variantConstruction: "Variant(v)"),
    .init(caseName: "basis",              swiftType: "Basis",              variantExtraction: "Basis(variant)!",              variantConstruction: "Variant(v)"),
    .init(caseName: "transform3d",        swiftType: "Transform3D",        variantExtraction: "Transform3D(variant)!",        variantConstruction: "Variant(v)"),
    .init(caseName: "projection",         swiftType: "Projection",         variantExtraction: "Projection(variant)!",         variantConstruction: "Variant(v)"),
    .init(caseName: "color",              swiftType: "Color",              variantExtraction: "Color(variant)!",              variantConstruction: "Variant(v)"),
    .init(caseName: "stringName",         swiftType: "StringName",         variantExtraction: "StringName(variant)!",         variantConstruction: "Variant(v)"),
    .init(caseName: "nodePath",           swiftType: "NodePath",           variantExtraction: "NodePath(variant)!",           variantConstruction: "Variant(v)"),
    .init(caseName: "array",              swiftType: "VariantArray",       variantExtraction: "VariantArray(variant)!",       variantConstruction: "Variant(v)"),
    .init(caseName: "dictionary",         swiftType: "VariantDictionary",  variantExtraction: "VariantDictionary(variant)!",  variantConstruction: "Variant(v)"),
    .init(caseName: "packedByteArray",    swiftType: "PackedByteArray",    variantExtraction: "PackedByteArray(variant)!",    variantConstruction: "Variant(v)"),
    .init(caseName: "packedInt32Array",   swiftType: "PackedInt32Array",   variantExtraction: "PackedInt32Array(variant)!",   variantConstruction: "Variant(v)"),
    .init(caseName: "packedInt64Array",   swiftType: "PackedInt64Array",   variantExtraction: "PackedInt64Array(variant)!",   variantConstruction: "Variant(v)"),
    .init(caseName: "packedFloat32Array", swiftType: "PackedFloat32Array", variantExtraction: "PackedFloat32Array(variant)!", variantConstruction: "Variant(v)"),
    .init(caseName: "packedFloat64Array", swiftType: "PackedFloat64Array", variantExtraction: "PackedFloat64Array(variant)!", variantConstruction: "Variant(v)"),
    .init(caseName: "packedStringArray",  swiftType: "PackedStringArray",  variantExtraction: "PackedStringArray(variant)!",  variantConstruction: "Variant(v)"),
    .init(caseName: "packedVector2Array", swiftType: "PackedVector2Array", variantExtraction: "PackedVector2Array(variant)!", variantConstruction: "Variant(v)"),
    .init(caseName: "packedVector3Array", swiftType: "PackedVector3Array", variantExtraction: "PackedVector3Array(variant)!", variantConstruction: "Variant(v)"),
    .init(caseName: "packedColorArray",   swiftType: "PackedColorArray",   variantExtraction: "PackedColorArray(variant)!",   variantConstruction: "Variant(v)"),
    .init(caseName: "packedVector4Array", swiftType: "PackedVector4Array", variantExtraction: "PackedVector4Array(variant)!", variantConstruction: "Variant(v)"),
]

/// Non-serializable GType cases that should throw on encoding
private let nonCodableGTypes = ["rid", "object", "callable", "signal"]

extension Generator {
    func generateCodableTaggedRepresentation(_ p: Printer) {
        p.b("extension Variant") {
            p("/// A type-discriminated Codable representation of a Variant value.")
            p("/// Used to serialize/deserialize Variant values to/from Codable-compatible formats.")
            p("/// Non-serializable types (Object, Callable, Signal, RID) are not included;")
            p("/// attempting to create a CodableTaggedRepresentation from such a Variant will throw.")
            p.b("enum CodableTaggedRepresentation: Codable, Equatable") {
                for entry in codableGTypeCases {
                    p("case \(entry.caseName)(\(entry.swiftType))")
                }

                p("")

                // CodingKeys
                p.b("private enum CodingKeys: Swift.String, CodingKey") {
                    p("case type")
                    p("case value")
                }

                p("")

                // encode(to:)
                p.b("public func encode(to encoder: Encoder) throws") {
                    p("var container = encoder.container(keyedBy: CodingKeys.self)")
                    p.b("switch self") {
                        for entry in codableGTypeCases {
                            p("case .\(entry.caseName)(let v):")
                            p("    try container.encode(\"\(entry.caseName)\", forKey: .type)")
                            p("    try container.encode(v, forKey: .value)")
                        }
                    }
                }

                p("")

                // init(from:)
                p.b("public init(from decoder: Decoder) throws") {
                    p("let container = try decoder.container(keyedBy: CodingKeys.self)")
                    p("let type = try container.decode(Swift.String.self, forKey: .type)")
                    p.b("switch type") {
                        for entry in codableGTypeCases {
                            p("case \"\(entry.caseName)\":")
                            p("    self = .\(entry.caseName)(try container.decode(\(entry.swiftType).self, forKey: .value))")
                        }
                        p("default:")
                        p("    throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: \"Unknown Variant type tag: \\(type)\")")
                    }
                }

                p("")

                // init(_ variant: Variant) throws
                p("/// Creates a CodableTaggedRepresentation from a Variant.")
                p("/// Throws `EncodingError.invalidValue` for non-serializable types (Object, Callable, Signal, RID) and nil Variants.")
                p.b("init(_ variant: Variant) throws") {
                    p.b("switch variant.gtype") {
                        p("case .nil:")
                        p("    throw EncodingError.invalidValue(variant, EncodingError.Context(codingPath: [], debugDescription: \"Cannot encode nil Variant. Use CodableTaggedRepresentation? (Optional) for nil Variants.\"))")

                        for entry in codableGTypeCases {
                            p("case .\(entry.caseName):")
                            p("    self = .\(entry.caseName)(\(entry.variantExtraction))")
                        }

                        for nonCodable in nonCodableGTypes {
                            p("case .\(nonCodable):")
                            p("    throw EncodingError.invalidValue(variant, EncodingError.Context(codingPath: [], debugDescription: \"Variant of type \\(variant.gtype) is not serializable.\"))")
                        }
                    }
                }

                p("")

                // toVariant()
                p("/// Converts this tagged representation back to a Variant.")
                p.b("public func toVariant() -> Variant") {
                    p.b("switch self") {
                        for entry in codableGTypeCases {
                            p("case .\(entry.caseName)(let v): return \(entry.variantConstruction)")
                        }
                    }
                }
            }
        }
    }
}
