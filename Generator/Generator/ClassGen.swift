//
//  ClassGen.swift
//  Generator
//
//  Created by Miguel de Icaza on 3/26/23.
//
// Need support for:
//   enum::
//   typedarray::
//   bitfield::

import Foundation

// Populated with the types loaded from the api.json, we assume they are all reference types
// anything else is not
var referenceTypes: [String:Bool] = [:]

// Maps a typename to its toplevel Json element
var tree: [String: JGodotExtensionAPIClass] = [:]

var typeToChildren: [String:[String]] = [:]

func makeDefaultInit (godotType: String) -> String {
    switch godotType {
    case "int":
        return "0"
    case "float":
        return "0.0"
    case "bool":
        return "false"
    case "String":
        return "GString ()"
    case let t where t.starts (with: "typedarray::"):
        return "GodotCollection<\(getGodotType (String (t.dropFirst(12))))>()"
    case "enum::Error":
        return ".ok"
    case "enum::Variant.Type":
        return ".`nil`"
    case let e where e.starts (with: "enum::"):
        return "\(e.dropFirst(6))(rawValue: 0)!"
    case let e where e.starts (with: "bitfield::"):
        return "\(getGodotType (godotType)) ()"
   
    case let other where builtinGodotTypeNames.contains(other):
        return "\(godotType) ()"
    case "void*":
        return "nil"
    default:
        if isCoreType(name: godotType) {
            return "\(getGodotType(godotType)) ()"
        } else {
            return "\(getGodotType(godotType)) (fast: true)"
        }
    }
}

func makeDefaultReturn (godotType: String) -> String {
    return "return \(makeDefaultInit(godotType: godotType))"
}

func argTypeNeedsCopy (godotType: String) -> Bool {
    if isStructMap [godotType] ?? false {
        return true
    }
    if godotType.starts(with: "enum::") {
        return true
    }
    if godotType.starts(with: "bitfield::") {
        return true
    }
    return false
}

