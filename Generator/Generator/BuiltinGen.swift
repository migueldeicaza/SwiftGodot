//
//  BuiltinGen.swift
//  Generator
//
//  Created by Miguel de Icaza on 3/26/23.
//

import Foundation

func generateBuiltinCtors (_ ctors: [JGodotConstructor], godotTypeName: String, typeName: String, typeEnum: String, members: [JGodotSingleton]?)
{
    let isStruct = isStructMap [typeName] ?? false
    
    for m in ctors {
        
        var args = ""

        let ptrName = "constructor\(m.index)"
        p ("static var \(ptrName): GDExtensionPtrConstructor = gi.variant_get_ptr_constructor (\(typeEnum), \(m.index))!\n")
        
        for arg in m.arguments ?? [] {
            if args != "" { args += ", " }
            args += getArgumentDeclaration(arg, eliminate: "", kind: .builtInField)
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
            let ptr = isStruct ? "self" : "content"
            
            // We need to initialize some variables before we call
            if let members {
                for x in members {
                    p ("self.\(x.name) = \(MemberBuiltinJsonTypeToSwift(x.type)) ()")
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

enum MethodCallKind {
    case methodCall
    case operatorCall
}

func generateMethodCall (typeName: String, methodToCall: String, godotReturnType: String?, isStatic: Bool, arguments: [JNameAndType]?, kind: MethodCallKind) {
    let has_return = godotReturnType != nil
    
    let resultTypeName = "\(getGodotType (SimpleType (type: godotReturnType ?? ""), kind: .builtIn))"
    if has_return {
        p ("var result: \(resultTypeName) = \(resultTypeName)()")
    }
    
    let argPrep = generateArgPrepare(arguments ?? [])
    if argPrep != "" {
        p (argPrep)
    }
    let ptrArgs = (arguments?.count ?? 0) > 0 ? "&args" : "nil"
    let ptrResult: String
    if has_return {
        let isStruct = isStructMap [godotReturnType ?? ""] ?? false
        if isStruct {
            ptrResult = "&result"
        } else {
            ptrResult = "&result.content"
        }
    } else {
        ptrResult = "nil"
    }
    
    // Method calls pass the number of parameters to the method
    let numberOfArgs = kind == .methodCall ? ", \(arguments?.count ?? 0)" : ""
    
    if isStatic {
            p ("\(typeName).\(methodToCall) (nil, \(ptrArgs), \(ptrResult)\(numberOfArgs))")
    } else {
        if isStructMap [typeName] ?? false {
            p ("withUnsafePointer (to: self) { ptr in ")
            p ("    \(typeName).\(methodToCall) (UnsafeMutableRawPointer (mutating: ptr), \(ptrArgs), \(ptrResult)\(numberOfArgs))")
            p ("}")
        } else {
            p ("\(typeName).\(methodToCall) (&content, \(ptrArgs), \(ptrResult)\(numberOfArgs))")
        }
    }
    if has_return {
        // let cast = castGodotToSwift (m.returnType, "result")
        p ("return result")
    }
}

// List of operators we do not want to generate, as we have custom versions
let skipOperators: [String:[(String,String)]] = [
    "StringName": [("==", "StringName")]
]

/// - Parameters:
///   - operators: the array of operators
///   - godotTypeName: the type for which we are generating operators
///   - typeName: the type name above, but in Swift
func generateBuiltinOperators (_ operators: [JGodotOperator], godotTypeName: String, typeName: String) {
    var n = 0
    
    for op in operators {
        let ptrName = "operator_\(n)"
        n += 1
        
        if let right = op.rightType {
            guard right != "Variant" else { continue }

            
            if let skippable = skipOperators [godotTypeName] {
                if skippable.contains (where: { $0.0 == op.name && $0.1 == op.rightType }) {
                    continue
                }
            }
            guard let (operatorCode, swiftOperator) = infixOperatorMap (op.name) else {
                continue
            }
            b ("static var \(ptrName): GDExtensionPtrOperatorEvaluator = ", suffix: "()"){
                let rightTypeCode = builtinTypecode (right)
                let leftTypeCode = builtinTypecode (godotTypeName)
                p ("return gi.variant_get_ptr_operator_evaluator (\(operatorCode), \(leftTypeCode), \(rightTypeCode))!")
            }
            
            let retType = getGodotType(SimpleType (type: op.returnType), kind: .builtIn)
            b ("public static func \(swiftOperator) (lhs: \(typeName), rhs: \(getGodotType(SimpleType(type: right), kind: .builtIn))) -> \(retType) "){
                
                let args: [JGodotArgument] = [
                    JGodotArgument(name: "lhs", type: godotTypeName, defaultValue: nil, meta: nil),
                    JGodotArgument(name: "rhs", type: right, defaultValue: nil, meta: nil)
                ]
                generateMethodCall(typeName: typeName, methodToCall: ptrName, godotReturnType: op.returnType, isStatic: true, arguments: args, kind: .operatorCall)
            }
        }
    }
}
    


func generateBuiltinMethods (_ methods: [JGodotBuiltinClassMethod], _ typeName: String, _ typeEnum: String, isStruct: Bool)
{
    if methods.count > 0 {
        p ("\n/* Methods */\n")
    }
    for m in methods {
        if m.name == "repeat" {
            // TODO: Avoid clash for now
            continue
        }

        let ret = getGodotType(SimpleType (type: m.returnType ?? ""), kind: .builtIn)
        
        // TODO: problem caused by gobject_object being defined as "void", so it is not possible to create storage to that.
        if ret == "Object" {
            continue
        }
        let retSig = ret == "" ? "" : "-> \(ret)"
        var args = ""
    
        let ptrName = "method_\(m.name)"
        
        b ("static var \(ptrName): GDExtensionPtrBuiltInMethod = ", suffix: "()"){
            p ("let name = StringName (\"\(m.name)\")")
            p ("return gi.variant_get_ptr_builtin_method (\(typeEnum), &name.content, \(m.hash))!")
        }
        
        for arg in m.arguments ?? [] {
            if args != "" { args += ", " }
            args += getArgumentDeclaration(arg, eliminate: "")
        }
        
        b ("public\(isStruct ? "" : " final") func \(escapeSwift (snakeToCamel(m.name))) (\(args))\(retSig)") {
            
            generateMethodCall (typeName: typeName, methodToCall: ptrName, godotReturnType: m.returnType, isStatic: m.isStatic, arguments: m.arguments, kind: .methodCall)
        }
    }
}

var builtinGodotTypeNames = Set<String>()
var builtinClassStorage: [String:String] = [:]

func generateBuiltinClasses (values: [JGodotBuiltinClass], outputDir: String) {
    func generateBuiltinClass (_ bc: JGodotBuiltinClass) {
        // TODO: isKeyed, hasDestrcturo,
        var kind: String
        if bc.members != nil {
            kind = "struct"
        } else {
            kind = "class"
        }
        builtinGodotTypeNames.insert(bc.name)
        let typeName = mapTypeName (bc.name)
        let typeEnum = "GDEXTENSION_VARIANT_TYPE_" + camelToSnake(bc.name).uppercased()
        
        
        var conformances: [String] = []
        var synthesizeEquatable = false
        if kind == "struct" {
            conformances.append ("Equatable")
            conformances.append ("Hashable")
        } else {
            if bc.operators.contains(where: { op in op.name == "==" && op.rightType == bc.name }) {
                conformances.append ("Equatable")
                synthesizeEquatable = true
            }
        }
        if bc.name == "String" || bc.name == "StringName" {
            conformances.append ("ExpressibleByStringLiteral")
        }
        var proto = ""
        if conformances.count > 0 {
            proto = ": " + conformances.joined(separator: ", ")
        } else {
            proto = ""
        }
        b ("public \(kind) \(typeName)\(proto)") {
            if bc.name == "String" {
                b ("public init (_ str: String)") {
                    p ("gi.string_new_with_utf8_chars (&content, str)")
                }
                p ("// ExpressibleByStringLiteral conformace")
                b ("public required init (stringLiteral value: String)") {
                    p ("gi.string_new_with_utf8_chars (&content, value)")
                }
            }
            if bc.name == "StringName" {
                // TODO: This is a little brittle, because I am
                // hardcoding the constructor1 here, it should
                // really produce this when it matches the kind
                // directly to be the one that takes a StringName
                // parameter
                b ("public init (fromPtr: UnsafeRawPointer?)") {
                    p ("var args: [UnsafeRawPointer?] = [")
                    p ("    fromPtr,")
                    p ("]")
                    p ("StringName.constructor1 (&content, &args)")
                }
                p ("// ExpressibleByStringLiteral conformace")
                b ("public required init (stringLiteral value: String)") {
                    p ("gi.string_new_with_utf8_chars (&content, value)")
                }
            }
            if bc.hasDestructor {
                b ("static var destructor: GDExtensionPtrDestructor = ", suffix: "()"){
                    p ("return gi.variant_get_ptr_destructor (\(typeEnum))!")
                }
                
                b ("deinit"){
                    p ("\(typeName).destructor (&content)")
                }
            }
            if kind == "class" {
                let (storage, initialize) = getBuiltinStorage (bc.name)
                p ("// Contains a binary blob where this type information is stored")
                p ("var content: \(storage)\(initialize)")
                builtinClassStorage [bc.name] = storage
                // TODO: This is a little brittle, because I am
                // hardcoding the constructor1 here, it should
                // really produce this when it matches the kind
                // directly to be the one that takes the same
                // parameter
                p ("// Used to construct objects on virtual proxies")
                b ("init (content: \(storage))") {
                    p ("var copy = content")
                    p ("var args: [UnsafeRawPointer?] = [UnsafeRawPointer (&copy)]")
                    p ("StringName.constructor1 (&self.content, &args)")
                }
            }
            if let members = bc.members {
                for x in members {
                    p ("var \(x.name): \(MemberBuiltinJsonTypeToSwift (x.type))")
                }
            }

            if let enums = bc.enums {
                generateEnums(values: enums)
            }
            generateBuiltinCtors (bc.constructors, godotTypeName: bc.name, typeName: typeName, typeEnum: typeEnum, members: bc.members)
            generateBuiltinMethods(bc.methods ?? [], typeName, typeEnum, isStruct: kind == "struct")
            generateBuiltinOperators (bc.operators, godotTypeName: bc.name, typeName: typeName)
        }
    }
    
    for bc in values {
        switch bc.name {
            // We do not generate code for a few types, we will bridge those instead
        case "int", "float", "bool":
            break
        default:
            result = "// This file is autogenerated, do not edit\n"
            result += "import Foundation\nimport GDExtension\n\n"

            generateBuiltinClass (bc)
            try! result.write(toFile: outputDir + "/\(bc.name).swift", atomically: true, encoding: .utf8)
        }
    }
}
