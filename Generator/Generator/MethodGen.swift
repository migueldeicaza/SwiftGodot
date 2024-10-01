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

struct MethodArgument {
    enum Translation {
        /// e.g. Float, Vector3
        case direct
        
        /// e.g. GArray.content
        case contentRef
        
        /// e.g. Object.handle
        case objectRef(isOptional: Bool)
        
        /// e.g. ObjectCollection<Object>, VariantCollection<Float>
        case typedArray(String)
        
        /// Implicit GString -> String
        case string
        
        /// Implicit Float -> Double
        case double
        
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
        
        static var builtInClassOptions: Self {
            var result: Self = [.floatToDouble, nonOptionalObjects]
            
            if mapStringToSwift {
                result.insert(.gStringToString)
            }
            
            return result
        }
        
        static var classOptions: Self {
            var result: Self = []
            
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
        
        if src.type.contains("*") {
            translation = .cPointer
        } else {
            let tokens = src.type.split(separator: "::")
            
            switch tokens.count {
            case 1:
                if options.contains(.gStringToString) && src.type == "String" {
                    translation = .string
                } else if options.contains(.floatToDouble) && src.type == "float" {
                    translation = .double
                } else {
                    if isStructMap[src.type] == true {
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
            case .contentRef:
                accessor = "\(argument.name).content"
            case .string:
                p("let \(argument.name) = GString(\(argument.name))")
                accessor = "\(argument.name).content"
            case .direct:
                accessor = argument.name
            case .objectRef(let isOptional):
                if isOptional {
                    accessor = "\(argument.name)?.handle"
                } else {
                    accessor = "\(argument.name).handle"
                }
            case .rawValue:
                accessor = "\(argument.name).rawValue"
            case .typedArray:
                accessor = "\(argument.name).array.content"
            case .cPointer:
                accessor = "\(argument.name)"
            case .double:
                p("let \(argument.name) = Double(\(argument.name))")
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
                p("let \(argumentName) = Variant(\(argumentName))")
            }
            
            p("withUnsafePointer(to: &\(argumentName).content)", arg: " pArg\(index) in") {
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
                    if arguments.isEmpty {
                        \(call("pArgs", .literal(arguments.count))) // no variadic arguments, just mandatory
                    } else {
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
                    }                            
                    """)
                }
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

struct MethodReturnValue {
    enum Translation {
        case variant
    }
    
    let translation: Translation
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
        print("Skipping \(className).\(method.name), unsupported c pointer type")
        return nil
    }
    
    let bindName = "method_\(method.name)"
    var visibilityAttribute: String
    var defaultArgumentLabel: String
    var finalAttribute: String
    // Default method name
    var swiftMethodName: String = godotMethodToSwift (method.name)
    let staticAttribute = method.isStatic || asSingleton ? " static" : ""
    var inlineAttribute = ""
    if let methodHash = method.optionalHash {
        let staticVarVisibility = if bindName != "method_get_class" { "fileprivate " } else { "" }
        assert (!method.isVirtual)
        switch generatedMethodKind {
        case .classMethod:
            p.staticVar(visibility: staticVarVisibility, name: bindName, type: "GDExtensionMethodBindPtr") {
                p ("let methodName = StringName (\"\(method.name)\")")
            
                p ("return withUnsafePointer (to: &\(className).godotClassName.content)", arg: " classPtr in") {
                    p ("withUnsafePointer (to: &methodName.content)", arg: " mnamePtr in") {
                        p ("gi.classdb_get_method_bind (classPtr, mnamePtr, \(methodHash))!")
                    }
                }
            }
        case .utilityFunction:
            p.staticVar(visibility: staticVarVisibility, name: bindName, type: "GDExtensionPtrUtilityFunction") {
                p ("let methodName = StringName (\"\(method.name)\")")
                p ("return withUnsafePointer (to: &methodName.content)", arg: " ptr in") {
                    p ("return gi.variant_get_ptr_utility_function (ptr, \(methodHash))!")
                }
            }
        }
        
        // If this is an internal, and being reference by a property, hide it
        if usedMethods.contains (method.name) {
            inlineAttribute = "@inline(__always)"
            // Try to hide as much as possible, but we know that Godot child nodes will want to use these
            // (DirectionalLight3D and Light3D) rely on this.
            visibilityAttribute = method.name == "get_param" || method.name == "set_param" ? "internal" : "fileprivate"
            defaultArgumentLabel = "_ "
            swiftMethodName = method.name
        } else {
            visibilityAttribute = "public"
            defaultArgumentLabel = ""
        }
        if staticAttribute == "" {
            finalAttribute = "final "
        } else {
            finalAttribute = ""
        }
    } else {
        assert (method.isVirtual)
        // virtual overwrittable method
        finalAttribute = ""
        visibilityAttribute = "@_documentation(visibility: public)\nopen"
        defaultArgumentLabel = ""
            
        registerVirtualMethodName = swiftMethodName
    }
    
    struct Builder {
        var setup = ""      // all variable copies and _result go here
        var args: [String] = []
        var call = ""       // call to helper goes here.
        var result = ""     // return of _result goes here.
    }
    var builder = Builder()
    
    var args = ""
    var argSetup = ""
    var varArgSetup = ""
    var varArgSetupInit = ""
    if method.isVararg {
        varArgSetupInit = "\nlet content = UnsafeMutableBufferPointer<Variant.ContentType>.allocate(capacity: arguments.count)\n" +
        "defer { content.deallocate () }\n"
    
        varArgSetup += "for idx in 0..<arguments.count {\n"
        varArgSetup += "    content [idx] = arguments [idx].content\n"
        varArgSetup += "    _args.append (content.baseAddress! + idx)\n"
        varArgSetup += "}\n"
    }
    let godotReturnType = method.returnValue?.type
    let godotReturnTypeIsReferenceType = classMap [godotReturnType ?? ""] != nil
    let returnOptional = godotReturnTypeIsReferenceType && isReturnOptional(className: className, method: method.name)
    let returnType = getGodotType (method.returnValue) + (returnOptional ? "?" : "")

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
                let (storage, initialize) = getBuiltinStorage ("Array")
                return "var _result: \(storage)\(initialize)"
            } else if godotReturnType == "String" {
                return "let _result = GString ()"
            } else {
                if godotReturnTypeIsReferenceType {
                    // frameworkType = true
                    return "var _result = UnsafeRawPointer (bitPattern: 0)"
                } else {
                    if godotReturnType.starts(with: "enum::") {
                        return "var _result: Int64 = 0 // to avoid packed enums on the stack"
                    } else {
                        
                        var declType: String = "let"
                        if (argTypeNeedsCopy(godotType: godotReturnType)) {
                            if builtinGodotTypeNames [godotReturnType] != .isClass {
                                declType = "var"
                            }
                        }
                        return "\(declType) _result: \(returnType) = \(makeDefaultInit(godotType: godotReturnType))"
                    }
                }
            }
        }
        return ""
    }
    
    func getArgsPtr() -> String {
        (args != "") ? "&_args" : "nil"
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
                if godotReturnType.starts (with: "typedarray::") {
                    ptrResult = "&_result"
                } else if frameworkType {
                    ptrResult = "&_result"
                } else if builtinSizes [godotReturnType] != nil {
                    ptrResult = "&_result.content"
                } else {
                    ptrResult = "&_result.handle"
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

    /// this version inlines withArgPointers by calling `object_method_bind_call_v` or `gi.object_method_bind_ptrcall_v`
    /// which builds the argument list using variadic arguments.
    func call_object_method_bind_v(hasArgs: Bool, ptrResult: String) -> String {
        switch generatedMethodKind {
        case .classMethod:
            let instance = method.isStatic ? "nil" : "UnsafeMutableRawPointer (mutating: \(asSingleton ? "shared." : "")handle)"
            let methodName = "\(className).method_\(method.name)"
            let methodArgs = builder.args.joined(separator: ", ")
                        
            if method.isVararg {
                // Large generics cause issues on Windows compiler, legacy approach is used
                #if canImport(Darwin)
                if hasArgs {
                    let methodArgsCount = "GDExtensionInt(\(builder.args.count))"
                    
                    return """
                    withUnsafeArgumentsPointer(\(methodArgs)) { args in 
                        gi.object_method_bind_call(\([methodName, instance, "args", methodArgsCount, ptrResult, "nil"].joined(separator: ", ")))                        
                    }
                    """
                } else {
                    return "gi.object_method_bind_call(\([methodName, instance, "nil", "0", ptrResult, "nil"].joined(separator: ", ")))"
                }
                #else
                return "gi.object_method_bind_call_v(\([methodName, instance, ptrResult, "nil", methodArgs].joined(separator: ", ")))"
                #endif
            } else {
                // Large generics cause issues on Windows compiler, legacy approach is used
                #if canImport(Darwin)
                if hasArgs {
                    return """
                    withUnsafeArgumentsPointer(\(methodArgs)) { args in
                        gi.object_method_bind_ptrcall(\([methodName, instance, "args", ptrResult].joined(separator: ", ")))
                    }
                    """
                } else {
                    return "gi.object_method_bind_ptrcall(\([methodName, instance, "nil", ptrResult].joined(separator: ", ")))"
                }
                #else
                return "gi.object_method_bind_ptrcall_v(\([methodName, instance, ptrResult, methodArgs].joined(separator: ", ")))"
                #endif
            }
        case .utilityFunction:
            let ptrArgs = hasArgs ? "_args" : "nil"
            let call_object_method_bind = if method.isVararg {
                "\(bindName) (\(ptrResult), \(ptrArgs), Int32 (_args.count))"
            } else {
                "\(bindName) (\(ptrResult), \(ptrArgs), Int32 (\(method.arguments?.count ?? 0)))"
            }
            return
                """
                withArgPointers(\(builder.args.joined(separator: ", "))) { _args in
                    \(call_object_method_bind)
                }
                """
        }
    }
    
    func call_object_method_bind(ptrArgs: String, ptrResult: String) -> String {
        switch generatedMethodKind {
        case .classMethod:
            let instanceHandle = method.isStatic ? "nil, " : "UnsafeMutableRawPointer (mutating: \(asSingleton ? "shared." : "")handle), "
            if method.isVararg {
                return "gi.object_method_bind_call (\(className).method_\(method.name), \(instanceHandle)\(ptrArgs), Int64 (_args.count), \(ptrResult), nil)"
            } else {
                return "gi.object_method_bind_ptrcall (\(className).method_\(method.name), \(instanceHandle)\(ptrArgs), \(ptrResult))"
            }
        case .utilityFunction:
            if method.isVararg {
                return "\(bindName) (\(ptrResult), \(ptrArgs), Int32 (_args.count))"
            } else {
                return "\(bindName) (\(ptrResult), \(ptrArgs), Int32 (\(method.arguments?.count ?? 0)))"
            }
        }
    }
    
    func getReturnStatement() -> String {
        if returnType == "" {
            return ""
        }
        guard returnType != "" else { return "" }
        if method.isVararg {
            if returnType == "Variant" {
                return "return Variant(takingOver: _result)"
            } else if returnType == "GodotError" {
                return "return GodotError(rawValue: Int64(Variant(copying: _result))!)!"
            } else if returnType == "String" {
                return "return _result.description"
            } else {
                fatalError("Do not support this return type = \(returnType)")
            }
        } else if frameworkType {
            //print ("OBJ RETURN: \(className) \(method.name)")
            return "guard let _result else { \(returnOptional ? "return nil" : "fatalError (\"Unexpected nil return from a method that should never return nil\")") } ; return lookupObject (nativeHandle: _result)!"
        } else if godotReturnType?.starts(with: "typedarray::") ?? false {
            let defaultInit = makeDefaultInit(godotType: godotReturnType!, initCollection: "content: _result")
            return "return \(defaultInit)"
        } else if godotReturnType?.starts(with: "enum::") ?? false {
            return "return \(returnType) (rawValue: _result)!"
        } else if godotReturnType == "String" {
            return "return _result.description"
        } else {
            return "return _result"
        }
    }
    
    var withUnsafeCallNestLevel = 0
    var eliminate: String = defaultArgumentLabel
    if let margs = method.arguments {
        var firstArg: String? = nil
        for arg in margs {
            if args != "" { args += ", " }
            var isRefOptional = false
            if classMap [arg.type] != nil {
                isRefOptional = isMethodArgumentOptional (className: className, method: method.name, arg: arg.name)
            }
            
            // Omit first argument label, if necessary
            if firstArg == nil {
                if shouldOmitFirstArgLabel(typeName: className, methodName: method.name, argName: arg.name) {
                    eliminate = "_ "
                } else {
                    eliminate = defaultArgumentLabel
                }
            } else {
                eliminate = defaultArgumentLabel
            }
            firstArg = arg.name
            args += getArgumentDeclaration(arg, eliminate: eliminate, isOptional: isRefOptional)
            var reference = escapeSwift (snakeToCamel (arg.name))

            if method.isVararg {
                if isRefOptional {
                    argSetup += "let copy_\(arg.name) = \(reference) == nil ? Variant() : Variant (\(reference)!)\n"
                } else {
                    argSetup += "let copy_\(arg.name) = Variant (\(reference))\n"
                }
            } else if arg.type == "String" {
                argSetup += "let gstr_\(arg.name) = GString (\(reference))\n"
            } else if argTypeNeedsCopy(godotType: arg.type) {
                // Wrap in an Int
                if arg.type.starts(with: "enum::") {
                    reference = "Int64 (\(reference).rawValue)"
                }
                if isSmallInt (arg) {
                    argSetup += "var copy_\(arg.name): Int = Int (\(reference))\n"
                } else {
                    argSetup += "var copy_\(arg.name) = \(reference)\n"
                }
            }
        }
        if method.isVararg {
            if args != "" { args += ", "}
            args += "_ arguments: Variant..."
        }
        // generate a helper function, a la withUnsafePointers() above, which
        // combines extracting the parameters into pointers and packing them into the _args array.
        // We can modularize this by creating functions that generate the return type and return
        // statements.

#if os(Windows)
        // Workaround for: https://github.com/migueldeicaza/SwiftGodot/issues/299
        builder.setup = "#if false\n\n"
#else
        if method.isVararg {
            builder.setup = "#if false\n\n"
        } else {
            builder.setup = "#if true\n\n"
        }
#endif
        builder.setup += argSetup
        // Use implicit bridging to build _args array of type [UnsafeMutableRawPointer?]. This preserves the
        // values of the parameters, because they are treated as inout parameters. Then cast to [UnsafeRawPointer?],
        // because of how GDExtensionInterfaceObjectMethodBindPtrcall is declared:
        // public typealias GDExtensionInterfaceObjectMethodBindPtrcall = @convention(c) (GDExtensionMethodBindPtr?, GDExtensionObjectPtr?, UnsafePointer<GDExtensionConstTypePtr?>?, GDExtensionTypePtr?) -> Void
        // UnsafePointer<GDExtensionConstTypePtr?>? is equivalent to UnsafePointer<UnsafeRawPointer?>? or [UnsafeRawPointer?].
        argSetup += "var _args: [UnsafeRawPointer?] = []\n"
        for arg in margs {
            // When we move from GString to String in the public API
            //                if arg.type == "String" {
            //                    argSetup += "stringToGodotHandle (\(arg.name))\n"
            //                } else
            //                {
            var argref: String
            var optstorage: String
            var needAddress = "&"
            //var isRefParameter = false
            var refParameterIsOptional = false
            if method.isVararg {
                argref = "copy_\(arg.name)"
                optstorage = ".content"
            } else if arg.type == "String" {
                argref = "gstr_\(arg.name)"
                optstorage = ".content"
            } else if argTypeNeedsCopy(godotType: arg.type) {
                argref = "copy_\(arg.name)"
                optstorage = ""
            } else {
                argref = escapeSwift (snakeToCamel (arg.name))
                if isStructMap [arg.type] ?? false {
                    optstorage = ""
                } else {
                    if builtinSizes [arg.type] != nil && arg.type != "Object" {
                        optstorage = ".content"
                    } else if arg.type.starts(with: "typedarray::") {
                        optstorage = ".array.content"
                    } else {
                        // The next two are unused, because we set isRefParameter,
                        // but for documentation/clarity purposes
                        optstorage = ".handle"
                        needAddress = ""
                        //isRefParameter = true
                        
                        refParameterIsOptional = isMethodArgumentOptional (className: className, method: method.name, arg: arg.name)
                    }
                }
            }
            // With Godot 4.1 we need to pass the address of the handle
            let prefix = String(repeating: " ", count: withUnsafeCallNestLevel * 4)
            let retFromWith = returnType != "" ? "return " : ""

            if refParameterIsOptional || optstorage == ".handle" {
                let ea = escapeSwift(argref)
                let deref = refParameterIsOptional ? "?" : ""
                let accessPar = refParameterIsOptional ? "\(ea) == nil ? nil : p\(withUnsafeCallNestLevel)" : "p\(withUnsafeCallNestLevel)"
                argSetup += "\(prefix)\(retFromWith)withUnsafePointer (to: \(ea)\(deref).handle) { p\(withUnsafeCallNestLevel) in\n\(prefix)_args.append (\(accessPar))\n"
                withUnsafeCallNestLevel += 1
                let handle_ref = "copy_\(arg.name)_handle"
                builder.setup += "var \(handle_ref) = \(ea)\(deref).handle\n"
                builder.args.append("&\(handle_ref)")
            } else {
                argSetup += "\(prefix)\(retFromWith)withUnsafePointer (to: \(needAddress)\(escapeSwift(argref))\(optstorage)) { p\(withUnsafeCallNestLevel) in\n\(prefix)    _args.append (p\(withUnsafeCallNestLevel))\n"
                withUnsafeCallNestLevel += 1
                builder.args.append("\(needAddress)\(escapeSwift(argref))\(optstorage)")
            }
        }
        argSetup += varArgSetupInit.indented(by: withUnsafeCallNestLevel)
        argSetup += varArgSetup.indented(by: withUnsafeCallNestLevel)
        builder.call =
        """
        \(call_object_method_bind_v(hasArgs: args != "", ptrResult: getCallResultArgument()))
        \(getReturnStatement())
        #else\n
        """
    } else if method.isVararg {
        // No regular arguments, check if these are varargs
        if method.isVararg {
            args = "_ arguments: Variant..."
        }
        argSetup += "var _args: [UnsafeRawPointer?] = []\n"
        argSetup += varArgSetupInit.indented(by: withUnsafeCallNestLevel)
        argSetup += varArgSetup.indented(by: withUnsafeCallNestLevel)
    }
    
    if inlineAttribute != "" {
        p (inlineAttribute)
    }
    // Sadly, the parameters have no useful documentation
    doc (p, cdef, method.description)
    // Generate the method entry point
    if let classDiscardables = discardableResultList [className] {
        if classDiscardables.contains(method.name) == true {
            p ("@discardableResult /* discardable per discardableList: \(className), \(method.name) */ ")
        }
    }
    p ("\(visibilityAttribute)\(staticAttribute) \(finalAttribute)func \(swiftMethodName) (\(args))\(returnType != "" ? "-> " + returnType : "")") {
        if method.optionalHash == nil {
            if let godotReturnType {
                p (makeDefaultReturn (godotType: godotReturnType))
            }
        } else {
            if returnType != "" {
                p(returnTypeDecl())
            } else if (method.isVararg) {
                p ("var _result: Variant.ContentType = Variant.zero")
            }
            
            let instanceArg: String
            if method.isStatic {
                instanceArg = "nil"
            } else {
                let accessor: String
                if asSingleton {
                    accessor = "shared.handle"
                } else {
                    accessor = "handle"
                }
                instanceArg = "UnsafeMutableRawPointer(mutating: \(accessor))"
            }
            
            func getMethodNameArgument() -> String {
                assert(generatedMethodKind == .classMethod)
                
                if staticAttribute.isEmpty {
                    return "\(className).method_\(method.name)"
                } else {
                    return "method_\(method.name)"
                }
            }
            
            if !method.isVararg {
                func callClassMethod(argsRef: String) {
                    assert(generatedMethodKind == .classMethod)
                    
                    let argsList = [
                        getMethodNameArgument(),
                        instanceArg,
                        argsRef,
                        getCallResultArgument()
                    ].joined(separator: ", ")
                    
                    p("gi.object_method_bind_ptrcall(\(argsList))")
                }
                
                func callUtilityFunction(argsRef: String, count: Int) {
                    assert(generatedMethodKind == .utilityFunction)
                    
                    let argsList = [
                        getCallResultArgument(),
                        argsRef,
                        "\(count)" // just a literal, no need to convert to Int32
                    ].joined(separator: ", ")
                    
                    p("method_\(method.name)(\(argsList))")
                }
                                
                if methodArguments.isEmpty {
                    switch generatedMethodKind {
                    case .classMethod:
                        callClassMethod(argsRef: "nil")
                    case .utilityFunction:
                        callUtilityFunction(argsRef: "nil", count: 0)
                    }
                } else {
                    preparingArguments(p, arguments: methodArguments) {
                        aggregatingPreparedArguments(p, argumentsCount: methodArguments.count) {
                            switch generatedMethodKind {
                            case .classMethod:
                                callClassMethod(argsRef: "pArgs")
                            case .utilityFunction:
                                callUtilityFunction(argsRef: "pArgs", count: methodArguments.count)
                            }
                        }
                    }
                }
            } else {
                func callVarargClassMethod(argsRef: String, count: MarshaledArgumentsCount) -> String {
                    assert(generatedMethodKind == .classMethod)
                    
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
                }
                
                func callVarargUtilityFunction(argsRef: String, count: MarshaledArgumentsCount) -> String {
                    assert(generatedMethodKind == .utilityFunction)
                    
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
                            
                if methodArguments.isEmpty {
                    func call(argsRef: String, count: MarshaledArgumentsCount) -> String {
                        switch generatedMethodKind {
                        case .classMethod:
                            return callVarargClassMethod(argsRef: argsRef, count: count)
                        case .utilityFunction:
                            return callVarargUtilityFunction(argsRef: argsRef, count: count)
                        }
                    }
                                        
                    p("""
                    if arguments.isEmpty {
                        \(call(argsRef: "nil", count: .literal(0))) // no arguments
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

                                \(call(argsRef: "pArgs", count: .expression("arguments.count")))
                            }
                        }
                    }
                    """)
                } else {
                    preparingMandatoryVariadicArguments(p, arguments: arguments) {
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
                                    
                            func call(count: MarshaledArgumentsCount) -> String {
                                switch generatedMethodKind {
                                case .classMethod:
                                    return callVarargClassMethod(argsRef: "pArgs", count: count)
                                case .utilityFunction:
                                    return callVarargUtilityFunction(argsRef: "pArgs", count: count)
                                }
                            }
                            
                            p("""
                            if arguments.isEmpty {
                                \(call(count: .literal(arguments.count))) // no variadic arguments, just mandatory
                            } else {
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
                            
                                    \(call(count: .expression("\(arguments.count) + arguments.count")))
                                }
                            }                            
                            """)
                        }
                    }
                }
            }
            
            p(getReturnStatement())
        }
    }
    return registerVirtualMethodName
}
