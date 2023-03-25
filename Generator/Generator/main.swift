//
//  main.swift
//  SwiftGodot/Generator
//
//  Created by Miguel de Icaza on 5/20/20.
//  Copyright © 2020-2023 Miguel de Icaza. MIT Licensed
//

import Foundation

// IF we want a single file, or one file per type
var singleFile = true

var args = CommandLine.arguments

let projectDir = args.count > 1 ? args [1] : "/Users/miguel/cvs/godot-master/godot"
var generatorOutput = "/Users/miguel/cvs/SwiftGodot/SwiftGodot/Sources/SwiftGodot/generated/"

let outputDir = args.count > 2 ? args [2] : generatorOutput

print ("Usage is: generator [godot-main-directory [output-directory]]")
print ("where godot-main-directory contains api.json and builtin-api.json")
print ("If unspecified, this will default to the built-in versions")

let jsonData = try! Data(contentsOf: URL(fileURLWithPath: projectDir + "/extension_api.json"))
let jsonApi = try! JSONDecoder().decode(JGodotExtensionAPI.self, from: jsonData)
var methodBindCount = 0

var result = ""
var indentStr = ""
var indent = 0 {
    didSet {
        indentStr = String (repeating: "    ", count: indent)
    }
}

func p (_ str: String) {
    for x in str.split(separator: "\n", omittingEmptySubsequences: false) {
        print ("\(indentStr)\(x)", to: &result)
    }
}

func b (_ str: String, block: () -> ()) {
    p (str + " {")
    indent += 1
    block ()
    indent -= 1
    p ("}\n")
}

func getGodotType (_ t: String) -> String {
    if t == "Error" {
        return "GError"
    }
    return t
}

func generateEnums (to: TextOutputStream, values: [JGodotGlobalEnumElement]) {
    func dropMatchingPrefix (_ enumName: String, _ enumKey: String) -> String {
        let snake = snakeToCamel (enumKey)
        if enumKey == "VERTICAL" {
            print()
        }
        if snake.lowercased().starts(with: enumName.lowercased()) {
            if snake.count == enumName.count {
                return snake
            }
            let ret = String (snake [snake.index (snake.startIndex, offsetBy: enumName.count)...])
            if let f = ret.first {
                if f.isNumber {
                    return snake
                }
            }
            if ret == "" {
                return snake
            }
            return ret.first!.lowercased() + ret.dropFirst()
        }
        return snake
    }
    
    for enumDef in values {
        if enumDef.isBitfield {
            b ("public struct \(getGodotType (enumDef.name)): OptionSet") {
                p ("public let rawValue: Int")
                b ("public init (rawValue: Int)") {
                    p ("self.rawValue = rawValue")
                }
                for enumVal in enumDef.values {
                    let name = dropMatchingPrefix (enumDef.name, enumVal.name)
                    p ("public static let \(escapeSwift (name)) = \(enumDef.name) (rawValue: \(enumVal.value))")
                }
            }
            return
        }
        var enumDefName = enumDef.name
        if enumDefName.starts(with: "Variant") {
            p ("extension Variant {")
            indent += 1
            enumDefName = String (enumDefName.dropFirst("Variant.".count))
        }
        b ("public enum \(getGodotType (enumDefName)): Int") {
            for enumVal in enumDef.values {
                let enumValName = enumVal.name
                if enumDefName == "InlineAlignment" {
                    if enumValName == "INLINE_ALIGNMENT_TOP_TO" || enumValName == "INLINE_ALIGNMENT_TO_TOP" ||
                    enumValName == "INLINE_ALIGNMENT_IMAGE_MASK" || enumValName == "INLINE_ALIGNMENT_TEXT_MASK" {
                        continue
                    }
                }
                let name = dropMatchingPrefix (enumDefName, enumValName)
                p ("case \(escapeSwift(name)) = \(enumVal.value) // \(enumVal.name)")
            }
        }
        if enumDef.name.starts (with: "Variant") {
            indent -= 1
            p ("}\n")
        }
    }
}

print ("Running with projectDir=$(projectDir) and output=\(outputDir)")

generateEnums(to: result, values: jsonApi.globalEnums)

try! result.write(toFile: outputDir + "/generated.swift", atomically: true, encoding: .utf8)

print ("Done")
