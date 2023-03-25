//
//  TypeHelpers.swift
//  Generator
//
//  Created by Miguel de Icaza on 3/25/23.
//

import Foundation

func jsonTypeToSwift (_ type: String) -> String {
    switch type {
    case "float": return "Float"
    case "int": return "Int32"
    case "bool": return "Bool"
    default:
        return type
    }
}


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

