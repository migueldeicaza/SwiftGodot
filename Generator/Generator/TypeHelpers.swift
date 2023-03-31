//
//  TypeHelpers.swift
//  Generator
//
//  Created by Miguel de Icaza on 3/25/23.
//

import Foundation

// This is the configuration float_64, which means
// 32-bit floats, but 64 bit ints.
func BuiltinJsonTypeToSwift (_ type: String) -> String {
    switch type {
    case "float": return "Float"
    case "int": return "Int64"
    case "bool": return "Bool"
    default:
        return type
    }
}

// We need this separately, because this is used to generate
// the members, which for some reason use "Int32" and "Float32"
// regardless of what the sizes are declared for the API.
func MemberBuiltinJsonTypeToSwift (_ type: String) -> String {
    switch type {
    case "float": return "Float"
    case "int":
        return "Int32"
    case "bool": return "Bool"
    default:
        return type
    }
}

protocol JNameAndType: TypeWithMeta {
    var name: String { get }
    var type: String { get }
    var meta: JGodotArgumentMeta? { get }
}

extension JGodotSingleton: JNameAndType {}
extension JGodotArgument: JNameAndType {}


func isClassType (name: String) -> Bool {
    !(isCoreType(name: name) || isPrimitiveType(name: name))
}

var core_types = [
              "String",
              "Vector2",
              "Vector2i",
              "Rect2",
              "Rect2i",
              "Vector3",
              "Vector3i",
              "Transform2D",
              "Plane",
              "Quat",
              "AABB",
              "Basis",
              "Transform",
              "Color",
              "StringName",
              "NodePath",
              "RID",
              "Callable",
              "Signal",
              "Dictionary",
              "Array",
              "PackedByteArray",
              "PackedInt32Array",
              "PackedInt64Array",
              "PackedFloat32Array",
              "PackedFloat64Array",
              "PackedStringArray",
              "PackedVector2Array",
              "PackedVector3Array",
              "PackedColorArray",
              "Error",
              "Variant",
]

func isCoreType (name: String) -> Bool {
    core_types.contains(name)
}

func isPrimitiveType (name: String) -> Bool {
    return name == "int" || name == "bool" || name == "float" || name == "void" || name.hasPrefix("enum")
}

func mapTypeName (_ name: String) -> String {
    if name == "String" {
        return "GString"
    }
    if name == "Array" {
        return "GArray"
    }
    return name
}

struct SimpleType: TypeWithMeta {
    var type: String
    var meta: JGodotArgumentMeta?
}

// Built-ins if they declare methods/returns use one kind of returns
// which are different than the hardcoded values for things like
// Vectord3 or Vector3i which are Float/Int32.   This is a hotmess

enum ArgumentKind {
    // Uses type, plus "meta" to determine what to use
    case classes
    
    // Uses the hardcoded values for Int32/Float
    case builtInField
    
    // Uses the builtin-size definitions
    case builtIn
}


func getGodotType (_ t: TypeWithMeta?, kind: ArgumentKind = .classes) -> String {
    guard let t else {
        return ""
    }
    
    switch t.type {
    case "int":
        if let meta = t.meta {
            switch meta {
            case .int32:
                return "Int32"
            case .uint32:
                return "UInt32"
            case .int64:
                return "Int"
            case .uint64:
                return "UInt"
            case .int16:
                return "Int16"
            case .uint16:
                return "UInt16"
            case .uint8:
                return "UInt8"
            case .int8:
                return "Int8"
            default:
                fatalError()
            }
        } else {
            if kind == .builtInField {
                return "Int32"
            } else {
                return "Int64"
            }
        }
    case "float", "real":
        if kind == .builtInField {
            return "Float"
        } else {
            if let meta = t.meta {
                switch meta {
                case .double:
                    return "Double"
                case .float:
                    return "Float"
                default:
                    fatalError()
                }
            } else {
                return "Double"
            }
        }
    case "Nil":
        return "Variant"
    case "void":
        return ""
    case "bool":
        return "Bool"
    case "String":
        return "GString"
    case "Array":
        return "GArray"
    case "void*":
        return "OpaquePointer?"
    case "Type":
        return "GType"
    default:
        if t.type == "Error" {
            return "GodotError"
        }
        if t.type.starts(with: "enum::Error") {
            return "GodotError"
        }
        if t.type.starts(with: "enum::Variant.Type") {
            return "Variant.GType"
        }
        if t.type.starts(with: "enum::") {
            
            return String (t.type.dropFirst(6))
        }
        if t.type.starts (with: "typedarray::") {
            let nested = SimpleType(type: String (t.type.dropFirst(12)), meta: nil)
            return "GodotCollection<\(getGodotType (nested))>"
        }
        if t.type.starts (with: "bitfield::") {
            return "\(t.type.dropFirst(10))"
        }
        return t.type
    }
}

func getBuiltinStorage (_ name: String) -> String {
    guard let size = builtinSizes [name] else {
        fatalError()
    }
    switch size {
    case 4, 0:
        return "Int32 = 0"
    case 8:
        return "Int64 = 0"
    case 16:
        return "(Int64, Int64) = (0, 0)"
    default:
        fatalError()
    }
}
