//
//  MethodGen.swift
//  Generator
//
//  Created by Miguel de Icaza on 5/15/23.
//

import Foundation
import ExtensionApi

extension String {
    func indented(by indentation: Int) -> String {
        let indentationString = String(repeating: "    ", count: indentation)
        let lines = split(separator: "\n", omittingEmptySubsequences: false)
        return lines
            .map {
                "\(indentationString)\($0)"
            }
            .joined(separator: "\n")
    }
}

enum MarshaledArgumentsCount {
    case literal(Int)
    case expression(String)
}

enum GeneratedMethodKind {
    case classMethod
    case utilityFunction
}

// To test the design, will use an external file later
// determines whether the className/method returns an optional reference type
func isReturnOptional (className: String, method: String) -> Bool {
    switch className {
    case "RenderingServer":
        switch method {
        case "get_rendering_device":
            return false
        default:
            return true
        }
    default:
        return true
    }
}

// To test the design, will use an external file later
// determines whether the className/method/argument is an optional reference type
func isMethodArgumentOptional (className: String, method: String, arg: String) -> Bool {
    switch className {
    case "Node":
        switch method {
        case "_input":
            switch arg {
            case "event":
                return false
            default:
                return true
            }
        default:
            return true
        }
    case "Image":
        switch method {
        case "blit_rect":
            switch arg {
            case "src":
                return false
            default:
                return true
            }
        default:
            return true
        }
    default:
        return true
    }
}

protocol NonCriticalError: Error {
    var explanation: String { get }
}

@discardableResult
func performExplaniningNonCriticalErrors<T>(_ body: () throws -> T) -> T? {
    do {
        return try body()
    } catch let error as NonCriticalError {
        print(error.explanation)
        return nil
    } catch {
        fatalError(error.localizedDescription)
    }
}

enum MethodGenError: NonCriticalError {
    case unsupportedArgument(typeName: String, methodName: String, argumentName: String, argumentTypeName: String, reason: String)
    
    var explanation: String {
        switch self {
        case let .unsupportedArgument(typeName, methodName, argumentName, argumentTypeName, reason):
            return """
            Skipping \(typeName).\(methodName)
                Reason - \(reason)
                    \(argumentName): \(argumentTypeName)
            
            """
        }
    }
}

/// Parsed `JGodotArgument` that derives what's the proper strategy for processing the argument and marshaling it
struct MethodArgument {
    enum Translation {
        /// e.g. Float, Vector3
        case direct
        
        /// e.g. Godot Variant to Swift Variant?
        case variant
        
        /// e.g. VariantArray.content
        case contentRef
        
        /// e.g. Object.pNativeObject
        case objectRef(isOptional: Bool)
        
        /// e.g. TypedArray<Object>, TypedArray<Float>
        case typedArray(String)
        
        /// Implicit GString -> String
        case string
        
        /// Implicit Float -> Double, Implict small Int -> Int
        case directPromoted(to: String)
    
        /// enums and bitfields
        case rawValue
        
        /// C pointers, need special treatment in future
        case cPointer
    }
    
    struct TranslationOptions: OptionSet {
        let rawValue: UInt64
        
        static let floatToDouble = Self(rawValue: 1 << 0)
        static let gStringToString = Self(rawValue: 1 << 1)
        static let nonOptionalObjects = Self(rawValue: 1 << 2)
        
        // TODO: looks like this is dead code when it comes to current API? (isSmallInt seems redundant)
        static let smallIntToInt = Self(rawValue: 1 << 3)
        
        static var builtInClassOptions: Self {
            var result: Self = [.floatToDouble, nonOptionalObjects, .smallIntToInt]
            
            if mapStringToSwift {
                result.insert(.gStringToString)
            }
            
            return result
        }
        
        static var classOptions: Self {
            var result: Self = [.smallIntToInt]
            
            if mapStringToSwift {
                result.insert(.gStringToString)
            }
            
            return result
        }
    }
    
    let name: String
    let translation: Translation
    
