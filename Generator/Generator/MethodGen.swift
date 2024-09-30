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

enum MethodsGenerationKind {
    case classMethods
    case utilityFunctions
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
    case unsupportedArgument(className: String, methodName: String, argumentName: String, argumentTypeName: String, reason: String)
    
    var explanation: String {
        switch self {
        case let .unsupportedArgument(className, methodName, argumentName, typeName, reason):
            return """
            Skipping \(className).\(methodName)
                Reason - \(reason)
                    \(argumentName): \(typeName)
            
            """
        }
    }
}

struct MethodArgument {
    enum Translation {
        case direct
        case contentRef
        case objectRef(isOptional: Bool)
        case typedArray(String)
        case string
        case rawValue
        case opaquePointer
    }
    
    let name: String
    let translation: Translation
    
    init(from src: JGodotArgument, className: String, methodName: String) throws {
        func makeError(reason: String) -> MethodGenError {
            MethodGenError.unsupportedArgument(className: className, methodName: methodName, argumentName: src.name, argumentTypeName: src.type, reason: reason)
        }
        
        self.name = godotArgumentToSwift(src.name)
        
        if src.type.contains("*") {
            translation = .opaquePointer
        } else {
            let tokens = src.type.split(separator: "::")
            
            switch tokens.count {
            case 1:
                if src.type == "String" && mapStringToSwift {
                    translation = .string
                } else {
                    if isStructMap[src.type] == true {
                        translation = .direct
                    } else {
                        if builtinSizes[src.type] != nil && src.type != "Object" {
                            translation = .contentRef
                        } else if classMap[src.type] != nil {
                            translation = .objectRef(
                                isOptional: isMethodArgumentOptional(
                                    className: className,
                                    method: methodName,
                                    arg: src.name
                                )
                            )
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
                accessor = "&\(argument.name).content"
            case .string:
                accessor = "&\(argument.name).content"
                p("let \(argument.name) = GString(\(argument.name))")
            case .direct:
                accessor = argument.name
            case .objectRef(let isOptional):
                if isOptional {
                    accessor = "\(argument.name)?.handle"
                } else {
                    accessor = "&\(argument.name).handle"
                }
            case .rawValue:
                accessor = "\(argument.name).rawValue"
            case .typedArray:
                accessor = "\(argument.name).array.content"
            case .opaquePointer:
                accessor = "\(argument.name)"
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
func methodGen (_ p: Printer, method: MethodDefinition, className: String, cdef: JClassInfo?, usedMethods: Set<String>, kind: MethodsGenerationKind, asSingleton: Bool) throws -> String? {
    
    let arguments = method.arguments ?? []
    
    // TODO: move down
    let methodArguments = try arguments.map { argument in
        try MethodArgument(from: argument, className: className, methodName: method.name)
    }
    
    var registerVirtualMethodName: String? = nil
    
    //let loc = "\(cdef.name).\(method.name)"
    if let arguments = method.arguments, arguments.contains(where: { $0.type.contains("*")}) {
        var fault = false
        for arg in arguments {
            if arg.type.contains ("*") {
                switch arg.type {
                case "const void*":
                    break
                case "AudioFrame*":
                    break
                default:
                    if !fault {
                        fault = true
                        //print ("TODO: do not currently have support for C pointer types \(cdef?.name ?? "").\(method.name):")
                    }
                    //print ("     \(arg.name): \(arg.type)")
                    break
                }
            }
        }
        if fault {
            return nil
        }
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
        switch kind {
        case .classMethods:
            p.staticVar(visibility: staticVarVisibility, name: bindName, type: "GDExtensionMethodBindPtr") {
                p ("let methodName = StringName (\"\(method.name)\")")
            
                p ("return withUnsafePointer (to: &\(className).godotClassName.content)", arg: " classPtr in") {
                    p ("withUnsafePointer (to: &methodName.content)", arg: " mnamePtr in") {
                        p ("gi.classdb_get_method_bind (classPtr, mnamePtr, \(methodHash))!")
                    }
                }
            }
        case .utilityFunctions:
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
        switch kind {
        case .classMethods:
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
        case .utilityFunctions:
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
        switch kind {
        case .classMethods:
            let instanceHandle = method.isStatic ? "nil, " : "UnsafeMutableRawPointer (mutating: \(asSingleton ? "shared." : "")handle), "
            if method.isVararg {
                return "gi.object_method_bind_call (\(className).method_\(method.name), \(instanceHandle)\(ptrArgs), Int64 (_args.count), \(ptrResult), nil)"
            } else {
                return "gi.object_method_bind_ptrcall (\(className).method_\(method.name), \(instanceHandle)\(ptrArgs), \(ptrResult))"
            }
        case .utilityFunctions:
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
            
    if let margs = method.arguments {
        var firstArg: String? = nil
        for arg in margs {
            if args != "" { args += ", " }
            var isRefOptional = false
            if classMap [arg.type] != nil {
                isRefOptional = isMethodArgumentOptional (className: className, method: method.name, arg: arg.name)
            }
            
            // Omit first argument label, if necessary
            let argumentLabel: String
            if firstArg == nil {
                if shouldOmitFirstArgLabel(typeName: className, methodName: method.name, argName: arg.name) {
                    argumentLabel = "_ "
                } else {
                    argumentLabel = defaultArgumentLabel
                }
            } else {
                argumentLabel = defaultArgumentLabel
            }
            firstArg = arg.name
            args += getArgumentDeclaration(arg, eliminate: argumentLabel, isOptional: isRefOptional)
        }
        
        if method.isVararg {
            if args != "" { args += ", "}
            args += "_ arguments: Variant..."
        }
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
                assert(kind == .classMethods)
                
                if staticAttribute.isEmpty {
                    return "\(className).method_\(method.name)"
                } else {
                    return "method_\(method.name)"
                }
            }
            
            if !method.isVararg {
                func callClassMethod(argsRef: String) {
                    assert(kind == .classMethods)
                    
                    let argsList = [
                        getMethodNameArgument(),
                        instanceArg,
                        argsRef,
                        getCallResultArgument()
                    ].joined(separator: ", ")
                    
                    p("gi.object_method_bind_ptrcall(\(argsList))")
                }
                
                func callUtilityFunction(argsRef: String, count: Int) {
                    assert(kind == .utilityFunctions)
                    
                    let argsList = [
                        getCallResultArgument(),
                        argsRef,
                        "\(count)" // just a literal, no need to convert to Int32
                    ].joined(separator: ", ")
                    
                    p("method_\(method.name)(\(argsList))")
                }
                                
                if methodArguments.isEmpty {
                    switch kind {
                    case .classMethods:
                        callClassMethod(argsRef: "nil")
                    case .utilityFunctions:
                        callUtilityFunction(argsRef: "nil", count: 0)
                    }
                } else {
                    preparingArguments(p, arguments: methodArguments) {
                        let argsList = (0..<methodArguments.count)
                            .map {
                                "pArg\($0)"
                            }.joined(separator: ", ")
                        
                        p("withUnsafePointer(to: UnsafeRawPointersN\(methodArguments.count)(\(argsList)))", arg: " pArgs in") {
                            p("pArgs.withMemoryRebound(to: UnsafeRawPointer?.self, capacity: \(methodArguments.count))", arg: " pArgs in") {
                                switch kind {
                                case .classMethods:
                                    callClassMethod(argsRef: "pArgs")
                                case .utilityFunctions:
                                    callUtilityFunction(argsRef: "pArgs", count: methodArguments.count)
                                }
                            }
                        }
                    }
                }
            } else {
                enum CountArgument {
                    case literal(Int)
                    case expression(String)
                }
                
                func callVarargClassMethod(argsRef: String, count: CountArgument) -> String {
                    assert(kind == .classMethods)
                    
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
                
                func callVarargUtilityFunction(argsRef: String, count: CountArgument) -> String {
                    assert(kind == .utilityFunctions)
                    
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
                    func call(argsRef: String, count: CountArgument) -> String {
                        switch kind {
                        case .classMethods:
                            return callVarargClassMethod(argsRef: argsRef, count: count)
                        case .utilityFunctions:
                            return callVarargUtilityFunction(argsRef: argsRef, count: count)
                        }
                    }
                    
                    // Right now there is only a single function that is variadic and doesn't have mandatory arguments
                    p("""
                    if arguments.isEmpty {
                        \(call(argsRef: "nil", count: .literal(0))) // no variadic arguments, just mandatory
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
                                    pArgsBuffer.initializeElement(at: \(arguments.count) + i, to: contentsPtr + i)
                                }

                                \(call(argsRef: "pArgs", count: .expression("\(arguments.count) + arguments.count")))
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
                                    
                            func call(count: CountArgument) -> String {
                                switch kind {
                                case .classMethods:
                                    return callVarargClassMethod(argsRef: "pArgs", count: count)
                                case .utilityFunctions:
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
