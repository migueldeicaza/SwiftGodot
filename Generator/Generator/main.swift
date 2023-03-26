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
    switch t {
    case "int":
        return "Int"
    case "float", "real":
        return "Float"
    case "Nil":
        return "Variant"
    case "void":
        return ""
    case "bool":
        return "Bool"
    case "String":
        return "GString"
    default:
        return t
    }
}

func generateEnums (values: [JGodotGlobalEnumElement]) {
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

func getArgumentDeclaration (_ argument: JGodotSingleton, eliminate: String) -> String {
    //let optNeedInOut = isCoreType(name: argument.type) ? "inout " : ""
    let optNeedInOut = ""
    return "\(eliminate)\(escapeSwift (snakeToCamel (argument.name))): \(optNeedInOut)\(getGodotType(argument.type))"
}

func generateArgPrepare (_ args: [JGodotSingleton]) -> String {
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
                    optstorage = ".handle /* \(arg.type) -> \(isStructMap [arg.type]) */" // + builtinTypeToGdName(arg.type)
                }
            } else {
                argref = "copy_\(arg.name)"
                optstorage = ""
            }
            if (isStructMap [arg.type] ?? false) {
                
                body += "    UnsafeRawPointer(&\(escapeSwift(argref))\(optstorage)), // isCoreType: \(arg.type) \(isCoreType (name: arg.type)) - \(escapeSwift(argref)) argRef:\(argref)\n"
            } else {
                body += "    UnsafeRawPointer(&\(escapeSwift(argref)).handle),\n"
            }
            //body += "    &\(argref),\n"
            //twiwarnDelete += "    _ = \(argref)\n"
        }
        body += "]\n"
        
    }
    return body
}

func generateBuiltinCtors (_ ctors: [JGodotConstructor], /*_ gdname: String,*/ typeName: String, typeEnum: String)
{
    var generated = ""
    var ctorCount = 0
    for m in ctors {
        var mr: String
        
        var args = ""
    
        let ptrName = "constructor\(ctorCount)"
        p ("static var \(ptrName): GDExtensionPtrConstructor = gi.variant_get_ptr_constructor (\(typeEnum), \(ctorCount))!\n")
        ctorCount += 1
        for arg in m.arguments ?? [] {
            if args != "" { args += ", " }
            args += getArgumentDeclaration(arg, eliminate: "")
        }
        
        b ("public init (\(args))") {
            p (generateArgPrepare(m.arguments ?? []))
            
            let ptrArgs = (m.arguments != nil) ? "&args" : "nil"
            
            // I used to have a nicer model, rather than everything having a
            // handle, I had a named handle, like "_godot_string"
            let ptr = isStructMap [typeName] ?? false ? "self" : "handle"
            
            p ("\(typeName).\(ptrName) (&\(ptr), \(ptrArgs))")
        }
    }
}

var isStructMap: [String:Bool] = [:]

func generateBuiltinClasses (values: [JGodotBuiltinClass]) {
    func generateBuiltinClass (_ bc: JGodotBuiltinClass) {
        // TODO: isKeyed, hasDestrcturo,
        var kind: String
        if bc.members != nil {
            kind = "struct"
        } else {
            kind = "class"
        }
        let typeName = mapTypeName (bc.name)
        let typeEnum = "GDEXTENSION_VARIANT_TYPE_" + camelToSnake(bc.name).uppercased()
        b ("public \(kind) \(typeName) ") {
            if bc.name == "String" {
                b ("public init (_ str: String)") {
                    p ("var vh: UnsafeMutableRawPointer?")
                    p ("gi.string_new_with_utf8_chars (&vh, str)")
                    p ("handle = OpaquePointer (vh)")
                }
            }
            if kind == "class" {
                p ("var handle: OpaquePointer?")
            }
            if let members = bc.members {
                for x in members {
                    p ("var \(x.name): \(jsonTypeToSwift (x.type))")
                }
            }

            generateBuiltinCtors (bc.constructors, typeName: typeName, typeEnum: typeEnum)
            if let methods = bc.methods {
                for method in methods {
                    if method.name == "repeat" {
                        // TODO: Avoid clash for now
                        continue
                    }
                    var ret = method.returnType == nil ? "" : "-> \(jsonTypeToSwift (method.returnType!))"
                    b ("func \(method.name) ()\(ret)") {
                        p ("abort ()")
                    }
                }
            }
        }
    }
    
    for bc in values {
        switch bc.name {
            // We do not generate code for a few types, we will bridge those instead
        case "int", "float", "bool":
            break
        default:
            generateBuiltinClass (bc)
        }
    }
}

print ("Running with projectDir=$(projectDir) and output=\(outputDir)")
result = "// This file is autogenerated, do not edit\n"
result += "import Foundation\nimport GDExtension\n\n"

generateEnums(values: jsonApi.globalEnums)
for x in jsonApi.builtinClasses {
    let value = x.members?.count ?? 0 > 0
    isStructMap [String (x.name)] = value
}
for x in ["Float", "Int", "float", "int", "Variant"] {
    isStructMap [x] = true
}
generateBuiltinClasses(values: jsonApi.builtinClasses)

try! result.write(toFile: outputDir + "/generated.swift", atomically: true, encoding: .utf8)

print ("Done")
