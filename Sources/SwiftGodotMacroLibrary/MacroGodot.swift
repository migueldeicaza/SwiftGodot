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
    var existingMembers: [String: DeclSyntax] = [:]
    
    let classDecl: ClassDeclSyntax
    let className: String
    
    init(classDecl: ClassDeclSyntax) {
        self.classDecl = classDecl
        className = classDecl.name.text
    }
    
    func checkNameCollision(_ name: String, for decl: DeclSyntax) throws {
        if existingMembers.updateValue(decl, forKey: name) != nil {
            throw GodotMacroError.nameCollision(name)
        }
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
        
        injectClassInfo()
                
        ctor.append("classInfo.registerSignal(")
        ctor.append("name: \(className).\(signalName.swiftName).name,")
        ctor.append("arguments: \(className).\(signalName.swiftName).arguments")
        ctor.append(")")
    }
    
    func processExportGroup(name: String, prefix: String) {
        injectClassInfo()
        ctor.append(
            """
            SwiftGodot._addPropertyGroup(className: className, name: "\(name)", prefix: "\(prefix)")\n
            """
        )
    }
    
    func processExportSubgroup(name: String, prefix: String) {
        injectClassInfo()
        ctor.append(
            """
            SwiftGodot._addPropertySubgroup(className: className, name: "\(name)", prefix: "\(prefix)")\n
            """
        )
    }
        
    func processFunction(_ funcDecl: FunctionDeclSyntax) throws {
        if !funcDecl.hasCallableAttribute {
            return
        }
        
        if funcDecl.hasClassOrStaticModifier {
            throw GodotMacroError.unsupportedStaticMember
        }
        
        let funcName = funcDecl.name.text
        
        let arguments = funcDecl
            .parameters
            .map { parameter in
                let typename = parameter.type.description.trimmingCharacters(in: .whitespacesAndNewlines)                
                return "SwiftGodot._argumentPropInfo(\(typename).self, name: \"\(parameter.internalName)\")"
            }
            .map {
                "        \($0)"
            }
            .joined(separator: ",\n")
                
        let returnTypename: String
        if let type = funcDecl.signature.returnClause?.type {
            returnTypename = type.description.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            returnTypename = "Swift.Void"
        }
                
        
        let flags: String
        if funcDecl.hasClassOrStaticModifier {
            flags = ".static"
        } else {
            flags = ".default"
        }
        
        injectClassInfo()
        ctor.append("""
            SwiftGodot._registerMethod(
                className: className,
                name: "\(funcName)", 
                flags: \(flags), 
                returnValue: SwiftGodot._returnValuePropInfo(\(returnTypename).self), 
                arguments: [
            \(arguments)
                ], 
                function: \(className)._mproxy_\(funcName)
            )
            """)
        
        try checkNameCollision(funcName, for: DeclSyntax(funcDecl))
    }
      

    func processVariable(_ varDecl: VariableDeclSyntax, previousGroupPrefix: String?, previousSubgroupPrefix: String?) throws {
        if varDecl.hasExportAttribute {
            try processExportVariable(varDecl, prefix: previousSubgroupPrefix ?? previousGroupPrefix)
        } else if varDecl.hasSignalAttribute {
            try processSignalVariable(varDecl, prefix: previousSubgroupPrefix ?? previousGroupPrefix)
        }
    }

    
    // Returns true if it used "tryCase"
    func processExportVariable (_ varDecl: VariableDeclSyntax, prefix: String?) throws {
        assert(varDecl.hasExportAttribute)
        
        if varDecl.hasClassOrStaticModifier {
            throw GodotMacroError.unsupportedStaticMember
        }
        
        guard let exportAttribute = varDecl.attributes.attribute(named: "Export") else {
            fatalError("`processExportVariable` called for variable without `Export` attribute")
        }
                        
        // We cornered ourselves by not having named parameters for the first two arguments
        let labeledExpressionList = exportAttribute.arguments?.as(LabeledExprListSyntax.self)

        // If the first one is an MemberAccessExprSyntax, it is not a labeled expression, so in that case, we have a
        // hint, and in that case, the second can be a hint
        let hintExpr = labeledExpressionList?.first?.expression.as(MemberAccessExprSyntax.self)?.declName
        let hintStrExpr = hintExpr == nil ? nil : labeledExpressionList?.dropFirst().first
        
        let usageExpr = labeledExpressionList?.first { labelExpr in
            labelExpr.description == "usage"
        }

        for binding in varDecl.bindings {
            guard let ips = binding.pattern.as(IdentifierPatternSyntax.self) else {
                throw GodotMacroError.noIdentifier(binding)
            }
            
            let varNameWithPrefix = ips.identifier.text
            let varNameWithoutPrefix = String(varNameWithPrefix.trimmingPrefix(prefix ?? ""))
            let proxySetterName = "_mproxy_set_\(varNameWithPrefix)"
            let proxyGetterName = "_mproxy_get_\(varNameWithPrefix)"
            let setterName = "set_\(varNameWithoutPrefix.camelCaseToSnakeCase())"
            let getterName = "get_\(varNameWithoutPrefix.camelCaseToSnakeCase())"
            
            if !binding.isSettableBinding {
                throw GodotMacroError.exportMacroOnReadonlyVariable(varNameWithPrefix)
            }
            
            var args: [String] = [
                "at: \\\(className).\(varNameWithPrefix)",
                "name: \"\(varNameWithPrefix.camelCaseToSnakeCase())\""
            ]
            
            if let hint = hintExpr?.description {
                args.append("userHint: .\(hint)")
            } else {
                args.append("userHint: nil")
            }
            
            if let hintStr = hintStrExpr?.description {
                args.append("userHintStr: \(hintStr)")
            } else {
                args.append("userHintStr: nil")
            }
            
            if let usage = usageExpr?.expression.description {
                args.append("userUsage: \(usage)")
            } else {
                args.append("userUsage: nil")
            }
            
            let argsStr = args
                .map { String(repeating: " ", count: 8) + $0 }
                .joined(separator: ",\n")
            
            
            injectClassInfo()
            ctor.append("""
            SwiftGodot._registerPropertyWithGetterSetter(
                className: className,
                info: SwiftGodot._propInfo(
            \(argsStr)
                ),
                getterName: "\(getterName)\",
                setterName: "\(setterName)",                
                getterFunction: \(className).\(proxyGetterName),
                setterFunction: \(className).\(proxySetterName)                
            )
            """)
            
            try checkNameCollision(getterName, for: DeclSyntax(varDecl))
            try checkNameCollision(setterName, for: DeclSyntax(varDecl))
        }
    }
        
    func processSignalVariable(_ varDecl: VariableDeclSyntax, prefix: String?) throws {
        if varDecl.hasClassOrStaticModifier {
            throw GodotMacroError.unsupportedStaticMember
        }

        for binding in varDecl.bindings {
            guard let ips = binding.pattern.as(IdentifierPatternSyntax.self) else {
                throw GodotMacroError.noIdentifier(binding)
            }
            
            let nameWithPrefix = ips.identifier.text
            let name = String(nameWithPrefix.trimmingPrefix(prefix ?? ""))
            
            guard let typeAnnotation = binding.typeAnnotation else {
                throw GodotMacroError.noSignalType(nameWithPrefix)
            }
            
            let typeName = typeAnnotation.type.description.trimmingCharacters(in: .whitespacesAndNewlines)

            injectClassInfo()
            let godotName = name.camelCaseToSnakeCase()
            ctor.append("\(typeName).register(as: \"\(godotName)\", in: className)")
            try checkNameCollision(godotName, for: DeclSyntax(varDecl))
        }
    }

    
    var ctor: String = ""
    var genMethods: [String] = []
    var injected = false

    func injectClassInfo() {
        if injected { return }
        injected = true
        ctor += """
            let classInfo = ClassInfo<\(className)>(name: className)\n
        """
    }

    func processType () throws -> String {
        ctor = """
        private static let _initializeClass: Void = {
            let className = StringName("\(className)")
            assert(ClassDB.classExists(class: className))\n
        """
        var previousGroupPrefix: String? = nil
        var previousSubgroupPrefix: String? = nil
        for member in classDecl.memberBlock.members.enumerated() {
            let decl = member.element.decl
            let macroExpansion = MacroExpansionDeclSyntax(decl)
            
            if let name = macroExpansion?.exportGroupName {
                previousGroupPrefix = macroExpansion?.exportGroupPrefix ?? ""
                processExportGroup(name: name, prefix: previousGroupPrefix ?? "")
            } else if let name = macroExpansion?.exportSubgroupName {
                previousSubgroupPrefix = macroExpansion?.exportSubgroupPrefix ?? ""
                processExportSubgroup(name: name, prefix: previousSubgroupPrefix ?? "")
            } else if let funcDecl = FunctionDeclSyntax(decl) {
                try processFunction (funcDecl)
            } else if let varDecl = VariableDeclSyntax(decl) {
                try processVariable(
                    varDecl,
                    previousGroupPrefix: previousGroupPrefix,
                    previousSubgroupPrefix: previousSubgroupPrefix
                )
            } else if let macroExpansion {
                try classInitSignals(macroExpansion)
            }
        }

        ctor.append("} ()\n")
        return ctor
    }

}

