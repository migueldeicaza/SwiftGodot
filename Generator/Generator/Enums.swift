//
//  Enums.swift
//  Generator
//
//  Created by Miguel de Icaza on 4/19/23.
//

import ExtensionApi

/// Those cases don't bring anything but confusion, we don't need to export them at all
private let droppedCases: Set<String> = [
    "Variant.Type.TYPE_MAX"
]

extension Generator {
    func generateEnums (_ p: Printer, cdef: JClassInfo?, values: [JGodotGlobalEnumElement], prefix: String?) {
        for enumDef in values {
            let isBitField = enumDef.isBitfield ?? false

            var enumDefName = enumDef.name
            let enumCasePrefix = enumDef.values.commonPrefix()

            if isBitField || enumDef.name == "ConnectFlags" {
                let optionTypeName = getGodotType (SimpleType (type: enumDef.name))
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

            p ("public enum \(getGodotType (SimpleType (type: enumDefName))): Int64, CaseIterable, CustomDebugStringConvertible\(extraConformances)") {
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

                var debugLines: [String] = []
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

                    if prefix == "" {
                        debugLines.append ("case .\(enumName): return \".\(enumName)\"")
                    }
                }

                p ("/// A textual representation of this instance, suitable for debugging")
                p ("public var debugDescription: String") {
                    p ("switch self") {
                        for line in debugLines {
                            p (line)
                        }
                    }
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
            if let prefix {
                globalEnums [prefix + enumDef.name] = enumDef
            }
        }
    }
}
