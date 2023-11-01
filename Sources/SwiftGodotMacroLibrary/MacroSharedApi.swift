//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 9/25/23.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


// Given a TypeSyntax, returns the type and whether it is an optional type or not
func getIdentifier (_ x: TypeSyntax?) -> (String, Bool)? {
    guard var x else { return nil }
    var opt = false
    if let optSyntax = x.as (OptionalTypeSyntax.self) {
        x = optSyntax.wrappedType
        opt = true
    }
    if let txt = x.as (IdentifierTypeSyntax.self)?.name.text {
        return (txt, opt)
    }
    return nil
}

enum GodotMacroError: Error, DiagnosticMessage {
    case requiresClass
    case requiresVar
    case requiresFunction
    case noVariablesFound
    case noTypeFound(VariableDeclSyntax)
    case unsupportedType(VariableDeclSyntax)
    case expectedIdentifier(PatternBindingListSyntax.Element)
    case unknownError(Error)
    
    var severity: DiagnosticSeverity {
        return .error
    }

    var message: String {
        switch self {
        case .requiresClass:
            "@Godot attribute can only be applied to a class"
        case .requiresVar:
            "@Export attribute can only be applied to variables"
        case .requiresFunction:
            "@Callable attribute can only be applied to functions"
        case .noVariablesFound:
            "@Export no variables found"
        case .noTypeFound(let v):
            "@Export no type was found \(v)"
        case .unsupportedType (let v):
            "@Export the type \(v) is not supported"
        case .expectedIdentifier(let e):
            "@Export expected an identifier, instead got \(e)"
        case .unknownError(let e):
            "Unknown nested error processing this directive: \(e)"
        }
    }
    
    var diagnosticID: MessageID {
        MessageID(domain: "SwiftGodotMacros", id: message)
    }
}

enum MacroError: Error {
    case typeName(FunctionParameterSyntax)
    case missingParameterName(FunctionParameterSyntax)
    case noVariablesFound(VariableDeclSyntax)
    case noTypeFound(VariableDeclSyntax)
    case unsupportedType(VariableDeclSyntax)
    case propertyGetSet
    var localizedDescription: String {
        switch self {
        case .typeName (let p):
            return "Could not lookup the typename \(p)"
        case .missingParameterName(let p):
            return "Missing a parameter name \(p)"
        case .noVariablesFound(let v):
            return "No variables were found on \(v)"
        case .noTypeFound(let v):
            return "No type was found \(v)"
        case .unsupportedType(let v):
            return "This type is not supported in the macro binding \(v)"
        case .propertyGetSet:
            return "Properties exported to Godot must be readable and writable"
        }
    }
}

/// Returns true if the declarartion has the '@name' attribute
func hasAttribute (_ name: String, _ attrs: AttributeListSyntax?) -> Bool {
    guard let attrs else { return false }
    let match = attrs.contains {
        guard case let .attribute(attribute) = $0 else {
            return false
        }
        if attribute.attributeName.as (IdentifierTypeSyntax.self)?.name.text == name {
            return true
        }
        return false
    }
    return match
}

/// True if the attribtue list syntax has an attribute name 'Export'
func hasExportAttribute (_ attrs: AttributeListSyntax?) -> Bool {
    hasAttribute ("Export", attrs)
}

/// True if the attribtue list syntax has an attribute name 'Callable'
func hasCallableAttribute (_ attrs: AttributeListSyntax?) -> Bool {
    hasAttribute ("Callable", attrs)
}

/// True if the attribtue list syntax has an attribute name 'signal'
func hasSignalAttribute (_ attrs: AttributeListSyntax?) -> Bool {
    hasAttribute ("signal", attrs)
}

func getTypeName (_ parameter: FunctionParameterSyntax) -> String? {
    guard let typeName = parameter.type.as (IdentifierTypeSyntax.self)?.name.text else {
        return nil
    }
    return typeName
}

var godotVariants = [
    "Int": ".int",
    "Float": ".float",
    "Double": ".float",
    "Bool": ".bool",
    "AABB": ".aabb",
    "Array": ".array",
    "Basis": ".basis",
    "Callable": ".callable",
    "Color": ".color",
    "GDictionary": ".dictionary",
    "Nil": ".nil",
    "NodePath": ".nodePath",
    "PackedByteArray": ".packedByteArray",
    "PackedColorArray": ".packedColorArray",
    "PackedFloat32Array": ".packedFloat32Array",
    "PackedFloat64Array": ".packedFloat64Array",
    "PackedInt32Array": ".packedInt32Array",
    "PackedInt64Array": ".packedInt64Array",
    "PackedStringArray": ".packedStringArray",
    "PackedVector2Array": ".packedVector2Array",
    "PackedVector3Array": ".packedVector3Array",
    "Plane": ".plane",
    "Projection": ".projection",
    "Quaternion": ".quaternion",
    "RID": ".rid",
    "Rect2": ".rect2",
    "Rect2i": ".rect2i",
    "Signal": ".signal",
    "String": ".string",
    "StringName": ".stringName",
    "Transform2D": ".transform2d",
    "Transform3D": ".transform3d",
    "Vector2": ".vector2",
    "Vector2i": ".vector2i",
    "Vector3": ".vector3",
    "Vector3i": ".vector3i",
    "Vector4": ".vector4",
    "Vector4i": ".vector4i",
]

func godotTypeToProp (typeName: String) -> String {
    godotVariants [typeName] ?? ".object"
}

struct SignalName {
    let godotName: String
    let swiftName: String
}

extension ExprSyntax {
    
    func signalName() -> SignalName? {
        // Extract the signalName parameter if it's wrapped in quotes, eg: "name"
        if let stringLiteralExpr = StringLiteralExprSyntax(self),
           let segmentSyntax = StringSegmentSyntax(stringLiteralExpr.segments.first),
           case let .stringSegment(signalName) = segmentSyntax.content.tokenKind {
            return SignalName(
                godotName: signalName,
                swiftName: signalName.snakeToCamelcase()
            )
        }
        
        return nil
    }
    
    /// Extracts a type name
    func typeName() -> String? {
        if let memberAccessSyntax = MemberAccessExprSyntax(self),
           let base = memberAccessSyntax.base,
           let decl = DeclReferenceExprSyntax(base),
           case let .identifier(name) = decl.baseName.tokenKind {
            return name
        }
        
        return nil
    }
}


private extension String {
    func swiftName() -> String {
        if self == uppercased() {
            lowercased()
        } else {
            lowercaseFirstLetter()
        }
    }

    func snakeToCamelcase() -> String {
        let parts = split(separator: "_")

        guard let firstItem = parts.first else {
            return ""
        }

        return String(firstItem).swiftName() +
            parts.dropFirst().map { String($0).uppercaseFirstLetter() }.joined()
    }

    private func lowercaseFirstLetter() -> String {
        if let firstLetter = first {
            firstLetter.lowercased() + dropFirst()
        } else {
            self
        }
    }

    private func uppercaseFirstLetter() -> String {
        if let firstLetter = first {
            firstLetter.uppercased() + dropFirst()
        } else {
            self
        }
    }
}
