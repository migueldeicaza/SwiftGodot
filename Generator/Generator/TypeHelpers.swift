//
//  TypeHelpers.swift
//  Generator
//
//  Created by Miguel de Icaza on 3/25/23.
//

import Foundation
import ExtensionApi

// This is the configuration float_64, which means
// 32-bit floats, but 64 bit ints.
func BuiltinJsonTypeToSwift (_ type: String) -> String {
    switch type {
    case "float": return "Float"
    case "int": return "Int"
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

/// Returns true for the Built-in types that are generated as classes, rather than structures
func isBuiltinClass (_ godotTypeName: String) -> Bool {
    builtinClassStorage [godotTypeName] != nil
}

/// Given an enumeration name, and a value associated with it, returns the Swift
/// enum value, or nil if it can not be found.
/// Example type: "ArrowDirection", value: "0" would return ".up"
func mapEnumValue (enumDef: String, value: String) -> String? {
    func findEnumMatch (element:  JGodotGlobalEnumElement) -> String? {
        let enumCasePrefix = element.values.commonPrefix()
        for evalue in element.values {
            let ename = evalue.name
            if ename == "INLINE_ALIGNMENT_TOP_TO" || ename == "INLINE_ALIGNMENT_TO_TOP" || ename == "INLINE_ALIGNMENT_IMAGE_MASK" || ename == "INLINE_ALIGNMENT_TEXT_MASK" {
                continue
                
            }

            if "\(evalue.value)" == value {
                let name = snakeToCamel(evalue.name.dropPrefix(enumCasePrefix))
                return ".\(escapeSwift (name))"
            }
        }
        print ("WARNING: Enum, did not find a matching value in \(enumDef) for \(value)")
        return nil
    }
    let t = enumDef.dropFirst(6)
    if let globalEnumDef = globalEnums [String (t)]  {
        return findEnumMatch(element: globalEnumDef)
    }
    guard let p = t.firstIndex(of: ".") else {
        print ("WARNING: Enum, not a global, and not a type: \(enumDef)")
        return nil
    }
    let type = t [t.startIndex..<p]
    let enumt = t [t.index(p, offsetBy: 1)...]
    guard let x = classMap [String (type)] else {
        print ("WARNING: Enum, could not find type \(type) for \(enumDef)")
        return nil
    }
    for e in x.enums ?? [] {
        if e.name == enumt {
            return findEnumMatch(element: e)
        }
    }
    print ("WARNING: Enum. did not find a matching value in \(enumDef) for \(value)")
    return nil
}

func godotMethodToSwift (_ name: String) -> String {
    return escapeSwift (snakeToCamel(name))
}

func godotPropertyToSwift (_ name: String) -> String {
    let v = escapeSwift (snakeToCamel(name))
    if v == "description" {
        return "additionalDescription"
    }
    return v
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
    return name == "int" || name == "bool" || name == "float" || name == "void" || name.hasPrefix("enum::") || name.hasPrefix("bitfield::")
}

func mapTypeName (_ name: String) -> String {
    if name == "String" {
        return "GString"
    }
    if name == "Array" {
        return "GArray"
    }
    if name == "Dictionary" {
        return "GDictionary"
    }
    return name
}
func mapTypeNameDoc (_ name: String) -> String {
    if name == "String" {
        return "String"
    }
    if name == "Type" {
        return "GType"
    }
    if name == "Dictionary" {
        return "GDictionary"
    }
    return mapTypeName (name)
}

func gtypeFromTypeName (_ name: String) -> String {
    switch name {
    case "Nil": return "`nil`"
    case "Bool": return "bool"
    case "Int": return "int"
    case "String": return "string"
    case "Vector2": return "vector2"
    case "Vector2i": return "vector2i"
    case "Rect2": return "rect2"
    case "Rect2i": return "rect2i"
    case "Vector3": return "vector3"
    case "Vector3i": return "vector3i"
    case "Transform2D": return "transform2d"
    case "Vector4": return "vector4"
    case "Vector4i": return "vector4i"
    case "Plane": return "plane"
    case "Quaternion": return "quaternion"
    case "AABB": return "aabb"
    case "Basis": return "basis"
    case "Transform3D": return "transform3d"
    case "Projection": return "projection"
    case "Color": return "color"
    case "StringName": return "stringName"
    case "NodePath": return "nodePath"
    case "RID": return "rid"
    case "Object": return "object"
    case "Callable": return "callable"
    case "Signal": return "signal"
    case "Dictionary": return "dictionary"
    case "Array": return "array"
    case "PackedByteArray": return "packedByteArray"
    case "PackedInt32Array": return "packedInt32Array"
    case "PackedInt64Array": return "packedInt64Array"
    case "PackedFloat32Array": return "packedFloat32Array"
    case "PackedFloat64Array": return "packedFloat64Array"
    case "PackedStringArray": return "packedStringArray"
    case "PackedVector2Array": return "packedVector2Array"
    case "PackedVector3Array": return "packedVector3Array"
    case "PackedColorArray": return "packedColorArray"
    default:
        fatalError("Unknonw data type: \(name)")
    }
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

var mapStringToSwift = true

/// Given a type definition with its metadata, and the context where the type is being
/// useds, returns the type for it.
///
///
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
                    // Looks like Godot just ignores its own
                    // metadata of "Float" and uses Double.
                    return "Double"
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
        if mapStringToSwift {
            return "String" // We are going to use Swift strings
        } else {
            return "GString"
        }
    case "Dictionary":
        return "GDictionary"
    case "Array":
        return "GArray"
    case "void*":
        return "OpaquePointer?"
    case "const Glyph*":
        return "OpaquePointer?"
    case "Type":
        return "GType"
    case "const void*":
        return "OpaquePointer?"
    case "AudioFrame*":
        return "OpaquePointer?"
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
        if t.type.starts(with: "enum::VisualShader.Type") {
            return "VisualShader.GType"
        }
        if t.type.starts(with: "enum::IP.Type") {
            return "IP.GType"
        }
        if t.type.starts(with: "enum::") {
            
            return String (t.type.dropFirst(6))
        }
        if t.type.starts (with: "typedarray::") {
            let nestedTypeName = String (t.type.dropFirst(12))
            let nested = SimpleType(type: nestedTypeName, meta: nil)

            if classMap [nestedTypeName] != nil {
                return "ObjectCollection<\(getGodotType (nested))>"
            } else {
                return "VariantCollection<\(getGodotType (nested))>"
            }
        }
        if t.type.starts (with: "bitfield::") {
            return "\(t.type.dropFirst(10))"
        }
        return t.type
    }
}

/// Built-ins classes keep their data stored internally in a variable called
/// "content", given a godotType name of those, this returns a pair
/// containing the Swift-type that is used to store this, and a suitable initialization
/// value for it.
func getBuiltinStorage (_ name: String) -> (String, String) {
    guard let size = builtinSizes [name] else {
        fatalError()
    }
    switch size {
    case 4, 0:
        return ("Int32", " = 0")
    case 8:
        return ("Int64", " = 0")
    case 16:
        return ("(Int64, Int64)", " = (0, 0)")
    default:
        fatalError()
    }
}

// Name of the operator from the JSON file
func infixOperatorMap (_ name: String) -> (String, String)? {
    switch (name) {
    case "==": return ("GDEXTENSION_VARIANT_OP_EQUAL", "==")
    case "!=": return ("GDEXTENSION_VARIANT_OP_NOT_EQUAL", "!=")
    case "and": return ("GDEXTENSION_VARIANT_OP_AND", "&&")
    case "or": return ("GDEXTENSION_VARIANT_OP_AND", "||")
    case "<": return ("GDEXTENSION_VARIANT_OP_LESS_EQUAL", "<")
    case "<=": return ("GDEXTENSION_VARIANT_OP_LESS", "<=")
    case ">": return ("GDEXTENSION_VARIANT_OP_GREATER", ">")
    case ">=": return ("GDEXTENSION_VARIANT_OP_GREATER_EQUAL", ">=")
    case "+": return ("GDEXTENSION_VARIANT_OP_ADD", "+")
    case "-": return ("GDEXTENSION_VARIANT_OP_SUBTRACT", "-")
    case "*": return ("GDEXTENSION_VARIANT_OP_MULTIPLY", "*")
    case "/": return ("GDEXTENSION_VARIANT_OP_DIVIDE", "/")
    case "xor":
        // TODO, define our own. Swift does not support regular xor,
        return nil
    case "in":
        // TODO, define our own. Swift does not have an 'in'
        return nil
    case "%":
        return ("GDEXTENSION_VARIANT_OP_MODULE", "%")
    default:
        fatalError()
    }
}

func builtinTypecode (_ name: String) -> String {
    switch name {
    case "Nil": return "GDEXTENSION_VARIANT_TYPE_NIL"
    case "bool": return "GDEXTENSION_VARIANT_TYPE_BOOL"
    case "int": return "GDEXTENSION_VARIANT_TYPE_INT"
    case "float": return "GDEXTENSION_VARIANT_TYPE_FLOAT"
    case "String": return "GDEXTENSION_VARIANT_TYPE_STRING"
    case "Vector2": return "GDEXTENSION_VARIANT_TYPE_VECTOR2"
    case "Vector2i": return "GDEXTENSION_VARIANT_TYPE_VECTOR2I"
    case "Rect2": return "GDEXTENSION_VARIANT_TYPE_RECT2"
    case "Rect2i": return "GDEXTENSION_VARIANT_TYPE_RECT2I"
    case "Vector3": return "GDEXTENSION_VARIANT_TYPE_VECTOR3"
    case "Vector3i": return "GDEXTENSION_VARIANT_TYPE_VECTOR3I"
    case "Transform2D": return "GDEXTENSION_VARIANT_TYPE_TRANSFORM2D"
    case "Vector4": return "GDEXTENSION_VARIANT_TYPE_VECTOR4"
    case "Vector4i": return "GDEXTENSION_VARIANT_TYPE_VECTOR4I"
    case "Plane": return "GDEXTENSION_VARIANT_TYPE_PLANE"
    case "Quaternion": return "GDEXTENSION_VARIANT_TYPE_QUATERNION"
    case "AABB": return "GDEXTENSION_VARIANT_TYPE_AABB"
    case "Basis": return "GDEXTENSION_VARIANT_TYPE_BASIS"
    case "Transform3D": return "GDEXTENSION_VARIANT_TYPE_TRANSFORM3D"
    case "Projection": return "GDEXTENSION_VARIANT_TYPE_PROJECTION"
    case "Color": return "GDEXTENSION_VARIANT_TYPE_COLOR"
    case "StringName": return "GDEXTENSION_VARIANT_TYPE_STRING_NAME"
    case "NodePath": return "GDEXTENSION_VARIANT_TYPE_NODE_PATH"
    case "RID": return "GDEXTENSION_VARIANT_TYPE_RID"
    case "Object": return "GDEXTENSION_VARIANT_TYPE_OBJECT"
    case "Callable": return "GDEXTENSION_VARIANT_TYPE_CALLABLE"
    case "Signal": return "GDEXTENSION_VARIANT_TYPE_SIGNAL"
    case "Dictionary": return "GDEXTENSION_VARIANT_TYPE_DICTIONARY"
    case "Array": return "GDEXTENSION_VARIANT_TYPE_ARRAY"
    case "PackedByteArray":     return "GDEXTENSION_VARIANT_TYPE_PACKED_BYTE_ARRAY"
    case "PackedInt32Array":    return "GDEXTENSION_VARIANT_TYPE_PACKED_INT32_ARRAY"
    case "PackedInt64Array":    return "GDEXTENSION_VARIANT_TYPE_PACKED_INT64_ARRAY"
    case "PackedFloat32Array":  return "GDEXTENSION_VARIANT_TYPE_PACKED_FLOAT32_ARRAY"
    case "PackedFloat64Array":  return "GDEXTENSION_VARIANT_TYPE_PACKED_FLOAT64_ARRAY"
    case "PackedStringArray":   return "GDEXTENSION_VARIANT_TYPE_PACKED_STRING_ARRAY"
    case "PackedVector2Array":  return "GDEXTENSION_VARIANT_TYPE_PACKED_VECTOR2_ARRAY"
    case "PackedVector3Array":  return "GDEXTENSION_VARIANT_TYPE_PACKED_VECTOR3_ARRAY"
    case "PackedColorArray":    return "GDEXTENSION_VARIANT_TYPE_PACKED_COLOR_ARRAY"
    default:
        fatalError()
    }
}

