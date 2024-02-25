//
//  GodotMacro.swift
//
//  Created by Miguel de Icaza on 9/25/23.
//
// TODO:
//   - Make it so that if a class has an init() that we do not generate ours,
//     so users can initialize their defaults.   But how do we deal with the
//     requirement to call classInit?
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

class GodotMacroProcessor {
    var propertyDeclarations: [PropertyDeclarationKey: String] = [:]
    struct PropertyDeclarationKey: Hashable {
        let typeName: String
        let parameterElementTypeName: String?
        let genericParameterNames: [String]
        let parameterName: String
        
        init(typeName: String, parameterElementTypeName: String? = nil, genericParameterNames: [String] = [], parameterName: String) {
            self.typeName = typeName
            self.parameterElementTypeName = parameterElementTypeName
            self.genericParameterNames = genericParameterNames
            self.parameterName = parameterName
        }
    }
    
    let classDecl: ClassDeclSyntax
    let className: String
    
    init (classDecl: ClassDeclSyntax) {
        self.classDecl = classDecl
        className = classDecl.name.text
    }
    
    func lookupPropParam (parameterTypeName: String, parameterElementTypeName: String? = nil, parameterName: String) -> String {
        let key = PropertyDeclarationKey(
            typeName: parameterTypeName,
            parameterElementTypeName: parameterElementTypeName,
            parameterName: parameterName
        )
        if let v = propertyDeclarations [key] {
            return v
        }
        let propType = godotTypeToProp (typeName: parameterTypeName)
        
        let name = "prop_\(propertyDeclarations.count)"
        
        let className: String
        let hintStr: String
        let hint = propType == ".array" ? ".arrayType" : ".none"
        
        if propType == ".array",
           let parameterElementTypeName {
            let godotArrayElementTypeName: String
            
            if let gType = godotVariants[parameterElementTypeName],
               let fromGType = godotArrayElementType(gType: gType) {
                godotArrayElementTypeName = fromGType
            } else {
                godotArrayElementTypeName = parameterElementTypeName
            }
            
            className = "Array[\(godotArrayElementTypeName)]"
            hintStr = godotArrayElementTypeName
        } else if propType == ".object" {
            className = parameterTypeName
            hintStr = ""
        } else {
            className = ""
            hintStr = ""
        }
        
        // TODO: perhaps for these prop infos that are parameters to functions, we should not bother making them unique
        // and instead share all the Ints, all the Floats and so on.
        ctor.append ("\tlet \(name) = PropInfo (propertyType: \(propType), propertyName: \"\(parameterName)\", className: StringName(\"\(className)\"), hint: \(hint), hintStr: \"\(hintStr)\", usage: .default)\n")
        propertyDeclarations [key] = name
        return name
    }

    func lookupPropReturn (parameterTypeName: String, genericParameterTypeNames: [String], parameterName: String) -> String {
        let key = PropertyDeclarationKey(
            typeName: parameterTypeName,
            genericParameterNames: genericParameterTypeNames,
            parameterName: parameterName
        )
        if let v = propertyDeclarations [key] {
            return v
        }
        
        let propType: String
        let className: String
        let hintStr: String
        
        if let gArrayCollectionElementTypeName = genericParameterTypeNames.first {
            let godotArrayElementTypeName: String
            if let gType = godotVariants[gArrayCollectionElementTypeName], let fromGType = godotArrayElementType(gType: gType) {
                godotArrayElementTypeName = fromGType
            } else {
                godotArrayElementTypeName = gArrayCollectionElementTypeName
            }
            
            propType = godotTypeToProp (typeName: "Array")
            className = "Array[\(godotArrayElementTypeName)]"
            hintStr = godotArrayElementTypeName
        } else {
            propType = godotTypeToProp (typeName: parameterTypeName)
            
            if propType == ".object" {
                className = parameterTypeName
            } else {
                className = ""
            }
            hintStr = ""
        }
        
        let name = "prop_\(propertyDeclarations.count)"
        let hint = propType == ".array" ? ".arrayType" : ".none"
        // TODO: perhaps for these prop infos that are parameters to functions, we should not bother making them unique
        // and instead share all the Ints, all the Floats and so on.
        ctor.append ("\tlet \(name) = PropInfo (propertyType: \(propType), propertyName: \"\", className: StringName(\"\(className)\"), hint: \(hint), hintStr: \"\(hintStr)\", usage: .default)\n")
        propertyDeclarations [key] = name
        return name
    }
    
    
    func classInitSignals(_ declSyntax: MacroExpansionDeclSyntax) throws {
        guard declSyntax.macroName.tokenKind == .identifier("signal") else {
            return
        }
        
        guard let firstArg = declSyntax.arguments.first else {
            return
        }
        
        guard let signalName = firstArg.expression.signalName() else {
            return
        }
        
        ctor.append("classInfo.registerSignal(")
        ctor.append("name: \(className).\(signalName.swiftName).name,")
        ctor.append("arguments: \(className).\(signalName.swiftName).arguments")
        ctor.append(")")
    }
    
