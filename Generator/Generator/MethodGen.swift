//
//  MethodGen.swift
//  Generator
//
//  Created by Miguel de Icaza on 5/15/23.
//

import Foundation
import ExtensionApi

enum MethodGenType {
    case `class`
    case `utility`
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
func isRefParameterOptional (className: String, method: String, arg: String) -> Bool {
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
func methodGen (_ p: Printer, method: MethodDefinition, className: String, cdef: JClassInfo?, usedMethods: Set<String>, kind: MethodGenType, asSingleton: Bool) -> String? {
    var registerVirtualMethodName: String? = nil
    
    //let loc = "\(cdef.name).\(method.name)"
    if (method.arguments ?? []).contains(where: { $0.type.contains("*")}) {
        //print ("TODO: do not currently have support for C pointer types \(loc)")
        return nil
    }
//    if method.returnValue?.type.firstIndex(of: "*") != nil {
//        //print ("TODO: do not currently support C pointer returns \(loc)")
//        return nil
//    }
    let bindName = "method_\(method.name)"
    var visibility: String
    var allEliminate: String
    var finalp: String
    // Default method name
    var methodName: String = godotMethodToSwift (method.name)
    let instanceOrStatic = method.isStatic || asSingleton ? " static" : ""
    var inline = ""
    if let methodHash = method.optionalHash {
        let staticVarVisibility = if bindName != "method_get_class" { "fileprivate " } else { "" }
        assert (!method.isVirtual)
        switch kind {
        case .class:
            p.staticVar(visibility: staticVarVisibility, name: bindName, type: "GDExtensionMethodBindPtr") {
                p ("let methodName = StringName (\"\(method.name)\")")
            
                p ("return withUnsafePointer (to: &\(className).godotClassName.content)", arg: " classPtr in") {
                    p ("withUnsafePointer (to: &methodName.content)", arg: " mnamePtr in") {
                        p ("gi.classdb_get_method_bind (classPtr, mnamePtr, \(methodHash))!")
                    }
                }
            }
        case .utility:
            p.staticVar(visibility: staticVarVisibility, name: bindName, type: "GDExtensionPtrUtilityFunction") {
                p ("let methodName = StringName (\"\(method.name)\")")
                p ("return withUnsafePointer (to: &methodName.content)", arg: " ptr in") {
                    p ("return gi.variant_get_ptr_utility_function (ptr, \(methodHash))!")
                }
            }
        }
        
        // If this is an internal, and being reference by a property, hide it
        if usedMethods.contains (method.name) {
            inline = "@inline(__always)"
            // Try to hide as much as possible, but we know that Godot child nodes will want to use these
            // (DirectionalLight3D and Light3D) rely on this.
            visibility = method.name == "get_param" || method.name == "set_param" ? "internal" : "fileprivate"
            allEliminate = "_ "
            methodName = method.name
        } else {
            visibility = "public"
            allEliminate = ""
        }
        if instanceOrStatic == "" {
            finalp = "final "
        } else {
            finalp = ""
        }
    } else {
        assert (method.isVirtual)
        // virtual overwrittable method
        finalp = ""
        visibility = "@_documentation(visibility: public)\nopen"
        allEliminate = ""
            
        registerVirtualMethodName = methodName
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
                return "var _result: Variant.ContentType = Variant.zero"
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
    
    func getResultPtr() -> String {
        let ptrResult: String
        if returnType != "" {
            guard let godotReturnType else { fatalError("godotReturnType is nil!") }

            if method.isVararg {
                ptrResult = "&_result"
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
        case .class:
            let instanceHandle = method.isStatic ? "nil, " : "UnsafeMutableRawPointer (mutating: \(asSingleton ? "shared." : "")handle), "
            let argList = hasArgs ? ", \(builder.args.joined(separator: ", "))" : ""
            if method.isVararg {
                return "gi.object_method_bind_call_v (\(className).method_\(method.name), \(instanceHandle)\(ptrResult), nil\(argList))"
            } else {
                return "gi.object_method_bind_ptrcall_v (\(className).method_\(method.name), \(instanceHandle)\(ptrResult)\(argList))"
            }
        case .utility:
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
        case .class:
            let instanceHandle = method.isStatic ? "nil, " : "UnsafeMutableRawPointer (mutating: \(asSingleton ? "shared." : "")handle), "
            if method.isVararg {
                return "gi.object_method_bind_call (\(className).method_\(method.name), \(instanceHandle)\(ptrArgs), Int64 (_args.count), \(ptrResult), nil)"
            } else {
                return "gi.object_method_bind_ptrcall (\(className).method_\(method.name), \(instanceHandle)\(ptrArgs), \(ptrResult))"
            }
        case .utility:
            if method.isVararg {
                return "\(bindName) (\(ptrResult), \(ptrArgs), Int32 (_args.count))"
            } else {
                return "\(bindName) (\(ptrResult), \(ptrArgs), Int32 (\(method.arguments?.count ?? 0)))"
            }
        }
    }
    
    func getReturnResult() -> String {
        if returnType == "" {
            return ""
        }
        guard returnType != "" else { return "" }
        if method.isVararg {
            if returnType == "Variant" {
                return "return Variant (fromContentPtr: &_result)"
            } else if returnType == "GodotError" {
                return "return GodotError (rawValue: Int64 (Variant (fromContentPtr: &_result))!)!"
            } else if returnType == "String" {
                return "return GString (Variant (fromContentPtr: &_result))?.description ?? \"\""
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
    var eliminate: String = allEliminate
    if let margs = method.arguments {
        var firstArg: String? = nil
        for arg in margs {
            if args != "" { args += ", " }
            var isRefOptional = false
            if classMap [arg.type] != nil {
                isRefOptional = isRefParameterOptional (className: className, method: method.name, arg: arg.name)
            }
            
            // if the first argument name matches the last part of the method name, we want
            // to skip giving it a name.   For example:
            // addPattern (pattern: xx) becomes addPattern (_ pattern: xx)
            if firstArg == nil {
                if method.name.hasSuffix("_\(arg.name)") {
                    eliminate = "_ "
                } else {
                    eliminate = allEliminate
                }
            } else {
                eliminate = allEliminate
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
                        
                        refParameterIsOptional = isRefParameterOptional (className: className, method: method.name, arg: arg.name)
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
        argSetup += varArgSetupInit
        argSetup += varArgSetup
        builder.call =
        """
        \(call_object_method_bind_v(hasArgs: args != "", ptrResult: getResultPtr()))
        \(getReturnResult())
        #else\n
        """
    } else if method.isVararg {
        // No regular arguments, check if these are varargs
        if method.isVararg {
            args = "_ arguments: Variant..."
        }
        argSetup += "var _args: [UnsafeRawPointer?] = []\n"
        argSetup += varArgSetupInit
        argSetup += varArgSetup
    }
    
    if inline != "" {
        p (inline)
    }
    // Sadly, the parameters have no useful documentation
    doc (p, cdef, method.description)
    // Generate the method entry point
    if let classDiscardables = discardableResultList [className] {
        if classDiscardables.contains(method.name) == true {
            p ("@discardableResult /* discardable per discardableList: \(className), \(method.name) */ ")
        }
    }
    p ("\(visibility)\(instanceOrStatic) \(finalp)func \(methodName) (\(args))\(returnType != "" ? "-> " + returnType : "")") {
        // We will change the nest level in the body after we print out the prefix of the nested withUnsafe calls
        
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
            
            if builder.setup != "" {
                p(builder.setup)
                p(builder.call)
            }
            
            if argSetup != "" {
                p (argSetup)
            }
            if withUnsafeCallNestLevel > 0 {
                p.indent += withUnsafeCallNestLevel
            }

            p(call_object_method_bind(ptrArgs: getArgsPtr(), ptrResult: getResultPtr()))
            
            if returnType != "" {
                p (getReturnResult())
            }
            
            // Unwrap the nested calls to 'withUnsafePointer'
            while withUnsafeCallNestLevel > 0 {
                withUnsafeCallNestLevel -= 1
                p.indent -= 1
                p ("}")
            }
            
// REFACTOR: just so we can see the two side-by-side
            if builder.setup != "" {
                p ("\n#endif")
            }
        }
    }
    return registerVirtualMethodName
}
