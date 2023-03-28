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

func generateMethods (cdef: JGodotExtensionAPIClass, methods: [JGodotClassMethod], _ usedMethods: Set<String>) {
    p ("/* Methods */")
    
    for method in methods {
        let bindName = "method_\(method.name)"
        
        // TODO: these are methods that the user will overwrite
        guard let methodHash = method.hash else {
            //print ("Method with no Hash: \(cdef.name).\(method.name)")
            continue
        }
        b ("static var \(bindName): GDExtensionMethodBindPtr =", suffix: "()") {
            p ("let methodName = StringName (\"\(method.name)\")")
            
            if method.hash == nil {
                
            }
            /// TODO: make the handle in the generated bindings be an UnsafeRawPointer
            /// to avoid these casts here
            p ("return gi.classdb_get_method_bind (UnsafeRawPointer (\(cdef.name).className.handle), UnsafeRawPointer (methodName.handle), \(methodHash))!")
        }

        // If this is an internal, and being reference by a property, hide it
        var visibility: String
        var eliminate: String
        if usedMethods.contains (method.name) {
            visibility = "private"
            eliminate = "_ "
        } else {
            visibility = method.isVirtual ? "open" : "public"
            eliminate = ""
        }

        var args = ""
        for arg in method.arguments ?? [] {
            if args != "" { args += ", " }
            args += getArgumentDeclaration(arg, eliminate: eliminate)
        }

        let returnType = getGodotType (method.returnValue?.type ?? "")
    
        b ("\(visibility) func \(method.name) (\(args))\(returnType != "" ? "-> " + returnType : "")") {
            p ("fatalError ()")
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
        
        b ("public var \(escapeSwift (snakeToCamel(property.name))): \(type!)"){
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

var okList = ["Object", "RefCounted", "Node2D", "Node", "CanvasItem", "ConfigFile"]
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
            typeDecl = "open class \(cdef.name)"
        }
        
        // class or extension (for Object)
        b (typeDecl) {
            p ("static private var className = StringName (\"\(cdef.name)\")")
            if cdef.inherits != nil {
                b ("public override init (nativeHandle: UnsafeRawPointer)") {
                    p("super.init (nativeHandle: nativeHandle)")
                }
            } else {
                p ("var handle: UnsafeRawPointer")
                b ("public init (nativeHandle: UnsafeRawPointer)") {
                    p ("handle = nativeHandle")
                }
            }
            var referencedMethods = Set<String>()
            
            if let enums = cdef.enums {
                generateEnums (values: enums)
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
