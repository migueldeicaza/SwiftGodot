//
//  BuiltinGen.swift
//  Generator
//
//  Created by Miguel de Icaza on 3/26/23.
//

import Foundation
import ExtensionApi

/// Given an initializer of the form "Vector (0, 1, 0)" returns a proper Swift "Vector (x: 0, y: 1, z: 0)" value
///
func getInitializer (_ bc: JGodotBuiltinClass, _ val: String) -> String? {
    if let pstart = val.firstIndex(of: "("), let pend = val.lastIndex(of: ")"){
        let va = val [val.index(pstart, offsetBy: 1)..<pend]
        let splitArgs: [Substring.SubSequence]
        if #available(iOS 16.0, *) {
            splitArgs = va.split(separator: ", ")
        } else {
            fatalError ("This requires a modern MacOS to build")
        }
        // Find a constructor with that number of arguments
        for constructor in bc.constructors {
            
            if constructor.arguments?.count ?? -1 == splitArgs.count {
                // Found
                var prefixedArgs = ""
                for i in 0..<splitArgs.count {
                    if prefixedArgs.count != 0 { prefixedArgs += ", "}
                    let name = constructor.arguments! [i].name
                    var pval = splitArgs [i]

                    // Some Godot constants leak into the initializers
                    if pval.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "inf" {
                        pval = "Float.infinity"[...]
                    }

                    prefixedArgs = prefixedArgs + name + ": " + pval
                }
                return String (val [val.startIndex..<pstart]) + " (" + prefixedArgs + ")"
            }
        }
        
        // Fallback for missing constructors
        let format: String?
        switch (bc.name, splitArgs.count) {
        case ("Transform2D", 6):
            format = "Transform2D (xAxis: Vector2 (x: %@, y: %@), yAxis: Vector2 (x: %@, y: %@), origin: Vector2 (x: %@, y: %@))"
        case ("Basis", 9):
            format = "Basis (xAxis: Vector3 (x: %@, y: %@, z: %@), yAxis: Vector3 (x: %@, y: %@, z: %@), zAxis: Vector3 (x: %@, y: %@, z: %@))"
        case ("Transform3D", 12):
            format = "Transform3D (basis: Basis (xAxis: Vector3 (x: %@, y: %@, z: %@), yAxis: Vector3 (x: %@, y: %@, z: %@), zAxis: Vector3 (x: %@, y: %@, z: %@)), origin: Vector3(x: %@, y: %@, z: %@))"
        case ("Projection", 16):
            format = "Projection (xAxis: Vector4 (x: %@, y: %@, z: %@, w: %@), yAxis: Vector4 (x: %@, y: %@, z: %@, w: %@), zAxis: Vector4 (x: %@, y: %@, z: %@, w: %@), wAxis: Vector4 (x: %@, y: %@, z: %@, w: %@))"
        default:
            format = nil
        }
        if let format {
            return String (format: format, arguments: splitArgs.map (String.init))
        }
        return nil
    }
    return val
}

func generateBuiltinConstants (_ p: Printer,
                               _ bc: JGodotBuiltinClass,
                               typeName: String) {
        
    guard let constants = bc.constants else { return }
    
    for constant in constants {
        // Check if we need to inject parameter names
        guard let val = getInitializer (bc, constant.value) else {
            print ("Generator: no constructor matching constant \(bc.name).\(constant.name) = \(constant.value)")
            continue
        }
        
        if constant.description != "" {
            doc (p, bc, constant.description)
        }
        p ("public static let \(snakeToCamel (constant.name)) = \(val)")
    }
}

