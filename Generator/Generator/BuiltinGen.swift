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
        guard let constantValue = constant.value else { continue }
        guard let val = getInitializer (bc, constantValue) else {
            print ("Generator: no constructor matching constant \(bc.name).\(constant.name) = \(constantValue)")
            continue
        }
        
        if constant.description != "" {
            doc (p, bc, constant.description)
        }
        p ("public static var \(snakeToCamel(constant.name)): \(constant.swiftTypeName) { \(val) }")
    }
}

func generateBuiltinCtors (_ p: Printer,
                           _ gip: Printer,
                           _ bc: JGodotBuiltinClass,
                           _ ctors: [JGodotConstructor],
                           godotTypeName: String,
                           typeName: String,
                           typeGodotInterfaceName: String,
                           typeEnum: String,
                           members: [JGodotArgumentType]?)
{
    let isStruct = isStruct(typeName)

    for m in ctors {
        var args = ""
        var visibility = "public"
        
        let ptrName = "constructor\(m.index)"
        gip.staticProperty(isStored: true, name: ptrName, type: "GDExtensionPtrConstructor") {
            gip("gi.variant_get_ptr_constructor(\(typeEnum), \(m.index))!")
        }
            
        for arg in m.arguments ?? [] {
            if args != "" { args += ", " }
            args += getArgumentDeclaration(arg, omitLabel: false, kind: .builtInField, isOptional: arg.type == "Variant")
        }
        
        if let desc = m.description, desc != "" {
            doc (p, bc, desc)
        }
        if args == "" {
            if !isStruct {
                visibility.append(" required")
            }
        }
        
        p ("\(visibility) init(\(args))") {
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
                        
            // I used to have a nicer model, rather than everything having a
            // handle, I had a named handle, like "_godot_string"
            let ptr = isStruct ? "self" : "content"
            
            // We need to initialize some variables before we call
            if let members {
                if bc.name == "Color" {
                    p ("self.red = 0")
                    p ("self.green = 0")
                    p ("self.blue = 0")
                    p ("self.alpha = 1")
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
            
            let arguments = (m.arguments ?? []).map {
                // must not fail
                try! MethodArgument(from: $0, typeName: typeName, methodName: "#constructor\(m.index)", options: .builtInClassOptions)
            }
            
            if arguments.isEmpty {
                preparingArguments(p, arguments: arguments) {
                    p ("\(typeGodotInterfaceName).\(ptrName)(&\(ptr), nil)")
                }
            } else {
                preparingArguments(p, arguments: arguments) {
                    aggregatingPreparedArguments(p, argumentsCount: arguments.count) {
                        p("\(typeGodotInterfaceName).\(ptrName)(&\(ptr), pArgs)")
                    }
                }
            }
        }
    }
}

func generateMethodCall (_ p: Printer,
                         typeName: String,
                         typeGodotInterfaceName: String,
                         methodToCall: String,
                         godotReturnType: String?,
                         isStatic: Bool,
                         isVararg: Bool,
                         arguments: [JGodotArgumentType]) {
    let hasReturnStatement = godotReturnType != nil
    
    let resultTypeName = "\(getGodotType (SimpleType (type: godotReturnType ?? ""), kind: .builtIn))"
    if hasReturnStatement {
        if godotReturnType == "String" && mapStringToSwift {
            p ("let result = GString ()")
        } else if godotReturnType == "Variant" {
            p("var result = Variant.zero")
        } else {
            var declType = "var"
            if builtinGodotTypeNames [godotReturnType ?? ""] == .isClass {
                declType = "let"
            }
            p ("\(declType) result: \(resultTypeName) = \(resultTypeName)()")
        }
    }
    
    let methodArguments = arguments.map { argument in
        // must never fail
        try! MethodArgument(from: argument, typeName: typeName, methodName: methodToCall, options: .builtInClassOptions)
    }
        
    let ptrResult: String
    if hasReturnStatement {
        if godotReturnType == "Variant" {
            ptrResult = "&result"
        } else {
            let isStruct = isStruct(godotReturnType ?? "")
            if isStruct {
                ptrResult = "&result"
            } else {
                ptrResult = "&result.content"
            }
        }
    } else {
        ptrResult = "nil"
    }
    
    generateMethodCall(p, isVariadic: isVararg, arguments: arguments, methodArguments: methodArguments) { argsRef, count in
        let countArg: String
        
        switch count {
        case .literal(let literal):
            countArg = "\(literal)"
        case .expression(let expr):
            countArg = "Int32(\(expr))"
        }
        
        if isStatic {
            return "\(typeGodotInterfaceName).\(methodToCall)(nil, \(argsRef), \(ptrResult), \(countArg))"
        } else {
            if isStruct(typeName) {
                return """
                var mutSelfCopy = self
                withUnsafeMutablePointer (to: &mutSelfCopy) { ptr in
                   \(typeGodotInterfaceName).\(methodToCall)(ptr, \(argsRef), \(ptrResult), \(countArg))
                }
                """
            } else {
                return "\(typeGodotInterfaceName).\(methodToCall)(&content, \(argsRef), \(ptrResult), \(countArg))"
            }
        }
    }
    
    if hasReturnStatement {
        if godotReturnType == "Variant" {
            p("return Variant(takingOver: result)")
        } else if godotReturnType == "String" && mapStringToSwift {
            p("return result.description")
        } else {
            p("return result")
        }
    }
}

// List of operators we do not want to generate, as we have custom versions
let skipOperators: [String:[(String,String)]] = [
    "StringName": [("==", "StringName")]
]

private struct OperatorSignature: Hashable, ExpressibleByStringLiteral {
    let name: String
    let lhs: String
    let rhs: String
    
    init(name: String, lhs: String, rhs: String) {
        self.name = name
        self.lhs = lhs
        self.rhs = rhs
    }
    
    init(stringLiteral value: StringLiteralType) {
        let components = value.split(separator: " ")
        
        precondition(components.count == 3)
        
        lhs = String(components[0])
        name = String(components[1])
        rhs = String(components[2])
    }
}

private struct MethodSignature: Hashable, ExpressibleByStringLiteral {
    let typeName: String
    let methodName: String
    
    init(typeName: String, methodName: String) {
        self.typeName = typeName
        self.methodName = methodName
    }
    
    init(stringLiteral value: StringLiteralType) {
        let components = value.split(separator: ".")
        
        precondition(components.count == 2)
        typeName = String(components[0])
        methodName = String(components[1])
    }
}

/// - Parameters:
///   - operators: the array of operators
///   - godotTypeName: the type for which we are generating operators
///   - typeName: the type name above, but in Swift
func generateBuiltinOperators (_ p: Printer,
                               _ gip: Printer,
                               _ bc: JGodotBuiltinClass,
                               typeName: String,
                               typeGodotInterfaceName: String
) {
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
            gip.staticProperty(isStored: true, name: ptrName, type: "GDExtensionPtrOperatorEvaluator") {
                let rightTypeCode = builtinTypecode(right)
                let leftTypeCode = builtinTypecode(godotTypeName)
                gip("return gi.variant_get_ptr_operator_evaluator(\(operatorCode), \(leftTypeCode), \(rightTypeCode))!")
            }
            
            let retType = getGodotType(SimpleType (type: op.returnType), kind: .builtIn)
            
            let lhsTypeName = typeName
            let rhsTypeName = getGodotType(SimpleType(type: right), kind: .builtIn)
                        
            let customImplementation = customBuiltinOperatorImplementations[OperatorSignature(name: swiftOperator, lhs: lhsTypeName, rhs: rhsTypeName)]
            
            if let desc = op.description, desc != "" {
                doc (p, bc, desc)
            }
            
            p ("public static func \(swiftOperator)(lhs: \(lhsTypeName), rhs: \(rhsTypeName)) -> \(retType) "){
                if customImplementation != nil {
                    p("#if !CUSTOM_BUILTIN_IMPLEMENTATIONS")
                }
                
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
                if isStruct(op.returnType) {
                    ptrResult = "&result"
                } else {
                    ptrResult = "&result.content"
                }
                let lhsa = try! MethodArgument(
                    from: JGodotArgument(name: "lhs", type: godotTypeName, defaultValue: nil, meta: nil),
                    typeName: godotTypeName,
                    methodName: "#operator\(swiftOperator)",
                    options: .builtInClassOptions
                )
                
                let rhsa = try! MethodArgument(
                    from: JGodotArgument(name: "rhs", type: right, defaultValue: nil, meta: nil),
                    typeName: godotTypeName,
                    methodName: "#operator\(swiftOperator)",
                    options: .builtInClassOptions
                )
                    
                preparingArguments(p, arguments: [lhsa, rhsa]) {
                    p("\(typeGodotInterfaceName).\(ptrName)(pArg0, pArg1, \(ptrResult))")
                }
                
                if op.returnType == "String" && mapStringToSwift {
                    p ("return result.description")
                } else {
                    p ("return result")
                }
                
                if let customImplementation {
                    p("#else // CUSTOM_BUILTIN_IMPLEMENTATIONS")
                    p(customImplementation)
                    p("#endif")
                }
            }
        }
    }
}
    


