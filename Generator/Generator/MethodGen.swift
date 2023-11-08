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

/// Generates a method definition
/// - Parameters:
///  - p: Our printer to generate the method
///  - method: the definition to generate
///  - className: the name of the class where this is being generated
///  - usedMethods: a set of methods that have been referenced by properties, to determine whether we make this public or private
/// - Returns: nil, or the method we surfaced that needs to have the virtual supporting infrastructured wired up
func methodGen (_ p: Printer, method: MethodDefinition, className: String, cdef: JClassInfo?, docClass: DocClass?, usedMethods: Set<String>, kind: MethodGenType, asSingleton: Bool) -> String? {
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
            p ("\(staticVarVisibility)static var \(bindName): GDExtensionMethodBindPtr =", suffix: "()") {
                p ("let methodName = StringName (\"\(method.name)\")")
            
                p ("return withUnsafePointer (to: &\(className).className.content)", arg: " classPtr in") {
                    p ("withUnsafePointer (to: &methodName.content)", arg: " mnamePtr in") {
                        p ("gi.classdb_get_method_bind (classPtr, mnamePtr, \(methodHash))!")
                    }
                }
            }
        case .utility:
            p ("\(staticVarVisibility)static var \(bindName): GDExtensionPtrUtilityFunction =", suffix: "()") {
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
            } else {
                argSetup += "\(prefix)\(retFromWith)withUnsafePointer (to: \(needAddress)\(escapeSwift(argref))\(optstorage)) { p\(withUnsafeCallNestLevel) in\n\(prefix)    _args.append (p\(withUnsafeCallNestLevel))\n"
                withUnsafeCallNestLevel += 1
            }
        }
        argSetup += varArgSetupInit
        argSetup += varArgSetup
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

    if let docClass, let methods = docClass.methods {
        if let docMethod = methods.method.first(where: { $0.name == method.name }) {
            doc (p, cdef, docMethod.description)
            // Sadly, the parameters have no useful documentation
        }
    }
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
            var frameworkType = false
            if returnType != "" {
                guard let godotReturnType else {
                    fatalError ("If the returnType is not empty, we should have a godotReturnType")
                }
                if method.isVararg {
                    p ("var _result: Variant.ContentType = Variant.zero")
                } else if godotReturnType.starts(with: "typedarray::") {
                    let (storage, initialize) = getBuiltinStorage ("Array")
                    p ("var _result: \(storage)\(initialize)")
                } else if godotReturnType == "String" {
                    p ("let _result = GString ()")
                } else {
                    if godotReturnTypeIsReferenceType {
                        frameworkType = true
                        p ("var _result = UnsafeRawPointer (bitPattern: 0)")
                    } else {
                        if godotReturnType.starts(with: "enum::") {
                            p ("var _result: Int = 0 // to avoid packed enums on the stack")
                        } else {
                            
                            var declType: String = "let"
                            if (argTypeNeedsCopy(godotType: godotReturnType)) {
                                if builtinGodotTypeNames [godotReturnType] != .isClass {
                                    declType = "var"
                                }
                            }
                            p ("\(declType) _result: \(returnType) = \(makeDefaultInit(godotType: godotReturnType))")
                        }
                    }
                }
            }
            
            if argSetup != "" {
                p (argSetup)
            }
            if withUnsafeCallNestLevel > 0 {
                p.indent += withUnsafeCallNestLevel
            }
            
            let ptrArgs = (args != "") ? "&_args" : "nil"
            let ptrResult: String
            if returnType != "" {
                guard let godotReturnType else { return }

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
                ptrResult = "nil"
            }
            
            switch kind {
            case .class:
                let instanceHandle = method.isStatic ? "nil, " : "UnsafeMutableRawPointer (mutating: \(asSingleton ? "shared." : "")handle), "
                if method.isVararg {
                    p ("gi.object_method_bind_call (\(className).method_\(method.name), \(instanceHandle)\(ptrArgs), Int64 (_args.count), \(ptrResult), nil)")
                } else {
                    p ("gi.object_method_bind_ptrcall (\(className).method_\(method.name), \(instanceHandle)\(ptrArgs), \(ptrResult))")
                }
            case .utility:
                if method.isVararg {
                    p ("\(bindName) (\(ptrResult), \(ptrArgs), Int32 (_args.count))")
                } else {
                    p ("\(bindName) (\(ptrResult), \(ptrArgs), Int32 (\(method.arguments?.count ?? 0)))")
                }
            }
            
            if returnType != "" {
                if method.isVararg {
                    if returnType == "Variant" {
                        p ("return Variant (fromContent: _result)")
                    } else if returnType == "GodotError" {
                        p ("return GodotError (rawValue: Int (Variant (fromContent: _result))!)!")
                    } else if returnType == "String" {
                        p ("return GString (Variant (fromContent: _result))?.description ?? \"\"")
                    } else {
                        fatalError("Do not support this return type")
                    }
                } else if frameworkType {
                    //print ("OBJ RETURN: \(className) \(method.name)")
                    p ("guard let _result else") {
                        if returnOptional {
                            p ("return nil")
                        } else {
                            p ("fatalError (\"Unexpected nil return from a method that should never return nil\")")
                        }
                    }
                    p ("return lookupObject (nativeHandle: _result)!")
                } else if godotReturnType?.starts(with: "typedarray::") ?? false {
                    let defaultInit = makeDefaultInit(godotType: godotReturnType!, initCollection: "content: _result")
                    
                    p ("return \(defaultInit)")
                } else if godotReturnType!.starts(with: "enum::"){
                    p ("return \(returnType) (rawValue: _result)!")
                } else if godotReturnType == "String" {
                    p ("return _result.description")
                } else {
                    p ("return _result")
                }
            }
            
            // Unwrap the nested calls to 'withUnsafePointer'
            while withUnsafeCallNestLevel > 0 {
                withUnsafeCallNestLevel -= 1
                p.indent -= 1
                p ("}")
            }
        }
    }
    return registerVirtualMethodName
}
