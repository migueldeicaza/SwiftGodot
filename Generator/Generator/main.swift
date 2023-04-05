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
var generatorOutput = args.count > 2 ? args [2] : "/Users/miguel/cvs/SwiftGodot/Sources/SwiftGodot"

let outputDir = args.count > 2 ? args [2] : generatorOutput

print ("Usage is: generator [godot-main-directory [output-directory]]")
print ("where godot-main-directory contains api.json and builtin-api.json")
print ("If unspecified, this will default to the built-in versions")

let jsonData = try! Data(contentsOf: URL(fileURLWithPath: projectDir + "/extension_api.json"))
let jsonApi = try! JSONDecoder().decode(JGodotExtensionAPI.self, from: jsonData)

// Determines whether a built-in type is defined as a structure, this means:
// that it has fields and does not have a "handle" pointer to the native object
var isStructMap: [String:Bool] = [:]

// Where we accumulate our output for the p/b routines
var result = ""
var indentStr = ""          // The current indentation string, based on `indent`
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

func b (_ str: String, suffix: String = "", block: () -> ()) {
    p (str + " {")
    indent += 1
    block ()
    indent -= 1
    p ("}\(suffix)\n")
}

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

func generateEnums (values: [JGodotGlobalEnumElement]) {
    for enumDef in values {
        if enumDef.isBitfield ?? false {
            b ("public struct \(getGodotType (SimpleType (type: enumDef.name))): OptionSet") {
                p ("public let rawValue: Int")
                b ("public init (rawValue: Int)") {
                    p ("self.rawValue = rawValue")
                }
                for enumVal in enumDef.values {
                    let name = dropMatchingPrefix (enumDef.name, enumVal.name)
                    p ("public static let \(escapeSwift (name)) = \(enumDef.name) (rawValue: \(enumVal.value))")
                }
            }
            continue
        }
        var enumDefName = enumDef.name
        if enumDefName.starts(with: "Variant") {
            p ("extension Variant {")
            indent += 1
            enumDefName = String (enumDefName.dropFirst("Variant.".count))
        }
        b ("public enum \(getGodotType (SimpleType (type: enumDefName))): Int") {
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
                p ("\(prefix)case \(escapeSwift(name)) = \(enumVal.value) // \(enumVal.name)")
            }
        }
        if enumDef.name.starts (with: "Variant") {
            indent -= 1
            p ("}\n")
        }
    }
}

func mapEnumValue (enumDef: String, value: String) -> String? {
    let t = enumDef.dropFirst(6)
    guard let p = t.firstIndex(of: ".") else {
        print ("Cant find enum \(enumDef)")
        return nil
    }
    let type = t [t.startIndex..<p]
    let enumt = t [t.index(p, offsetBy: 1)...]
    print ("Got \(type) -- \(enumt)")
    guard let x = classMap [String (type)] else {
        print ("WARNING: could not find type \(type) for \(enumDef)")
        return nil
    }
    for e in x.enums ?? [] {
        if e.name == enumt {
            for evalue in e.values {
                if "\(evalue.value)" == value {
                    let name = dropMatchingPrefix (String (e.name), evalue.name)
                    return ".\(escapeSwift (name))"
                }
            }
        }
    }
    return nil
}

func getArgumentDeclaration (_ argument: JNameAndType, eliminate: String, kind: ArgumentKind = .classes) -> String {
    //let optNeedInOut = isCoreType(name: argument.type) ? "inout " : ""
    let optNeedInOut = ""
    
    var def: String = ""
    if let dv = argument.defaultValue, dv != "" {
        // TODO:
        //  - handle creating initializers from enums (builtint)
        //  - empty arrays
        //  - bitfield defaults
        //  - Structure with initialized values (Color (1,1,1,1))
        //  - NodePath ("") ctor
        //  - nil values (needs to both turn the value nullable and handle that in the marshal code
        //  - typedarrays, the default values need to be handled one by one, or a general conversion
        // system needs to be implemented
        if !argument.type.starts(with: "Array") && !argument.type.starts(with: "bitfield::") && (!(isStructMap [argument.type] ?? false) || isPrimitiveType(name: argument.type)) && argument.type != "NodePath" && !argument.type.starts(with: "typedarray::") && !argument.type.starts (with: "Dictionary") && dv != "null" {
            if argument.type == "String" {
                def = " = GString (\(dv))"
            } else if argument.type == "StringName" {
                def = " = StringName (\"dv\")"
            } else if argument.type.starts(with: "enum::"){
                if let ev = mapEnumValue (enumDef: argument.type, value: dv) {
                    def = " = \(ev)"
                }
            } else {
                def = " = \(dv)"
            }
        }
    }
    return "\(eliminate)\(escapeSwift (snakeToCamel (argument.name))): \(optNeedInOut)\(getGodotType(argument, kind: kind))\(def)"
}

func generateArgPrepare (_ args: [JNameAndType]) -> String {
    var body = ""
    
    if args.count > 0 {
        for arg in args {
            //if !isCoreType (name: arg.type) {
            if isStructMap [arg.type] ?? false {
                body += "var copy_\(arg.name) = \(escapeSwift (snakeToCamel (arg.name)))\n"
            }
        }

        body += "var args: [UnsafeRawPointer?] = [\n"
        
        for arg in args {
            var argref: String
            var optstorage: String
            if !(isStructMap [arg.type] ?? false) { // { ) isCoreType(name: arg.type){
                argref = escapeSwift (snakeToCamel (arg.name))
                if isStructMap [arg.type] ?? false {
                    optstorage = ""
                } else {
                    if builtinSizes [arg.type] != nil && arg.type != "Object" {
                        optstorage = ".content"
                    } else {
                        optstorage = ".handle"
                    }
                }
            } else {
                argref = "copy_\(arg.name)"
                optstorage = ""
            }
            if (isStructMap [arg.type] ?? false) {
                
                body += "    UnsafeRawPointer(&\(escapeSwift(argref))\(optstorage)), // isCoreType: \(arg.type) \(isCoreType (name: arg.type)) - \(escapeSwift(argref)) argRef:\(argref)\n"
            } else {
                body += "    UnsafeRawPointer(&\(escapeSwift(argref))\(optstorage)),\n"
            }
        }
        body += "]"
        
    }
    return body
}

print ("Running with projectDir=$(projectDir) and output=\(outputDir)")
result = "// This file is autogenerated, do not edit\n"
result += "import Foundation\nimport GDExtension\n\n"

generateEnums(values: jsonApi.globalEnums)
for x in jsonApi.builtinClasses {
    let value = x.members?.count ?? 0 > 0
    isStructMap [String (x.name)] = value
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

var classMap: [String:JGodotExtensionAPIClass] = [:]
for x in jsonApi.classes {
    classMap [x.name] = x
}
try! result.write(toFile: outputDir + "/generated-builtin/core-defs.swift", atomically: true, encoding: .utf8)

generateBuiltinClasses(values: jsonApi.builtinClasses, outputDir: outputDir + "/generated-builtin/")

result = ""
generateClasses (values: jsonApi.classes, outputDir: outputDir)

print ("Done")
