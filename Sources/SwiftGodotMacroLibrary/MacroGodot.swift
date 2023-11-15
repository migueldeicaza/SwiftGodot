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
    let classDecl: ClassDeclSyntax
    let className: String
    
    init (classDecl: ClassDeclSyntax) {
        self.classDecl = classDecl
        className = classDecl.name.text
    }
    
    var propertyDeclarations: [String: String] = [:]
    func lookupProp (parameterTypeName: String, parameterName: String) -> String {
        let key = "\(parameterTypeName)/\(parameterName)"
        if let v = propertyDeclarations [key] {
            return v
        }
        let propType = godotTypeToProp (typeName: parameterTypeName)
        
        let name = "prop_\(propertyDeclarations.count)"
        
        // TODO: perhaps for these prop infos that are parameters to functions, we should not bother making them unique
        // and instead share all the Ints, all the Floats and so on.
        ctor.append ("\tlet \(name) = PropInfo (propertyType: \(propType), propertyName: \"\(parameterName)\(parameterTypeName)\", className: className, hint: .none, hintStr: \"\", usage: .default)\n")
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
    
    // Processes a function
    func processFunction (_ funcDecl: FunctionDeclSyntax) throws {
        guard hasCallableAttribute(funcDecl.attributes) else {
            return
        }
        let funcName = funcDecl.name.text
        var funcArgs = ""
        var retProp: String? = nil
        if let (retType, _) = getIdentifier (funcDecl.signature.returnClause?.type) {
            retProp = lookupProp(parameterTypeName: retType, parameterName: "")
        }

        for parameter in funcDecl.signature.parameterClause.parameters {
            guard let ptype = getTypeName(parameter) else {
                throw MacroError.typeName (parameter)
            }
            let propInfo = lookupProp (parameterTypeName: ptype, parameterName: "")
            if funcArgs == "" {
                funcArgs = "\tlet \(funcName)Args = [\n"
            }
            funcArgs.append ("\t\t\(propInfo),\n")
        }
        if funcArgs != "" {
            funcArgs.append ("\t]\n")
        }
        ctor.append (funcArgs)
        ctor.append ("\tclassInfo.registerMethod(name: StringName(\"\(funcName)\"), flags: .default, returnValue: \(retProp ?? "nil"), arguments: \(funcArgs == "" ? "[]" : "\(funcName)Args"), function: \(className)._mproxy_\(funcName))")
    }
    
    func processVariable (_ varDecl: VariableDeclSyntax) throws {
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
        guard let typeName = type.as (IdentifierTypeSyntax.self)?.name.text else {
            throw GodotMacroError.unsupportedType(varDecl)
        }
        let exportAttr = varDecl.attributes.first?.as(AttributeSyntax.self)
        let lel = exportAttr?.arguments?.as(LabeledExprListSyntax.self)
        let f = lel?.first?.expression.as(MemberAccessExprSyntax.self)?.declName
        
        let s = lel?.dropFirst().first
        
        for singleVar in varDecl.bindings {
            guard let ips = singleVar.pattern.as(IdentifierPatternSyntax.self) else {
                throw GodotMacroError.expectedIdentifier(singleVar)
            }
            let varName = ips.identifier.text
            let setterName = "_mproxy_set_\(varName)"
            let getterName = "_mproxy_get_\(varName)"

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
            let pinfo = "_p\(varName)"
            ctor.append (
    """
    let \(pinfo) = PropInfo (
        propertyType: \(propType),
        propertyName: "\(varName)",
        className: className,
        hint: .\(f?.description ?? "none"),
        hintStr: \(s?.description ?? "\"\""),
        usage: .default)
    
    """)
            
            ctor.append("\tclassInfo.registerMethod (name: \"\(getterName)\", flags: .default, returnValue: \(pinfo), arguments: [], function: \(className).\(getterName))\n")
            ctor.append("\tclassInfo.registerMethod (name: \"\(setterName)\", flags: .default, returnValue: nil, arguments: [\(pinfo)], function: \(className).\(setterName))\n")
            ctor.append("\tclassInfo.registerProperty (\(pinfo), getter: \"\(getterName)\", setter: \"\(setterName)\")")
        }
    }
    
    var ctor: String = ""
    var genMethods: [String] = []
    
    func processType () throws -> String {
        ctor =
    """
    private static var _initializeClass: Void = {
        let className = StringName("\(className)")
        let classInfo = ClassInfo<\(className)> (name: className)\n
    """
        for member in classDecl.memberBlock.members.enumerated() {
            let decl = member.element.decl
            // MacroExpansionDeclSyntax
            if let funcDecl = FunctionDeclSyntax(decl) {
                try processFunction (funcDecl)
            } else if let varDecl = VariableDeclSyntax(decl) {
                try processVariable (varDecl)
            } else if let macroDecl = MacroExpansionDeclSyntax(decl) {
                try classInitSignals(macroDecl)
            }
        }
        ctor.append("} ()")
        return ctor
    }

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
            let classInit = try processor.processType ()
            
            let classInitProperty = DeclSyntax(
            """
            override open class var classInitializer: Void {
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
                
                var implementedOverridesDecl = "override open class func implementedOverrides() -> [StringName] {\nsuper.implementedOverrides() + [\n"
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
        InitSwiftExtensionMacro.self,
        NativeHandleDiscardingMacro.self,
        PickerNameProviderMacro.self,
        SceneTreeMacro.self,
        Texture2DLiteralMacro.self,
        SignalMacro.self
    ]
}