    func processExportGroup(name: String, prefix: String) {
        ctor.append(
            """
            classInfo.addPropertyGroup(name: "\(name)", prefix: "\(prefix)")\n
            """
        )
    }
    
    func processExportSubgroup(name: String, prefix: String) {
        ctor.append(
            """
            classInfo.addPropertySubgroup(name: "\(name)", prefix: "\(prefix)")\n
            """
        )
    }
    
    // Processes a function
    func processFunction (_ funcDecl: FunctionDeclSyntax) throws {
        guard hasCallableAttribute(funcDecl.attributes) else {
            return
        }
        let funcName = funcDecl.name.text
        var funcArgs = ""
        var retProp: String? = nil
        if let (retType, generics, _) = getIdentifier (funcDecl.signature.returnClause?.type) {
            retProp = lookupPropReturn(
                parameterTypeName: retType,
                genericParameterTypeNames: generics,
                parameterName: ""
            )
        }

        for parameter in funcDecl.signature.parameterClause.parameters {
            guard let ptype = getTypeName(parameter) else {
                throw MacroError.typeName (parameter)
            }
            let pname = getParamName(parameter)
            let propInfo = lookupPropParam(
                parameterTypeName: ptype,
                parameterElementTypeName: parameter.arrayElementTypeName ?? parameter.variantCollectionElementTypeName ?? parameter.objectCollectionElementTypeName,
                parameterName: pname
            )
            if funcArgs == "" {
                funcArgs = "\tlet \(funcName)Args = [\n"
            }
            funcArgs.append ("\t\t\(propInfo),\n")
        }
        if funcArgs != "" {
            funcArgs.append ("\t]\n")
        }
        ctor.append (funcArgs)
        ctor.append ("\tclassInfo.registerMethod(name: StringName(\"\(funcName)\"), flags: .default, returnValue: \(retProp ?? "nil"), arguments: \(funcArgs == "" ? "[]" : "\(funcName)Args"), function: \(className)._mproxy_\(funcName))\n")
    }
    
    func processVariable (_ varDecl: VariableDeclSyntax, prefix: String?) throws {
        guard hasExportAttribute(varDecl.attributes) else {
            return
        }
        guard let last = varDecl.bindings.last else {
            throw GodotMacroError.noVariablesFound
        }
        guard var type = last.typeAnnotation?.type else {
            throw GodotMacroError.noTypeFound(varDecl)
        }
        if let optSyntax = type.as (OptionalTypeSyntax.self) {
            type = optSyntax.wrappedType
        }
        guard varDecl.isArray == false else {
            throw GodotMacroError.requiresGArrayCollection
        }
        guard let typeName = type.as (IdentifierTypeSyntax.self)?.name.text else {
            throw GodotMacroError.unsupportedType(varDecl)
        }
        let exportAttr = varDecl.attributes.first?.as(AttributeSyntax.self)
        let labeledExpressionList = exportAttr?.arguments?.as(LabeledExprListSyntax.self)
        let firstLabeledExpression = labeledExpressionList?.first?.expression.as(MemberAccessExprSyntax.self)?.declName
        let secondLabeledExpression = labeledExpressionList?.dropFirst().first
        
        for singleVar in varDecl.bindings {
            guard let ips = singleVar.pattern.as(IdentifierPatternSyntax.self) else {
                throw GodotMacroError.expectedIdentifier(singleVar)
            }
            let varNameWithPrefix = ips.identifier.text
            let varNameWithoutPrefix = String(varNameWithPrefix.trimmingPrefix(prefix ?? ""))
            let proxySetterName = "_mproxy_set_\(varNameWithPrefix)"
            let proxyGetterName = "_mproxy_get_\(varNameWithPrefix)"
            let setterName = "_mproxy_set_\(varNameWithoutPrefix)"
            let getterName = "_mproxy_get_\(varNameWithoutPrefix)"

            if let accessors = last.accessorBlock {
                if accessors.as (CodeBlockSyntax.self) != nil {
                    throw MacroError.propertyGetSet
                }
                if let block = accessors.as (AccessorBlockSyntax.self) {
                    var hasSet = false
                    var hasGet = false
                    switch block.accessors {
                    case .accessors(let list):
                        for accessor in list {
                            switch accessor.accessorSpecifier.tokenKind {
                            case .keyword(let val):
                                switch val {
                                case .didSet, .willSet:
                                    hasSet = true
                                    hasGet = true
                                case .set:
                                    hasSet = true
                                case .get:
                                    hasGet = true
                                default:
                                    break
                                }
                            default:
                                break
                            }
                        }
                    default:
                        throw MacroError.propertyGetSet
                    }
                    
                    if hasSet == false || hasGet == false {
                        throw MacroError.propertyGetSet
                    }
                }
            }
            let propType = godotTypeToProp (typeName: typeName)
            let pinfo = "_p\(varNameWithPrefix)"
            ctor.append (
    """
    let \(pinfo) = PropInfo (
        propertyType: \(propType),
        propertyName: "\(varNameWithPrefix)",
        className: className,
        hint: .\(firstLabeledExpression?.description ?? "none"),
        hintStr: \(secondLabeledExpression?.description ?? "\"\""),
        usage: .default)
    
    """)
            
            ctor.append("\tclassInfo.registerMethod (name: \"\(getterName)\", flags: .default, returnValue: \(pinfo), arguments: [], function: \(className).\(proxyGetterName))\n")
            ctor.append("\tclassInfo.registerMethod (name: \"\(setterName)\", flags: .default, returnValue: nil, arguments: [\(pinfo)], function: \(className).\(proxySetterName))\n")
            ctor.append("\tclassInfo.registerProperty (\(pinfo), getter: \"\(getterName)\", setter: \"\(setterName)\")\n")
        }
    }
    
