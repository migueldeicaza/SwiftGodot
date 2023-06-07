//
//  BuiltinGen.swift
//  Generator
//
//  Created by Miguel de Icaza on 3/26/23.
//

import Foundation

/// Given an initializer of the form "Vector (0, 1, 0)" returns a proper Swift "Vector (x: 0, y: 1, z: 0)" value
///
func getInitializer (_ bc: JGodotBuiltinClass, _ val: String) -> String? {
    if let pstart = val.firstIndex(of: "("), let pend = val.lastIndex(of: ")"){
        var found = false
        let splitArgs = val [val.index(pstart, offsetBy: 1)..<pend].split(separator: ",")
        // Find a constructor with that number of arguments
        for constructor in bc.constructors {
            
            if constructor.arguments?.count ?? -1 == splitArgs.count {
                // Found
                var prefixedArgs = ""
                for i in 0..<splitArgs.count {
                    if prefixedArgs.count != 0 { prefixedArgs += ", "}
                    var name = constructor.arguments! [i].name
                    var pval = splitArgs [i]

                    // Some Godot constants leak into the initializers
                    if pval.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "inf" {
                        pval = "Double.infinity"[...]
                    }

                    prefixedArgs = prefixedArgs + name + ": " + pval
                }
                return String (val [val.startIndex..<pstart]) + " (" + prefixedArgs + ")"
            }
        }
        return nil
    }
    return val
}

func generateBuiltinConstants (_ p: Printer,
                               _ bc: JGodotBuiltinClass,
                               _ docClass: DocBuiltinClass?,
                               typeName: String) {
        
    guard let constants = bc.constants else { return }
    let docConstants = docClass?.constants?.constant
    
    var docConstantMap: [String: String] = [:]
    for dc in docConstants ?? [] {
        docConstantMap [dc.name] = dc.rest
    }
    
    for constant in constants {
        // Check if we need to inject parameter names
        var val = constant.value
        guard let val = getInitializer (bc, constant.value) else {
            continue
        }
        
        if let rest = docConstantMap [constant.name] {
            doc (p, bc, "\(rest)")
        }
        p ("public static let \(snakeToCamel (constant.name)) = \(val)")
    }
}

