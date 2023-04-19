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

let jsonFile = args.count > 1 ? args [1] : "/Users/miguel/cvs/godot-master/extension_api.json"
var generatorOutput = args.count > 2 ? args [2] : "/Users/miguel/cvs/SwiftGodot/DEBUG"
var docRoot =  args.count > 3 ? args [3] : "/Users/miguel/cvs/godot-master/doc"

let outputDir = args.count > 2 ? args [2] : generatorOutput

print ("Usage is: generator [godot-main-directory [output-directory]]")
print ("where godot-main-directory contains api.json and builtin-api.json")
print ("If unspecified, this will default to the built-in versions")

let jsonData = try! Data(contentsOf: URL(fileURLWithPath: jsonFile))
let jsonApi = try! JSONDecoder().decode(JGodotExtensionAPI.self, from: jsonData)

// Determines whether a built-in type is defined as a structure, this means:
// that it has fields and does not have a "handle" pointer to the native object
var isStructMap: [String:Bool] = [:]

func dropMatchingPrefix (_ enumName: String, _ enumKey: String) -> String {
    let snake = snakeToCamel (enumKey)
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

var globalEnums: [String: JGodotGlobalEnumElement] = [:]

var coreDefPrinter = Printer()
coreDefPrinter.preamble()

print ("Running with projectDir=$(projectDir) and output=\(outputDir)")
let globalDocs = loadClassDoc(base: docRoot, name:  "@GlobalScope")
var classMap: [String:JGodotExtensionAPIClass] = [:]
for x in jsonApi.classes {
    classMap [x.name] = x
}

var builtinMap: [String: JGodotBuiltinClass] = [:]
generateEnums(coreDefPrinter, cdef: nil, values: jsonApi.globalEnums, constantDocs: globalDocs?.constants?.constant, prefix: "")

for x in jsonApi.builtinClasses {
    let value = x.members?.count ?? 0 > 0
    isStructMap [String (x.name)] = value
    builtinMap [x.name] = x
}
for x in ["Float", "Int", "float", "int", "Variant", "Int32", "Bool", "bool"] {
    isStructMap [x] = true
}

var builtinSizes: [String: Int] = [:]
for cs in jsonApi.builtinClassSizes {
    if cs.buildConfiguration == "float_64" {
        for c in cs.sizes {
            builtinSizes [c.name] = c.size
        }
    }
}

let generatedBuiltinDir = outputDir + "/generated-builtin/"
let generatedDir = outputDir + "/generated/"

try! FileManager.default.createDirectory(atPath: generatedBuiltinDir, withIntermediateDirectories: true)
try! FileManager.default.createDirectory(atPath: generatedDir, withIntermediateDirectories: true)

generateBuiltinClasses(values: jsonApi.builtinClasses, outputDir: generatedBuiltinDir)

generateClasses (values: jsonApi.classes, outputDir: generatedDir)

generateCtorPointers (coreDefPrinter)
coreDefPrinter.save (generatedBuiltinDir + "/core-defs.swift")

print ("Done")
