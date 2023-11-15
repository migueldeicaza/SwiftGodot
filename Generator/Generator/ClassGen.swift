//
//  ClassGen.swift
//  Generator
//
//  Created by Miguel de Icaza on 3/26/23.
//

import Foundation
import ExtensionApi

// Populated with the types loaded from the api.json, we assume they are all reference types
// anything else is not
var referenceTypes: [String:Bool] = [:]

// Maps a typename to its toplevel Json element
var tree: [String: JGodotExtensionAPIClass] = [:]

var typeToChildren: [String:[String]] = [:]

func makeDefaultInit (godotType: String, initCollection: String = "") -> String {
    switch godotType {
    case "int":
        return "0"
    case "float":
        return "0.0"
    case "bool":
        return "false"
    case "String":
        return "String ()"
    case "Array":
        return "GArray ()"
    case "Dictionary":
        return "GDictionary ()"
    case let t where t.starts (with: "typedarray::"):
        let nestedTypeName = String (t.dropFirst(12))
        let simple = SimpleType(type: nestedTypeName)
        if classMap [nestedTypeName] != nil {
            return "ObjectCollection<\(getGodotType (simple))>(\(initCollection))"
        } else {
            return "VariantCollection<\(getGodotType (simple))>(\(initCollection))"
        }
    case "enum::Error":
        return ".ok"
    case "enum::Variant.Type":
        return ".`nil`"
    case let e where e.starts (with: "enum::"):
        return "\(e.dropFirst(6))(rawValue: 0)!"
    case let e where e.starts (with: "bitfield::"):
        let simple = SimpleType (type: godotType, meta: nil)
        return "\(getGodotType (simple)) ()"
   
    case let other where builtinGodotTypeNames [other] != nil:
        return "\(godotType) ()"
    case "void*", "const Glyph*":
        return "nil"
    default:
        if isCoreType(name: godotType) {
            return "\(getGodotType(SimpleType (type: godotType))) ()"
        } else {
            return "\(getGodotType(SimpleType (type: godotType))) (fast: true)"
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

func generateVirtualProxy (_ p: Printer,
                           cdef: JGodotExtensionAPIClass,
                           methodName: String,
                           method: JGodotClassMethod) {
    // Generate the glue for the virtual methods (those that start with an underscore in Godot
    guard method.isVirtual else {
        print ("ERROR: internally, we passed methods that are not virtual")
        return
    }
    let virtRet: String?
    var returnOptional = false
    if let ret = method.returnValue {
        let godotReturnType = ret.type
        let godotReturnTypeIsReferenceType = classMap [godotReturnType] != nil
        returnOptional = godotReturnTypeIsReferenceType && isReturnOptional(className: cdef.name, method: methodName)

        virtRet = getGodotType(ret)
    } else {
        virtRet = nil
    }
    p ("func _\(cdef.name)_proxy\(method.name) (instance: UnsafeMutableRawPointer?, args: UnsafePointer<UnsafeRawPointer?>?, retPtr: UnsafeMutableRawPointer?)") {
        p ("guard let instance else { return }")
        if let arguments = method.arguments, arguments.count > 0 {
            p ("guard let args else { return }")
        }
        p ("let swiftObject = Unmanaged<\(cdef.name)>.fromOpaque(instance).takeUnretainedValue()")
        
        var argCall = ""
        var argPrep = ""
        var i = 0
        for arg in method.arguments ?? [] {
            if argCall != "" { argCall += ", " }
            let argName = escapeSwift (snakeToCamel (arg.name))
            
            // Drop the first argument name for methods whose name already include the argument
            // name, like 'setMultiplayerPeer (peer: ..)' becomes 'setMultiplayerPeer (_ peer: ...)'
            if i > 0 || !method.name.hasSuffix("_\(arg.name)") {
                argCall += "\(argName): "
            }
            if arg.type == "String" {
                argCall += "GString.stringFromGStringPtr (ptr: args [\(i)]!) ?? \"\""
            } else if classMap [arg.type] != nil {
                //
                // This idiom guarantees that: if this is a known object, we surface this
                // object, but if it is not known, then we create the instance
                //
                argPrep += "let resolved_\(i) = args [\(i)]!.load (as: UnsafeRawPointer.self)\n"
                let handleResolver: String
                if hasSubclasses.contains(cdef.name) {
                    // If the type we are bubbling up has subclasses, we want to create the most
                    // derived type if possible, so we perform the longer lookup
                    handleResolver = "lookupObject (nativeHandle: resolved_\(i))!"
                } else {
                    // There are no subclasses, so we can create the object right away
                    handleResolver = "\(arg.type) (nativeHandle: resolved_\(i))"
                }
                argCall += "lookupLiveObject (handleAddress: resolved_\(i)) as? \(arg.type) ?? \(handleResolver)"
            } else if let storage = builtinClassStorage [arg.type] {
                argCall += "\(mapTypeName (arg.type)) (content: args [\(i)]!.assumingMemoryBound (to: \(storage).self).pointee)"
            } else {
                let gt = getGodotType(arg)
                argCall += "args [\(i)]!.assumingMemoryBound (to: \(gt).self).pointee"
            }
            i += 1
        }
        let hasReturn = method.returnValue != nil
        if argPrep != "" {
            p (argPrep)
        }
        var call = "swiftObject.\(methodName) (\(argCall))"
        if method.returnValue?.type == "String" {
            call = "GString (\(call))"
        }
        if hasReturn {
            p ("let ret = \(call)")
        } else {
            p ("\(call)")
        }
        if let ret = method.returnValue {
            if isStructMap [ret.type] ?? false || isStructMap [virtRet ?? "NON_EXIDTENT"] ?? false || ret.type.starts(with: "bitfield::"){
                p ("retPtr!.storeBytes (of: ret, as: \(virtRet!).self)")
            } else if ret.type.starts(with: "enum::") {
                p ("retPtr!.storeBytes (of: Int32 (ret.rawValue), as: Int32.self)")
            } else if ret.type.contains("*") {
                p ("retPtr!.storeBytes (of: ret, as: OpaquePointer?.self)")
            } else {
                let derefField: String
                let derefType: String
                if ret.type.starts(with: "typedarray::") {
                    derefField = "array.content"
                    derefType = "type (of: ret.array.content)"
                } else if classMap [ret.type] != nil {
                    derefField = "handle"
                    derefType = "UnsafeRawPointer?.self"
                } else {
                    derefField = "content"
                    derefType = "type (of: ret.content)"
                }
                
                let target: String
                if ret.type.starts (with: "typedarray::") {
                    target = "array.content"
                } else {
                    target = classMap [ret.type] != nil ? "handle" : "content"
                }
                p ("retPtr!.storeBytes (of: ret\(returnOptional ? "?" : "").\(derefField), as: \(derefType)) // \(ret.type)")
                
                // Poor man's transfer the ownership: we clear the content
                // so the destructor has nothing to act on, because we are
                // returning the reference to the other side.
                if target == "content" {
                    let type = getGodotType(SimpleType(type: ret.type))
                    switch type {
                    case "String":
                        p ("ret.content = GString.zero")
                    case "Array":
                        p ("ret.content = GArray.zero")
                    default:
                        p ("ret.content = \(type).zero")
                    }
                }
            }
        }
    }
}

// Dictioanry of Godot Type Name to array of method names that can get a @discardableResult
var discardableResultList: [String: Set<String>] = [
    "Object": ["emit_signal"],
    "GArray": ["append"],
    "PackedByteArray": ["append"],
    "PackedColorArray": ["append"],
    "PackedFloat32Array": ["append"],
    "PackedFloat64Array": ["append"],
    "PackedInt32Array": ["append"],
    "PackedInt64Array": ["append"],
    "PackedStringArray": ["append"],
    "PackedVector2Array": ["append"],
    "PackedVector3Array": ["append"],
    "CharacterBody2D": ["move_and_slide"]
]

func generateMethod (_ p: Printer, method: MethodDefinition) {
    
}
///
/// Returns a hashtable mapping a godot method name to a Swift Name + its definition
/// this list is used to generate later the proxies outside the class
///
func generateMethods (_ p: Printer,
                      cdef: JGodotExtensionAPIClass,
                      docClass: DocClass?,
                      methods: [JGodotClassMethod],
                      usedMethods: Set<String>,
                      asSingleton: Bool) -> [String:(String, JGodotClassMethod)] {
    p ("/* Methods */")
    
    var virtuals: [String:(String, JGodotClassMethod)] = [:]
   
    for method in methods {
        if let virtualMethodName = methodGen (p, method: method, className: cdef.name, cdef: cdef, docClass: docClass, usedMethods: usedMethods, kind: .class, asSingleton: asSingleton) {
            virtuals [method.name] = (virtualMethodName, method)
        }
    }
    
    if virtuals.count > 0 {
        p ("override class func getVirtualDispatcher (name: StringName) -> GDExtensionClassCallVirtual?"){
            p ("guard implementedOverrides().contains(name) else { return nil }")
            p ("switch name.description") {
                for name in virtuals.keys.sorted() {
                    p ("case \"\(name)\":")
                    p ("    return _\(cdef.name)_proxy\(name)")
                }
                p ("default:")
                p ("    return super.getVirtualDispatcher (name: name)")
            }
        }
    }
    return virtuals
}

func generateConstants (_ p: Printer,
                        cdef: JGodotExtensionAPIClass,
                        docClass: DocClass?,
                        _ constants: [JGodotValueElement]) {
    p ("/* Constants */")
    let docConstants = docClass?.constants?.constant
    
    for constant in constants {
        for dc in docConstants ?? [] {
            if dc.name == constant.name {
                doc (p, cdef, "\(dc.rest)")
            }
        }
        p ("public static let \(snakeToCamel (constant.name)) = \(constant.value)")
    }
}
func generateProperties (_ p: Printer,
                         cdef: JGodotExtensionAPIClass,
                         docClass: DocClass?,
                         _ properties: [JGodotProperty],
                         _ methods: [JGodotClassMethod],
                         _ referencedMethods: inout Set<String>,
                         asSingleton: Bool)
{
    p ("\n/* Properties */\n")

    func findMethod (forProperty: JGodotProperty, startAt: JGodotExtensionAPIClass, name: String, resolvedName: inout String, argName: inout String) -> JGodotClassMethod? {
        if let here = methods.first(where: { $0.name == name}) {
            return here
        }
        var cdef: JGodotExtensionAPIClass? = startAt
        while true {
            guard let parentName = cdef?.inherits, parentName != "" else {
                return nil
            }
            cdef = classMap [parentName]
            guard let cdef else {
                print ("Warning: Missing type \(parentName)")
                return nil
            }
            if let there = cdef.methods?.first (where: { $0.name == name }) {
                //print ("Congrats, found a method that was previously missing!")
                
                // Now, if the parent class has a property referencing this,
                // we use the mapped name, otherwise, we use the raw name
                if cdef.properties?.contains(where: { $0.getter == there.name || $0.setter == there.name }) ?? false {
                    return there
                }
                resolvedName = godotMethodToSwift (there.name)
                if let aname = there.arguments?.first?.name {
                    // Now check thta this argument does not need to be dropped
                    if !there.name.hasSuffix("_\(aname)") {
                        argName = aname + ": "
                    }
                }
                return there
            }
        }
    }
    
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
        
        var getterName = property.getter
        var gettterArgName = ""
        guard let method = findMethod (forProperty: property, startAt: cdef, name: property.getter, resolvedName: &getterName, argName: &gettterArgName) else {
            // Not a bug, but needs to be handled https://github.com/migueldeicaza/SwiftGodot/issues/67
            //print ("GodotBug: \(loc): property declared \(property.getter), but it does not exist with that name")
            continue
        }
        var setterName = property.setter ?? ""
        var setterArgName = ""
        var setterMethod: JGodotClassMethod? = nil
        if let psetter = property.setter {
            setterMethod = findMethod(forProperty: property, startAt: cdef, name: psetter, resolvedName: &setterName, argName: &setterArgName)
            if setterMethod == nil {
                // Not a bug, but needs to be handled: https://github.com/migueldeicaza/SwiftGodot/issues/67
                //print ("GodotBug \(loc) property declared \(property.setter!) but it does not exist with that name")
                continue
            }
        }

        if method.arguments?.count ?? 0 > 1 {
            print ("WARNING \(loc) property references a getter method that takes more than one argument")
            continue
        }
        if setterMethod?.arguments?.count ?? 0 > 2 {
            print ("WARNING \(loc) property references a getter method that takes more than two arguments")
            continue
        }
        guard (method.returnValue?.type) != nil else {
            print ("WARNING \(loc) Could not get a return type for method")
            continue
        }
        let godotReturnType = method.returnValue?.type
        let godotReturnTypeIsReferenceType = classMap [godotReturnType ?? ""] != nil

        let propertyOptional = godotReturnTypeIsReferenceType && isReturnOptional(className: cdef.name, method: property.getter)
        
        // Lookup the type from the method, not the property,
        // sometimes the method is a GString, but the property is a StringName
        type = getGodotType (method.returnValue) + (propertyOptional ? "?" : "")
        

        // Ok, we have an indexer, this means we call the property with an int
        // but we need the type from the method
        var access: String
        if let idx = property.index {
            let type = getGodotType(method.arguments! [0])
            if type == "Int32" {
                access = "\(idx)"
            } else {
                access = "\(type) (rawValue: \(idx))!"
            }
        } else {
            access = ""
        }
        
        if let docClass, let members = docClass.members {
            if let docMember = members.member.first(where: { $0.name == property.name }) {
                doc (p, cdef, docMember.value)
            }
        }
        p ("\(asSingleton ? "static" : "final") public var \(godotPropertyToSwift (property.name)): \(type!)"){
            p ("get"){
                p ("return \(getterName) (\(gettterArgName)\(access))")
            }
            referencedMethods.insert (property.getter)
            if let setter = property.setter {
                p ("set") {
                    var value = "newValue"
                    if type == "StringName" && setterMethod?.arguments![0].type == "String" {
                        value = "String (newValue)"
                    }
                    var ignore = ""
                    if setterMethod?.returnValue != nil {
                        ignore = "_ = "
                    }
                    p ("\(ignore)\(setterName) (\(access)\(access != "" ? ", " : "")\(setterArgName)\(value))")
                }
                referencedMethods.insert (setter)
            }
        }
    }
}

#if false
var okList = [ "RefCounted", "Node", "Sprite2D", "Node2D", "CanvasItem", "Object", "String", "StringName", "AStar2D", "Material", "Camera3D", "Node3D", "ProjectSettings", "MeshInstance3D", "BoxMesh", "SceneTree", "Window", "Label", "Timer", "AudioStreamPlayer", "PackedScene", "PathFollow2D", "InputEvent", "ClassDB", "AnimatedSprite2D", "Input", "CollisionShape2D", "SpriteFrames", "RigidBody2D" ]
#else
var okList: [String] = []
#endif

func generateClasses (values: [JGodotExtensionAPIClass], outputDir: String?) async {
    // TODO: duplicate, we can remove this and use classMap
    // Assemble all the reference types, we use to test later
    for cdef in values {
        referenceTypes[cdef.name] = true
    }
    // TODO: no longer used, probably can remove
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
    
    // Collect all the signals
//    for cdef in values {
//        if let signals = cdef.signals {
//            for signal in signals {
//                if signal.arguments! [0] == signal.arguments! [1] {
//
//                }
//            }
//        }
//    }
    
    await withTaskGroup(of: Void.self) { group in
        for cdef in values {
            group.addTask {
                await processClass (cdef: cdef, outputDir: outputDir)
            }
        }
    }
}

func generateSignalType (_ p: Printer, _ cdef: JGodotExtensionAPIClass, _ signal: JGodotSignal, _ name: String) -> String {
    doc (p, cdef, "Signal support.\n")
    doc (p, cdef, "Use the ``\(name)/connect(flags:_:)`` method to connect to the signal on the container object, and ``\(name)/disconnect(_:)`` to drop the connection.\nYou can also await the ``\(name)/emitted`` property for waiting for a single emission of the signal.")
    
    var lambdaFull = ""
    p ("public class \(name)") {
        p ("var target: Object")
        p ("var signalName: StringName")
        p ("init (target: Object, signalName: StringName)") {
            p ("self.target = target")
            p ("self.signalName = signalName")
        }
        doc (p, cdef, "Connects the signal to the specified callback\n\nTo disconnect, call the disconnect method, with the returned token on success\n - Parameters:\n  - callback: the method to invoke when this signal is raised\n  - flags: Optional, can be also added to configure the connection's behavior (see ``Object/ConnectFlags`` constants).\n - Returns: an object token that can be used to disconnect the object from the target on success, or the error produced by Godot.")
        
        p ("@discardableResult /* \(name) */")
        var args = ""
        var argUnwrap = ""
        var callArgs = ""
        var argIdx = 0
        var lambdaIgnore = ""
        for arg in signal.arguments ?? [] {
            if args != "" {
                args += ", "
                callArgs += ", "
                lambdaIgnore += ", "
                lambdaFull += ", "
            }
            args += getArgumentDeclaration(arg, eliminate: "_ ", isOptional: false)
            let construct: String
            
            if let _ = classMap [arg.type] {
                argUnwrap += "var ptr_\(argIdx): UnsafeMutableRawPointer?\n"
                argUnwrap += "args [\(argIdx)].toType (Variant.GType.object, dest: &ptr_\(argIdx))\n"
                construct = "lookupLiveObject (handleAddress: ptr_\(argIdx)!) as? \(arg.type) ?? \(arg.type) (nativeHandle: ptr_\(argIdx)!)"
            } else if arg.type == "String" {
                    construct = "\(mapTypeName(arg.type)) (args [\(argIdx)])!.description"
            } else if arg.type == "Variant" {
                construct = "args [\(argIdx)]"
            } else {
                construct = "\(getGodotType(arg)) (args [\(argIdx)])!"
            }
            argUnwrap += "let arg_\(argIdx) = \(construct)\n"
            callArgs += "arg_\(argIdx)"
            lambdaIgnore += "_"
            lambdaFull += escapeSwift (snakeToCamel (arg.name))
            argIdx += 1
        }
        p ("public func connect (flags: Object.ConnectFlags = [], _ callback: @escaping (\(args)) -> ()) -> Object") {
            p ("let signalProxy = SignalProxy()")
            p ("signalProxy.proxy = ") {
                p ("args in")
                p (argUnwrap)
                p ("callback (\(callArgs))")
            }
            p ("let callable = Callable(object: signalProxy, method: SignalProxy.proxyName)")
            p ("let r = target.connect(signal: signalName, callable: callable, flags: UInt32 (flags.rawValue))")
            p ("if r != .ok { print (\"Warning, error connecting to signal, code: \\(r)\") }")
            p ("return signalProxy")
        }

        doc (p, cdef, "Disconnects a signal that was previously connected, the return value from calling ``connect(flags:_:)``")
        p ("public func disconnect (_ token: Object)") {
            p ("target.disconnect(signal: signalName, callable: Callable (object: token, method: SignalProxy.proxyName))")
        }
        doc (p, cdef, "You can await this property to wait for the signal to be emitted once")
        p ("public var emitted: Void "){
            p ("get async") {
                p ("await withCheckedContinuation") {
                    p ("c in")
                    p ("connect (flags: .oneShot) { \(lambdaIgnore) in c.resume () }")
                }
            }
        }
    }
    return lambdaFull
}

func generateSignals (_ p: Printer,
                      cdef: JGodotExtensionAPIClass,
                      docClass: DocClass?,
                      signals: [JGodotSignal]) {
    p ("// Signals ")
    var parameterSignals: [JGodotSignal] = []
    var sidx = 0
    
    for signal in signals {
        let signalProxyType: String
        let lambdaSig: String
        if signal.arguments != nil {
            parameterSignals.append (signal)
            
            sidx += 1
            signalProxyType = "Signal\(sidx)"
            lambdaSig = " " + generateSignalType (p, cdef, signal, signalProxyType) + " in"
        } else {
            signalProxyType = "SimpleSignal"
            lambdaSig = ""
        }
        let signalName = godotMethodToSwift (signal.name)
        
        if let sdoc = docClass?.signals?.signal.first (where: { $0.name == signal.name }) {
            doc (p, cdef, sdoc.description)
            p ("///")
        }
        doc (p, cdef, "To connect to this signal, reference this property and call the\n`connect` method with the method you want to invoke\n")
        doc (p, cdef, "Example:")
        doc (p, cdef, "```swift")
        doc (p, cdef, "obj.\(signalName).connect {\(lambdaSig)")
        p ("///    print (\"caught signal\")\n/// }")
        doc (p, cdef, "```")
        p ("public var \(signalName): \(signalProxyType) { \(signalProxyType) (target: self, signalName: \"\(signal.name)\") }")
        p ("")
    }
}

func generateSignalDocAppendix (_ p: Printer, cdef: JGodotExtensionAPIClass, signals: [JGodotSignal]?) {
    guard let signals = signals, signals.count > 0 else {
        return
    }
    if signals.count > 0 {
        doc (p, cdef, "\nThis object emits the following signals:")
    } else {
        doc (p, cdef, "\nThis object emits this signal:")
    }
    for signal in signals {
        let signalName = godotMethodToSwift (signal.name)
        doc (p, cdef, "- ``\(signalName)``")
    }
}

func processClass (cdef: JGodotExtensionAPIClass, outputDir: String?) async {
    let docClass = loadClassDoc(base: docRoot, name: cdef.name)
    
    // Determine if it is a singleton, but exclude EditorInterface
    let isSingleton = jsonApi.singletons.contains (where: { $0.name == cdef.name })
    let asSingleton = isSingleton && cdef.name != "EditorInterface"
    
    // Clear the result
    let p = await PrinterFactory.shared.initPrinter()
    p.preamble()
    p ("// Generated by Swift code generator - do not edit\n@_implementationOnly import GDExtension\n")
    
    // Save it
    defer {
        if let outputDir {
            p.save(outputDir + "\(cdef.name).swift")
        }
    }
    
    let inherits = cdef.inherits ?? "Wrapped"
    var conformances: [String] = []
    if cdef.name == "Object" {
        conformances.append("GodotObject")
    }
    var proto = ""
    if conformances.count > 0 {
        proto = ", " + conformances.joined(separator: ", ")
    } else {
        proto = ""
    }
    
    let typeDecl = "open class \(cdef.name): \(inherits)\(proto)"
    
    var virtuals: [String: (String, JGodotClassMethod)] = [:]
    doc (p, cdef, docClass?.brief_description)
    if docClass?.description ?? "" != "" {
        doc (p, cdef, "")      // Add a newline before the fuller description
        doc (p, cdef, docClass?.description)
    }
    generateSignalDocAppendix (p, cdef: cdef, signals: cdef.signals)
    // class or extension (for Object)
    p (typeDecl) {
        if isSingleton {
            p ("/// The shared instance of this class")
            p ("public static var shared: \(cdef.name) =", suffix: "()") {
                p ("withUnsafePointer (to: &\(cdef.name).className.content)", arg: " ptr in") {
                    p ("\(cdef.name) (nativeHandle: gi.global_get_singleton (ptr)!)")
                }
            }
        }
        p ("static private var className = StringName (\"\(cdef.name)\")")
        p ("/// Creates a \(cdef.name) that wraps the Godot native object pointed to by the nativeHandle")
        p ("public required init (nativeHandle: UnsafeRawPointer)") {
            p("super.init (nativeHandle: nativeHandle)")
        }
        p ("/// Ths initializer is invoked by derived classes as they chain through their most derived type name that our framework produced")
        p ("internal override init (name: StringName)") {
            p("super.init (name: name)")
        }
        
        let fastInitOverrides = cdef.inherits != nil ? "override " : ""
        
        p ("internal \(fastInitOverrides)init (fast: Bool)") {
            p ("super.init (name: \(cdef.name).className)")
        }
        if cdef.isInstantiable {
            p ("/// Initializes a new instance of the type \(cdef.name), call this constructor")
            p ("/// when you create a subclass of this type.")
            p ("public required init ()") {
                p ("super.init (name: StringName (\"\(cdef.name)\"))")
                p ("let _ = Self.classInitializer")
            }
        } else {
            p ("/// This class can not be instantiated by user code")
            p ("public required init ()") {
                p ("fatalError (\"You cannot subclass or instantiate \(cdef.name) directly\")")
            }
        }
        
        var referencedMethods = Set<String>()
        
        if let enums = cdef.enums {
            generateEnums (p, cdef: cdef, values: enums, constantDocs: docClass?.constants?.constant, prefix: nil)
        }
        
        let oResult = p.result
        
        if let constants = cdef.constants {
            generateConstants (p, cdef: cdef, docClass: docClass, constants)
        }
        
        if let properties = cdef.properties {
            generateProperties (p, cdef: cdef, docClass: docClass, properties, cdef.methods ?? [], &referencedMethods, asSingleton: asSingleton)
        }
        if let methods = cdef.methods {
            virtuals = generateMethods (p, cdef: cdef, docClass: docClass, methods: methods, usedMethods: referencedMethods, asSingleton: asSingleton)
        }
        
        if let signals = cdef.signals {
            generateSignals (p, cdef: cdef, docClass: docClass, signals: signals)
        }

        // Remove code that we did not want generated
        if okList.count > 0 && !okList.contains (cdef.name) {
            p.result = oResult
        }
        
        if cdef.name == "Object" {
            p ("open class var classInitializer: Void { () }")
        }
    }

    if virtuals.count > 0 {
        p ("// Support methods for proxies")
        for k in virtuals.keys.sorted () {
            guard let (methodName, methodDef) = virtuals [k] else {
                print ("Internal error: in processClass \(cdef.name)")
                continue
            }
            if okList.count == 0 || okList.contains (cdef.name) {
                generateVirtualProxy(p, cdef: cdef, methodName: methodName, method: methodDef)
            }
        }
    }
}

func generateCtorPointers (_ p: Printer) {
    p ("var godotFrameworkCtors = [")
    for x in referenceTypes.keys.sorted() {
        p ("    \"\(x)\": \(x).self, //(nativeHandle:),")
    }
    p ("]")
}
