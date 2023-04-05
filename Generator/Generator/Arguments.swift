//
//  Arguments.swift
//  Generator
//
//  Created by Miguel de Icaza on 4/5/23.
//

import Foundation

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