    init(from src: JGodotArgument, typeName: String, methodName: String, options: TranslationOptions) throws {
        func makeError(reason: String) -> MethodGenError {
            MethodGenError.unsupportedArgument(typeName: typeName, methodName: methodName, argumentName: src.name, argumentTypeName: src.type, reason: reason)
        }
        
        self.name = godotArgumentToSwift(src.name)

        // Splits a string that might contain '::' into either two, or a single element
        func typeSplit (_ type: String) -> [String.SubSequence] {
            if let r = type.range(of: "::") {
                return [
                    type[type.startIndex..<r.lowerBound],
                    type[r.upperBound...]
                ]
            } else {
                return [type [type.startIndex...]]
            }
        }
        if src.type.contains("*") {
            translation = .cPointer
        } else {
            let tokens = typeSplit (src.type)
            
            switch tokens.count {
            case 1:
                if src.type == "Variant" {
                    translation = .variant
                } else if options.contains(.gStringToString) && src.type == "String" {
                    translation = .string
                } else if options.contains(.floatToDouble) && src.type == "float" {
                    translation = .directPromoted(to: "Double")
                } else if options.contains(.smallIntToInt) && isSmallInt(src) {
                    translation = .directPromoted(to: "Int")
                } else {
                    if isStruct(src.type) {
                        translation = .direct
                    } else {
                        if builtinSizes[src.type] != nil && src.type != "Object" {
                            translation = .contentRef
                        } else if classMap[src.type] != nil {                            
                            if options.contains(.nonOptionalObjects) {
                                translation = .objectRef(isOptional: false)
                            } else {
                                translation = .objectRef(
                                    isOptional: isMethodArgumentOptional(
                                        className: typeName,
                                        method: methodName,
                                        arg: src.name
                                    )
                                )
                            }
                        } else {
                            throw makeError(reason: "Unknown type")
                        }
                    }
                }
            case 2:
                let prefix = tokens[0]
                let name = tokens[1]
                
                switch prefix {
                case "bitfield":
                    translation = .rawValue
                case "enum":
                    translation = .rawValue
                case "typedarray":
                    translation = .typedArray(String(name))
                default:
                    throw makeError(reason: "Unknown prefix '\(prefix)'")
                }
            default:
                throw makeError(reason: "Too many tokens separated by '::'")
            }
        }
    }
}

func preparingArguments(_ p: Printer, arguments: [MethodArgument], body: () -> Void) {
    func withNestedUnsafe(index: Int) {
        if index >= arguments.count {
            body()
        } else {
            let argument = arguments[index]
            let accessor: String
            
            switch argument.translation {
            case .variant:
                accessor = "\(argument.name).content"
            case .contentRef:
                accessor = "\(argument.name).content"
            case .string:
                p("let \(argument.name) = GString(\(argument.name))")
                accessor = "\(argument.name).content"
            case .direct:
                accessor = argument.name
            case .objectRef(let isOptional):
                if isOptional {
                    accessor = "\(argument.name)?.pNativeObject"
                } else {
                    accessor = "\(argument.name).pNativeObject"
                }
            case .rawValue:
                accessor = "\(argument.name).rawValue"
            case .typedArray:
                accessor = "\(argument.name).array.content"
            case .cPointer:
                accessor = "\(argument.name)"
            case .directPromoted(let promotedType):
                p("let \(argument.name) = \(promotedType)(\(argument.name))")
                accessor = argument.name
            }
            
            p("withUnsafePointer(to: \(accessor))", arg: " pArg\(index) in") {
                withNestedUnsafe(index: index + 1)
            }
        }
    }
    
    withNestedUnsafe(index: 0)
}