func generateBuiltinCtors (_ p: Printer,
                           _ bc: JGodotBuiltinClass,
                           _ ctors: [JGodotConstructor],
                           godotTypeName: String,
                           typeName: String,
                           typeEnum: String,
                           members: [JGodotArgument]?)
{
    let isStruct = isStructMap [typeName] ?? false
    
    for m in ctors {
        var args = ""
        var visibility = "public"
        
        let ptrName = "constructor\(m.index)"
        p ("static var \(ptrName): GDExtensionPtrConstructor = gi.variant_get_ptr_constructor (\(typeEnum), \(m.index))!\n")
        
        for arg in m.arguments ?? [] {
            if args != "" { args += ", " }
            args += getArgumentDeclaration(arg, eliminate: "", kind: .builtInField, isOptional: false)
        }
        
        if let desc = m.description, desc != "" {
            doc (p, bc, desc)
        }
        if args == "" {
            if !isStruct {
                visibility.append(" required")
            }
        }
        
        p ("\(visibility) init (\(args))") {
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
            let ptrArgs = (m.arguments != nil) ? "&args" : "nil"
            
            // I used to have a nicer model, rather than everything having a
            // handle, I had a named handle, like "_godot_string"
            let ptr = isStruct ? "self" : "content"
            
            // We need to initialize some variables before we call
            if let members {
                if bc.name == "Color" {
                    p ("self.red = 0")
                    p ("self.green = 0")
                    p ("self.blue = 0")
                    p ("self.alpha = 0")
                } else if bc.name == "Quaternion" && m.arguments == nil {
                    p ("self.x = 0")
                    p ("self.y = 0")
                    p ("self.z = 0")
                    p ("self.w = 1")
                } else if bc.name == "Transform2D" && m.arguments == nil {
                    p ("self.x = Vector2 (x: 1, y: 0)")
                    p ("self.y = Vector2 (x: 0, y: 1)")
                    p ("self.origin = Vector2 ()")                    
                } else if bc.name == "Basis" && m.arguments == nil {
                    p ("self.x = Vector3 (x: 1, y: 0, z: 0)")
                    p ("self.y = Vector3 (x: 0, y: 1, z: 0)")
                    p ("self.z = Vector3 (x: 0, y: 0, z: 1)")
                } else if bc.name == "Projection" && m.arguments == nil {
                    p ("self.x = Vector4 (x: 1, y: 0, z: 0, w: 0)")
                    p ("self.y = Vector4 (x: 0, y: 1, z: 0, w: 0)")
                    p ("self.z = Vector4 (x: 0, y: 0, z: 1, w: 0)")
                    p ("self.w = Vector4 (x: 0, y: 0, z: 0, w: 1)")
                } else {
                    for x in members {
                        p ("self.\(x.name) = \(MemberBuiltinJsonTypeToSwift(x.type)) ()")
                    }
                }
                // Another special case: empty constructors in generated structs (those we added fields for)
                // we just keep the manual initialization and do not call the constructor
                if m.arguments == nil {
                    return
                }
            }
            var (argPrepare, nestLevel) = generateArgPrepare(m.arguments ?? [], methodHasReturn: false)
            if argPrepare != "" {
                p (argPrepare)
                if nestLevel > 0 {
                    p.indent += nestLevel
                }
            }
            
            // Call
            p ("\(typeName).\(ptrName) (&\(ptr), \(ptrArgs))")
            
            // Unwrap the nested calls to 'withUnsafePointer'
            while nestLevel > 0 {
                nestLevel -= 1
                p.indent -= 1
                p ("}")
            }
        }
    }
}

enum MethodCallKind {
    case methodCall
    case operatorCall
}

