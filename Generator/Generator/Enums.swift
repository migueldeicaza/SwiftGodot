//
//  Enums.swift
//  Generator
//
//  Created by Miguel de Icaza on 4/19/23.
//

import Foundation

func generateEnums (_ p: Printer, cdef: JClassInfo?, values: [JGodotGlobalEnumElement], constantDocs: [DocConstant]? , prefix: String?) {
    
    var docEnumToValue: [String:String] = [:]
    for d in constantDocs ?? [] {
        docEnumToValue [d.name] = d.rest
    }
            
    for enumDef in values {
        if enumDef.isBitfield ?? false {
            p ("public struct \(getGodotType (SimpleType (type: enumDef.name))): OptionSet") {
                p ("public let rawValue: Int")
                p ("public init (rawValue: Int)") {
                    p ("self.rawValue = rawValue")
                }
                for enumVal in enumDef.values {
                    let name = dropMatchingPrefix (enumDef.name, enumVal.name)
                    if let ed = docEnumToValue [enumVal.name] {
                        doc (p, cdef, ed)
                    }
                    p ("public static let \(escapeSwift (name)) = \(enumDef.name) (rawValue: \(enumVal.value))")
                }
            }
            continue
        }
        var enumDefName = enumDef.name
        if enumDefName.starts(with: "Variant") {
            p ("extension Variant {")
            p.indent += 1
            enumDefName = String (enumDefName.dropFirst("Variant.".count))
        }
        p ("public enum \(getGodotType (SimpleType (type: enumDefName))): Int") {
            var used = Set<Int> ()
            
            for enumVal in enumDef.values {
                let enumValName = enumVal.name
                if enumDefName == "InlineAlignment" {
                    if enumValName == "INLINE_ALIGNMENT_TOP_TO" || enumValName == "INLINE_ALIGNMENT_TO_TOP" ||
                    enumValName == "INLINE_ALIGNMENT_IMAGE_MASK" || enumValName == "INLINE_ALIGNMENT_TEXT_MASK" {
                        continue
                    }
                }
                let name = dropMatchingPrefix (enumDefName, enumValName)
                let prefix: String
                if used.contains(enumVal.value) {
                    prefix = "// "
                } else {
                    prefix = ""
                }
                used.insert(enumVal.value)
                if let ed = docEnumToValue [enumValName] {
                    doc (p, cdef, ed)
                }
                p ("\(prefix)case \(escapeSwift(name)) = \(enumVal.value) // \(enumVal.name)")
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
