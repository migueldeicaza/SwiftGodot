//
//  DocModel.swift
//  Generator
//
//  Created by Miguel de Icaza on 4/5/23.
//

import Foundation
import ExtensionApi

@available(macOS 13.0, iOS 16.0, *)
let rxConstantParam: Regex<(Substring,Substring,Substring)> = try! Regex ("\\[(constant|param) ([\\w\\._@]+)\\]")
@available(macOS 13.0, iOS 16.0, *)
let rxEnumMethodMember: Regex<(Substring,Substring,Substring)> = try! Regex ("\\[(enum|method|member) ([\\w\\.@_/]+)\\]")
@available(macOS 13.0, iOS 16.0, *)
let rxTypeName: Regex<(Substring, Substring)> = try! Regex ("\\[([A-Z]\\w+)\\]")
@available(macOS 13.0, iOS 16.0, *)
let rxEmptyLeading: Regex<Substring> = try! Regex ("\\s+")

// If the string contains a ".", it will return a pair
// with the first element containing all the text up until the last dot
// and the second with the rest.   If it does not contain it,
// the first value is an empty string

func splitAtLastDot (str: String.SubSequence) -> (String, String) {
    if let p = str.lastIndex(of: ".") {
        let first = String (str [str.startIndex..<p])
        let last = String (str [str.index(p, offsetBy: 1)...])
        return (String (first), String (last))
    } else {
        return ("", String (str))
    }
}