    func processGArrayCollectionVariable(_ varDecl: VariableDeclSyntax, prefix: String?) throws {
        guard hasExportAttribute(varDecl.attributes) else {
            return
        }
        guard let last = varDecl.bindings.last else {
            throw GodotMacroError.noVariablesFound
        }
        
        guard let type = last.typeAnnotation?.type else {
            throw GodotMacroError.noTypeFound(varDecl)
        }
        
        guard !type.is (OptionalTypeSyntax.self) else {
            throw GodotMacroError.requiresNonOptionalGArrayCollection
        }
        
        guard let elementTypeName = varDecl.gArrayCollectionElementTypeName else {
            return
        }
        
        for singleVar in varDecl.bindings {
            guard let ips = singleVar.pattern.as(IdentifierPatternSyntax.self) else {
                throw GodotMacroError.expectedIdentifier(singleVar)
            }
            let varNameWithPrefix = ips.identifier.text
            let varNameWithoutPrefix = String(varNameWithPrefix.trimmingPrefix(prefix ?? ""))
            
            let proxySetterName = "_mproxy_set_\(varNameWithPrefix)"
            let proxyGetterName = "_mproxy_get_\(varNameWithPrefix)"
            let setterName = "set_\(varNameWithoutPrefix.camelCaseToSnakeCase())"
            let getterName = "get_\(varNameWithoutPrefix.camelCaseToSnakeCase())"
            
            if let accessors = last.accessorBlock {
                if accessors.as (CodeBlockSyntax.self) != nil {
                    throw MacroError.propertyGetSet
                }
                if let block = accessors.as (AccessorBlockSyntax.self) {
                    var hasSet = false
                    var hasGet = false
                    switch block.accessors {
                    case .accessors(let list):
                        for accessor in list {
                            switch accessor.accessorSpecifier.tokenKind {
                            case .keyword(let val):
                                switch val {
                                case .didSet, .willSet:
                                    hasSet = true
                                    hasGet = true
                                case .set:
                                    hasSet = true
                                case .get:
                                    hasGet = true
                                default:
                                    break
                                }
                            default:
                                break
                            }
                        }
                    default:
                        throw MacroError.propertyGetSet
                    }
                    
                    if hasSet == false || hasGet == false {
                        throw MacroError.propertyGetSet
                    }
                }
            }
            let pinfo = "_p\(varNameWithPrefix)"
            let godotArrayElementTypeName: String
            if let gType = godotVariants[elementTypeName], let fromGType = godotArrayElementType(gType: gType) {
                godotArrayElementTypeName = fromGType
            } else {
                godotArrayElementTypeName = elementTypeName
            }
            
            let godotArrayTypeName = "Array[\(godotArrayElementTypeName)]"
            ctor.append (
    """
    let \(pinfo) = PropInfo (
        propertyType: \(godotTypeToProp(typeName: "Array")),
        propertyName: "\(varNameWithPrefix.camelCaseToSnakeCase())",
        className: StringName("\(godotArrayTypeName)"),
        hint: .arrayType,
        hintStr: "\(godotArrayElementTypeName)",
        usage: .default)\n
    """)
            
            ctor.append("\tclassInfo.registerMethod (name: \"\(getterName)\", flags: .default, returnValue: \(pinfo), arguments: [], function: \(className).\(proxyGetterName))\n")
            ctor.append("\tclassInfo.registerMethod (name: \"\(setterName)\", flags: .default, returnValue: nil, arguments: [\(pinfo)], function: \(className).\(proxySetterName))\n")
            ctor.append("\tclassInfo.registerProperty (\(pinfo), getter: \"\(getterName)\", setter: \"\(setterName)\")\n")
        }
    }
    
