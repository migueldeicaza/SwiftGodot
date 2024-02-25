//
//  Enums.swift
//  Generator
//
//  Created by Miguel de Icaza on 4/19/23.
//

import Foundation
import ExtensionApi

// The name of the form 'bitfield::'
func findEnumDef (name: String) -> JGodotGlobalEnumElement? {
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
            
        p ("public enum \(getGodotType (SimpleType (type: enumDefName))): Int64, CustomDebugStringConvertible\(extraConformances)") {
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
                p ("public var localizedDescription: String { debugDescription }")
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