extension String {
    func camelCaseToSnakeCase() -> String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return processCamelCaseRegex(pattern: acronymPattern)?
            .processCamelCaseRegex(pattern: normalPattern)?.lowercased() ?? lowercased()
    }

    fileprivate func processCamelCaseRegex(pattern: String) -> String? {
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
            let classError = Diagnostic(node: declaration.root, message: GodotMacroError.godotMacroNotOnClass)
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
                    implementedOverridesDecl.append("    \(name),\n")
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
struct SwiftGodotCompilerPlugin: CompilerPlugin {
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
        SignalMacro.self,
        SignalAttachmentMacro.self,
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
        guard isExportGroup, arguments.count == 2, let argument = arguments.last else { return nil }
        return LabeledExprSyntax (argument)?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content
            .text
    }
    
    var exportGroupName: String? {
        guard isExportGroup, arguments.count >= 1, let argument = arguments.first else { return nil }
        return LabeledExprSyntax (argument)?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content
            .text
    }
    
    var exportSubgroupPrefix: String? {
        guard isExportSubgroup, arguments.count == 2, let argument = arguments.last else { return nil }
        return LabeledExprSyntax (argument)?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content
            .text
    }
    
    var exportSubgroupName: String? {
        guard isExportSubgroup, arguments.count >= 1, let argument = arguments.first else { return nil }
        return LabeledExprSyntax (argument)?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content
            .text
    }
}