func preparingMandatoryVariadicArguments(_ p: Printer, arguments: [JGodotArgument], body: () -> Void) {
    func withNestedUnsafe(index: Int = 0) {
        if index >= arguments.count {
            body()
        } else {
            let argument = arguments[index]
            let argumentName = godotArgumentToSwift(argument.name)
                        
            if argument.type != "Variant" {
                p("let \(argumentName) = \(argumentName).toVariant()")
            }
            
            p("withUnsafePointer(to: \(argumentName).content)", arg: " pArg\(index) in") {
                withNestedUnsafe(index: index + 1)
            }
        }
    }
    
    withNestedUnsafe()
}

typealias CallArgsRef = String

func generateMethodCall(_ p: Printer, isVariadic: Bool, arguments: [JGodotArgument], methodArguments: [MethodArgument], call: (CallArgsRef, MarshaledArgumentsCount) -> String) {
    if !isVariadic {
        if methodArguments.isEmpty {
            p(call("nil", .literal(0)))
        } else {
            preparingArguments(p, arguments: methodArguments) {
                aggregatingPreparedArguments(p, argumentsCount: methodArguments.count) {
                    p(call("pArgs", .literal(methodArguments.count)))
                }
            }
        }
    } else {
        if methodArguments.isEmpty {
            // Right now there is only a single function that is variadic and doesn't have mandatory arguments
            p("""
            if arguments.isEmpty {
                \(call("nil", .literal(0))) // no arguments
            } else {
                // A temporary allocation containing pointers to `Variant.ContentType` of marshaled arguments
                withUnsafeTemporaryAllocation(of: UnsafeRawPointer?.self, capacity: arguments.count) { pArgsBuffer in
                    // We use entire buffer so can initialize every element in the end. It's not
                    // necessary for UnsafeRawPointer and other POD types (which Variant.ContentType also is)
                    // but we'll do it for the sake of correctness
                    defer { pArgsBuffer.deinitialize() }
                    guard let pArgs = pArgsBuffer.baseAddress else {
                        fatalError("pargsBuffer.baseAddress is nil")
                    }
                    // A temporary allocation containing `Variant.ContentType` of marshaled arguments
                    withUnsafeTemporaryAllocation(of: Variant.ContentType.self, capacity: arguments.count) { contentsBuffer in
                        defer { contentsBuffer.deinitialize() }
                        guard let contentsPtr = contentsBuffer.baseAddress else {
                            fatalError("contentsBuffer.baseAddress is nil")
                        }

                        for i in 0..<arguments.count {
                            // Copy `content`s of the variadic `Variant`s into `contentBuffer`
                            contentsBuffer.initializeElement(at: i, to: arguments[i].content)
                            // Initialize `pArgs` elements following mandatory arguments to point at respective contents of `contentsBuffer`
                            pArgsBuffer.initializeElement(at: i, to: contentsPtr + i)
                        }

                        \(call("pArgs", .expression("arguments.count")))
                    }
                }
            }
            """)
        } else {
            preparingMandatoryVariadicArguments(p, arguments: arguments) {
                p.if(
                "arguments.isEmpty",
                then: {
                    aggregatingPreparedArguments(p, argumentsCount: arguments.count) {
                        p(call("pArgs", .literal(arguments.count)))
                    }
                },
                else: {
                    p("// A temporary allocation containing pointers to `Variant.ContentType` of marshaled arguments")
                    p("withUnsafeTemporaryAllocation(of: UnsafeRawPointer?.self, capacity: \(methodArguments.count) + arguments.count)", arg: " pArgsBuffer in") {
                        p("""
                        defer { pArgsBuffer.deinitialize() }
                        guard let pArgs = pArgsBuffer.baseAddress else {
                            fatalError("pArgsBuffer.baseAddress is nil")
                        }
                        """)
                        for i in 0..<methodArguments.count {
                            p("pArgsBuffer.initializeElement(at: \(i), to: pArg\(i))")
                        }
                        
                        p("""
                        // A temporary allocation containing `Variant.ContentType` of marshaled arguments
                        withUnsafeTemporaryAllocation(of: Variant.ContentType.self, capacity: arguments.count) { contentsBuffer in
                            defer { contentsBuffer.deinitialize() }
                            guard let contentsPtr = contentsBuffer.baseAddress else {
                                fatalError("contentsBuffer.baseAddress is nil")
                            }
                            
                            for i in 0..<arguments.count {
                                // Copy `content`s of the variadic `Variant`s into `contentBuffer`
                                contentsBuffer.initializeElement(at: i, to: arguments[i].content)
                                // Initialize `pArgs` elements following mandatory arguments to point at respective contents of `contentsBuffer`                                        
                                pArgsBuffer.initializeElement(at: \(arguments.count) + i, to: contentsPtr + i)
                            }
                        
                            \(call("pArgs", .expression("\(arguments.count) + arguments.count")))
                        }                           
                        """)
                    }
                })
            }
        }
    }
}