func generateMethods (cdef: JGodotExtensionAPIClass, methods: [JGodotClassMethod], _ usedMethods: Set<String>) {
    p ("/* Methods */")
    
    for method in methods {
        if method.name == "_shaped_text_get_glyphs" {
            print ("ere")
        }
        if method.isVararg {
            print ("TODO: No vararg support yet")
            continue
        }
        if (method.arguments ?? []).contains(where: { $0.type.contains("*")}) {
            print ("TODO: do not currently have support for C pointer types")
            continue
        }
        if method.returnValue?.type.firstIndex(of: "*") != nil {
            print ("TODO: do not currently support C pointer returns")
            continue
        }
        let bindName = "method_\(method.name)"

        var visibility: String
        var eliminate: String
        var finalp: String
        // Default method name
        var methodName: String = escapeSwift (snakeToCamel(method.name))
        
        let instanceOrStatic = method.isStatic ? " static" : ""
        if let methodHash = method.hash {
            b ("static var \(bindName): GDExtensionMethodBindPtr =", suffix: "()") {
                p ("let methodName = StringName (\"\(method.name)\")")
                
                /// TODO: make the handle in the generated bindings be an UnsafeRawPointer
                /// to avoid these casts here
                p ("return gi.classdb_get_method_bind (UnsafeRawPointer (&\(cdef.name).className.handle), UnsafeRawPointer (&methodName.handle), \(methodHash))!")
            }
            
            // If this is an internal, and being reference by a property, hide it
            if usedMethods.contains (method.name) {
                visibility = "private"
                eliminate = "_ "
                methodName = method.name
            } else {
                visibility = method.isVirtual ? "open" : "public"
                eliminate = ""
            }
            if instanceOrStatic == "" {
                finalp = "final "
            } else {
                finalp = ""
            }
        } else {
            // virtual overwrittable method
            finalp = ""
            visibility = "public"
            eliminate = ""
        }
        
        var args = ""
        var argSetup = ""
        
        if let margs = method.arguments {
            for arg in margs {
                if args != "" { args += ", " }
                args += getArgumentDeclaration(arg, eliminate: eliminate)
                
                if argTypeNeedsCopy(godotType: arg.type) {
                    argSetup += "var copy_\(arg.name) = \(escapeSwift (snakeToCamel (arg.name)))\n"
                }
            }
            argSetup += "var args: [UnsafeRawPointer?] = [\n"
            for arg in margs {
// When we move from GString to String in the public API
//                if arg.type == "String" {
//                    argSetup += "stringToGodotHandle (\(arg.name))\n"
//                } else
//                {
                    var argref: String
                    var optstorage: String
                    
                    if argTypeNeedsCopy(godotType: arg.type) {
                        argref = "copy_\(arg.name)"
                        optstorage = ""
                    } else {
                        argref = escapeSwift (snakeToCamel (arg.name))
                        if isStructMap [arg.type] ?? false {
                            optstorage = ""
                        } else {
                            optstorage = ".handle"
                        }
                    }
                    
                    if argTypeNeedsCopy(godotType: arg.type) {
                        argSetup += "    UnsafeRawPointer(&\(escapeSwift(argref))\(optstorage)), // isCoreType: \(arg.type) \(isCoreType (name: arg.type)) - \(escapeSwift(argref)) argRef:\(argref)\n"
                    } else {
                        argSetup += "    UnsafeRawPointer(&\(escapeSwift(argref)).handle), // isCoreType: \(arg.type) \(isCoreType (name: arg.type)) - \(escapeSwift(argref)) argRef:\(argref)\n"
                    }
//                }
            }
            argSetup += "]"
        }

        let godotReturnType = method.returnValue?.type
        let returnType = getGodotType (method.returnValue?.type ?? "")
        
        b ("\(visibility)\(instanceOrStatic) \(finalp)func \(methodName) (\(args))\(returnType != "" ? "-> " + returnType : "")") {
            if method.hash == nil {
                if let godotReturnType {
                    p (makeDefaultReturn (godotType: godotReturnType))
                }
            } else {
                if returnType != "" {
                    p ("var _result: \(returnType) = \(makeDefaultInit(godotType: godotReturnType ?? ""))")
                }

                if argSetup != "" {
                    p (argSetup)
                }
                let ptrArgs = (args != "") ? "&args" : "nil"
                let ptrResult: String
                if returnType != "" {
                    if returnType == "VisualShaderNodeParticleAccelerator.Mode" {
                        print ("here")
                    }
                    if argTypeNeedsCopy(godotType: godotReturnType!) {
                        ptrResult = "&_result"
                    } else {
                        ptrResult = "&_result.handle"
                    }
                } else {
                    ptrResult = "nil"
                }

                let instanceHandle = method.isStatic ? "nil" : "UnsafeMutableRawPointer (mutating: handle)"
                p ("gi.object_method_bind_ptrcall (\(cdef.name).method_\(method.name), \(instanceHandle), \(ptrArgs), \(ptrResult))")
                
                if returnType != "" {
                    p ("return _result")
                }
            }
        }
    }
}


func generateProperties (cdef: JGodotExtensionAPIClass, _ properties: [JGodotProperty], _ methods: [JGodotClassMethod], _ referencedMethods: inout Set<String>)
{
    p ("\n/* Properties */\n")

    for property in properties {
        var type: String?
    
        // Ignore properties that only have getters, just let the setter
        // method be surfaced instead
        if property.getter == "" {
            print ("Property with only a setter: \(cdef.name).\(property.name)")
            continue
        }
        if property.getter.starts(with: "_") {
            // These exist, but have no equivalent method
            // see VisualShaderNodeParameterRef._parameter_type as an example
            continue
        }

//        // There are properties declared, but they do not actually exist
//        // CurveTexture claims to have a get_width, but the method does not exist
//        if type == nil {
//            continue
//        }
//        if type!.hasPrefix("Vector3.Axis") {
//            continue
//        }
        let loc = "\(cdef.name).\(property.name)"
        guard let method = methods.first(where: { $0.name == property.getter}) else {
            print ("WARNING \(loc): Could not find matching method for getter")
            continue
        }
        guard let setterMethod = methods.first(where: { $0.name == property.setter}) else {
            print ("WARNING \(loc) Could not find matching method for setter")
            continue
        }

        if method.arguments?.count ?? 0 > 1 {
            print ("WARNING \(loc) property references a getter method that takes more than one argument")
            continue
        }
        if setterMethod.arguments?.count ?? 0 > 2 {
            print ("WARNING \(loc) property references a getter method that takes more than two arguments")
            continue
        }
        if property.name == "positional_shadow_atlas_quad_0" {
            print ("a")
        }
        guard let returnType = method.returnValue?.type else {
            print ("WARNING \(loc) Could not get a return type for method")
            continue
        }
        // Lookup the type from the method, not the property,
        // sometimes the method is a GString, but the property is a StringName
        type = getGodotType (returnType)

        // Ok, we have an indexer, this means we call the property with an int
        // but we need the type from the method
        var access: String
        if let idx = property.index {
            let type = getGodotType(method.arguments! [0].type)
            if type == "Int32" {
                access = "\(idx)"
            } else {
                access = "\(type) (rawValue: \(idx))!"
            }
        } else {
            access = ""
        }
        
        b ("final public var \(escapeSwift (snakeToCamel(property.name))): \(type!)"){
            b ("get"){
                p ("return \(property.getter) (\(access))")
            }
            referencedMethods.insert (property.getter)
            if let setter = property.setter {
                b ("set") {
                    var value = "newValue"
                    if type == "StringName" && setterMethod.arguments![0].type == "String" {
                        value = "GString (from: newValue)"
                    }
                    p ("\(setter) (\(access)\(access != "" ? ", " : "")\(value))")
                }
                referencedMethods.insert (setter)
            }
        }
    }
}

