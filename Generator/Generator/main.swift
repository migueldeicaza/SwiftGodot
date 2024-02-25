//
//  main.swift
//  SwiftGodot/Generator
//
//  Created by Miguel de Icaza on 5/20/20.
//  Copyright © 2020-2023 Miguel de Icaza. MIT Licensed
//
import Foundation
import ExtensionApi

var args = CommandLine.arguments

let jsonFile = args.count > 1 ? args [1] : "/Users/miguel/cvs/SwiftGodot/Sources/ExtensionApi/extension_api.json"
var generatorOutput = args.count > 2 ? args [2] : "/Users/miguel/cvs/SwiftGodot-DEBUG"
var docRoot =  args.count > 3 ? args [3] : "/Users/miguel/cvs/godot-master/doc"
let outputDir = args.count > 2 ? args [2] : generatorOutput
let generateResettableCache = false 

// IF we want a single file, or one file per type
var singleFile = args.contains("--singlefile")

if args.count < 2 {
    print ("Usage is: generator path-to-extension-api output-directory doc-directory")
    print ("- path-to-extensiona-ppi is the full path to extension_api.json from Godot")
    print ("- output-directory is where the files will be placed")
    print ("- doc-directory is the Godot documentation resides (godot/doc)")
    print ("Running with Miguel's testing defaults")
}

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

print ("Running with projectDir=$(projectDir) and output=\(outputDir)")

// Maps from a the class name to its definition
var classMap: [String:JGodotExtensionAPIClass] = [:]

// Tracks whether a Godot type has subclasses, we want to use this
// to determine whether we want to perform the more expensive lookup
// for handle -> Swift type using `lookupObject` rather than creating
// a plain wrapper directly from the handle
var hasSubclasses = Set<String> ()

for x in jsonApi.classes {
    classMap [x.name] = x
    if let parentClass = x.inherits {
        hasSubclasses.insert(parentClass)
    }
}

var builtinMap: [String: JGodotBuiltinClass] = [:]

for x in jsonApi.builtinClasses {
    let value = x.members?.count ?? 0 > 0
    isStructMap [String (x.name)] = value
    builtinMap [x.name] = x
}
for x in ["Float", "Int", "float", "int", "Int32", "Bool", "bool"] {
    isStructMap [x] = true
}

let buildConfiguration: String = "float_64"
var builtinSizes: [String: Int] = [:]
for cs in jsonApi.builtinClassSizes {
    if cs.buildConfiguration == buildConfiguration {
        for c in cs.sizes {
            builtinSizes [c.name] = c.size
        }
    }
}
var builtinMemberOffsets: [String: [JGodotMember]] = [:]
for mo in jsonApi.builtinClassMemberOffsets {
    if mo.buildConfiguration == buildConfiguration {
        for c in mo.classes {
            builtinMemberOffsets [c.name.rawValue] = c.members
        }
    }
}

let generatedBuiltinDir: String? = singleFile ? nil : (outputDir + "/generated-builtin/")
let generatedDir: String? = singleFile ? nil : (outputDir + "/generated/")

if singleFile {
    try! FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
} else if let generatedBuiltinDir, let generatedDir {
    try! FileManager.default.createDirectory(atPath: generatedBuiltinDir, withIntermediateDirectories: true)
    try! FileManager.default.createDirectory(atPath: generatedDir, withIntermediateDirectories: true)
}

let semaphore = DispatchSemaphore(value: 0)
let _ = Task {
    let coreDefPrinter = await PrinterFactory.shared.initPrinter()
    coreDefPrinter.preamble()
    generateEnums(coreDefPrinter, cdef: nil, values: jsonApi.globalEnums, prefix: "")
    await generateBuiltinClasses(values: jsonApi.builtinClasses, outputDir: generatedBuiltinDir)
    await generateUtility(values: jsonApi.utilityFunctions, outputDir: generatedBuiltinDir)
    await generateClasses (values: jsonApi.classes, outputDir: generatedDir)
    generateCtorPointers (coreDefPrinter)
    if let generatedBuiltinDir {
        coreDefPrinter.save (generatedBuiltinDir + "/core-defs.swift")
    }
    
    if singleFile {
        await PrinterFactory.shared.save(outputDir + "/generated.swift")
    }
    semaphore.signal()
}
semaphore.wait()

//print ("Done")