func generateBuiltinMethods (_ p: Printer,
                             _ gip: Printer,
                             _ bc: JGodotBuiltinClass,
                             _ methods: [JGodotBuiltinClassMethod],
                             _ typeName: String,
                             _ typeGodotInterfaceName: String,
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
        
        
        let ret: String
        if m.returnType == "Variant" {
            ret = "Variant?"
        } else {
            ret = getGodotType(SimpleType (type: m.returnType ?? ""), kind: .builtIn)
        }
        
        // TODO: problem caused by gobject_object being defined as "void", so it is not possible to create storage to that.
        if ret == "Object" {
            continue
        }
        let retSig = ret == "" ? "" : " -> \(ret)"
        var args = ""
    
        let ptrName = "method_\(m.name)"
        
        gip.staticProperty(visibility: "internal", isStored: true, name: ptrName, type: "GDExtensionPtrBuiltInMethod") {
            gip("var name = FastStringName(\"\(m.name)\")")
            gip("return gi.variant_get_ptr_builtin_method(\(typeEnum), &name.content, \(m.hash))!")
        }
        
        for arg in m.arguments ?? [] {
            let omitFirstLabel: Bool
            // Omit first argument label, if necessary
            if args.isEmpty, shouldOmitFirstArgLabel(typeName: typeName, methodName: m.name, argName: arg.name) {
                omitFirstLabel = true
            } else {
                omitFirstLabel = false
            }
            if args != "" { args += ", " }
            args += getArgumentDeclaration(arg, omitLabel: omitFirstLabel, isOptional: arg.type == "Variant")
        }
        if m.isVararg {
            if args != "" { args += ", " }
            args += "_ arguments: Variant?..."
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
        
        let methodName = escapeSwift(snakeToCamel(m.name))
        let customImplementation = customBuiltinMethodImplementations[MethodSignature(typeName: bc.name, methodName: methodName)]
        
        p ("public\(keyword) func \(methodName)(\(args))\(retSig)") {
            if customImplementation != nil {
                p("#if !CUSTOM_BUILTIN_IMPLEMENTATIONS")
            }
            
            generateMethodCall(p, typeName: typeName, typeGodotInterfaceName: typeGodotInterfaceName, methodToCall: ptrName, godotReturnType: m.returnType, isStatic: m.isStatic, isVararg: m.isVararg, arguments: m.arguments ?? [])
            
            if let customImplementation {
                p("#else // CUSTOM_BUILTIN_IMPLEMENTATIONS")
                p(customImplementation)
                p("#endif")
            }
        }
    }
    if bc.isKeyed {
        let variantType = builtinTypecode(bc.name)
        gip.staticProperty(isStored: true, name: "keyed_getter", type: "GDExtensionPtrKeyedGetter") {
            gip("return gi.variant_get_ptr_keyed_getter (\(variantType))!")
        }
        gip.staticProperty(isStored: true, name: "keyed_setter", type: "GDExtensionPtrKeyedSetter") {
            gip("return gi.variant_get_ptr_keyed_setter (\(variantType))!")
        }
        gip.staticProperty(isStored: true, name: "keyed_checker", type: "GDExtensionPtrKeyedChecker") {
            gip("return gi.variant_get_ptr_keyed_checker (\(variantType))!")
        }
        p("""
        public subscript(key: Variant?) -> Variant? {
            get {                            
                withUnsafePointer(to: key.content) { pKeyContent in
                    if \(typeGodotInterfaceName).keyed_checker(&content, pKeyContent) != 0 {
                        var result = Variant.zero
                        \(typeGodotInterfaceName).keyed_getter(&content, pKeyContent, &result)
                        // Returns unowned handle
                        return Variant(takingOver: result)
                    } else {
                        return nil
                    }
                }                
            }
        
            set {
                withUnsafePointer(to: key.content) { pKeyContent in
                    if let newValue {
                        \(typeGodotInterfaceName).keyed_setter(&content, pKeyContent, &newValue.content)
                    } else {                    
                        var nilContent = Variant.zero
                        \(typeGodotInterfaceName).keyed_setter(&content, pKeyContent, &nilContent)
                    }
                }                                
            }
        }
        """)        
    }
    if let returnType = bc.indexingReturnType, !bc.isKeyed, !bc.name.hasSuffix ("Array"), bc.name != "String" {
        let godotType = getGodotType (JGodotReturnValue (type: returnType, meta: nil))
        let variantType = builtinTypecode (bc.name)
        gip.staticProperty(isStored: true, name: "indexed_getter", type: "GDExtensionPtrIndexedGetter") {
            gip("return gi.variant_get_ptr_indexed_getter (\(variantType))!")
        }
        gip.staticProperty(isStored: true, name: "indexed_setter", type: "GDExtensionPtrIndexedSetter") {
            gip("return gi.variant_get_ptr_indexed_setter (\(variantType))!")
        }
        p("public subscript(index: Int64) -> \(godotType)") {
            p("mutating get") {
                p("var result = \(godotType)()")
                p("\(typeGodotInterfaceName).indexed_getter (&self, index, &result)")
                p("return result")
            }
            p("set") {
                p("var value = newValue")
                p("\(typeGodotInterfaceName).indexed_setter (&self, index, &value)")
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
    // Always register builtin enum metadata so other stages can resolve enum defaults
    for bc in values {
        if let enums = bc.enums {
            registerEnumDefinitions(enums, prefix: bc.name + ".")
        }
    }
    
    // Prime builtin type metadata even when we're not emitting builtin source files.
    //
    // This generator is used in two modes:
    // - SwiftGodotRuntime: emits builtin sources
    // - SwiftGodot (and split targets): imports SwiftGodotRuntime and emits only classes
    //
    // The class generation stage still needs to know which builtins are class-backed
    // (and what their Swift wrapper names are) so that virtual proxy glue can unwrap
    // arguments correctly.
    for bc in values {
        if bc.name == "Nil" { continue }
        switch bc.name {
        case "int", "float", "bool":
            continue
        default:
            builtinGodotTypeNames[bc.name] = bc.members != nil ? .isStruct : .isClass
            if bc.members == nil {
                let (storage, _) = getBuiltinStorage(bc.name, asComputedProperty: false)
                builtinClassStorage[bc.name] = storage
            }
        }
    }

    let filteredValues = values.filter { shouldGenerateBuiltin($0.name) }

    func generateBuiltinClass(p: Printer, _ bc: JGodotBuiltinClass) {
        // TODO: isKeyed, hasDestrcturo,
        let kind: BKind = builtinGodotTypeNames[bc.name]!
        
        let typeName = mapTypeName (bc.name)
        let typeEnum = "GDEXTENSION_VARIANT_TYPE_" + camelToSnake(bc.name).uppercased()
                
        let typeGodotInterfaceName = "GodotInterfaceFor" + bc.name
        
        /// Printer for collecting godot procedures pointers
        let gip = Printer()
                
        var conformances: [String] = ["_GodotBridgeableBuiltin"]
        if kind == .isStruct {
            conformances.append ("Equatable")
            conformances.append ("Hashable")
        } else {
            if bc.operators.contains(where: { op in op.name == "==" && op.rightType == bc.name }) {
                conformances.append ("Equatable")
            }
            
            if bc.methods?.contains(where: { method in
                method.name == "hash"
            }) == true {
                conformances.append("Hashable")
            }
        }

        if bc.name == "String" || bc.name == "StringName" || bc.name == "NodePath" {
            conformances.append ("ExpressibleByStringLiteral")
            conformances.append ("ExpressibleByStringInterpolation")
            conformances.append ("LosslessStringConvertible")
        }
        if bc.name.hasSuffix ("Array") {
            conformances.append ("Collection")
            conformances.append ("RandomAccessCollection")
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
        
        var isContentRepresented: Bool? = nil
                
        p ("public \(kind == .isStruct ? "struct" : "final class") \(typeName)\(proto)") {
            if bc.name == "String" {
                p("""
                public required init(_ string: String) {
                    gi.string_new_with_utf8_chars(&content, string)
                }
                """)
                
                p("""
                // ExpressibleByStringLiteral conformance
                public required init(stringLiteral value: String) {
                    gi.string_new_with_utf8_chars(&content, value)
                }
                """)
            }
            if bc.name == "NodePath"  {
                p("""
                /// ExpressibleByStringLiteral conformance
                public required init(stringLiteral value: String) {
                    let gstring = GString(value)
                    withUnsafePointer(to: &gstring.content) { pContent in
                        withUnsafePointer(to: pContent) { pArgs in
                            \(typeGodotInterfaceName).constructor2(&content, pArgs)
                        }
                    }
                }
                """)
                
                p("""
                /// LosslessStringConvertible conformance
                public required init(_ value: String) {
                    let gstring = GString(value)
                    withUnsafePointer(to: &gstring.content) { pContent in
                        withUnsafePointer(to: pContent) { pArgs in
                            \(typeGodotInterfaceName).constructor2(&content, pArgs)
                        }
                    }
                }
                """)
                
                p ("/// Produces a string representation of this NodePath")
                p ("public var description: String") {
                    p ("let sub = getSubnameCount () > 0 ? getConcatenatedSubnames ().description : \"\"")
                    p ("return (isAbsolute() ? \"/\" : \"\") + (getNameCount () > 0 ? getConcatenatedNames ().description : \"\") + (sub == \"\" ? sub : \":\\(sub)\")")
                }
            }
            if bc.name == "StringName" {
                // TODO: This is a little brittle, because I am
                // hardcoding the constructor1 here, it should
                // really produce this when it matches the kind
                // directly to be the one that takes a StringName
                // parameter
                p("""
                public init(fromPtr ptr: UnsafeRawPointer?) {
                    withUnsafePointer(to: ptr) { pArgs in
                        \(typeGodotInterfaceName).constructor1(&content, pArgs) 
                    }
                }
                """)
                
                p("""
                /// ExpressibleByStringLiteral conformace
                public required init(stringLiteral value: String) {
                    let gstring = GString(value)
                    withUnsafePointer(to: &gstring.content) { pContent in 
                        withUnsafePointer(to: pContent) { pArgs in
                            \(typeGodotInterfaceName).constructor2(&content, pArgs)
                        }
                    }
                }
                """)
                
                p("""
                /// LosslessStringConvertible conformance 
                public required init(_ value: String) {
                    let gstring = GString(value)
                    withUnsafePointer(to: &gstring.content) { pContent in
                        withUnsafePointer(to: pContent) { pArgs in
                            \(typeGodotInterfaceName).constructor2(&content, pArgs)
                        }
                    }
                }
                """)
            }
            if bc.name == "Callable" {
                p ("/// Creates a Callable instance from a Swift function")
                p ("/// - Parameter callback: the swift function that receives `Arguments`, and returns a `Variant`")
                p ("public init(_ callback: @escaping (borrowing Arguments) -> Variant?)") {
                    p ("content = CallableWrapper.callableVariantContent(wrapping: callback)")
                }

#if false 
                p ("/// Creates a Callable instance from a Swift function")
                p ("/// - Parameter callback: the swift function that receives an array of Variant arguments, and returns an optional Variant")
                p("""
                @available(*, deprecated, message: "Use `init(_ callback: @escaping (borrowing Arguments) -> Variant)` instead.")
                """)
                p ("public init (_ callback: @escaping ([Variant])->Variant?)") {
                    p ("content = CallableWrapper.callableVariantContent(wrapping: callback)")
                }
#endif
            }
            if bc.hasDestructor {
                gip("// MARK: - Destructor")
                gip.staticProperty(isStored: true, name: "destructor", type: "GDExtensionPtrDestructor") {
                    gip("return gi.variant_get_ptr_destructor(\(typeEnum))!")
                }
                
                p("deinit"){
                    p("if content != \(typeName).zero") {
                        p("\(typeGodotInterfaceName).destructor(&content)")
                    }
                }
            }
            if bc.name.hasPrefix("Packed") && bc.name.hasSuffix("Array") {
                p ("/// The number of elements in the array")
                p ("public var count: Int { Int (size()) }")
            }
            if kind == .isClass {
                let (storage, initialize) = getBuiltinStorage(bc.name, asComputedProperty: true)
                p("""
                // Contains a binary blob where this type information is stored
                public var content: ContentType = \(typeName).zero
                
                // Used to initialize empty types
                public static var zero: ContentType\(initialize)
                // Convenience type that matches the build configuration storage needs
                public typealias ContentType = \(storage)
                """)

                builtinClassStorage [bc.name] = storage
                // TODO: This is a little brittle, because I am
                // hardcoding the constructor1 here, it should
                // really produce this when it matches the kind
                // directly to be the one that takes the same
                // parameter                
                p("""
                // Used to construct objects on virtual proxies
                public required init(content proxyContent: ContentType) {
                    withUnsafePointer(to: proxyContent) { pContent in
                        withUnsafePointer(to: pContent) { pArgs in
                            \(typeGodotInterfaceName).constructor1(&content, pArgs)
                        }
                    }
                }
                """)
                
                p("""
                /// Initialize with existing `ContentType` assuming this ``\(typeName)`` owns it since now.
                init(takingOver content: ContentType)
                """) {
                    p("self.content = content")
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
            let storedMembers: [JGodotArgumentType]?
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
            
            generateBuiltinConstants(p, bc, typeName: typeName)
            
            gip("// MARK: - Constructors")
            generateBuiltinCtors(p, gip, bc, bc.constructors, godotTypeName: bc.name, typeName: typeName, typeGodotInterfaceName: typeGodotInterfaceName, typeEnum: typeEnum, members: storedMembers)
            gip("// MARK: - Methods")
            generateBuiltinMethods(p, gip, bc, bc.methods ?? [], typeName, typeGodotInterfaceName, typeEnum, isStruct: kind == .isStruct)
            gip("// MARK: - Operators")
            generateBuiltinOperators(p, gip, bc, typeName: typeName, typeGodotInterfaceName: typeGodotInterfaceName)
                                                
            isContentRepresented = storedMembers == nil
            
            gip("// MARK: - Variant conversion")
            gip.staticProperty(isStored: true, name: "variantFromSelf", type: "GDExtensionVariantFromTypeConstructorFunc") {
                gip("gi.get_variant_from_type_constructor(\(typeEnum))!")
            }
            
            gip.staticProperty(isStored: true, name: "selfFromVariant", type: "GDExtensionTypeFromVariantConstructorFunc") {
                gip("gi.get_variant_to_type_constructor(\(typeEnum))!")
            }
            
            if kind == .isClass && conformances.contains("Hashable") {
                p("""
                public func hash(into hasher: inout Hasher) {
                    hasher.combine(hash())
                }
                """)
            }
                                                
            p("""
            /// Wrap ``\(typeName)`` into a ``Variant``
            @inline(__always)
            @inlinable
            public func toVariant() -> Variant {
                Variant(self)
            }
            
            /// Wrap ``\(typeName)`` into a ``Variant?``
            @inline(__always)
            @inlinable
            @_disfavoredOverload
            public func toVariant() -> Variant? {
                Variant(self)
            }
            
            /// Wrap ``\(typeName)`` into a ``FastVariant``
            @inline(__always)
            @inlinable
            public func toFastVariant() -> FastVariant {
                FastVariant(self)
            }
            
            /// Wrap ``\(typeName)`` into a ``FastVariant?``
            @inline(__always)
            @inlinable
            @_disfavoredOverload
            public func toFastVariant() -> FastVariant? {
                FastVariant(self)
            }
            
            /// Extract ``\(typeName)`` from a ``Variant``. Throws `VariantConversionError` if it's not possible.
            @inline(__always)
            @inlinable
            public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {                
                guard let value = Self(variant) else {
                    throw .unexpectedContent(parsing: self, from: variant)
                }
                return value                
            }
            
            @inline(__always)
            @inlinable
            public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {                
                guard let value = Self(variant) else {
                    throw .unexpectedContent(parsing: self, from: variant)
                }
                return value                
            }
            
            """)
            
            if isContentRepresented == true {
                p("""
                /// Initialze ``\(typeName)`` from ``Variant``. Fails if `variant` doesn't contain ``\(typeName)``
                @inline(__always)                                
                public convenience init?(_ variant: Variant) {
                    guard Self._variantType == variant.gtype else { return nil }
                    var content = \(typeName).zero
                    withUnsafeMutablePointer(to: &content) { pPayload in
                        variant.constructType(into: pPayload, constructor: \(typeGodotInterfaceName).selfFromVariant)                        
                    }
                    self.init(takingOver: content)
                }
                
                /// Initialze ``\(typeName)`` from ``Variant``. Fails if `variant` doesn't contain ``\(typeName)`` or is `nil`
                @inline(__always)
                @inlinable
                public convenience init?(_ variant: Variant?) {
                    guard let variant else { return nil }
                    self.init(variant)
                }
                
                /// Initialze ``\(typeName)`` from ``FastVariant``. Fails if `variant` doesn't contain ``\(typeName)``
                @inline(__always)                                
                public convenience init?(_ variant: borrowing FastVariant) {
                    guard Self._variantType == variant.gtype else { return nil }
                    var content = \(typeName).zero
                    withUnsafeMutablePointer(to: &content) { pPayload in
                        variant.constructType(into: pPayload, constructor: \(typeGodotInterfaceName).selfFromVariant)                        
                    }
                    self.init(takingOver: content)
                }
                
                /// Initialze ``\(typeName)`` from ``FastVariant``. Fails if `variant` doesn't contain ``\(typeName)`` or is `nil`
                @inline(__always)
                @inlinable
                public convenience init?(_ variant: borrowing FastVariant?) {                    
                    switch variant {
                    case .some(let variant):
                        self.init(variant)
                    case .none:
                        return nil
                    }
                }
                """)
            } else {
                p("""
                /// Initialze ``\(typeName)`` from ``Variant``. Fails if `variant` doesn't contain ``\(typeName)``
                @inline(__always)                
                public init?(_ variant: Variant) {
                    guard Self._variantType == variant.gtype else { return nil }
                    self.init()
                    
                    withUnsafeMutablePointer(to: &self) { pPayload in
                        variant.constructType(into: pPayload, constructor: \(typeGodotInterfaceName).selfFromVariant)                        
                    }
                }
                
                /// Initialze ``\(typeName)`` from ``Variant``. Fails if `variant` doesn't contain ``\(typeName)`` or is `nil`
                @inline(__always)
                @inlinable
                public init?(_ variant: Variant?) {
                    guard let variant else { return nil }
                    self.init(variant)
                }
                
                /// Initialze ``\(typeName)`` from ``FastVariant``. Fails if `variant` doesn't contain ``\(typeName)``
                @inline(__always)                
                public init?(_ variant: borrowing FastVariant) {
                    guard Self._variantType == variant.gtype else { return nil }
                    self.init()
                    
                    withUnsafeMutablePointer(to: &self) { pPayload in
                        variant.constructType(into: pPayload, constructor: \(typeGodotInterfaceName).selfFromVariant)                        
                    }
                }
                
                /// Initialze ``\(typeName)`` from ``FastVariant``. Fails if `variant` doesn't contain ``\(typeName)`` or is `nil`
                @inline(__always)
                @inlinable
                public init?(_ variant: borrowing FastVariant?) {
                    switch variant {
                    case .some(let variant):
                        self.init(variant)
                    case .none:
                        return nil
                    }
                }
                
                """)
            }
                        
            let propInfoPropertyType: String
            switch bc.name {
            case "Transform2D":
                propInfoPropertyType = ".transform2d"
            case "Transform3D":
                propInfoPropertyType = ".transform3d"
            default:
                let isAbbrev = bc.name.allSatisfy { $0.isUppercase }
                if isAbbrev {
                    propInfoPropertyType = ".\(bc.name.lowercased())"
                } else {
                    propInfoPropertyType = ".\((bc.name.first?.lowercased() ?? "") + bc.name.dropFirst())"
                }
            }
            
            p("""
            /// Internal API. For indicating that Godot `Array` of ``\(typeName)`` has type `Array[\(bc.name)]`
            @inline(__always)
            @inlinable
            public static var _variantType: Variant.GType {
                \(propInfoPropertyType) 
            }
            """)
            
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
            if bc.name.hasSuffix ("Array") {
                p ("public var startIndex: Int") {
                    p ("0")
                }
                p ("public var endIndex: Int") {
                    p ("Int (size ())")
                }

                p ("public func index(after i: Int) -> Int") {
                    p ("i+1")
                }

                p ("public func index(before i: Int) -> Int") {
                    p ("return i-1")
                }
            }
        }
        
        if let isContentRepresented {
            p("public extension Variant") {
                p("""
                /// Initialize ``Variant`` by wrapping ``\(typeName)?``, fails if it's `nil`
                @inline(__always)
                @inlinable
                convenience init?(_ from: \(typeName)?) {
                    guard let from else {
                        return nil
                    }
                    self.init(from)
                }
                
                /// Initialize ``Variant`` by wrapping ``\(typeName)``
                @inline(__always)
                convenience init(_ from: \(typeName))
                """) {
                    if isContentRepresented {
                        p("""
                        self.init(payload: from.content, constructor: \(typeGodotInterfaceName).variantFromSelf)
                        """)
                    } else {
                        p("""
                        self.init(payload: from, constructor: \(typeGodotInterfaceName).variantFromSelf)
                        """)
                    }
                }
            }
            
            p("public extension FastVariant") {
                p("""
                /// Initialize ``FastVariant`` by wrapping ``\(typeName)?``, fails if it's `nil`
                @inline(__always)
                @inlinable
                init?(_ from: \(typeName)?) {
                    guard let from else {
                        return nil
                    }
                    self.init(from)
                }
                
                /// Initialize ``FastVariant`` by wrapping ``\(typeName)``
                @inline(__always)
                init(_ from: \(typeName))
                """) {
                    if isContentRepresented {
                        p("""
                        self.init(payload: from.content, constructor: \(typeGodotInterfaceName).variantFromSelf)
                        """)
                    } else {
                        p("""
                        self.init(payload: from, constructor: \(typeGodotInterfaceName).variantFromSelf)
                        """)
                    }
                }
            }
            
            p("""
            /// Static storage for keeping pointers to Godot implementation wrapped by \(typeName)
            enum \(typeGodotInterfaceName)
            """) {
                p(gip.result)
            }
        }
    }
    
    for bc in filteredValues {
        switch bc.name {
            // This one is ignored altogether. We've got `Optional` in Swift
        case "Nil":
            break
            // We do not generate code for a few types, we will bridge those instead
        case "int", "float", "bool":
            break
        default:
            // printer for class itself
            let p: Printer = await PrinterFactory.shared.initPrinter(bc.name, withPreamble: true)
                        
            mapStringToSwift = bc.name != "String"
            generateBuiltinClass(p: p, bc)
            mapStringToSwift = true
            if let outputDir {
                p.save(outputDir + "/\(bc.name).swift")
            }
        }
    }
}

// MARK: - Custom operators impl
private let customBuiltinOperatorImplementations: [OperatorSignature: String] = [
    // MARK: Vector3
    "Vector3 * Vector3": """
    return Vector3(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
    """,
    
    "Vector3 / Vector3": """
    return Vector3(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
    """,
    
    "Vector3 + Vector3": """
    return Vector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    """,
    
    "Vector3 - Vector3": """
    return Vector3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    """,
        
    "Vector3 * Double": """
    let rhs = Float(rhs)
    return Vector3(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    """,
    
    "Vector3 / Double": """
    let rhs = Float(rhs)
    return Vector3(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    """,
]

// MARK: - Custom methods impl
private let customBuiltinMethodImplementations: [MethodSignature: String] = [
    // MARK: Vector3
    "Vector3.dot": """
    // https://github.com/godotengine/godot/blob/f7c567e2f56d6e63f4749387a67e5ea4903c4696/core/math/vector3.h#L206-L208
    return Double(x * with.x + y * with.y + z * with.z)        
    """,
    
    "Vector3.cross": """
    // https://github.com/godotengine/godot/blob/f7c567e2f56d6e63f4749387a67e5ea4903c4696/core/math/vector3.h#L197-L204
    return Vector3(
        x: (y * with.z) - (z * with.y),
        y: (z * with.x) - (x * with.z),
        z: (x * with.y) - (y * with.x)
    )
    """,
    
    "Vector3.length": """
    // https://github.com/godotengine/godot/blob/f7c567e2f56d6e63f4749387a67e5ea4903c4696/core/math/vector3.h#L476-L481
    return sqrt(Double(x * x + y * y + z * z))   
    """,
    
    "Vector3.lengthSquared": """
    // https://github.com/godotengine/godot/blob/f7c567e2f56d6e63f4749387a67e5ea4903c4696/core/math/vector3.h#L484-L489
    return Double(x * x + y * y + z * z)
    """,
    
    "Vector3.distance": """
    // https://github.com/godotengine/godot/blob/f7c567e2f56d6e63f4749387a67e5ea4903c4696/core/math/vector3.h#L292-L295
    return Double((to - self).length())
    """,
]