func generateBuiltinCtors (_ p: Printer,
                           _ bc: JGodotBuiltinClass,
                           _ docClass: DocBuiltinClass?,
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
        
        if godotTypeName.starts(with: "Vector") && m.arguments?.count ?? 0 == 0 {
            // Do not expose the empty constructors to the world, they are kind of useless
            // but the generator references them to initialize values
            visibility = ""
        }
        let ptrName = "constructor\(m.index)"
        p ("static var \(ptrName): GDExtensionPtrConstructor = gi.variant_get_ptr_constructor (\(typeEnum), \(m.index))!\n")
        
        for arg in m.arguments ?? [] {
            if args != "" { args += ", " }
            args += getArgumentDeclaration(arg, eliminate: "", kind: .builtInField, isOptional: false)
        }
        
        // Find the document for this constructor
        if let docClass, let ctorDocs = docClass.constructors?.constructor {
            for ctorDoc in ctorDocs {
                let ctorDocParamCount = ctorDoc.param.count
                if ctorDocParamCount == (m.arguments?.count ?? -1) {
                    var fail = false
                    for i in 0..<ctorDocParamCount {
                        if ctorDoc.param [i].type != m.arguments! [i].type {
                            fail = true
                            break
                        }
                    }
                    if !fail {
                        doc (p, bc, ctorDoc.description)
                        break
                    }
                }
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
                if bc.name == "Color" {
                    p ("self.red = 0")
                    p ("self.green = 0")
                    p ("self.blue = 0")
                    p ("self.alpha = 0")
                } else if bc.name == "Plane" {
                    p ("self.plane = Vector3 ()")
                    p ("self.d = 0")
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
            // Call
            p ("\(typeName).\(ptrName) (&\(ptr), \(ptrArgs))")
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
            p ("var result = GString ()")
        } else {
            p ("var result: \(resultTypeName) = \(resultTypeName)()")
        }
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
        if godotReturnType == "String" && mapStringToSwift {
            p ("return result.description")
        } else {
            p ("return result")
        }
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
                               _ docClass: DocBuiltinClass?,
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
            p ("static var \(ptrName): GDExtensionPtrOperatorEvaluator = ", suffix: "()"){
                let rightTypeCode = builtinTypecode (right)
                let leftTypeCode = builtinTypecode (godotTypeName)
                p ("return gi.variant_get_ptr_operator_evaluator (\(operatorCode), \(leftTypeCode), \(rightTypeCode))!")
            }
            
            let retType = getGodotType(SimpleType (type: op.returnType), kind: .builtIn)
            if let docClass, let opDocs = docClass.operators?.operator {
                for opDoc in opDocs {
                    if opDoc.name.hasSuffix(op.name) && opDoc.return.first?.type == op.returnType && right == opDoc.param.first?.type {
                        doc (p, bc, opDoc.description)
                        break
                    }
                }
            }
            p ("public static func \(swiftOperator) (lhs: \(typeName), rhs: \(getGodotType(SimpleType(type: right), kind: .builtIn))) -> \(retType) "){
                let ptrResult: String
                if op.returnType == "String" && mapStringToSwift {
                    p ("var result = GString ()")
                } else {
                    p ("var result: \(retType) = \(retType)()")
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
                             _ docClass: DocBuiltinClass?,
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

        let ret = getGodotType(SimpleType (type: m.returnType ?? ""), kind: .builtIn)
        
        // TODO: problem caused by gobject_object being defined as "void", so it is not possible to create storage to that.
        if ret == "Object" {
            continue
        }
        let retSig = ret == "" ? "" : "-> \(ret)"
        var args = ""
    
        let ptrName = "method_\(m.name)"
        
        p ("static var \(ptrName): GDExtensionPtrBuiltInMethod = ", suffix: "()"){
            p ("let name = StringName (\"\(m.name)\")")
            p ("return gi.variant_get_ptr_builtin_method (\(typeEnum), &name.content, \(m.hash))!")
        }
        
        for arg in m.arguments ?? [] {
            if args != "" { args += ", " }
            args += getArgumentDeclaration(arg, eliminate: "", isOptional: false)
        }
        
        if let docClass, let methods = docClass.methods {
            if let docMethod = methods.method.first(where: { $0.name == m.name }) {
                doc (p, bc, docMethod.description)
                // Sadly, the parameters have no useful documentation
            }
        }
        p ("public\(isStruct ? "" : " final") func \(escapeSwift (snakeToCamel(m.name))) (\(args))\(retSig)") {
            
            generateMethodCall (p, typeName: typeName, methodToCall: ptrName, godotReturnType: m.returnType, isStatic: m.isStatic, arguments: m.arguments, kind: .methodCall)
        }
    }
    if bc.isKeyed {
        p ("static var keyed_setter: GDExtensionPtrKeyedSetter = ", suffix: "()") {
            p ("return gi.variant_get_ptr_keyed_setter (GDEXTENSION_VARIANT_TYPE_DICTIONARY)!")
        }
        p ("static var keyed_getter: GDExtensionPtrKeyedGetter = ", suffix: "()") {
            p ("return gi.variant_get_ptr_keyed_getter (GDEXTENSION_VARIANT_TYPE_DICTIONARY)!")
        }
        p ("static var keyed_checker: GDExtensionPtrKeyedChecker = ", suffix: "()") {
            p ("return gi.variant_get_ptr_keyed_checker (GDEXTENSION_VARIANT_TYPE_DICTIONARY)!")
        }
        p ("public subscript (key: Variant) -> Variant?") {
            p ("get") {
                p ("var keyCopy = key")
                p ("var result = Variant.zero")
                p ("if Dictionary.keyed_checker (&content, &keyCopy) != 0") {
                    p ("Dictionary.keyed_getter (&content, &keyCopy, &result)")
                    p ("return Variant (fromContent: result)")
                }
                p ("else") {
                    p ("return nil")
                }
            }
            p ("set") {
                p ("var keyCopy = key")
                p ("if var newCopy = newValue") {
                    p ("Dictionary.keyed_setter (&content, &keyCopy, &newCopy)")
                }
                p ("else") {
                    p ("Dictionary.keyed_setter (&content, &keyCopy, nil)")
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

func generateBuiltinClasses (values: [JGodotBuiltinClass], outputDir: String) {

    func generateBuiltinClass (p: Printer, _ bc: JGodotBuiltinClass, _ docClass: DocBuiltinClass?) {
        // TODO: isKeyed, hasDestrcturo,
        var kind: String
        if bc.members != nil {
            kind = "struct"
        } else {
            kind = "class"
        }
        builtinGodotTypeNames [bc.name] = kind == "struct" ? .isStruct : .isClass
        let typeName = mapTypeName (bc.name)
        let typeEnum = "GDEXTENSION_VARIANT_TYPE_" + camelToSnake(bc.name).uppercased()
        
        
        var conformances: [String] = []
        if kind == "struct" {
            conformances.append ("Equatable")
            conformances.append ("Hashable")
        } else {
            if bc.operators.contains(where: { op in op.name == "==" && op.rightType == bc.name }) {
                conformances.append ("Equatable")
            }
        }
        conformances.append ("GodotVariant")
        if bc.name == "String" || bc.name == "StringName" || bc.name == "NodePath" {
            conformances.append ("ExpressibleByStringLiteral")
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
        
        doc (p, bc, docClass?.brief_description)
        if docClass?.description ?? "" != "" {
            doc (p, bc, "")      // Add a newline before the fuller description
            doc (p, bc, docClass?.description)
        }
        
        p ("public \(kind) \(typeName)\(proto)") {
            if bc.name == "String" {
                p ("public init (_ str: String)") {
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
                    p ("var from = GString (value)")
                    p ("var args: [UnsafeRawPointer?] = [")
                    p ("    UnsafeRawPointer(&from.content),")
                    p ("]")
                    p ("NodePath.constructor2 (&content, &args)")
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
                    p ("var from = GString (value)")
                    p ("var args: [UnsafeRawPointer?] = [")
                    p ("    UnsafeRawPointer(&from.content),")
                    p ("]")
                    p ("StringName.constructor2 (&content, &args)")
                }
            }
            if bc.hasDestructor {
                p ("static var destructor: GDExtensionPtrDestructor = ", suffix: "()"){
                    p ("return gi.variant_get_ptr_destructor (\(typeEnum))!")
                }
                
                p ("deinit"){
                    p ("\(typeName).destructor (&content)")
                }
            }
            
//            p ("public static var variantType: Variant.GType") {
//                p (".\(snakeToCamel (bc.name))")
//            }
            

            if kind == "class" {
                let (storage, initialize) = getBuiltinStorage (bc.name)
                p ("// Contains a binary blob where this type information is stored")
                p ("var content: ContentType\(initialize)")
                p ("// Used to initialize empty types")
                p ("static let zero: ContentType \(initialize)")
                p ("// Convenience type that matches the build configuration storage needs")
                p ("typealias ContentType = \(storage)")
                builtinClassStorage [bc.name] = storage
                // TODO: This is a little brittle, because I am
                // hardcoding the constructor1 here, it should
                // really produce this when it matches the kind
                // directly to be the one that takes the same
                // parameter
                p ("// Used to construct objects on virtual proxies")
                p ("init (content: \(storage))") {
                    p ("var copy = content")
                    p ("var args: [UnsafeRawPointer?] = [UnsafeRawPointer (&copy)]")
                    p ("\(typeName).constructor1 (&self.content, &args)")
                }
            }
            
            p ("/// Creates a new instance from the given variant if it contains a \(typeName)")
            let gtype = gtypeFromTypeName (bc.name)
            // Now generate the variant constructor
            if kind == "class" {
                p ("public required init? (_ from: Variant)") {
                    p ("guard from.gtype == .\(gtype) else") {
                        p ("return nil")
                    }
                    p ("var localContent: \(typeName).ContentType = \(typeName).zero")
                    p ("from.toType(.\(gtype), dest: &localContent)")
                    p ("// Replicate the constructor, because of a lame Swift requirement")
                    p ("var args: [UnsafeRawPointer?] = [UnsafeRawPointer(&localContent)]")
                    p ("\(typeName).constructor1 (&content, &args)")
                }
            } else {
                p ("public init? (_ from: Variant)") {
                    p ("guard from.gtype == .\(gtype) else") {
                        p ("return nil")
                    }
                    p ("var v = \(bc.name)()")
                    p ("from.toType(.\(gtype), dest: &v)")
                    p ("self.init (from: v)")
                }                
            }
            p ("/// Wraps this \(typeName) into a Variant")
            p ("public func toVariant () -> Variant ") {
                p ("Variant (self)")
            }
            
            let mdocs = docClass?.members
            func memberDoc (_ name: String)  {
                for md in mdocs?.member ?? [] {
                    if md.name == name {
                        doc (p, bc, md.value)
                    }
                }
            }
            if let members = bc.members {
                if bc.name == "Color" {
                    memberDoc ("red")
                    p ("public var red: Float")
                    memberDoc ("green")
                    p ("public var green: Float")
                    memberDoc ("blue")
                    p ("public var blue: Float")
                    memberDoc ("alpha")
                    p ("public var alpha: Float")
                } else if bc.name == "Plane" {
                    memberDoc ("plane")
                    p ("public var plane: Vector3")
                    memberDoc ("d")
                    p ("public var d: Float")
                } else {
                    for x in members {
                        memberDoc (x.name)
                        p ("public var \(x.name): \(MemberBuiltinJsonTypeToSwift (x.type))")
                    }
                }
            }

            if let enums = bc.enums {
                generateEnums(p, cdef: bc, values: enums, constantDocs: docClass?.constants?.constant, prefix: bc.name + ".")
            }
            generateBuiltinCtors (p, bc, docClass, bc.constructors, godotTypeName: bc.name, typeName: typeName, typeEnum: typeEnum, members: bc.members)
            
            generateBuiltinMethods(p, bc, docClass, bc.methods ?? [], typeName, typeEnum, isStruct: kind == "struct")
            generateBuiltinOperators (p, bc, docClass, typeName: typeName)
            if bc.isKeyed {
                
            }
            generateBuiltinConstants (p, bc, docClass, typeName: typeName)
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
    
    for bc in values {
        switch bc.name {
            // We do not generate code for a few types, we will bridge those instead
        case "int", "float", "bool":
            break
        default:
            let p = Printer ()
            p.preamble()
            let docClass = loadBuiltinDoc(base: docRoot, name: bc.name)
            mapStringToSwift = bc.name != "String"
            generateBuiltinClass (p: p, bc, docClass)
            mapStringToSwift = true
            p.save(outputDir + "/\(bc.name).swift")
        }
    }
}
