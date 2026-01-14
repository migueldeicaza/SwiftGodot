//
//  Enums.swift
//  Generator
//
//  Created by Miguel de Icaza on 4/19/23.
//

import Foundation
import ExtensionApi

/// Stores enum definitions so other generator stages (like default-value mapping)
/// can resolve `enum::Type.Value` even when we skip emitting the corresponding type.
func registerEnumDefinition(_ enumDef: JGodotEnum, prefix: String?) {
    guard let prefix else { return }
    globalEnums[prefix + enumDef.name] = enumDef
}

func registerEnumDefinitions(_ values: [JGodotEnum], prefix: String?) {
    guard let prefix else { return }
    for enumDef in values {
        registerEnumDefinition(enumDef, prefix: prefix)
    }
}

// The name of the form 'bitfield::'
func findEnumDef (name: String) -> JGodotEnum? {
    guard name.starts(with: "bitfield::") else {
        return nil
    }

    let full = name.dropFirst(10)
    guard let split = full.firstIndex(of: ".") else {
        print ("No support for global bitfields for \(name)")
        return nil
    }
    let type = full [full.startIndex..<split]
    guard let cdef = classMap [String (type)] else {
        print ("Could not find class \(type) for \(name)")
        return nil
    }
    let enumName = full [full.index(split, offsetBy: 1)...]
    guard let enums = cdef.enums else {
        print ("Could not find an enum \(enumName) in \(type)")
        return nil
    }
    for x in enums {
        if x.name == enumName {
            return x
        }
    }
    return nil
}

/// Those cases don't bring anything but confusion, we don't need to export them at all
let droppedCases: Set<String> = [
    "Variant.Type.TYPE_MAX"
]

func generateEnums (_ p: Printer, cdef: (any JClassInfo)?, values: [JGodotEnum], prefix: String?) {
    for enumDef in values {
        let isBitField = enumDef.isBitfield

        var enumDefName = enumDef.name
        let enumCasePrefix = enumDef.values.commonPrefix()

        if isBitField || enumDef.name == "ConnectFlags" {
            let optionTypeName = getGodotType (try! SimpleType (type: enumDef.name))
            var optionNames: [String] = []
            p ("public struct \(optionTypeName): OptionSet, CustomDebugStringConvertible") {
                p ("public let rawValue: Int")
                p ("public init (rawValue: Int)") {
                    p ("self.rawValue = rawValue")
                }
                for enumVal in enumDef.values {
                    // These can be replaced with the empty set, and we avoid a warning
                    if enumVal.value == 0 {
                        continue
                    }

                    let name = snakeToCamel(enumVal.name.dropPrefix(enumCasePrefix))
                    doc (p, cdef, enumVal.description)
                    let optionName = escapeSwift (name)
                    optionNames.append(optionName)
                    p ("public static let \(optionName) = \(enumDef.name) (rawValue: \(enumVal.value))")
                }

                p ("/// A textual representation of this instance, suitable for debugging")
                p ("public var debugDescription: String") {
                    p ("var result = \"\"")
                    for on in optionNames {
                        p ("if self.contains (.\(on)) { result += \"\(on), \" }")
                    }
                    p ("if result.hasSuffix (\", \") { result.removeLast (2) }")
                    p ("return result")
                }
            }
            continue
        }

        if enumDefName.starts(with: "Variant") {
            p ("extension Variant {")
            p.indent += 1
            enumDefName = String (enumDefName.dropFirst("Variant.".count))
        }
        let extraConformances = enumDefName == "Error" ? ", Error" : ""

        p ("public enum \(getGodotType (try! SimpleType (type: enumDefName))): Int64, CaseIterable\(extraConformances)") {
            var used = Set<Int> ()

            func getName (_ enumVal: JGodotValueElement) -> String? {
                let enumValName = enumVal.name
                if enumDefName == "InlineAlignment" {
                    if enumValName == "INLINE_ALIGNMENT_TOP_TO" || enumValName == "INLINE_ALIGNMENT_TO_TOP" ||
                        enumValName == "INLINE_ALIGNMENT_IMAGE_MASK" || enumValName == "INLINE_ALIGNMENT_TEXT_MASK" {
                        return nil
                    }
                }
                return snakeToCamel(enumVal.name.dropPrefix(enumCasePrefix))
            }

            for enumVal in enumDef.values {
                if droppedCases.contains("\(enumDef.name).\(enumVal.name)") {
                    continue
                }

                guard let name = getName (enumVal) else { continue }
                let prefix: String
                if used.contains(enumVal.value) {
                    prefix = "// "
                } else {
                    prefix = ""
                }
                used.insert(enumVal.value)

                doc (p, cdef, enumVal.description)
                let enumName = escapeSwift(name)
                if "\(enumDef.name).\(enumVal.name)" == "Variant.Type.TYPE_NIL" {
                    p("/// This case resurfaces during internal bridging of some operators and you will never encounter it")
                }
                p ("\(prefix)case \(enumName) = \(enumVal.value) // \(enumVal.name)")
            }

            if enumDefName == "Error" {
                /// Provides the description of the error.
                p ("public var localizedDescription: String { GD.errorString(error: self.rawValue) }")
            }
        }
        if enumDef.name.starts (with: "Variant") {
            p.indent -= 1
            p ("}\n")
        }
        registerEnumDefinition(enumDef, prefix: prefix)
    }
}
