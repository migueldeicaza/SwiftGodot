//
//  EditorExtensionMain.swift
//  
//
//  Created by Miguel de Icaza on 4/7/23.
//

import Foundation
import SwiftGodot


extension PackedStringArray {
    convenience init (_ values: [String]) {
        self.init ()
        for x in values {
            append(value: GString (x))
        }
    }
}

class SwiftScript: RefCounted {
    public required init () {
        super.init ()
    }
}
class SwiftLanguageIntegration: ScriptLanguageExtension {
    func pm (functionName: String = #function) {
        print ("SwiftLanguageIntegration, default: \(functionName)")
    }
    
    open override func _getName ()-> GString {
        return GString ("Swift Language Integration")
    }
    
    open override func _init () {
        print ("SwiftLanguageIntegration called")
        // TODO: could define useful things here
    }
    
    open override func _getType ()-> GString {
        return "SwiftScript"
    }
    
    open override func _getExtension ()-> GString {
        return "swift"
    }
    
    open override func _finish () {
        pm()
    }
    
    open override func _getReservedWords ()-> PackedStringArray {
        return PackedStringArray (["class", "func", "struct", "var"])
    }
    
    open override func _isControlFlowKeyword (keyword: GString)-> Bool {
        switch keyword.description {
        case "if", "break", "continue", "while", "repeat", "throw", "try",
            "return":
            return true
        default:
            return false
        }
    }
    
    open override func _getCommentDelimiters ()-> PackedStringArray {
        return PackedStringArray (["//", "/*"])
    }
    
    open override func _getStringDelimiters ()-> PackedStringArray {
        return PackedStringArray (["\" \"", "@\" \""])
    }
    
    open override func _makeTemplate (template: GString, className: GString, baseClassName: GString)-> Script {
        let s = Script ()
        s.sourceCode = GString ("Here we should put the template for \(template.description)")
        return s
    }
    
    open override func _getBuiltInTemplates (object: StringName)-> GodotCollection<Dictionary> {
        pm()
        return GodotCollection<Dictionary>()
    }
    
    open override func _isUsingTemplates ()-> Bool {
        return true
    }
    
    open override func _validate (script: GString, path: GString, validateFunctions: Bool, validateErrors: Bool, validateWarnings: Bool, validateSafeLines: Bool)-> Dictionary {
        pm ();
        return Dictionary ()
    }
    
    open override func _validatePath (path: GString)-> GString {
        pm()
        return GString ()
    }
    
    open override func _createScript ()-> Object {
        return SwiftScript ()
    }
    
    open override func _hasNamedClasses ()-> Bool {
        pm()
        return false
    }
    
    open override func _supportsBuiltinMode ()-> Bool {
        pm()
        return false
    }
    
    open override func _supportsDocumentation ()-> Bool {
        pm()
        return false
    }
    
    open override func _canInheritFromFile ()-> Bool {
        pm()
        return false
    }
    
    open override func _findFunction (className: GString, functionName: GString)-> Int32 {
        pm()
        return 0
    }
    
    open override func _makeFunction (className: GString, functionName: GString, functionArgs: PackedStringArray)-> GString {
        pm()
        return GString ()
    }
    
    open override func _openInExternalEditor (script: Script, line: Int32, column: Int32)-> GodotError {
        pm()
        return .ok
    }
    
    open override func _overridesExternalEditor ()-> Bool {
        pm()
        return false
    }
    
    open override func _completeCode (code: GString, path: GString, owner: Object)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _lookupCode (code: GString, symbol: GString, path: GString, owner: Object)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _autoIndentCode (code: GString, fromLine: Int32, toLine: Int32)-> GString {
        pm()
        return GString ()
    }
    
    open override func _addGlobalConstant (name: StringName, value: Variant) {
        pm()
    }
    
    open override func _addNamedGlobalConstant (name: StringName, value: Variant) {
        pm()
    }
    
    open override func _removeNamedGlobalConstant (name: StringName) {
        pm()
    }
    
    open override func _threadEnter () {
        pm()
    }
    
    open override func _threadExit () {
        pm()
    }
    
    open override func _debugGetError ()-> GString {
        pm()
        return GString ()
    }
    
    open override func _debugGetStackLevelCount ()-> Int32 {
        pm()
        return 0
    }
    
    open override func _debugGetStackLevelLine (level: Int32)-> Int32 {
        pm()
        return 0
    }
    
    open override func _debugGetStackLevelFunction (level: Int32)-> GString {
        pm()
        return GString ()
    }
    
    open override func _debugGetStackLevelLocals (level: Int32, maxSubitems: Int32, maxDepth: Int32)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _debugGetStackLevelMembers (level: Int32, maxSubitems: Int32, maxDepth: Int32)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _debugGetGlobals (maxSubitems: Int32, maxDepth: Int32)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _debugParseStackLevelExpression (level: Int32, expression: GString, maxSubitems: Int32, maxDepth: Int32)-> GString {
        pm()
        return GString ()
    }
    
    open override func _debugGetCurrentStackInfo ()-> GodotCollection<Dictionary> {
        pm()
        return GodotCollection<Dictionary>()
    }
    
    open override func _reloadAllScripts () {
        pm()
    }
    
    open override func _reloadToolScript (script: Script, softReload: Bool) {
        pm()
    }
    
    open override func _getRecognizedExtensions ()-> PackedStringArray {
        pm()
        return PackedStringArray ()
    }
    
    open override func _getPublicFunctions ()-> GodotCollection<Dictionary> {
        pm()
        return GodotCollection<Dictionary>()
    }
    
    open override func _getPublicConstants ()-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _getPublicAnnotations ()-> GodotCollection<Dictionary> {
        pm()
        return GodotCollection<Dictionary>()
    }
    
    open override func _profilingStart () {
        pm()
    }
    
    open override func _profilingStop () {
        pm()
    }
    
    open override func _frame () {
        pm()
    }
    
    open override func _handlesGlobalClassType (type: GString)-> Bool {
        pm()
        return false
    }
    
    open override func _getGlobalClassName (path: GString)-> Dictionary {
        pm()
        return Dictionary ()
    }
}

func setupScene (level: GDExtension.InitializationLevel) {
    if level == .editor {
        var e: Engine = Engine.shared

        var language = SwiftLanguageIntegration()
        
        e.registerScriptLanguage(language: language)
    }
}
@_cdecl ("swift_godot_editor_exension_main")
public func swift_entry_point(
    interfacePtr: OpaquePointer?,
    libraryPtr: OpaquePointer?,
    extensionPtr: OpaquePointer?) -> UInt8
{
    print ("SwiftGodotEditorExtension: Starting up")
    guard let interfacePtr, let libraryPtr, let extensionPtr else {
        return 0
    }
    initializeSwiftModule(interfacePtr, libraryPtr, extensionPtr, initHook: setupScene, deInitHook: { x in })
    return 1
}
