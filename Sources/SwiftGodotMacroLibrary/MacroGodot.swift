//
//  GodotMacro.swift
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
        ctor.append ("\tlet \(name) = PropInfo (propertyType: \(propType), propertyName: \"\(parameterName)_\(parameterTypeName)\", className: className, hint: .none, hintStr: \"\", usage: .propertyUsageDefault)\n")
        propertyDeclarations [key] = name
        return name
    }

    func process (funcDecl: FunctionDeclSyntax) throws {
        guard hasCallableAttribute(funcDecl.attributes) else {
            return
        }
        var funcName = funcDecl.name.text
        var funcArgs = ""
        var retProp: String? = nil
        if let (retType, _) = getIdentifier (funcDecl.signature.returnClause?.type) {
            retProp = lookupProp(parameterTypeName: retType, parameterName: "")
        }

        for parameter in funcDecl.signature.parameterClause.parameters {
            guard let ptype = getTypeName(parameter) else {
                throw MacroError.typeName (parameter)
            }
            let first = parameter.firstName.text
            let propInfo = lookupProp (parameterTypeName: ptype, parameterName: first)
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
    
    var ctor: String = ""
    var genMethods: [String] = []
    
    func processType () throws -> String {
        ctor =
    """
    static func _initClass () {
        let className = StringName("\(className)")
        let classInfo = ClassInfo<\(className)> (name: className)\n
    """
        for member in classDecl.members.members.enumerated() {
            let decl = member.element.decl
            if let funcDecl = decl.as(FunctionDeclSyntax.self) {
                let s = try process (funcDecl: funcDecl)
            } 
//            else if let varDecl = decl.as (VariableDeclSyntax.self) {
//                try process (varDecl: varDecl)
//            }
        }
        ctor.append("}")
        return ctor
    }

}

enum GodotMacroDiagnostic: String, DiagnosticMessage {
    case requiresClass
    case requiresFunction
    
    var severity: DiagnosticSeverity {
        switch self {
        case .requiresClass: .error
        case .requiresFunction: .error
        }
    }

    var message: String {
        switch self {
        case .requiresClass:
            "@Godot attribute can only be applied to a class"
        case .requiresFunction:
            "@Callable attribute can only be applied to functions"
        }
    }
    
    var diagnosticID: MessageID {
        MessageID(domain: "SwiftGodotMacros", id: rawValue)
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
            let classError = Diagnostic(node: declaration.root, message: GodotMacroDiagnostic.requiresClass)
            context.diagnose(classError)
            return []
        }
        
        let processor = GodotMacroProcessor(classDecl: classDecl)
        let classInit = try processor.processType ()
        
        let initRawHandleSyntax = try InitializerDeclSyntax("required init(nativeHandle _: UnsafeRawPointer)") {
            StmtSyntax("fatalError(\"init(nativeHandle:) has not been implemented\")")
        }
        let initSyntax = try InitializerDeclSyntax("required init()") {
            StmtSyntax("\(classDecl.name)._initClass ()\nsuper.init ()")
        }
        
        return [DeclSyntax (initRawHandleSyntax), DeclSyntax (initSyntax), DeclSyntax(stringLiteral: classInit)]

    }
}

@main
struct godotMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GodotMacro.self,
        GodotCallable.self,
        GodotExport.self
    ]
}

#if notyet

func makeGetAccessor (varName: String, isOptional: Bool) -> String {
    let name = "_pProxy_get\(varName)"
    if isOptional {
        genMethods.append (
"""
func \(name) (args: [Variant]) -> Variant? {
    guard let result = \(varName) else { return nil }
    return Variant (result)
}
""")
    } else {
        genMethods.append (
"""
func \(name) (args: [Variant]) -> Variant? {
    return Variant (\(varName))
}
""")
    }
    return name
}
func makeSetAccessor (varName: String, typeName: String, isOptional: Bool) -> String {
    let name = "_pProxy_set_\(varName)"
    if isOptional {
        genMethods.append (
"""
func \(name) (args: [Variant]) -> Variant? {
    if let v = args [0] {
        \(varName) = \(typeName)(v)
    } else {
        \(varName) = nil
    }
    return nil
}
""")
    } else {
        genMethods.append (
"""
func \(name) (args: [Variant]) -> Variant? {
    \(varName) = \(typeName)(args [0]!)
    return nil
}
""")
    }
    return name
}

func process (varDecl: VariableDeclSyntax) throws {
    guard hasExportAttribute(varDecl.attributes) else {
        return
    }
    var variableNames: [String] = []
    let last: PatternBindingListSyntax.Element?
    guard let last = varDecl.bindings.last else {
        throw MacroError.noVariablesFound (varDecl)
    }
    guard var type = last.typeAnnotation?.type else {
        throw MacroError.noTypeFound (varDecl)
    }
    var isOptional: Bool = false
    if let optSyntax = type.as (OptionalTypeSyntax.self) {
        type = optSyntax.wrappedType
        isOptional = true
    }
    guard let typeName = type.as (IdentifierTypeSyntax.self)?.name.text else {
        throw MacroError.unsupportedType(varDecl)
    }
    
    for singleVar in varDecl.bindings {
        guard let ips = singleVar.pattern.as(IdentifierPatternSyntax.self) else {
            fatalError()
        }
        let varName = ips.identifier.text
        variableNames.append (varName)
        var getterName: String = ""
        var setterName: String = ""
        if let accessors = last.accessorBlock {
            if accessors.as (CodeBlockSyntax.self) != nil {
                throw MacroError.propertyGetSet
            } else {
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
                    setterName = makeSetAccessor(varName: varName, typeName: typeName, isOptional: isOptional)
                    getterName = makeGetAccessor(varName: varName, isOptional: isOptional)
                }
            }
        } else {
            getterName = makeGetAccessor(varName: varName, isOptional: isOptional)
            setterName = makeSetAccessor(varName: varName, typeName: typeName, isOptional: isOptional)
        }
        let pinfo = lookupProp(parameterTypeName: typeName, parameterName: varName)
        ctor.append("\tclassInfo.registerMethod (name: \"\(getterName)\", flags: .default, returnValue: \(pinfo), arguments: [], function: \(className).\(getterName))\n")
        ctor.append("\tclassInfo.registerMethod (name: \"\(setterName)\", flags: .default, returnValue: nil, arguments: [\(pinfo)], function: \(className).\(getterName))\n")
        ctor.append("\tclassInfo.registerProperty (pinfo, getter: \"\(getterName)\", setter: \"\(setterName)\")")
    }
}

#endif
