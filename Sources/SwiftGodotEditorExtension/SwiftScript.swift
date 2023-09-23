//
//  SwiftScript.swift
//  
//
//  Created by Miguel de Icaza on 9/22/23.
//

import Foundation
import SwiftGodot

class SwiftScript: ScriptExtension {
    var source: String
    
    public required init () {
        source = ""
        super.init ()
    }

    required init(nativeHandle: UnsafeRawPointer) {
        source = ""
        fatalError("init(nativeHandle:) has not been implemented")
    }
    
    func pm (_ data: String = "", functionName: String = #function) {
        print ("Script: \(functionName) \(data)")
    }
    
    public override func _isTool() -> Bool {
        //pm()
        return false
    }
    
    public override func _isValid() -> Bool {
        pm()
        return true
    }
    
    public override func _getMembers() -> VariantCollection<StringName> {
        pm ()
        return VariantCollection<StringName>()
    }
    
    public override func _getLanguage() -> ScriptLanguage {
        return SwiftLanguageIntegration.shared
    }
    
    public override func _getConstants() -> Dictionary {
        pm ()
        return Dictionary()
    }
    
    public override func _updateExports() {
        pm ()
    }
    
    public override func _canInstantiate() -> Bool {
        return true
    }
    
    public override func _getDocumentation() -> VariantCollection<Dictionary> {
        pm()
        return VariantCollection<Dictionary>()
    }
    
    public override func _getRpcConfig() -> Variant {
        pm ()
        return "Hello".toVariant()
    }
    
    /// Must return the script that provides the base class for this script.
    public override func _getBaseScript() -> Script? {
        pm ()
        
        return nil
    }
    
    public override func _getGlobalName() -> StringName {
        pm ()
        return "GlobalName"
    }
    
    public override func _getSourceCode() -> String {
        pm ()
        return source
    }
    
    public override func _hasSourceCode() -> Bool {
        pm ()
        return source != ""
    }
    
    public override func _hasMethod(method: StringName) -> Bool {
        pm (method.description)
        return true
    }
    
    public override func _reload(keepState: Bool) -> GodotError {
        pm ("\(keepState)")
        return .ok
    }
    
    public override func _instanceHas(object: Object?) -> Bool {
        pm ()
        return false
    }
    
    public override func _getInstanceBaseType() -> StringName {
        guard let regex = try? Regex ("class [A-Za-z_][A-Za-z0-9_]*\\s*:\\s*([A-Za-z_][A-Za-z0-9_]*)") else {
            pm ("Failed to compile poor man's swift parser regex")
            return ""
        }
        for line in source.split(separator: "\n") {
            let res = line.matches(of: regex)
            if res.count == 0 || res [0].count != 2 {
                continue
            }
            if let base = res [0][1].substring {
                pm ("Returning: \(base)")
                return StringName (String (base))
            }
        }
        pm ("Did not find a base type")
        return ""
    }
    
    public override func _getScriptMethodList() -> VariantCollection<Dictionary> {
        pm ()
        return VariantCollection<Dictionary>()
    }
    
    public override func _getScriptSignalList() -> VariantCollection<Dictionary> {
        pm ()
        return VariantCollection<Dictionary>()
    }
    
    public override func _getScriptPropertyList() -> VariantCollection<Dictionary> {
        pm ()
        return VariantCollection<Dictionary>()
    }
    
    public override func _inheritsScript(script: Script?) -> Bool {
        pm ()
        return false
    }
    
    public override func _isPlaceholderFallbackEnabled() -> Bool {
        pm ()
        return false
    }
    
    public override func _setSourceCode(code: String) {
        pm ()
        source = code
    }
    
    public override func _getMemberLine(member: StringName) -> Int32 {
        pm ()
        return 1
    }
    
    public override func _getMethodInfo(method: StringName) -> Dictionary {
        return Dictionary()
    }
    
    public override func _hasScriptSignal(signal: StringName) -> Bool {
        pm ()
        return false
    }
    
    public override func _editorCanReloadFromFile() -> Bool {
        pm ()
        return false
    }
    
    public override func _getPropertyDefaultValue(property: StringName) -> Variant {
        pm ("For property: \(property.description)")
        return false.toVariant()
    }
    
    public override func _hasPropertyDefaultValue(property: StringName) -> Bool {
        pm (" property is: \(property.description) -> false")
        return false
    }
}