func generateMethodCall (_ p: Printer,
                         typeName: String,
                         methodToCall: String,
                         godotReturnType: String?,
                         isStatic: Bool,
                         arguments: [JGodotArgument]?,
                         kind: MethodCallKind) {
    let has_return = godotReturnType != nil
    
    let resultTypeName = "\(getGodotType (SimpleType (type: godotReturnType ?? ""), kind: .builtIn))"
    if has_return {
        if godotReturnType == "String" && mapStringToSwift {
            p ("let result = GString ()")
        } else {
            var declType = "var"
            if builtinGodotTypeNames [godotReturnType ?? ""] == .isClass {
                declType = "let"
            }
            p ("\(declType) result: \(resultTypeName) = \(resultTypeName)()")
        }
    }
    
    var (argPrep, nestLevel) = generateArgPrepare(arguments ?? [], methodHasReturn: (godotReturnType ?? "") != "")
    if argPrep != "" {
        p (argPrep)
        if nestLevel > 0 {
            p.indent += nestLevel
        }
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
        if godotReturnType == "String" && mapStringToSwift {
            p ("return result.description")
        } else {
            p ("return result")
        }
    }
    // Unwrap the nested calls to 'withUnsafePointer'
    while nestLevel > 0 {
        nestLevel -= 1
        p.indent -= 1
        p ("}")
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
func generateBuiltinOperators (_ p: Printer,
                               _ bc: JGodotBuiltinClass,
                               typeName: String) {
    let operators = bc.operators
    let godotTypeName = bc.name
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
            p.staticVar (name: ptrName, type: "GDExtensionPtrOperatorEvaluator") {
                let rightTypeCode = builtinTypecode (right)
                let leftTypeCode = builtinTypecode (godotTypeName)
                p ("return gi.variant_get_ptr_operator_evaluator (\(operatorCode), \(leftTypeCode), \(rightTypeCode))!")
            }
            
            let retType = getGodotType(SimpleType (type: op.returnType), kind: .builtIn)
            if let desc = op.description, desc != "" {
                doc (p, bc, desc)
            }
            p ("public static func \(swiftOperator) (lhs: \(typeName), rhs: \(getGodotType(SimpleType(type: right), kind: .builtIn))) -> \(retType) "){
                let ptrResult: String
                if op.returnType == "String" && mapStringToSwift {
                    p ("let result = GString ()")
                } else {
                    var declType: String = "var"
                    if builtinGodotTypeNames [op.returnType] == .isClass {
                        declType = "let"
                    }
                    p ("\(declType) result: \(retType) = \(retType)()")
                }
                let isStruct = isStructMap [op.returnType] ?? false
                if isStruct {
                    ptrResult = "&result"
                } else {
                    ptrResult = "&result.content"
                }
                let rhsa = JGodotArgument(name: "rhs", type: right, defaultValue: nil, meta: nil)
                let rhs = getArgRef (arg: rhsa)
                let lhsa = JGodotArgument(name: "lhs", type: godotTypeName, defaultValue: nil, meta: nil)
                let lhs = getArgRef (arg: lhsa)
                p (generateCopies([lhsa, rhsa]))
                p ("\(typeName).\(ptrName) (\(lhs), \(rhs), \(ptrResult))")
                if op.returnType == "String" && mapStringToSwift {
                    p ("return result.description")
                } else {
                    p ("return result")
                }
            }
        }
    }
}
    