var okList = [ "RefCounted", "Node", "Sprite2D", "Node2D", "CanvasItem", "Object", "String", "StringName" ]
               //, "InputEvent", "SceneTree", "Viewport", "Tween", "Texture2D", "Window", "MultiplayerAPI", "MainLoop", "Texture", "Resource", "MultiplayerPeer", "PacketPeer", "PropertyTweener", "CallbackTweener", "IntervalTweener", "Tweener", "MethodTweener", "Image", "PackedScene", "SceneTreeTimer", "SceneState", "World2D", "World3D", "ViewportTexture", "Camera2D", "Camera3D", "Control", "Camera3D", "PhysicsDirectSpaceState2D", "CameraAttributes", "Environment", "PhysicsDirectSpaceState3D", "PhysicsPointQueryParameters2D", "PhysicsShapeQueryParameters2D", "PhysicsShapeQueryParameters3D", "PhysicsRayQueryParameters3D","PhysicsRayQueryParameters2D", "PhysicsRayQueryParameters3D", "PhysicsPointQueryParameters3D", "Node3D", "Theme", "StyleBox", "Font", "Node3DGizmo", "Sky", "Material", "Shader", "TextServer", "Mesh", "MultiMesh"

func generateClasses (values: [JGodotExtensionAPIClass], outputDir: String) {
    // Assemble all the reference types, we use to test later
    for cdef in values {
        referenceTypes[cdef.name] = true
    }
    // Also a convenient hash to go from name to json
    // And track which types must be opened up
    for cdef in values {
        tree [cdef.name] = cdef
        
        let base = cdef.inherits ?? ""
        if base != "" {
            if var v = typeToChildren [cdef.name] {
                v.append(cdef.inherits ?? "")
            } else {
                typeToChildren [cdef.name] = [cdef.inherits ?? ""]
            }
        }
    }
    
    for cdef in values {
        // Clear the result
        result = ""
        p ("// Generated by Swift code generator - do not edit\nimport Foundation\nimport GDExtension\n")

        // Save it
        defer {
            try! result.write(toFile: outputDir + "/generated-\(cdef.name).swift", atomically: true, encoding: .utf8)
        }
        
        let typeDecl: String
        if let inherits = cdef.inherits {
            typeDecl = "open class \(cdef.name): \(inherits)"
        } else {
            typeDecl = "open class \(cdef.name): Wrapped"
        }
        
        // class or extension (for Object)
        b (typeDecl) {
            p ("static private var className = StringName (\"\(cdef.name)\")")
            b ("public override init (nativeHandle: UnsafeRawPointer)") {
                p("super.init (nativeHandle: nativeHandle)")
            }
            b ("internal override init (name: StringName)") {
                p("super.init (name: name)")
            }
            let defaultInitOverrides = cdef.inherits != nil ? "override " : ""
            b ("internal \(defaultInitOverrides)init (fast: Bool)") {
                p ("super.init (name: \(cdef.name).className)")
            }
            b ("public \(defaultInitOverrides)init ()") {
                p ("super.init (name: StringName (\"\(cdef.name)\"))")
            }
            var referencedMethods = Set<String>()
            
            if let enums = cdef.enums {
                generateEnums (values: enums)
            }
            if !okList.contains (cdef.name) {
                return
            }
            
            if let properties = cdef.properties {
                generateProperties (cdef: cdef, properties, cdef.methods ?? [], &referencedMethods)
            }
            if let methods = cdef.methods {
                generateMethods (cdef: cdef, methods: methods, referencedMethods)
            }
        }
        
    }
}

class Test {
    init (_ str: String) {}
}