    var ctor: String = ""
    var genMethods: [String] = []
    
    func processType () throws -> String {
        ctor =
    """
    private static var _initializeClass: Void = {
        let className = StringName("\(className)")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<\(className)> (name: className)\n
    """
        var previousGroupPrefix: String? = nil
        var previousSubgroupPrefix: String? = nil
        
        for member in classDecl.memberBlock.members.enumerated() {
            let decl = member.element.decl
            
            if let macroExpansion = MacroExpansionDeclSyntax(decl),
               let name = macroExpansion.exportGroupName {
                previousGroupPrefix = macroExpansion.exportGroupPrefix ?? ""
                processExportGroup(name: name, prefix: previousGroupPrefix ?? "")
            } else if let macroExpansion = MacroExpansionDeclSyntax(decl),
                 let name = macroExpansion.exportSubgroupName {
                previousSubgroupPrefix = macroExpansion.exportSubgroupPrefix ?? ""
                processExportSubgroup(name: name, prefix: previousSubgroupPrefix ?? "")
            } else if let funcDecl = FunctionDeclSyntax(decl) {
				try processFunction (funcDecl)
			} else if let varDecl = VariableDeclSyntax(decl) {
				if varDecl.isGArrayCollection {
                    try processGArrayCollectionVariable(varDecl, prefix: previousSubgroupPrefix ?? previousGroupPrefix)
				} else {
					try processVariable(varDecl, prefix: previousSubgroupPrefix ?? previousGroupPrefix)
				}
            } else if let macroDecl = MacroExpansionDeclSyntax(decl) {
                try classInitSignals(macroDecl)
            }
        }
        ctor.append("} ()\n")
        return ctor
    }

}

private func godotArrayElementType(gType: String) -> String? {
    let map: [String: String] = [
        ".bool": "bool",
        ".int": "int",
        ".float": "float",
        ".string": "String",
        ".vector2": "Vector2",
        ".vector2i": "Vector2i",
        ".rect2": "Rect2",
        ".rect2i": "Rect2i",
        ".vector3": "Vector3",
        ".vector3i": "Vector3i",
        ".transform2d": "Transform2D",
        ".vector4": "Vector4",
        ".vector4i": "Vector4i",
        ".plane": "Plane",
        ".quaternion": "Quaternion",
        ".aabb": "AABB",
        ".basis": "Basis",
        ".transform3d": "Transform3D",
        ".projection": "Projection",
        ".color": "Color",
        ".stringName": "StringName",
        ".nodePath": "NodePath",
        ".rid": "RID",
        ".object": "Object",
        ".callable": "Callable",
        ".signal": "Signal",
        ".dictionary": "Dictionary",
        ".array": "Array",
        ".packedByteArray": "PackedByteArray",
        ".packedInt32Array": "PackedInt32Array",
        ".packedInt64Array": "PackedInt64Array",
        ".packedFloat32Array": "PackedFloat32Array",
        ".packedFloat64Array": "PackedFloat64Array",
        ".packedStringArray": "PackedStringArray",
        ".packedVector2Array": "PackedVector2Array",
        ".packedVector3Array": "PackedVector3Array",
        ".packedColorArray": "PackedColorArray",
    ]
    return map[gType]
}

extension String {
    func camelCaseToSnakeCase() -> String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return processCamalCaseRegex(pattern: acronymPattern)?
            .processCamalCaseRegex(pattern: normalPattern)?.lowercased() ?? lowercased()
    }

    fileprivate func processCamalCaseRegex(pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
    }
}