func aggregatingPreparedArguments(_ p: Printer, argumentsCount: Int, body: () -> Void) {
    let argsList = (0..<argumentsCount)
        .map {
            "pArg\($0)"
        }.joined(separator: ", ")
    
    p("withUnsafePointer(to: UnsafeRawPointersN\(argumentsCount)(\(argsList)))", arg: " pArgs in") {
        p("pArgs.withMemoryRebound(to: UnsafeRawPointer?.self, capacity: \(argumentsCount))", arg: " pArgs in") {
            body()
        }
    }
}

/// The current code generation for passing parameters is both inefficient, and technically unsafe. We don't need
/// to use nested invocations of withUnsafePointer to generate pointers to multiple arguments, but we can instead generate
/// a helper version that generates multiple pointer in a single call. For example, if a function that we call using
/// `gi.object_method_bind_ptrcall()` takes 2 arguments, we can generate the following generic helper:
///
/// ```
/// func withUnsafePointers<T1, T2, ReturnType>(
///     _ p1: UnsafePointer<T1>, _ p2: UnsafePointer<T2>,
///     _ block: (UnsafePointer<T1>, UnsafePointer<T2>) -> ReturnType
/// ) -> ReturnType {
///     block(p1, p2)
/// }
/// ```
/// This reduces the complexity of the generated code, and can be extended to an arbitrary number of parameters.
///

