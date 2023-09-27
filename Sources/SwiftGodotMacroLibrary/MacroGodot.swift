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
        ctor.append ("\tlet \(name) = PropInfo (propertyType: \(propType), propertyName: \"\(parameterName)\(parameterTypeName)\", className: className, hint: .none, hintStr: \"\", usage: .propertyUsageDefault)\n")
        propertyDeclarations [key] = name
        return name
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
        ctor.append ("\tclassInfo.registerMethod(name: \"funcName\", flags: .default, returnValue: \(retProp ?? "nil"), arguments: \(funcArgs == "" ? "[]" : "\(funcName)Args"), function: \(className)._mproxy_\(funcName))")
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
        usage: .propertyUsageDefault)
    
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
    static func _initClass () {
        let className = StringName("\(className)")
        let _ = ClassInfo<\(className)> (name: className)\n
    """
        for member in classDecl.memberBlock.members.enumerated() {
            let decl = member.element.decl
            if let funcDecl = decl.as(FunctionDeclSyntax.self) {
                try processFunction (funcDecl)
            }
            else if let varDecl = decl.as (VariableDeclSyntax.self) {
                try processVariable (varDecl)
            }
        }
        ctor.append("}")
        return ctor
    }

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
            let initRawHandleSyntax = try InitializerDeclSyntax("required init(nativeHandle _: UnsafeRawPointer)") {
                StmtSyntax("\n\tfatalError(\"init(nativeHandle:) called, it is a sign that something is wrong, as these objects should not be re-hydrated\")")
            }
            let initSyntax = try InitializerDeclSyntax("required init()") {
                StmtSyntax("\n\t\(classDecl.name)._initClass ()\n\tsuper.init ()")
            }
            
            return [DeclSyntax (initRawHandleSyntax), DeclSyntax (initSyntax), DeclSyntax(stringLiteral: classInit)]
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
        Texture2DLiteralMacro.self
    ]
}
