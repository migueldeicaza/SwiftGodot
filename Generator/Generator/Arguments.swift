//
//  Arguments.swift
//  Generator
//
//  Created by Miguel de Icaza on 4/5/23.
//

import Foundation
import ExtensionApi
import SwiftSyntax
import SwiftSyntaxBuilder

func godotArgumentToSwift (_ name: String) -> String {
    return escapeSwift (snakeToCamel (name))
}

func isSmallInt(_ arg: JGodotArgument) -> Bool {
    if arg.type != "int" {
        return false
    }
    switch getGodotType(arg, kind: .classes) {
    case "Int32", "UInt32", "Int16", "UInt16", "Int8", "UInt8":
        return true
    default:
        return false
    }
}

func getArgumentDeclaration(_ argument: JGodotArgument, omitLabel: Bool, kind: ArgumentKind = .classes, isOptional: Bool) -> String {
    //let optNeedInOut = isCoreType(name: argument.type) ? "inout " : ""
    let optNeedInOut = ""
    
    var def: String = ""
    if var dv = argument.defaultValue, dv != "" {
        func dvMissing(_ kind: String) {
            #if WARN_MISSING
                print("Generator/default_value: no support for [\(kind)] = \(dv)")
            #endif
        }
        
        let argumentType = argument.type
        
        // This method is useful to customize the output of a call to a constructor
        // it splits out the arguments into an array of strings, calls the constructor
        // and then puts together the constructor invocation
        func makeWith (_ callback: ([String]) -> String) -> String {
            if #available(iOS 16.0, *) {
                let values = String (dv [dv.firstIndex(of: "(")!...].dropFirst ().dropLast()).split (separator: ", ").map { String ($0) }
                let res = callback (values)
                return " = \(argumentType) (\(res))"
            } else {
                fatalError("You need a modern MacOS to build this")
            }
        }
        // Given a dv of "Vector (1,0)" returns a SwiftGodot suitable "Vector(x: 1, y: 0)" based on the
        // args value that contains the desired labels
        func makeDef (_ args: [String]) -> String {
            // Turn a string like 'Vector2(0, 1)' into the array of values ["0", "1"]
            makeWith { values in
                return zip (args, values).map { v in String ("\(v.0): \(v.1)") }.joined (separator: ", ")
            }
        }
        
        // TODO:
        //  - handle creating initializers from enums (builtint)
        //  - empty arrays
        //  - Structure with initialized values (Color (1,1,1,1))
        //  - NodePath ("") ctor
        //  - nil values (needs to both turn the value nullable and handle that in the marshal code
        //  - typedarrays, the default values need to be handled one by one, or a general conversion
        // system needs to be implemented
        if !argumentType.starts(with: "Array") && !argumentType.starts(with: "bitfield::") && (!isStruct(argumentType) || isPrimitiveType(name: argumentType)) && argumentType != "NodePath" && !argumentType.starts(with: "typedarray::") && !argumentType.starts (with: "Dictionary") && dv != "null" {
            if argument.type == "String" {
                def = " = \(dv)"
            } else if argument.type == "StringName" {
                // GDScript has StringName literals, e.g. &"example" == StringName("example")
                // Some of the default values are marked as such literals in extension_api.json
                if dv.starts(with: "&") {
                    dv = String(dv.dropFirst())
                }
                def = " = StringName (\(dv))"
            } else if argument.type.starts(with: "enum::"){
                if let ev = mapEnumValue (enumDef: argument.type, value: dv) {
                    def = " = \(ev)"
                }
            } else if argumentType == "Variant" {
                dvMissing ("Variant")
            } else {
                def = " = \(dv)"
            }
        } else {
            // Here we add the new conversions, will eventually replace everything
            // above, as the do-not-run conditions are becoming large and difficult
            // to parse - they were fine to bootstrap, but not for the long term.
            
            switch argumentType {
                // Handle empty type arrays
            case let at where at.hasPrefix("typedarray::"):
                // We can not generate an array value for RDPipelineSpecializationConstant because it has no public constructor
                if dv == "[]" || dv.hasSuffix("]([])") && !dv.contains("RDPipelineSpecializationConstant"){
                    def = " = \(getGodotType(argument, kind: kind)) ()"
                } else {
                    dvMissing (argumentType)
                }
            case "Dictionary":
                if dv == "{}" {
                    def = " = GDictionary ()"
                } else {
                    dvMissing (argumentType)
                }
            case let bt where bt.hasPrefix("bitfield::"):
                if let defIntValue = Int (dv) {
                    if defIntValue == 0 {
                        def = " = []"
                    } else {
                        // Need to look it up
                        if let optionType = findEnumDef(name: argumentType) {
                            let prefix = optionType.values.commonPrefix()
                            var setValues = ""
                            
                            for value in optionType.values {
                                if (defIntValue & value.value) != 0 {
                                    let name = snakeToCamel(value.name.dropPrefix(prefix))
                                    if setValues != "" {
                                        setValues += ", "
                                    }
                                    setValues += ".\(name)"
                                }
                            }
                            def = " = [\(setValues)]"
                        } else {
                            dvMissing ("\(argumentType) due to not being able to lookup the type")
                        }
                    }
                } else {
                    dvMissing ("bitfield:: with a non-integer default value")
                }
            case "Array":
                if dv == "[]" {
                    def = " = GArray ()"
                } else {
                    // Tracked: https://github.com/migueldeicaza/SwiftGodot/issues/7
                    dvMissing ("arrays with values")
                    print ("Generator: no support for arrays with values: \(dv)")
                }
            case "Vector2":
                def = makeDef (["x", "y"])
            case "Vector2i":
                def = makeDef (["x", "y"])
            case "Vector3":
                def = makeDef (["x", "y", "z"])
            case "Color":
                def = makeDef (["r", "g", "b", "a"])
            case "Rect2":
                def = makeDef (["x", "y", "width", "height"])
            case "Rect2i":
                def = makeDef (["x", "y", "width", "height"])
            case "Transform2D":
                def = makeWith { a in
                    return "xAxis: Vector2 (x: \(a[0]), y: \(a[1])), yAxis: Vector2 (x: \(a[2]), y: \(a[3])), origin: Vector2 (x: \(a[4]), y: \(a[5]))"
                }
            case "NodePath":
                def = " = \(dv)"
            case "Transform3D":
                def = makeWith { a in
                    return "xAxis: Vector3 (x: \(a[0]), y: \(a[1]), z: \(a[2])), yAxis: Vector3 (x: \(a[3]), y: \(a[4]), z: \(a[5])), zAxis: Vector3(x: \(a[6]), y: \(a[7]), z: \(a[8])), origin: Vector3 (x: \(a[9]), y: \(a[10]), z: \(a[11]))"
                }
            case "Variant":
                if dv == "0" {
                    def = "Variant (0)"
                }
            default:
                if dv == "null" {
                    if argumentType == "Variant" {
                        def = " = Variant ()"
                    } else {
                        def = " = nil"
                    }
                } else {
                    dvMissing ("General \(argumentType)")
                }
            }
        }
    }
    
    let prefix = omitLabel ? "_ " : ""
    
    return "\(prefix)\(godotArgumentToSwift (argument.name)): \(optNeedInOut)\(getGodotType(argument, kind: kind))\(isOptional ? "?" : "")\(def)"
}

// The name of the form 'bitfield::'
private func findEnumDef (name: String) -> JGodotGlobalEnumElement? {
    guard name.starts(with: "bitfield::") else {
        return nil
    }

    let full = name.dropFirst(10)
    guard let split = full.firstIndex(of: ".") else {
        print ("No support for global bitfields for \(name)")
        return nil
    }
    let type = full [full.startIndex..<split]
    guard let cdef = classMap [String (type)] else {
        print ("Could not find class \(type) for \(name)")
        return nil
    }
    let enumName = full [full.index(split, offsetBy: 1)...]
    guard let enums = cdef.enums else {
        print ("Could not find an enum \(enumName) in \(type)")
        return nil
    }
    for x in enums {
        if x.name == enumName {
            return x
        }
    }
    return nil
}
