//
//  main.swift
//  SwiftGodot/Generator
//
//  Created by Miguel de Icaza on 5/20/20.
//  Copyright © 2020-2023 Miguel de Icaza. MIT Licensed
//
// TODO:
//   Implement destructors
//   I think that for classes, when I create a result value, I should not pass
//   the address of the class, but the address of the handle.
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

func b (_ str: String, suffix: String = "", block: () -> ()) {
    p (str + " {")
    indent += 1
    block ()
    indent -= 1
    p ("}\(suffix)\n")
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

protocol JNameAndType {
    var name: String { get }
    var type: String { get }
}

extension JGodotSingleton: JNameAndType { }
extension JGodotArgument: JNameAndType {}

func getArgumentDeclaration (_ argument: JNameAndType, eliminate: String) -> String {
    //let optNeedInOut = isCoreType(name: argument.type) ? "inout " : ""
    let optNeedInOut = ""
    return "\(eliminate)\(escapeSwift (snakeToCamel (argument.name))): \(optNeedInOut)\(getGodotType(argument.type))"
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
        body += "]"
        
    }
    return body
}

func generateBuiltinCtors (_ ctors: [JGodotConstructor], typeName: String, typeEnum: String, members: [JGodotSingleton]?)
{
    var ctorCount = 0
    for m in ctors {
        
        var args = ""
    
        let ptrName = "constructor\(m.index)"
        p ("static var \(ptrName): GDExtensionPtrConstructor = gi.variant_get_ptr_constructor (\(typeEnum), \(m.index))!\n")
        
        for arg in m.arguments ?? [] {
            if args != "" { args += ", " }
            args += getArgumentDeclaration(arg, eliminate: "")
        }
        
        b ("public init (\(args))") {
            // Determine if we have a constructors whose sole job is to initialize the members
            // of the struct, in that case, just do that, do not call into Godot.
            if let margs = m.arguments, let members, margs.count == members.count {
                var constructorMatchesFields = true
                for x in 0..<margs.count {
                    // This is so that we can match field `x` with `xAxis` in a few cases
                    if !(margs [x].name.starts (with: members [x].name) && margs [x].type == members [x].type) {
                        constructorMatchesFields = false
                        break
                    }
                }
                if constructorMatchesFields {
                    for x in 0..<margs.count {
                        p ("self.\(members [x].name) = \(escapeSwift (snakeToCamel (margs [x].name)))")
                    }
                    return
                }
            }
            let argPrepare = generateArgPrepare(m.arguments ?? [])
            if argPrepare != "" {
                p (argPrepare)
            }
            
            let ptrArgs = (m.arguments != nil) ? "&args" : "nil"
            
            // I used to have a nicer model, rather than everything having a
            // handle, I had a named handle, like "_godot_string"
            let ptr = isStructMap [typeName] ?? false ? "self" : "handle"
            
            // We need to initialize some variables before we call
            if let members {
                for x in members {
                    p ("self.\(x.name) = \(jsonTypeToSwift (x.type)) ()")
                }
                // Another special case: empty constructors in generated structs (those we added fields for)
                // we just keep the manual initialization and do not call the constructor
                if m.arguments == nil {
                    return
                }
            }
            // Call
            p ("\(typeName).\(ptrName) (&\(ptr), \(ptrArgs))")
        }
    }
}

func generateBuiltinMethods (_ methods: [JGodotBuiltinClassMethod], _ typeName: String, _ typeEnum: String)
{
    if methods.count > 0 {
        p ("\n/* Methods */\n")
    }
    for m in methods {
        if m.name == "repeat" {
            // TODO: Avoid clash for now
            continue
        }

        let ret = getGodotType(m.returnType ?? "")
        
        // TODO: problem caused by gobject_object being defined as "void", so it is not possible to create storage to that.
        if ret == "Object" {
            continue
        }
        let retSig = ret == "" ? "" : "-> \(ret)"
        var args = ""
    
        let ptrName = "method_\(m.name)"
        
        b ("static var \(ptrName): GDExtensionPtrBuiltInMethod = ", suffix: "()"){
            p ("let name = StringName (\"\(m.name)\")")
            p ("return gi.variant_get_ptr_builtin_method (\(typeEnum), UnsafeRawPointer (name.handle), \(m.hash))!")
        }
        
        for arg in m.arguments ?? [] {
            if args != "" { args += ", " }
            args += getArgumentDeclaration(arg, eliminate: "")
        }
        
        let has_return = m.returnType != nil
        
        b ("public func \(escapeSwift (snakeToCamel(m.name))) (\(args))\(retSig)") {
            let resultTypeName = "\(getGodotType (m.returnType ?? ""))"
            if has_return {
                p ("var result: \(resultTypeName) = \(resultTypeName)()")
            }
            
            let argPrep = generateArgPrepare(m.arguments ?? [])
            if argPrep != "" {
                p (argPrep)
            }
            let ptrArgs = (m.arguments?.count ?? 0) > 0 ? "&args" : "nil"
            let ptrResult: String
            if has_return {
                if isStructMap [m.returnType ?? ""] != nil {
                    ptrResult = "&result"
                } else {
                    ptrResult = "&result.handle"
                }
            } else {
                ptrResult = "nil"
            }
            if isStructMap [typeName] ?? false {
                p ("withUnsafePointer (to: self) { ptr in ")
                p ("    \(typeName).\(ptrName) (UnsafeMutableRawPointer (mutating: ptr), \(ptrArgs), \(ptrResult), \(m.arguments?.count ?? 0))")
                p ("}")
            } else {
                p ("\(typeName).\(ptrName) (&handle, \(ptrArgs), \(ptrResult), \(m.arguments?.count ?? 0))")
            }
            if has_return {
                // let cast = castGodotToSwift (m.returnType, "result")
                p ("return /* castGodotToSwift \(m.returnType) */ result")
            }
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
        b ("public \(kind) \(typeName)") {
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

            generateBuiltinCtors (bc.constructors, typeName: typeName, typeEnum: typeEnum, members: bc.members)
            generateBuiltinMethods(bc.methods ?? [], typeName, typeEnum)
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
for x in ["Float", "Int", "float", "int", "Variant", "Int32", "Bool", "bool"] {
    isStructMap [x] = true
}
generateBuiltinClasses(values: jsonApi.builtinClasses)

try! result.write(toFile: outputDir + "/generated.swift", atomically: true, encoding: .utf8)

print ("Done")
