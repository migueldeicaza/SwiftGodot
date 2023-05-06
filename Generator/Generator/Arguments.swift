//
//  Arguments.swift
//  Generator
//
//  Created by Miguel de Icaza on 4/5/23.
//

import Foundation

func godotArgumentToSwift (_ name: String) -> String {
    return escapeSwift (snakeToCamel (name))
}

func isSmallInt (_ arg: JNameAndType) -> Bool {
    if arg.type != "int" {
        return false
    }
    switch getGodotType(arg, kind: .classes) {
    case "Int32", "UInt32", "Int16", "UInt16", "Int8", "UInt8":
        return true
    default:
        return false
    }
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
                def = " = \(dv)"
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
    return "\(eliminate)\(godotArgumentToSwift (argument.name)): \(optNeedInOut)\(getGodotType(argument, kind: kind))\(def)"
}

func getArgRef (arg: JNameAndType) -> String {
    var argref: String
    var optstorage: String
    var needAddress = "&"
    if !(isStructMap [arg.type] ?? false) { // { ) isCoreType(name: arg.type){
        argref = godotArgumentToSwift (arg.name)
        if isStructMap [arg.type] ?? false {
            optstorage = ""
        } else if arg.type == "String" && mapStringToSwift {
            argref = "gstr_\(arg.name)"
            optstorage = ".content"
        } else {
            if builtinSizes [arg.type] != nil && arg.type != "Object" {
                optstorage = ".content"
            } else {
                needAddress = ""
                optstorage = ".handle"
            }
        }
    } else {
        argref = "copy_\(arg.name)"
        optstorage = ""
    }
    if (isStructMap [arg.type] ?? false) {
        return "UnsafeRawPointer(\(needAddress)\(escapeSwift(argref))\(optstorage))"
    } else {
        return "UnsafeRawPointer(\(needAddress)\(escapeSwift(argref))\(optstorage))"
    }
}

func generateCopies (_ args: [JNameAndType]) -> String {
    var body = ""
    
    for arg in args {
        //if !isCoreType (name: arg.type) {
        let reference = godotArgumentToSwift (arg.name)
        
        if isStructMap [arg.type] ?? false {
            body += "var copy_\(arg.name) = \(reference)\n"
        } else if arg.type == "String" && mapStringToSwift {
            body += "var gstr_\(arg.name) = GString (\(reference))\n"
        }
    }
    return body
}

func generateArgPrepare (_ args: [JNameAndType]) -> String {
    var body = ""
    
    if args.count > 0 {
        body += generateCopies (args)
        body += "var args: [UnsafeRawPointer?] = [\n"
        
        for arg in args {
            let ar = getArgRef(arg: arg)
            body += "    \(ar),\n"
        }
        body += "]"
        
    }
    return body
}
