//
//  DocModel.swift
//  Generator
//
//  Created by Miguel de Icaza on 4/5/23.
//

import Foundation
import XMLCoder

struct DocClass: Codable {
    @Attribute var name: String
    @Attribute var inherits: String?
    @Attribute var version: String
    var brief_description: String
    var description: String
    var tutorials: [DocTutorial]
    // TODO: theme_items see HSplitContaienr
    var methods: DocMethods?
    var members: DocMembers?
//    var signals: [DocSignal]
    var constants: DocConstants?
}

struct DocTutorial: Codable {
    var link: [DocLink]
}

struct DocLink: Codable, Equatable {
    @Attribute var title: String
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case value = ""
    }
}

struct DocMethods: Codable {
    var method: [DocMethod]
}

struct DocMethod: Codable {
    @Attribute var name: String
    @Attribute var qualifiers: String?
    var `return`: DocReturn
    var description: String
    var params: [DocParam]
    
    enum CodingKeys: String, CodingKey {
        case name
        case qualifiers
        case `return`
        case description
        case params
    }
}

struct DocParam: Codable {
    @Attribute var index: Int
    @Attribute var name: String
    @Attribute var type: String
}
struct DocReturn: Codable {
    @Attribute var type: String
}

struct DocMembers: Codable {
    var member: [DocMember]
}

struct DocMember: Codable {
    @Attribute var name: String
    @Attribute var type: String
    @Attribute var setter: String
    @Attribute var getter: String
    @Attribute var `enum`: String?
    @Attribute var `default`: String?
    var value: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case setter
        case getter
        case `enum`
        case `default`
        case value = ""
    }
}

struct DocConstants: Codable {
    var constants: [DocConstant]
}

struct DocConstant: Codable {
    @Attribute var name: String
    @Attribute var value: String
    @Attribute var `enum`: String?
    let rest: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case value
        case `enum`
        case rest = ""
    }
}

func loadClassDoc (base: String, name: String) -> DocClass? {
    guard let d = try? Data(contentsOf: URL (fileURLWithPath: "\(base)/classes/\(name).xml")) else {
        return nil
    }
    let decoder = XMLDecoder()
    do {
        let v = try decoder.decode(DocClass.self, from: d)
        return v
    } catch (let e){
        print ("Failed to load docs for \(name), details: \(e)")
        fatalError()
    }
}

// Attributes to handle:
// [NAME] is a type reference
// [b]..[/b] bold
// [method name] is a method reference, should apply the remapping we do
// 
func doc (_ cdef: JGodotExtensionAPIClass, _ text: String?) {
    guard let text else { return }
    
    // Until it is done
    return
    
    func lookupConstant (_ txt: String.SubSequence) -> String {
        for ed in cdef.enums ?? [] {
            for vp in ed.values {
                if vp.name == txt {
                    let name = dropMatchingPrefix(ed.name, vp.name)
                    return ".\(escapeSwift (name))"
                }
            }
        }
        print ("Doc: in \(cdef.name) did not find a constant for \(txt)")
        return ""
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

    func assembleArgs (_ arguments: [JGodotArgument]?) -> String {
        var args = ""
        
        // Assemble argument names
        for arg in arguments ?? [] {
            args.append(godotArgumentToSwift(arg.name))
            args.append(":")
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
                    args = assembleArgs (method.arguments)
                }
            } else if let m = builtinMap [type] {
                if let method = findMethod (name: member, on: m) {
                    args = assembleArgs(method.arguments)
                }
            }
            return "\(type)/\(godotMethodToSwift(member))(\(args))"
        } else {
            if let method = findMethod(name: member, on: cdef) {
                args = assembleArgs (method.arguments)
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

    let oIndent = indentStr
    indentStr = "\(indentStr)/// "
    
    var inCodeBlock = false
    for x in text.split(separator: "\n", omittingEmptySubsequences: false) {
        if x.contains ("[codeblocks]") {
            inCodeBlock = true
            continue
        }
        if x.contains ("[/codeblocks]") {
            inCodeBlock = false
            continue
        }
        if inCodeBlock { continue }
        
        var mod = x
        
        if #available(macOS 13.0, *) {
            // Replaces [params X] with `X`
            mod = mod.replacing(#/\[(constant|param) (\w+)\]/#, with: { x in
                switch x.output.1 {
                case "param":
                    return "`\(x.output.2)`"
                case "constant":
                    return lookupConstant (x.output.2)
                default:
                    print ("Doc: Error, unexpected \(x.output.1) tag")
                    return "[\(x.output.1) \(x.output.2)]"
                }
            })
            mod = mod.replacing(#/\[(enum|method|member) ([\w\.@_/]+)\]/#, with: { x in
                switch x.output.1 {
                case "method":
                    return "``\(convertMethod (x.output.2))``"
                case "member":
                    // Same as method for now?
                    return "``\(convertMember(x.output.2))``"
                case "enum":
                    return "``\(x.output.2)``"
                default:
                    print ("Doc: Error, unexpected \(x.output.1) tag")
                    return "[\(x.output.1) \(x.output.2)]"
                }
            })
            
            // [FirstLetterIsUpperCase] is a reference to a type
            mod = mod.replacing(#/\[([A-Z]\w+)\]/#, with: { x in
                return "``\(mapTypeNameDoc (String (x.output.1)))``"
            })
            // To avoid the greedy problem, it happens above, but not as much
            mod = mod.replacing("[b]", with: "**")
            mod = mod.replacing("[/b]", with: "**")
            mod = mod.replacing("[code]", with: "`")
            mod = mod.replacing("[/code]", with: "`")
            mod = mod.trimmingPrefix(#/\s+/#)
            // TODO
            // [member X]
            // [signal X]
            
        }
        p (String (mod))
    }

    
    indentStr = oIndent
}
