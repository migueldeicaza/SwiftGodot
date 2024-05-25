//
//  GeneratorExceptions.swift
//
//
//  Created by Joey Nelson on 5/25/24.
//

import Foundation

protocol GeneratorException {
    associatedtype GodotType: ExceptionalGodotType
    associatedtype Method: ExceptionalMethod

    static func isException(typeName: String, methodName: String) -> Bool
}

protocol ExceptionalGodotType: RawRepresentable where RawValue == String {
    associatedtype Method: ExceptionalMethod

    var validMethods: [Method] { get }

    func contains(method: Method) -> Bool
}

extension ExceptionalGodotType {
    func contains(method: Method) -> Bool {
        return validMethods.contains(method)
    }
}

extension GeneratorException {
    static func isException(typeName: String, methodName: String) -> Bool {
        guard let godotType = GodotType(rawValue: typeName),
              let method = Method(rawValue: methodName) as? GodotType.Method
        else { return false }

        return godotType.contains(method: method)
    }
}

protocol ExceptionalMethod: Equatable, RawRepresentable where RawValue == String {
    init?(rawValue: String)
}

enum Exceptions {

    /// Determines if the method should be omitted from autogeneration since Source/Native has a better alternative that avoids having to access Godot pointers.
    enum OmittedMethod: GeneratorException {
        enum Method: String, ExceptionalMethod {
            case lerp, snapped
        }

        enum GodotType: String, ExceptionalGodotType {
            case color = "Color"
            case vector2 = "Vector2"
            case vector2i = "Vector2i"
            case vector3 = "Vector3"
            case vector3i = "Vector3i"
            case vector4 = "Vector4"
            case vector4i = "Vector4i"

            var validMethods: [Method] {
                switch self {
                case .color:
                    return [.lerp]
                case .vector2, .vector3, .vector4:
                    return [.lerp, .snapped]
                case .vector2i, .vector3i, .vector4i:
                    return [.snapped]
                }
            }
        }
    }

    /// Determines if the method should be annotated with the @discardableResult attribute
    enum DiscardableResult: GeneratorException {
        enum Method: String, ExceptionalMethod {
            case emitSignal = "emit_signal"
            case pushBack = "push_back"
            case moveAndSlide = "move_and_slide"
            case append, reference, unreference, lerp, snapped
        }

        enum GodotType: String, ExceptionalGodotType {
            case object = "Object"
            case gArray = "GArray"
            case packedByteArray = "PackedByteArray"
            case packedColorArray = "PackedColorArray"
            case packedFloat32Array = "PackedFloat32Array"
            case packedFloat64Array = "PackedFloat64Array"
            case packedInt32Array = "PackedInt32Array"
            case packedInt64Array = "PackedInt64Array"
            case packedStringArray = "PackedStringArray"
            case packedVector2Array = "PackedVector2Array"
            case packedVector3Array = "PackedVector3Array"
            case characterBody2D = "CharacterBody2D"
            case characterBody3D = "CharacterBody3D"
            case refCounted = "RefCounted"

            var validMethods: [Method] {
                switch self {
                case .object:
                    return [.emitSignal]
                case .gArray:
                    return [.append]
                case .packedByteArray, .packedColorArray, .packedFloat32Array, .packedFloat64Array, .packedInt32Array, .packedInt64Array, .packedStringArray, .packedVector2Array, .packedVector3Array:
                    return [.append, .pushBack]
                case .characterBody2D, .characterBody3D:
                    return [.moveAndSlide]
                case .refCounted:
                    return [.reference, .unreference]
                }
            }
        }
    }

    enum UtilityMethod {
        enum Method: String {
            case absf, absi, acos, acosh, asbs, asin, asinh, atan, atan2, atanh, ceil, ceilf, ceili, cos, cosh, deg_to_rad, exp, floor, floorf, floori, fmod, fposmod, inverse_lerp, lerp, lerpf, log, posmod, pow, rad_to_deg, round, roundf, roundi, sin, snapped, snappedf, sqrt, tan, tanh
        }

        static func isUtilityMethod(methodName: String) -> Bool {
            return Method(rawValue: methodName) != nil
        }
    }

}