func camelToSnake(_ s: String) -> String {
    s.camelCaseToSnakeCase()
        .replacingOccurrences(of: "2_D", with: "2D").replacingOccurrences(of: "3_D", with: "3D")
        .replacingOccurrences(of: "2_d", with: "2d").replacingOccurrences(of: "3_d", with: "3d")
}

///
/// The Godot macro is applied to a class and it generates the boilerplate
/// `init(nativeHandle:)` and `init()` constructors along with the
/// static class initializer for any exported properties and methods.
///
public struct GodotMacro: MemberMacro {
    
    public static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            let classError = Diagnostic(node: declaration.root, message: GodotMacroError.requiresClass)
            context.diagnose(classError)
            return []
        }
        
        let processor = GodotMacroProcessor(classDecl: classDecl)
        do {
            let classInit = try processor.processType()

            let isFinal = classDecl.modifiers
                .map(\.name.tokenKind)
                .contains(.keyword(.final))

            let accessControlLevel = isFinal ? "public" : "open"

            let classInitProperty = DeclSyntax(
            """
            override \(raw: accessControlLevel) class var classInitializer: Void {
                let _ = super.classInitializer
                return _initializeClass
            }
            """
            )
            
            var decls = [classInitProperty, DeclSyntax(stringLiteral: classInit)]

            // Now look for overrides of Godot functions
            let functions = classDecl.memberBlock.members
                        .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
                        .filter { $0.name.text.starts(with: "_") }
                        .filter { $0.modifiers.contains(where: { $0.name.text == "override" }) == true }
            if functions.count > 0 {
                let stringNames = functions.map { function in
                    let functionName = function.name.text
                    let stringName = "StringName(\"\(camelToSnake (functionName))\")" // TODO: convert to Godot naming convention
                    return stringName
                }
                
                var isTool: Bool = false
                if case let .argumentList (arguments) = node.arguments, let expression = arguments.first?.expression {
                    isTool = expression.description.trimmingCharacters (in: .whitespacesAndNewlines) .hasSuffix(".tool")
                }
                
                var implementedOverridesDecl = "override \(accessControlLevel) class func implementedOverrides () -> [StringName] {\n"
                if !isTool {
                    implementedOverridesDecl += "guard !Engine.isEditorHint () else { return [] }\n"
                }
                implementedOverridesDecl += "return super.implementedOverrides () + [\n"
                for name in stringNames {
                    implementedOverridesDecl.append("\t\(name),\n")
                }
                implementedOverridesDecl.append("]\n}")
                decls.append (DeclSyntax(extendedGraphemeClusterLiteral: implementedOverridesDecl))
            }
            return decls
        } catch {
            let diagnostic: Diagnostic
            if let detail = error as? GodotMacroError {
                diagnostic = Diagnostic(node: declaration.root, message: detail)
            } else {
                diagnostic = Diagnostic(node: declaration.root, message: GodotMacroError.unknownError(error))
            }
            context.diagnose(diagnostic)
            return []
        }
    }
}

@main
struct godotMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GodotMacro.self,
        GodotCallable.self,
        GodotExport.self,
        GodotMacroExportGroup.self,
        InitSwiftExtensionMacro.self,
        NativeHandleDiscardingMacro.self,
        PickerNameProviderMacro.self,
        SceneTreeMacro.self,
        Texture2DLiteralMacro.self,
        SignalMacro.self
    ]
}

private extension MacroExpansionDeclSyntax {
    private var isExportGroup: Bool {
        macroName.text == "exportGroup"
    }
    
    private var isExportSubgroup: Bool {
        macroName.text == "exportSubgroup"
    }
    
    var exportGroupPrefix: String? {
        guard isExportGroup, arguments.count == 2 else { return nil }
        return arguments
            .last?
            .as(LabeledExprSyntax.self)?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content
            .text
    }
    
    var exportGroupName: String? {
        guard isExportGroup, arguments.count >= 1 else { return nil }
        return arguments
            .first?
            .as(LabeledExprSyntax.self)?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content
            .text
    }
    
    var exportSubgroupPrefix: String? {
        guard isExportSubgroup, arguments.count == 2 else { return nil }
        return arguments
            .last?
            .as(LabeledExprSyntax.self)?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content
            .text
    }
    
    var exportSubgroupName: String? {
        guard isExportSubgroup, arguments.count >= 1 else { return nil }
        return arguments
            .first?
            .as(LabeledExprSyntax.self)?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content
            .text
    }
}