func generateBuiltinMethods (_ p: Printer,
                             _ bc: JGodotBuiltinClass,
                             _ methods: [JGodotBuiltinClassMethod],
                             _ typeName: String,
                             _ typeEnum: String,
                             isStruct: Bool)
{
    if methods.count > 0 {
        p ("\n/* Methods */\n")
    }
    for m in methods {
        if m.name == "repeat" {
            // TODO: Avoid clash for now
            continue
        }
        
        if omittedMethodsList[typeName]?.contains(m.name) == true {
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
        
        p.staticVar (name: ptrName, type: "GDExtensionPtrBuiltInMethod") {
            p ("let name = StringName (\"\(m.name)\")")
            p ("return gi.variant_get_ptr_builtin_method (\(typeEnum), &name.content, \(m.hash))!")
        }
        
        for arg in m.arguments ?? [] {
            var eliminate: String = ""
            if args.isEmpty, m.name.hasSuffix ("_\(arg.name)") {
                // if the first argument name matches the last part of the method name, we want
                // to skip giving it a name.   For example:
                // addPattern (pattern: xx) becomes addPattern (_ pattern: xx)
                eliminate = "_ "
            }
            if args != "" { args += ", " }
            args += getArgumentDeclaration(arg, eliminate: eliminate, isOptional: false)
        }
        
        doc (p, bc, m.description)
        // Generate the method entry point
        if discardableResultList [bc.name]?.contains(m.name) ?? false && m.returnType != "" {
            p ("@discardableResult /* 1: \(m.name) */ ")
        }

        let keyword: String
        if m.isStatic {
            keyword = " static"
        } else if !isStruct {
            keyword = " final"
        } else {
            keyword = ""
        }
        p ("public\(keyword) func \(escapeSwift (snakeToCamel(m.name))) (\(args))\(retSig)") {
            
            generateMethodCall (p, typeName: typeName, methodToCall: ptrName, godotReturnType: m.returnType, isStatic: m.isStatic, arguments: m.arguments, kind: .methodCall)
        }
    }
    if bc.isKeyed {
        p.staticVar (name: "keyed_setter", type: "GDExtensionPtrKeyedSetter") {
            p ("return gi.variant_get_ptr_keyed_setter (GDEXTENSION_VARIANT_TYPE_DICTIONARY)!")
        }
        p.staticVar(name: "keyed_getter", type: "GDExtensionPtrKeyedGetter") {
            p ("return gi.variant_get_ptr_keyed_getter (GDEXTENSION_VARIANT_TYPE_DICTIONARY)!")
        }
        p.staticVar(name: "keyed_checker", type: "GDExtensionPtrKeyedChecker") {
            p ("return gi.variant_get_ptr_keyed_checker (GDEXTENSION_VARIANT_TYPE_DICTIONARY)!")
        }
        p ("public subscript (key: Variant) -> Variant?") {
            p ("get") {
                p ("let keyCopy = key")
                p ("var result = Variant.zero")
                p ("if GDictionary.keyed_checker (&content, &keyCopy.content) != 0") {
                    p ("GDictionary.keyed_getter (&content, &keyCopy.content, &result)")
                    p ("return Variant (fromContent: result)")
                }
                p ("else") {
                    p ("return nil")
                }
            }
            p ("set") {
                p ("let keyCopy = key")
                p ("if let newCopy = newValue") {
                    p ("GDictionary.keyed_setter (&content, &keyCopy.content, &newCopy.content)")
                }
                p ("else") {
                    p ("GDictionary.keyed_setter (&content, &keyCopy.content, nil)")
                }
            }
        }
    }
}

enum BKind {
    case isStruct
    case isClass
}
var builtinGodotTypeNames: [String:BKind] = ["Variant": .isClass]
var builtinClassStorage: [String:String] = [:]

func generateBuiltinClasses (values: [JGodotBuiltinClass], outputDir: String?) async {

    func generateBuiltinClass (p: Printer, _ bc: JGodotBuiltinClass) {
        // TODO: isKeyed, hasDestrcturo,
        let kind: BKind = builtinGodotTypeNames[bc.name]!
        
        let typeName = mapTypeName (bc.name)
        let typeEnum = "GDEXTENSION_VARIANT_TYPE_" + camelToSnake(bc.name).uppercased()
        
        
        var conformances: [String] = []
        if kind == .isStruct {
            conformances.append ("Equatable")
            conformances.append ("Hashable")
        } else {
            if bc.operators.contains(where: { op in op.name == "==" && op.rightType == bc.name }) {
                conformances.append ("Equatable")
            }
        }

        if bc.name == "String" || bc.name == "StringName" || bc.name == "NodePath" {
            conformances.append ("ExpressibleByStringLiteral")
            conformances.append ("ExpressibleByStringInterpolation")
            conformances.append ("LosslessStringConvertible")
        }
        if bc.name.starts(with: "Packed") {
            conformances.append ("Collection")
        }
        var proto = ""
        if conformances.count > 0 {
            proto = ": " + conformances.joined(separator: ", ")
        } else {
            proto = ""
        }
        
        doc (p, bc, bc.brief_description)
        if (bc.description ?? "") != "" {
            doc (p, bc, "")      // Add a newline before the fuller description
            doc (p, bc, bc.description)
        }
        
        p ("public \(kind == .isStruct ? "struct" : "class") \(typeName)\(proto)") {
            if bc.name == "String" {
                p ("public required init (_ str: String)") {
                    p ("gi.string_new_with_utf8_chars (&content, str)")
                }
                p ("// ExpressibleByStringLiteral conformace")
                p ("public required init (stringLiteral value: String)") {
                    p ("gi.string_new_with_utf8_chars (&content, value)")
                }
            }
            if bc.name == "NodePath"  {
                p ("// ExpressibleByStringLiteral conformace")
                p ("public required init (stringLiteral value: String)") {
                    p ("let from = GString (value)")
                    p ("var args: [UnsafeRawPointer?] = []")
                    p ("withUnsafePointer (to: &from.content)", arg: " ptr in") {
                        p ("args.append (ptr)")
                        p ("NodePath.constructor2 (&content, &args)")
                    }
                }
                p ("// LosslessStringConvertible conformance)")
                p ("public required init (_ value: String)") {
                    p ("let from = GString (value)")
                    p ("var args: [UnsafeRawPointer?] = []")
                    p ("withUnsafePointer (to: &from.content)", arg: " ptr in") {
                        p ("args.append (ptr)")
                        p ("NodePath.constructor2 (&content, &args)")
                    }
                }
                p ("public var description: String") {
                    p ("let sub = getConcatenatedSubnames ().description")
                    p ("return getConcatenatedNames ().description + (sub == \"\" ? sub : \":\\(sub)\")")
                }
            }
            if bc.name == "StringName" {
                // TODO: This is a little brittle, because I am
                // hardcoding the constructor1 here, it should
                // really produce this when it matches the kind
                // directly to be the one that takes a StringName
                // parameter
                p ("public init (fromPtr: UnsafeRawPointer?)") {
                    p ("var args: [UnsafeRawPointer?] = [")
                    p ("    fromPtr,")
                    p ("]")
                    p ("StringName.constructor1 (&content, &args)")
                }
                p ("// ExpressibleByStringLiteral conformace")
                p ("public required init (stringLiteral value: String)") {
                    p ("let from = GString (value)")
                    p ("var args: [UnsafeRawPointer?] = []")
                    p ("withUnsafePointer (to: &from.content)", arg: " ptr in"){
                        p ("args.append (ptr)")
                        p ("StringName.constructor2 (&content, &args)")
                    }
                }
                p ("// LosslessStringConvertible conformance)")
                p ("public required init (_ value: String)") {
                    p ("let from = GString (value)")
                    p ("var args: [UnsafeRawPointer?] = []")
                    p ("withUnsafePointer (to: &from.content)", arg: " ptr in"){
                        p ("args.append (ptr)")
                        p ("StringName.constructor2 (&content, &args)")
                    }
                }
            }
            if bc.name == "Callable" {
                p ("/// Creates a Callable instance from a Swift function")
                p ("/// - Parameter callback: the swift function that receives an array of Variant arguments, and returns an optional Variant")
                p ("public init (_ callback: @escaping ([Variant])->Variant?)") {
                    p ("content = CallableWrapper.makeCallable (callback)")
                }
            }
            if bc.hasDestructor {
                p.staticVar (name: "destructor", type: "GDExtensionPtrDestructor") {
                    p ("return gi.variant_get_ptr_destructor (\(typeEnum))!")
                }
                
                p ("deinit"){
                    p ("if content != \(typeName).zero") {
                        p ("\(typeName).destructor (&content)")
                    }
                }
            }

            if kind == .isClass {
                let (storage, initialize) = getBuiltinStorage (bc.name)
                p ("// Contains a binary blob where this type information is stored")
                p ("public var content: ContentType\(initialize)")
                p ("// Used to initialize empty types")
                p ("public static let zero: ContentType \(initialize)")
                p ("// Convenience type that matches the build configuration storage needs")
                p ("public typealias ContentType = \(storage)")
                builtinClassStorage [bc.name] = storage
                // TODO: This is a little brittle, because I am
                // hardcoding the constructor1 here, it should
                // really produce this when it matches the kind
                // directly to be the one that takes the same
                // parameter
                p ("// Used to construct objects on virtual proxies")
                p ("public required init (content: ContentType)") {
                    p ("var copy = content")
                    p ("var args: [UnsafeRawPointer?] = []")
                    p ("withUnsafePointer (to: &copy)", arg: " ptr in") {
                        p ("args.append (ptr)")
                        p ("\(typeName).constructor1 (&self.content, &args)")
                    }
                }
            }
           
            func memberDoc (_ name: String) {
                guard let members = bc.members else { return }
                for m in members {
                    if m.name == name {
                        doc (p, bc, m.description)
                    }
                }
            }
            let storedMembers: [JGodotArgument]?
            if bc.name == "Color" {
                memberDoc ("r")
                p ("public var red: Float")
                memberDoc ("g")
                p ("public var green: Float")
                memberDoc ("b")
                p ("public var blue: Float")
                memberDoc ("a")
                p ("public var alpha: Float")
                storedMembers = bc.members
            } else {
                if kind == .isStruct, let memberOffsets = builtinMemberOffsets [bc.name] {
                    storedMembers = memberOffsets.compactMap({ m in
                        return bc.members?.first(where: { $0.name == m.member })
                    })
                } else {
                    storedMembers = bc.members
                }
                if let members = storedMembers {
                    for x in members {
                        memberDoc (x.name)
                        p ("public var \(x.name): \(MemberBuiltinJsonTypeToSwift (x.type))")
                    }
                }
            }
                
            if let enums = bc.enums {
                generateEnums(p, cdef: bc, values: enums, prefix: bc.name + ".")
            }
            generateBuiltinCtors (p, bc, bc.constructors, godotTypeName: bc.name, typeName: typeName, typeEnum: typeEnum, members: storedMembers)
            
            generateBuiltinMethods(p, bc, bc.methods ?? [], typeName, typeEnum, isStruct: kind == .isStruct)
            generateBuiltinOperators (p, bc, typeName: typeName)
            
            if bc.isKeyed {
                
            }
            generateBuiltinConstants (p, bc, typeName: typeName)
            
            // Generate the synthetic `end` property
            if bc.name == "Rect2" || bc.name == "Rect2i" || bc.name == "AABB" {
                let retType: String
                memberDoc("end")
                switch bc.name {
                case "Rect2": retType = "Vector2"
                case "Rect2i": retType = "Vector2i"
                case "AABB": retType = "Vector3"
                default:
                    fatalError("Should never happen")
                }
                p ("public var end: \(retType)") {
                    p ("set") {
                        p ("size = newValue - position")
                    }
                    p ("get") {
                        p ("position + size")
                    }
                }
            }
            if bc.name.starts(with: "Packed") {
                p ("public var startIndex: Int") {
                    p ("0")
                }
                p ("public var endIndex: Int") {
                    p ("Int (size ())")
                }

                p ("public func index(after i: Int) -> Int") {
                    p ("i+1")
                }
            }
        }
    }
    
    // First map structs and classes from the builtins
    for bc in values {
        switch bc.name {
            // We do not generate code for a few types, we will bridge those instead
        case "int", "float", "bool":
            break
        default:
            builtinGodotTypeNames [bc.name] = bc.members != nil ? .isStruct : .isClass
        }
    }
    
    for bc in values {
        switch bc.name {
            // We do not generate code for a few types, we will bridge those instead
        case "int", "float", "bool":
            break
        default:
            let p: Printer = await PrinterFactory.shared.initPrinter()
            p.preamble()
            mapStringToSwift = bc.name != "String"
            generateBuiltinClass (p: p, bc)
            mapStringToSwift = true
            if let outputDir {
                p.save(outputDir + "/\(bc.name).swift")
            }
        }
    }
}