/// Generates a method definition
/// - Parameters:
///  - p: Our printer to generate the method
///  - method: the definition to generate
///  - className: the name of the class where this is being generated
///  - usedMethods: a set of methods that have been referenced by properties, to determine whether we make this public or private
/// - Returns: nil, or the method we surfaced that needs to have the virtual supporting infrastructured wired up
func generateMethod(_ p: Printer, method: MethodDefinition, className: String, cdef: JClassInfo?, usedMethods: Set<String>, generatedMethodKind: GeneratedMethodKind, asSingleton: Bool) throws -> String? {
    
    let arguments = method.arguments ?? []
    
    
    let argumentTranslationOptions: MethodArgument.TranslationOptions
    
    if mapStringToSwift {
        argumentTranslationOptions = .gStringToString
    } else {
        argumentTranslationOptions = []
    }
    
    // TODO: move down
    let methodArguments = try arguments.map { argument in
        try MethodArgument(from: argument, typeName: className, methodName: method.name, options: argumentTranslationOptions)
    }
    
    var registerVirtualMethodName: String? = nil
    
    let containsUnsupportedCPointerTypes = arguments
        .filter { arg in arg.type.contains("*") }
        .contains { arg in
            switch arg.type {
            case "const void*", "AudioFrame*":
                // supported
                return false
            default:
                return true
            }
        }
    
    if containsUnsupportedCPointerTypes {
        // TODO
        // print("Skipping \(className).\(method.name), unsupported c pointer type")
        return nil
    }
    
    let bindName = "method_\(method.name)"
    var visibilityAttribute: String?
    let omitAllArgumentLabels: Bool
    let finalAttribute: String?
    // Default method name
    var swiftMethodName: String = godotMethodToSwift (method.name)
    let staticAttribute = method.isStatic || asSingleton ? "static" : nil
    let inlineAttribute: String?
    let documentationVisibilityAttribute: String?
    if let methodHash = method.optionalHash {
        // get_class and unreference are also called by Wrapped
        let staticVarVisibility = if bindName != "method_get_class" && bindName != "method_unreference" { "fileprivate" } else { "" }
        switch generatedMethodKind {
        case .classMethod:
            p.staticProperty(visibility: staticVarVisibility, isStored: true, name: bindName, type: "GDExtensionMethodBindPtr") {
                p ("var methodName = FastStringName(\"\(method.name)\")")
            
                p ("return withUnsafePointer(to: &\(className).godotClassName.content)", arg: " classPtr in") {
                    p ("withUnsafePointer(to: &methodName.content)", arg: " mnamePtr in") {
                        p ("gi.classdb_get_method_bind(classPtr, mnamePtr, \(methodHash))!")
                    }
                }
            }
        case .utilityFunction:
            p.staticProperty(visibility: staticVarVisibility, isStored: true, name: bindName, type: "GDExtensionPtrUtilityFunction") {
                p ("var methodName = FastStringName(\"\(method.name)\")")
                p ("return withUnsafePointer(to: &methodName.content)", arg: " ptr in") {
                    p ("return gi.variant_get_ptr_utility_function(ptr, \(methodHash))!")
                }
            }
        }
    }

    if !method.isVirtual {
        // If this is an internal, and being reference by a property, hide it
        if usedMethods.contains (method.name) {
            inlineAttribute = "@inline(__always)"
            // Try to hide as much as possible, but we know that Godot child nodes will want to use these
            // (DirectionalLight3D and Light3D) rely on this.
            visibilityAttribute = method.name == "get_param" || method.name == "set_param" ? nil : "fileprivate"
            omitAllArgumentLabels = true
            swiftMethodName = method.name
        } else {
            inlineAttribute = nil
            visibilityAttribute = "public"
            omitAllArgumentLabels = false
        }
        if staticAttribute == nil {
            finalAttribute = "final"
        } else {
            finalAttribute = nil
        }
        
        documentationVisibilityAttribute = nil
    } else {
        inlineAttribute = nil
        // virtual overwrittable method
        finalAttribute = nil
        documentationVisibilityAttribute = "@_documentation(visibility: public)"
        visibilityAttribute = "open"

        omitAllArgumentLabels = false
            
        registerVirtualMethodName = swiftMethodName
    }
    
    var signatureArgs: [String] = []
    let godotReturnType = method.returnValue?.type
    let godotReturnTypeIsReferenceType = classMap [godotReturnType ?? ""] != nil
    let returnOptional = godotReturnType == "Variant" || godotReturnTypeIsReferenceType && isReturnOptional(className: className, method: method.name)
    let returnType = getGodotType(method.returnValue) + (returnOptional ? "?" : "")

    /// returns appropriate declaration of the return type, used by the helper function.
    let frameworkType = godotReturnTypeIsReferenceType
    func returnTypeDecl() -> String {
        if returnType != "" {
            guard let godotReturnType else {
                fatalError ("If the returnType is not empty, we should have a godotReturnType")
            }
            if method.isVararg {
                if godotReturnType == "String" {
                    return "let _result = GString()"
                } else {
                    return "var _result: Variant.ContentType = Variant.zero"
                }
            } else if godotReturnType.starts(with: "typedarray::") {
                let (storage, initialize) = getBuiltinStorage ("Array", asComputedProperty: false)
                return "var _result: \(storage)\(initialize)"
            } else if godotReturnType == "String" {
                return "let _result = GString ()"
            } else {
                if godotReturnTypeIsReferenceType {                    
                    return "var _result = GDExtensionObjectPtr(bitPattern: 0)"
                } else {
                    if godotReturnType == "Variant" {
                        return "var _result: Variant.ContentType = Variant.zero"
                    } else if godotReturnType.starts(with: "enum::") {
                        return "var _result: Int64 = 0 // to avoid packed enums on the stack"
                    } else {
                        
                        var declType: String = "let"
                        if (argTypeNeedsCopy(godotType: godotReturnType)) {
                            if builtinGodotTypeNames [godotReturnType] != .isClass {
                                declType = "var"
                            }
                        }
                        if method.isVirtual {
                            declType = "var"
                        }
                        return "\(declType) _result: \(returnType) = \(makeDefaultInit(godotType: godotReturnType))"
                    }
                }
            }
        }
        return ""
    }
    
    func getCallResultArgument() -> String {
        let ptrResult: String
        if returnType != "" {
            guard let godotReturnType else { fatalError("godotReturnType is nil!") }
            
            if method.isVararg {
                if godotReturnType == "String" {
                    ptrResult = "&_result.content"
                } else {
                    ptrResult = "&_result"
                }
            } else if argTypeNeedsCopy(godotType: godotReturnType) {
                let isClass = builtinGodotTypeNames [godotReturnType] == .isClass
                
                ptrResult = isClass ? "&_result.content" : "&_result"
            } else {
                if godotReturnType == "Variant" {
                    ptrResult = "&_result"
                } else if godotReturnType.starts (with: "typedarray::") {
                    ptrResult = "&_result"
                } else if frameworkType {
                    ptrResult = "&_result"
                } else if builtinSizes [godotReturnType] != nil {
                    ptrResult = "&_result.content"
                } else {
                    if method.isVirtual {
                        ptrResult = "&_result"
                    } else {
                        ptrResult = "&_result.pNativeObject"
                    }
                }
            }
        } else {
            if method.isVararg {
                ptrResult = "&_result"
            } else {
                ptrResult = "nil"
            }
        }
        return ptrResult
    }
    
    func getReturnStatement() -> String {
        if returnType == "" {
            return ""
        }
        guard returnType != "" else { return "" }
        if method.isVararg {
            if returnType == "Variant?" {
                return "return Variant(takingOver: _result)"
            } else if returnType == "GodotError" {
                return """
                guard let variant = Variant(copying: _result) else {
                    return .ok
                }
                
                guard let errorCode = Int(variant) else {
                    return .ok
                }
                
                return GodotError(rawValue: Int64(errorCode))!                
                """
            } else if returnType == "String" {
                return "return _result.description"
            } else {
                fatalError("Do not support this return type = \(returnType)")
            }
        } else if returnType == "Variant?" {
            return "return Variant(takingOver: _result)"
        } else if frameworkType {
            //print ("OBJ RETURN: \(className) \(method.name)")
            return "guard let _result else { \(returnOptional ? "return nil" : "fatalError (\"Unexpected nil return from a method that should never return nil\")") } ; return getOrInitSwiftObject(boundTo: _result, ownsRef: true)\(returnOptional ? "" : "!")"
        } else if godotReturnType?.starts(with: "typedarray::") ?? false {
            let defaultInit = makeDefaultInit(godotType: godotReturnType!, initCollection: "takingOver: _result")
            return "return \(defaultInit)"
        } else if godotReturnType?.starts(with: "enum::") ?? false {
            return "return \(returnType) (rawValue: _result)!"
        } else if godotReturnType == "String" {
            return "return _result.description"
        } else {
            return "return _result"
        }
    }
    
    for (index, arg) in arguments.enumerated() {
        let isOptional: Bool
        
        if arg.type == "Variant" {
            isOptional = true
        } else {
            if classMap [arg.type] != nil {
                isOptional = isMethodArgumentOptional(className: className, method: method.name, arg: arg.name)
            } else {
                isOptional = false
            }
        }
        
        let omitLabel: Bool
        // Omit first argument label, if necessary
        if index == 0 && !omitAllArgumentLabels {
            omitLabel = shouldOmitFirstArgLabel(typeName: className, methodName: method.name, argName: arg.name)
        } else {
            omitLabel = omitAllArgumentLabels
        }
        
        signatureArgs.append(getArgumentDeclaration(arg, omitLabel: omitLabel, isOptional: isOptional))
    }
    
    if method.isVararg {
        signatureArgs.append("_ arguments: Variant?...")
    }
    
    if let inlineAttribute {
        p(inlineAttribute)
    }
    // Sadly, the parameters have no useful documentation
    doc(p, cdef, method.description)
    // Generate the method entry point
    if let classDiscardables = discardableResultList[className] {
        if classDiscardables.contains(method.name) == true {
            p("@discardableResult /* discardable per discardableList: \(className), \(method.name) */ ")
        }
    }
    
    if let documentationVisibilityAttribute {
        p(documentationVisibilityAttribute)
    }
    
    let declarationTokens = [
        visibilityAttribute,
        staticAttribute,
        finalAttribute,
        "func",
        swiftMethodName
    ]
        .compactMap { $0 }
        .joined(separator: " ")
    
    let argumentsList = signatureArgs.joined(separator: ", ")
    
    let returnClause: String
    if returnType.isEmpty {
        returnClause = ""
    } else {
        returnClause = " -> \(returnType)"
    }
    
    p ("\(declarationTokens)(\(argumentsList))\(returnClause)") {
        if staticAttribute == nil {
            p("assertValidity()")
        }
        if method.optionalHash == nil {
            if let godotReturnType {
                p(makeDefaultReturn(godotType: godotReturnType))
            }
        } else {
            if returnType != "" {
                p(returnTypeDecl())
            } else if (method.isVararg) {
                p("var _result: Variant.ContentType = Variant.zero")
            }
            
            let instanceArg: String
            if method.isStatic {
                instanceArg = "nil"
            } else {                
                if asSingleton {
                    instanceArg = "shared.pNativeObject"
                } else {
                    instanceArg = "pNativeObject"
                }
            }
            
            func getMethodNameArgument() -> String {
                assert(generatedMethodKind == .classMethod)
                
                if staticAttribute == nil {
                    return "\(className).method_\(method.name)"
                } else {
                    return "method_\(method.name)"
                }
            }
            
            generateMethodCall(p, isVariadic: method.isVararg, arguments: arguments, methodArguments: methodArguments) { argsRef, count in
                if method.isVararg {
                    switch generatedMethodKind {
                    case .classMethod:
                        let countArg: String
                        
                        switch count {
                        case .literal(let literal):
                            countArg = "\(literal)"
                        case .expression(let expr):
                            countArg = "Int64(\(expr))"
                        }
                        
                        let argsList = [
                            getMethodNameArgument(),
                            instanceArg,
                            argsRef,
                            countArg,
                            getCallResultArgument(),
                            "nil"
                        ].joined(separator: ", ")
                        
                        return "gi.object_method_bind_call(\(argsList))"
                    case .utilityFunction:
                        let countArg: String
                        
                        switch count {
                        case .literal(let literal):
                            countArg = "\(literal)"
                        case .expression(let expr):
                            countArg = "Int32(\(expr))"
                        }
                        
                        let argsList = [
                            getCallResultArgument(),
                            argsRef,
                            countArg
                        ].joined(separator: ", ")
                        
                        return "method_\(method.name)(\(argsList))"
                    }
                } else {
                    switch generatedMethodKind {
                    case .classMethod:
                        guard case .literal = count else {
                            fatalError("Literal is expected")
                        }
                        
                        let argsList = [
                            getMethodNameArgument(),
                            instanceArg,
                            argsRef,
                            getCallResultArgument()
                        ].joined(separator: ", ")
                        
                        return "gi.object_method_bind_ptrcall(\(argsList))"
                    case .utilityFunction:
                        guard case let .literal(count) = count else {
                            fatalError("Literal is expected")
                        }
                        
                        let argsList = [
                            getCallResultArgument(),
                            argsRef,
                            "\(count)" // just a literal, no need to convert to Int32
                        ].joined(separator: ", ")
                        
                        return "method_\(method.name)(\(argsList))"
                    }
                }
            }
            
            p(getReturnStatement())
        }
    }
    return registerVirtualMethodName
}