// Attributes to handle:
// [NAME] is a type reference
// [b]..[/b] bold
// [method name] is a method reference, should apply the remapping we do
// 
func doc (_ p: Printer, _ cdef: JClassInfo?, _ text: String?) {
    guard let text else { return }
//    guard ProcessInfo.processInfo.environment ["GENERATE_DOCS"] != nil else {
//        return
//    }
    
    func lookupConstant (_ txt: String.SubSequence) -> String {
        func lookInDef (def: JClassInfo, match: String, local: Bool) -> String? {
            // TODO: for builtins, we wont have a cdef
            for ed in def.enums ?? [] {
                for vp in ed.values {
                    if vp.name == match {
                        let name = dropMatchingPrefix(ed.name, vp.name)
                        if local {
                            return ".\(escapeSwift (name))"
                        } else {
                            return getGodotType(SimpleType (type: "enum::" + ed.name)) + "/" + escapeSwift (name)
                        }
                    }
                }
            }
            
            if let cdef = def as? JGodotExtensionAPIClass {
                for x in cdef.constants ?? [] {
                    if match == x.name {
                        return "``\(snakeToCamel (x.name))``"
                    }
                }
            }
            return nil
        }
        
        if let cdef {
            if let result = lookInDef(def: cdef, match: String(txt), local: true) {
                return result
            }
        }
        for ed in jsonApi.globalEnums {
            for ev in ed.values {
                if ev.name == txt {
                    var type = ""
                    var lookup = ed.name
                    if let dot = ed.name.lastIndex(of: ".") {
                        let containerType = String (ed.name [ed.name.startIndex..<dot])
                        type = getGodotType (SimpleType (type: containerType)) + "."
                        lookup = String (ed.name [ed.name.index(dot, offsetBy: 1)...])
                    }
                    let name = dropMatchingPrefix(lookup, ev.name)
                    
                    return "``\(type)\(getGodotType (SimpleType (type: lookup)))/\(escapeSwift(String (name)))``"
                }
            }
        }
        let (type, name) = splitAtLastDot(str: txt)
        if type != "", let ldef = classMap [type] {
            if let r = lookInDef(def: ldef, match: name, local: false) {
                return "``\(getGodotType(SimpleType (type: type)) + "/" + r)``"
            }
        }
        
        return "``\(txt)``"
    }
    
    // If this is a Type.Name returns "Type", "Name"
    // If this is Type it returns (nil, "Name")
    func typeSplit (txt: String.SubSequence) -> (String?, String) {
        if let dot = txt.firstIndex(of: ".") {
            let rest = String (txt [text.index(dot, offsetBy: 1)...])
            return (String (txt [txt.startIndex..<dot]), rest)
        }
        
        return (nil, String (txt))
    }

    func assembleArgs (_ optMethod: JGodotClassMethod?, _ arguments: [JGodotArgument]?) -> String {
        var args = ""
        
        // Assemble argument names
        var i = 0
        for arg in arguments ?? [] {
            if optMethod != nil && i == 0 && optMethod!.name.hasSuffix(arg.name) {
                args.append ("_")
            } else {
                args.append(godotArgumentToSwift(arg.name))
            }
            args.append(":")
            i += 1
        }
        return args
    }
    
    func convertMethod (_ txt: String.SubSequence) -> String {
        if txt.starts(with: "@") {
            // TODO, examples:
            // @GlobalScope.remap
            // @GDScript.load

            return String (txt)
        }
        
        func findMethod (name: String, on: JGodotExtensionAPIClass) -> JGodotClassMethod? {
            on.methods?.first(where: { x in x.name == name })
        }
        func findMethod (name: String, on: JGodotBuiltinClass) -> JGodotBuiltinClassMethod? {
            on.methods?.first(where: { x in x.name == name })
        }
        
        let (type, member) = typeSplit(txt: txt)
        
        var args = ""
        if let type {
            if let m = classMap [type] {
                if let method = findMethod (name: member, on: m) {
                    args = assembleArgs (method, method.arguments)
                }
            } else if let m = builtinMap [type] {
                if let method = findMethod (name: member, on: m) {
                    args = assembleArgs(nil, method.arguments)
                }
            }
            return "\(type)/\(godotMethodToSwift(member))(\(args))"
        } else {
            if let apiDef = cdef as? JGodotExtensionAPIClass {
                if let method = findMethod(name: member, on: apiDef) {
                    args = assembleArgs (method, method.arguments)
                }
            } else if let builtinDef = cdef as? JGodotBuiltinClass {
                if let method = findMethod(name: member, on: builtinDef) {
                    args = assembleArgs (nil, method.arguments)
                }
            }
        }
          
        
        return "\(godotMethodToSwift(member))(\(args))"
    }

    func convertMember (_ txt: String.SubSequence) -> String {
        let (type, member) = typeSplit(txt: txt)
        if let type {
            return "\(type)/\(godotMethodToSwift(member))"
        }
        return godotPropertyToSwift(member)
    }

    let oIndent = p.indentStr
    p.indentStr = "\(p.indentStr)/// "
    
    var inCodeBlock = false
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
    for x in lines {
        if x.contains ("[codeblock") {
            inCodeBlock = true
            continue
        }
        if x.contains ("[/codeblock") {
            inCodeBlock = false
            continue
        }
        if inCodeBlock { continue }
        
        var mod = x
        
        if #available(macOS 13.0, iOS 16.0, *) {
            // Replaces [params X] with `X`
            mod = mod.replacing(rxConstantParam, with: { x in
                switch x.output.1 {
                case "param":
                    let pname = godotArgumentToSwift (String(x.output.2))
                    if pname.starts(with: "`") {
                        // Do not escape parameters that are already escaped, Swift wont know
                        return pname
                    }
                    return "`\(pname)`"
                case "constant":
                    return lookupConstant (x.output.2)
                default:
                    print ("Doc: Error, unexpected \(x.output.1) tag")
                    return "[\(x.output.1) \(x.output.2)]"
                }
            })
            mod = mod.replacing(rxEnumMethodMember, with: { x in
                switch x.output.1 {
                case "method":
                    return "``\(convertMethod (x.output.2))``"
                case "member":
                    // Same as method for now?
                    return "``\(convertMember(x.output.2))``"
                case "enum":
                    if let cdef {
                        if let enums = cdef.enums {
                            // If it is a local enum
                            if enums.contains(where: { $0.name == x.output.2 }) {
                                return "``\(cdef.name)/\(x.output.2)``"
                            }
                        }
                    }
                    return "``\(getGodotType(SimpleType(type: "enum::" + x.output.2)))``"
                    
                default:
                    print ("Doc: Error, unexpected \(x.output.1) tag")
                    return "[\(x.output.1) \(x.output.2)]"
                }
            })
            
            // [FirstLetterIsUpperCase] is a reference to a type
            mod = mod.replacing(rxTypeName, with: { x in
                let word = x.output.1
                return "``\(mapTypeNameDoc (String (word)))``"
            })
            // To avoid the greedy problem, it happens above, but not as much
            mod = mod.replacing("[b]Note:[/b]", with: "> Note:")
            mod = mod.replacing("[int]", with: "integer")
            mod = mod.replacing("[float]", with: "float")
            mod = mod.replacing("[b]Warning:[/b]", with: "> Warning:")
            mod = mod.replacing("[i]", with: "_")
            mod = mod.replacing("[/i]", with: "_")
            mod = mod.replacing("[b]", with: "**")
            mod = mod.replacing("[/b]", with: "**")
            mod = mod.replacing("[code]", with: "`")
            mod = mod.replacing("[/code]", with: "`")
            mod = mod.trimmingPrefix(rxEmptyLeading)
            // TODO
            // [member X]
            // [signal X]
            
        }
        if lines.count > 1 {
            p (String (mod)+"\n")
        } else {
            p (String (mod))
        }
    }
    p.indentStr = oIndent
}
