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

func isSmallInt (_ arg: JGodotArgument) -> Bool {
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

func getArgumentDeclaration (_ argument: JGodotArgument, eliminate: String, kind: ArgumentKind = .classes, isOptional: Bool) -> String {
    //let optNeedInOut = isCoreType(name: argument.type) ? "inout " : ""
    let optNeedInOut = ""
    
    var def: String = ""
    if let dv = argument.defaultValue, dv != "" {
        let argumentType = argument.type
        // TODO:
        //  - handle creating initializers from enums (builtint)
        //  - empty arrays
        //  - Structure with initialized values (Color (1,1,1,1))
        //  - NodePath ("") ctor
        //  - nil values (needs to both turn the value nullable and handle that in the marshal code
        //  - typedarrays, the default values need to be handled one by one, or a general conversion
        // system needs to be implemented
        if !argumentType.starts(with: "Array") && !argumentType.starts(with: "bitfield::") && (!(isStructMap [argumentType] ?? false) || isPrimitiveType(name: argumentType)) && argumentType != "NodePath" && !argumentType.starts(with: "typedarray::") && !argumentType.starts (with: "Dictionary") && dv != "null" {
            if argument.type == "String" {
                def = " = \(dv)"
            } else if argument.type == "StringName" {
                def = " = StringName (\"dv\")"
            } else if argument.type.starts(with: "enum::"){
                if let ev = mapEnumValue (enumDef: argument.type, value: dv) {
                    def = " = \(ev)"
                }
            } else if argumentType == "Variant" {
                // Not supported
            } else {
                def = " = \(dv)"
            }
        } else {
            // Here we add the new conversions, will eventually replace everything
            // above, as the do-not-run conditions are becoming large and difficult
            // to parse - they were fine to bootstrap, but not for the long term.
            
            // Handle empty type arrays
            if argumentType.starts(with: "typedarray::") {
                if dv == "[]" {
                    def = " = \(getGodotType(argument, kind: kind)) ()"
                } else {
                    // Tracked: https://github.com/migueldeicaza/SwiftGodot/issues/7
                    //print ("Generator: \(argumentType) support for default value: \(dv)")
                }
            } else if argumentType == "Dictionary" {
                if dv == "{}" {
                    def = " = SwiftGodot.Dictionary ()"
                } else {
                    print ("Generator: \(argumentType) missing support for default value: \(dv)")
                }
            } else if argumentType.starts(with: "bitfield::") {
                if let defIntValue = Int (dv) {
                    if defIntValue == 0 {
                        def = " = []"
                    } else {
                        // Need to look it up
                        if let optionType = findEnumDef(name: argumentType) {
                            var setValues = ""
                            
                            for value in optionType.values {
                                if (defIntValue & value.value) != 0 {
                                    let name = dropMatchingPrefix(optionType.name, value.name)
                                    if setValues != "" {
                                        setValues += ", "
                                    }
                                    setValues += ".\(name)"
                                }
                            }
                            def = " = [\(setValues)]"
                        } else {
                            print ("Generator: \(argumentType) could not produce default value for \(dv) because I can not find the type")
                        }
                    }
                } else {
                    print ("Generator: bitfield:: with a non-integer default value")
                }
            } else if argumentType == "Array" {
                if dv == "[]" {
                    def = " = GArray ()"
                } else {
                    // Tracked: https://github.com/migueldeicaza/SwiftGodot/issues/7
                    //print ("Generator: no support for arrays with values: \(dv)")
                }
            }
        }
    }
    return "\(eliminate)\(godotArgumentToSwift (argument.name)): \(optNeedInOut)\(getGodotType(argument, kind: kind))\(isOptional ? "?" : "")\(def)"
}

func getArgRef (arg: JGodotArgument) -> String {
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
                needAddress = "&"
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

func generateCopies (_ args: [JGodotArgument]) -> String {
    var body = ""
    
    for arg in args {
        //if !isCoreType (name: arg.type) {
        var reference = godotArgumentToSwift (arg.name)
        
        if isStructMap [arg.type] ?? false {
            if arg.type == "float" {
                reference = "Double (\(reference))"
            }
            body += "var copy_\(arg.name) = \(reference)\n"
        } else if arg.type == "String" && mapStringToSwift {
            body += "var gstr_\(arg.name) = GString (\(reference))\n"
        }
    }
    return body
}

func generateArgPrepare (_ args: [JGodotArgument]) -> String {
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
